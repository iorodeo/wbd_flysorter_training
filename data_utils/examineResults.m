function examineResults(fileName)

data = load(fileName);
indPos = find(data.y == 1);
indNeg = find(data.y == -1);

symbPos = data.labelmap(1);
symbNeg = data.labelmap(-1);

% Get regular traing resuls
corr = sign(data.yfit) == data.y;
fracCorr= sum(corr)/length(data.y);
fracCorrPos = sum(corr(indPos))/length(data.y(indPos));
fracCorrNeg = sum(corr(indNeg))/length(data.y(indNeg));
fprintf('\n');
fprintf('Training Fit\n');
fprintf('fraction correct:    %f\n', fracCorr);
fprintf('fraction correct %s:  %f\n', symbPos,fracCorrPos);
fprintf('fraction correct %s:  %f\n', symbNeg,fracCorrNeg);

% Get cross validation results
corrCV = sign(data.yfitcv) == data.y;
fracCorrCV= sum(corrCV)/length(data.y);
fracCorrPosCV = sum(corrCV(indPos))/length(data.y(indPos));
fracCorrNegCV = sum(corrCV(indNeg))/length(data.y(indNeg));
fprintf('\n');
fprintf('Cross Valication\n');
fprintf('fraction correct:    %f\n', fracCorrCV);
fprintf('fraction correct %s:  %f\n', symbPos,fracCorrPosCV);
fprintf('fraction correct %s:  %f\n', symbNeg,fracCorrNegCV);
fprintf('\n');

%length(data.y)
%length(data.yfit)
%length(data.yfitcv)

end
