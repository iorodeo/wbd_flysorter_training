function [classifier,X,y,featurenames,ens,labelfit,yfit] = TrainOrientationClassifier(gtposdata,imfiles,fitparams,X0,y0,datafiles)

fromfile = exist('datafiles','var') && ~isempty(datafiles);

if fromfile,
  idxgood = find(~isnan(gtposdata));
  %idxgood = 1:numel(gtposdata);
else
  idxgood = find([gtposdata.isfly]&~[gtposdata.ismultipleflies]&...
    (~isfield(gtposdata,'badim') || cellfun(@(x) ~isempty(x) && x,{gtposdata.badim})));
end
ntrain = numel(idxgood);

X = [];
y = nan(ntrain*4,1);


fprintf('Creating training data...\n');
for ii = 1:numel(idxgood),
  
  i = idxgood(ii);
  
  if mod(ii,100) == 0,
    fprintf('Example %d / %d\n',ii,numel(idxgood));
  end
  
  posdata = gtposdata(i);

  if fromfile,
    [~,x0,xud0,xlr0,xudlr0] = LoadHOGData(datafiles(i),{'hogdata','hogdata_flipud','hogdata_fliplr','hogdata_flipudlr'});
    if posdata,
      x = xud0'; xud = x0'; xlr = xudlr0'; xudlr = xlr0';
    else
      x = x0'; xud = xud0'; xlr = xlr0'; xudlr = xudlr0';
    end
    if ii == 1,
      X = nan(ntrain*4,numel(x));
      featurenames = cellstr(num2str((1:numel(x))'));
    end
    X(4*(ii-1)+1:4*ii,:) = [x;xlr;xud;xudlr];

  else

    imname = imfiles{i};
    imraw = imread(imname);
    imluv = rgbConvert(imraw,'luv');
    
    
    [nrcurr,nccurr,~] = size(imraw);
    theta = posdata.theta+pi/2;
    mu = [posdata.x,posdata.y];
    R = [cos(theta),-sin(theta),0
      sin(theta),cos(theta),0
      0,0,1];
    tform = maketform('affine',R);
    
    imluv_rot = imtransform(imluv,tform,...
      'UData',[1-mu(1),nccurr-mu(1)],...
      'VData',[1-mu(2),nrcurr-mu(2)],...
      'XData',(posdata.b+fitparams.classifyparams.padborder)*[-1,1],...
      'YData',(posdata.a+fitparams.classifyparams.padborder)*[-1,1],...
      'FillValues',255);
    
    if ii == 1,
      [x,featurenames] = PixelFeatureVector(imluv_rot,'isluv',true);
      X = nan(ntrain*4,numel(x));
    else
      x = PixelFeatureVector(imluv_rot,'isluv',true);
    end
    X(4*(ii-1)+1,:) = x;
    x = PixelFeatureVector(imluv_rot(:,end:-1:1,:),'isluv',true);
    X(4*(ii-1)+2,:) = x;
    x = PixelFeatureVector(imluv_rot(end:-1:1,:,:),'isluv',true);
    X(4*(ii-1)+3,:) = x;
    x = PixelFeatureVector(imluv_rot(end:-1:1,end:-1:1,:),'isluv',true);
    X(4*(ii-1)+4,:) = x;
  end
  y(4*(ii-1)+[1,2]) = 1;
  y(4*(ii-1)+[3,4]) = -1;
  
end

% train classifier

if nargin >= 5 && ~isempty(X0),
  X = [X0;X];
  y = [y0;y];
end

fprintf('Training classifier from %d examples.\n',numel(y));
[classifier,ens,labelfit,yfit] = myFitEnsemble(X,y,featurenames,fitparams.classifyparams.nlearn);
  