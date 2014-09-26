function [params,X,y,imis,fraccorrect] = TrainUserClassifier(gtposdata,imfiles,label,params,allowedLabels,varargin)

[fromfile,datafiles] = myparse(varargin,'fromfile',false,'datafiles',[]);

%% create training data

idxgood = find([gtposdata.isfly] & ~[gtposdata.ismultipleflies] & ismember(label,[allowedLabels{:}]));

n = numel(idxgood);

X = [];

fprintf('Creating training data...\n');

for ii = 1:n,

  i = idxgood(ii);
  
  if mod(ii,100) == 0,
    fprintf('Example %d / %d\n',ii,n);
  end
  
  posdata = gtposdata(i);
  imname = imfiles{i};

  if fromfile,
    gtdoflip = gtposdata(i).doflip;
    extraparams = {'doleftright',true,'fromfile',fromfile,'datafiles',datafiles(i),'gtdoflip',gtdoflip};
  else
    extraparams = {'doleftright',true,'fromfile',fromfile};
  end

  
  if ii == 1,
    [x,featurenames] = PixelFeatureVectorWrapper(imname,posdata,params,extraparams{:});
    X = nan(2*n,size(x,1));
  else
    [x] = PixelFeatureVectorWrapper(imname,posdata,params,extraparams{:});
  end
  X(2*ii-1:2*ii,:) = x';  
end

y = ones(1,n);
y(sex(idxgood)==allowedLabels{1}) = -1;
y = repmat(y,[2,1]);
y = y(:);

imis = repmat(idxgood(:)',[2,1]);
imis = imis(:);

%% train classifier

fprintf('Training classifier...\n');

%disp(size(X))
%disp(size(y))
%disp(size(featurenames))
%disp(class(featurenames))


[params.classifier,~,~,yfit] = myFitEnsemble(X,y,featurenames,params.nlearn);
params.featurenames = featurenames;

fraccorrect = nnz(sign(yfit)==y)/numel(y);

