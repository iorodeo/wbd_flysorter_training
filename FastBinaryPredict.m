function [labelfit,yfit] = FastBinaryPredict(classifier,X)

n = size(X,1);

% total score is computed as
% score = off;
% for j = 1:numel(xidx),
%   if x(xidx(j)) < thresh(j),
%     score = score + val(j);
%   end
% end

% n x K < 1 x K
% idx(j,k) is true if we want to add in val(k)
idx = bsxfun(@lt,X(:,classifier.xidx),classifier.thresh);
yfit = sum(-bsxfun(@times,classifier.val,idx),2) - classifier.off;

labelfit = ones(n,1);
labelfit(yfit < 0) = -1;