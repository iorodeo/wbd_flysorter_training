function runOrientationTraining(preProcessingFile,outputFileName,param)

% runOrientationTraining:
%
% opens processed training data and runs training. 
%

% Unpack orientation parameters - to match kristins orginal settings
% Note, there are some slight differences in names between c++ and 
% the original matlab version.

% When finding body connected components, we close holes
fitparams.se_close = strel('disk',param.closeRadius,0);

fitparams.area_open = param.openArea;
fitparams.mina = param.minimumArea;
fitparams.max_body_area = param.maximumArea;

fitparams.classifyparams = struct;
fitparams.classifyparams.padborder = param.padBorder;
fitparams.classifyparams.method = param.method;
fitparams.classifyparams.nlearn = param.nlearn; 
fitparams.classifyparams.learners = param.learners;

%% Old 
%% --------------------------------------------------------------------
%% Where do we set these params???
%% I think these params need to be in a config file or set by the gui. 
%% --------------------------------------------------------------------
%
%% when finding body connected components, we close holes
%fitparams.se_close = strel('disk',15,0);
%
%% minimum size of a fly body
%fitparams.area_open = 3400;
%fitparams.mina = 58.8333;
%
%% max size of a fly body
%fitparams.max_body_area = 16600;
%fitparams.max_body_a = 140;
%
%fitparams.classifyparams = struct;
%fitparams.classifyparams.padborder = 15;
%fitparams.classifyparams.method = 'GentleBoost';
%fitparams.classifyparams.nlearn = 100;
%fitparams.classifyparams.learners = 'Tree';
%% -------------------------------------------------------------------

fileData = load(preProcessingFile);
preProcessingData = fileData.preProcessingData;
opencvdata = preProcessingData.opencvdata;

% Create gtposdata structure --- what does 'gt' refer to ???
gtposdata = struct;
sex = [opencvdata.sex];  % This is a bug - sex ends up with a different number of elements then gtposdata
for i = 1:numel(opencvdata),
  gtposdata(i).x = opencvdata(i).x;
  gtposdata(i).y = opencvdata(i).y;
  gtposdata(i).a = nan;
  gtposdata(i).b = nan;
  gtposdata(i).theta = nan;
  gtposdata(i).bodyarea = nan;
  gtposdata(i).wingarea = nan;
  gtposdata(i).fracwing = nan;
  gtposdata(i).meanwingproj = nan;
  gtposdata(i).ismultipleflies = false;
  gtposdata(i).isfly = true;
  gtposdata(i).iswing = nan;
  gtposdata(i).success = true;
end

imfiles = {opencvdata.hogdata};

%% get groundtruth for whether the flies are upside-down or not
[fitparams,doflip,Xor,yor,imis] = LabelTrainOrientationClassifier([],[],fitparams,'fromfile',true,'datafiles',opencvdata); 

for i = 1:numel(gtposdata),
  if isnan(doflip(i)),
    gtposdata(i).ismultipleflies = true;
  else
    gtposdata(i).doflip = doflip(i);
  end
end


% Old
% -----------------------------------------------------------------------------------
%save(outputfile,'imfiles','opencvdata','gtposdata','fitparams','sex','doflip');
% -----------------------------------------------------------------------------------

save(outputFileName,'imfiles','opencvdata','gtposdata','fitparams','sex','doflip');

% look at area thresholds
fprintf('Set area threshold to < %d\n',min([opencvdata([gtposdata.ismultipleflies]).dd_bodyArea]));

%fileData = load(outputfile);
%imfiles = fileData.imfiles;
%opencvdata = fileData.opencvdata;
%gtposdata = fileData.gtposdata;
%fitparams = fileData.fitparams;
%sex = fileData.sex;
%doflip = fileData.flip;

% cross-validation
res = questdlg('Do you want to perform cross-validation? This will take a while.');
if strcmpi(res,'yes'),
  [yfitcv_or,fraccorrect_or] = CrossValidationOverMovies(Xor,yor,fitparams.featurenames,...
    imfiles(imis),fitparams.classifyparams.nlearn);
    % Old
    % -------------------------------------------------------
    %save('-append',outputfile,'yfitcv_or','fraccorrect_or');
    % -------------------------------------------------------
    save('-append',outputFileName,'yfitcv_or','fraccorrect_or');
end

% make an image of all the aligned flies
res = questdlg('Do you want to make an image of all the aligned flies?');
if strcmpi(res,'yes'),
  alignedflyim = ShowAlignedFliesFile(opencvdata,gtposdata);
  imwrite(repmat(alignedflyim,[1,1,3]),'aligned_flies.png', 'png');
end
