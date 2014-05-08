% [classifier,ens,labelfit,yfit] = myFitEnsemble(X,y,featurenames,nlearn)
% total score is computed as
% score = off;
% for j = 1:numel(xidx),
%   if x(xidx(j)) < thresh(j),
%     score = score + val(j);
%   end
% end

function [classifier,ens,labelfit,yfit] = myFitEnsemble(X,y,featurenames,nlearn)

% use matlab's boosting code
ens = fitensemble(X,y,'GentleBoost',nlearn,...
  'Tree','PredictorNames',featurenames,'prior','uniform');

% pull out the classifier
classifier = struct;

thresh = nan(1,numel(ens.Trained));
xidx = nan(1,numel(ens.Trained));
val = nan(2,numel(ens.Trained));
for j = 1:numel(ens.Trained),
  tree = ens.Trained{j}.CompactRegressionLearner.Impl.Tree;
  thresh(j) = tree.cutpoint(1);
  cutvar = tree.cutvar;
  cutvar = cutvar{1};
  xidx(j) = find(strcmp(cutvar,featurenames));
  % the rule is x(xidx(j)) < thresh(j) ? val(j,1) : val(j,2)
  val(:,j) = tree.nodemean([2,3]);
end
off = sum(val(2,:));
classifier.thresh = thresh;
classifier.xidx = xidx;
classifier.val = val(1,:)-val(2,:);
classifier.off = off;
classifier.off1 = val(2,:);

    
% test on training data to get scaling
[labelfit,yfit] = FastBinaryPredict(classifier,X); 
classifier.scale = prctile(abs(yfit),80);
