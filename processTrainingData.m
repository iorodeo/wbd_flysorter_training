function processTrainingData 
% processTrainingData 
%
% basic script for training the orientation clasifier

trainDataBaseDir = '.\flysorter_training';
outputFileName = 'opencv_data.mat';

% when finding body connected components, we close holes
fitparams.se_close = strel('disk',15,0);

% minimum size of a fly body
fitparams.area_open = 3400;
fitparams.mina = 58.8333;

% max size of a fly body
fitparams.max_body_area = 16600;
fitparams.max_body_a = 140;

fitparams.classifyparams = struct;
fitparams.classifyparams.padborder = 15;
fitparams.classifyparams.method = 'GentleBoost';
fitparams.classifyparams.nlearn = 100;
fitparams.classifyparams.learners = 'Tree';


% Kristin's libraries
if ispc,
    addpath ../JAABA/misc;
    addpath ../JAABA/filehandling;
    addpath ../piotr_toolbox_V3.0/channels;
else
    addpath ../JCtrax/misc;
    addpath ../JCtrax/filehandling;
    addpath ../piotr_toolbox_V3.0/channels;
end

opencvData = getOpencvData(trainDataBaseDir);
save(outputFileName, 'opencvData');


%[fitparams,doflip,Xor,yor,imis] = LabelTrainOrientationClassifier( [], [], ...
%    fitparams,'fromfile',true,'datafiles',opencvData); 



% Utility functions
% ---------------------------------------------------------------------------------------

function opencvData = getOpencvData(trainDataBaseDir)
% getOpencvData:
%
% Returns structure of opencv data given the base directory for the training data.
%

% Loop over training data directories
trainDataDirs = getTrainDataDirs(trainDataBaseDir);

opencvData = [];
offk= 0;

for dirNum = 1:1%numel(trainDataDirs)
    
    dirName = trainDataDirs{dirNum};
    fprintf('processing: dirNum = %d, dirName = %s\n',dirNum, dirName);
    
    datFiles = dir(fullfile(dirName,'*.txt'));
    imgFiles = dir(fullfile(dirName,'*.png'));

    % Load gender from labeled debug data
    loadStruct = load(fullfile(dirName,'labeleddebugdata.mat'));
    labeledDebugData = loadStruct.labeleddebugdata;

    % Create map for mapping frame number to gender. A little weird but seems to be the only way
    % a map with double keys and char values. 
    frameToGenderMap = createFrameToGenderMap(labeledDebugData);

    % Read in data files - position data and pixel feature vectors
    baseNamesCurr = {};

    for fileNum = 1:numel(datFiles)

        fileName = datFiles(fileNum).name;
        fprintf('  %s\n',fileName);
        
        isPosData = false;
        posDataInfo = [];

        if contains(fileName,'posdata')
            % File contains position data - get info from name and file contents
            regexpStr = '^(?<type>[^_]+)_frame_(?<frame>\d+)_posx_(?<x>\d+)_posy_(?<y>\d+)_id_(?<id>\d+)_posdata';
            nameInfo = regexp(fileName,regexpStr,'once','names');
            isPosData = ~isempty(nameInfo);
            if isPosData 
                posDataInfo = ReadDebugData(fullfile(dirName,fileName));
            end
            
        elseif contains(fileName, 'flipxy')
            % File constains pixel feature vector  - get info from file name.
            regexpStr = '^(?<type>[^_]+)_frame_(?<frame>\d+)_posx_(?<x>\d+)_posy_(?<y>\d+)_id_(?<id>\d+)_flipxy_(?<flipx>\d)(?<flipy>\d)';
            nameInfo = regexp(fileName,regexpStr,'once','names');
        end
        
        % Get base name of file
        regexpStr = 'frame_(?<frame>\d+)_posx_(?<x>\d+)_posy_(?<y>\d+)_id_(?<id>\d+)';
        baseName = regexp(fileName,regexpStr,'once','match');
        k = find(strcmp(baseNamesCurr,baseName));
        
        if isempty(k),
            k = numel(baseNamesCurr)+1;
            baseNamesCurr{end+1} = baseName; %#ok<SAGROW>
            dataCurr = rmfield(nameInfo,intersect(fieldnames(nameInfo),{'type','flipx','flipy'}));
            fns = fieldnames(dataCurr);
            for l = 1:numel(fns),
                dataCurr.(fns{l}) = str2double(dataCurr.(fns{l}));
            end
            dataCurr.dirName = dirName;
            if frameToGenderMap.isKey(dataCurr.frame)
                dataCurr.sex = frameToGenderMap(dataCurr.frame);
            else
                error('key %d not found in frameToGenderMap', dataCurr.frame);
            end

        else
            dataCurr = opencvData(offk+k);
        end
        
        if isPosData,
            % Add position data information fields
            fns = fieldnames(posDataInfo);
            for l = 1:numel(fns),
                dataCurr.(['dd_',fns{l}]) = posDataInfo.(fns{l});
            end
        else
            % Add pixel feature vector data
            if ~strcmp(nameInfo.type, 'data')
                error('uknown type %s', nameInfo.type);
            end
            if nameInfo.flipx == '0' && nameInfo.flipy == '0',
                dataCurr.hogdata = fullfile(dirName,fileName);
            elseif nameInfo.flipx == '0' && nameInfo.flipy == '1',
                dataCurr.hogdata_fliplr = fullfile(dirName,fileName);
            elseif nameInfo.flipx == '1' && nameInfo.flipy == '0',
                dataCurr.hogdata_flipud = fullfile(dirName,fileName);
            elseif nameInfo.flipx == '1' && nameInfo.flipy == '1',
                dataCurr.hogdata_flipudlr = fullfile(dirName,fileName);
            else
                error('unknown value for flipxy %s%s',nameInfo.flipx,nameInfo.flipy);
            end
        end
        
        opencvData = structarrayset(opencvData,offk+k,dataCurr);

    end % for fileNum = 1:numel(datFiles)

    % Read in image files
    for fileNum = 1:numel(imgFiles)
        fileName = imgFiles(fileNum).name;
        nameInfo = regexp(fileName,'^(?<type>[^_]+)_frame_(?<frame>\d+)_posx_(?<x>\d+)_posy_(?<y>\d+)_id_(?<id>\d+)','once','names');
        if isempty(nameInfo)
            error('could not parse image file name %s, skipping', fileName);
        end
        baseName = regexp(fileName,'frame_(?<frame>\d+)_posx_(?<x>\d+)_posy_(?<y>\d+)_id_(?<id>\d+)','once','match');
        k = find(strcmp(baseNamesCurr,baseName));
        if isempty(k),
          error('did not find data for this png file');
        end
        dataCurr = opencvData(offk+k);
        dataCurr.cropim = fullfile(dirName,fileName);
        opencvData = structarrayset(opencvData,offk+k,dataCurr);
    end

    offk = offk + numel(baseNamesCurr);

    
end


function frameToGenderMap = createFrameToGenderMap(labeledDebugData) 
% createFrameToGenderMap:
%
% Returns a containers.Map mapping frame numbers to manual gender assignment.
%
frameToGenderMap = containers.Map(0.1,'a').remove(0.1); 
for i = 1:numel(labeledDebugData)
    frameNumber = 1000*labeledDebugData(i).frame + labeledDebugData(i).count + 1;
    frameToGenderMap(frameNumber) = labeledDebugData.manuallabel;
end


function trainDataDirs = getTrainDataDirs(baseDir)
% getTrainDataDirs:
%
% Returns cell array of training data directories in the given base director.
%
baseDirInfo = dir(baseDir);
cnt = 0;
trainDataDirs = {};

for i = 1:numel(baseDirInfo)
    dirStruct = baseDirInfo(i);
    if strcmp(dirStruct.name, '.') || strcmp(dirStruct.name,'..')
        continue;
    end
    if ~dirStruct.isdir
        continue;
    end
    cnt = cnt + 1;
    trainDataDirs{cnt} = fullfile(baseDir, dirStruct.name);
end


function flag = contains(textStr, patternStr)
% contains:
%
% test whether or not textStr contains the patternStr
flag = ~isempty(strfind(textStr,patternStr));



