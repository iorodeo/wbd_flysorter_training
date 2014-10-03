function [yfitcv,fraccorrect] = CrossValidationOverMovies(X,y,featurenames,imfiles,nlearn,...
  varargin)

[movienames] = myparse(varargin,'movienames',{});

if isempty(movienames),
  
  movienames = cell(1,numel(imfiles));
  for i = 1:numel(imfiles),
    [~,movienames{i}] = fileparts(fileparts(imfiles{i}));
  end
  
end

[uniquepaths,~,movieidx] = unique(movienames);

yfitcv = nan(size(y));
yfitcv_pf = cell(1,numel(uniquepaths));
%order = randperm(numel(uniquepaths));
parfor i = 1:numel(uniquepaths),
  %i = order(ii);
  fprintf('Test set %d / %d (%s)\n',i,numel(uniquepaths),uniquepaths{i});
  % indices into X, y
  idxtestcurr = movieidx==i;
  idxtraincurr = ~idxtestcurr;
  classifier_cv = myFitEnsemble(X(idxtraincurr,:),y(idxtraincurr),...
    featurenames,nlearn);
  [lcurr,ycurr] = FastBinaryPredict(classifier_cv,X(idxtestcurr,:));
  %yfitcv(idxtestcurr) = ycurr;
  yfitcv_pf{i} = ycurr;
  fprintf('ncorrect = %d/%d\n',nnz(lcurr==y(idxtestcurr)),nnz(idxtestcurr));
end

for i = 1:numel(uniquepaths),
  idxtestcurr = movieidx==i;
  yfitcv(idxtestcurr) = yfitcv_pf{i};
end
fraccorrect = nnz(sign(yfitcv) == y)/numel(y);
