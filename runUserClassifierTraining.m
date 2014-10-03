function runUserClassifierTraining(param, allowedLabels, orientDataFileName, outputFileName)

% Unpack gender traiing parameters - to match kristins orginal settings
% Note, there are some slight differences in names between c++ and 
% the original matlab version.

classifyparams = struct;
classifyparams.padborder = param.padBorder;
classifyparams.method = param.method;
classifyparams.nlearn = param.nlearn;
classifyparams.learners = param.learners;


% Load orientation classifier data and unpack
orientdata = load(orientDataFileName);
gtposdata = orientdata.gtposdata;
imfiles = orientdata.imfiles;
label = orientdata.label;
opencvdata = orientdata.opencvdata;

%% train gender classifier
[classifyparams,X,y,imis,fraccorrect, yfit] = TrainUserClassifier(gtposdata,imfiles,label,classifyparams,allowedLabels,'fromfile',true,'datafiles',opencvdata);
labelmap = containers.Map({-1,1}, allowedLabels);
save(outputFileName, 'classifyparams','gtposdata','opencvdata','label','X','y','imfiles', 'fraccorrect', 'yfit','labelmap'); 

%% cross validation
res = questdlg('Do you want to perform cross-validation? This will take a while.');
if strcmpi(res,'yes'),
    [yfitcv,fraccorrectcv] = CrossValidationOverMovies(X,y,classifyparams.featurenames,imfiles(imis),classifyparams.nlearn);
    save('-append',outputFileName,'yfitcv','fraccorrectcv');
end



