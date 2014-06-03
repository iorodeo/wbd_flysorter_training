function runGenderTraining()
% runGenderTraining:
%
outputfile = 'genderdata.mat';

classifyparams = struct;
classifyparams.padborder = 15;
classifyparams.method = 'GentleBoost';
classifyparams.nlearn = 100;
classifyparams.learners = 'Tree';

% Load orientation classifier data and unpack
orientdataFileName = 'orientdata.mat'
orientdata = load(orientdataFileName);
orientdata
gtposdata = orientdata.gtposdata;
imfiles = orientdata.imfiles;
sex = orientdata.sex;
opencvdata = orientdata.opencvdata;

%% train gender classifier
[classifyparams,X,y,imis] = TrainGenderClassifier(gtposdata,imfiles,sex,classifyparams,'fromfile',true,'datafiles',opencvdata);
save(outputfile, 'classifyparams','gtposdata','opencvdata','sex','X','y','imfiles'); 

%% cross validation
res = questdlg('Do you want to perform cross-validation? This will take a while.');
if strcmpi(res,'yes'),
    [yfitcv,fraccorrect] = CrossValidationOverMovies(X,y,classifyparams.featurenames,imfiles(imis),classifyparams.nlearn);
    save('-append',outputfile,'yfitcv','fraccorrect');
end



