function runGenderTraining(param, orientDataFileName, outputFileName)

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
sex = orientdata.sex;
opencvdata = orientdata.opencvdata;

%% train gender classifier
[classifyparams,X,y,imis] = TrainGenderClassifier(gtposdata,imfiles,sex,classifyparams,'fromfile',true,'datafiles',opencvdata);
save(outputFileName, 'classifyparams','gtposdata','opencvdata','sex','X','y','imfiles'); 

%% cross validation
res = questdlg('Do you want to perform cross-validation? This will take a while.');
if strcmpi(res,'yes'),
    [yfitcv,fraccorrect] = CrossValidationOverMovies(X,y,classifyparams.featurenames,imfiles(imis),classifyparams.nlearn);
    save('-append',outputFileName,'yfitcv','fraccorrect');
end



