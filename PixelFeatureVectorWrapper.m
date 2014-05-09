function [x,featurenames] = PixelFeatureVectorWrapper(imname,posdata,params,varargin)

[doleftright,doupdown,dotranspose,isluv,fromfile,datafiles,gtdoflip,leftovers] = myparse_nocheck(varargin,...
  'doleftright',false,'doupdown',false,'dotranspose',false,'isluv',false,'fromfile',false,...
  'datafiles',[],'gtdoflip',false);

if fromfile,
  toload = {'hogdata','hogdata_fliplr','hogdata_flipud','hogdata_flipudlr'};
  [~,x0,xud0,xlr0,xudlr0] = LoadHOGData(datafiles,toload);
  % flip if necessary
  if gtdoflip,
    x = xud0;
    xud = x0;
    xlr = xudlr0;
    xudlr = xlr0;
  else
    x = x0;
    xud = xud0;
    xlr = xlr0;
    xudlr = xudlr0;
  end
  if nargout >= 2,
    featurenames = cellstr(num2str((1:numel(x))'));
  end
  if doleftright,
    x(:,end+1) = xlr;
  end
  if doupdown,
    x(:,end+1) = xud;
  end
  if dotranspose,
    x(:,end+1) = xudlr;
  end
else
  
  
  if ischar(imname),
    imluv = rgbConvert(imread(imname),'luv');
  else
    if isluv,
      imluv = imname;
    else
      imluv = rgbConvert(imname,'luv');
    end
  end
  
  [nrcurr,nccurr,~] = size(imluv);
  theta = posdata.theta+pi/2;
  mu = [posdata.x,posdata.y];
  R = [cos(theta),-sin(theta),0
    sin(theta),cos(theta),0
    0,0,1];
  tform = maketform('affine',R);
  
  imluv_rot = imtransform(imluv,tform,...
    'UData',[1-mu(1),nccurr-mu(1)],...
    'VData',[1-mu(2),nrcurr-mu(2)],...
    'XData',(posdata.b+params.padborder)*[-1,1],...
    'YData',(posdata.a+params.padborder)*[-1,1],...
    'FillValues',255);
  
  if nargout >= 2,
    [x,featurenames] = PixelFeatureVector(imluv_rot,leftovers{:},'isluv',true);
  else
    x = PixelFeatureVector(imluv_rot,leftovers{:},'isluv',true);
  end
  
  if doleftright,
    x(:,end+1) = PixelFeatureVector(imluv_rot(:,end:-1:1,:),leftovers{:},'isluv',true);
  end
  if doupdown,
    x(:,end+1) = PixelFeatureVector(imluv_rot(end:-1:1,:,:),leftovers{:},'isluv',true);
  end
  if dotranspose,
    x(:,end+1) = PixelFeatureVector(imluv_rot(end:-1:1,end:-1:1,:),leftovers{:},'isluv',true);
  end
  
end