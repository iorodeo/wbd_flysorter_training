function processTrainingData(userClassifierPlugin,trainingDataDirs,outputFileName) 
% processTrainingData 
%
% organizes data found int base training data directory. Saves this information in 
% to output file.


opencvdata = getOpencvData(userClassifierPlugin, trainingDataDirs);
preProcessingData.opencvdata = opencvdata;
preProcessingData.traingingDataDirs = trainingDataDirs;
save(outputFileName,'preProcessingData');


% Utility functions
% ---------------------------------------------------------------------------------------

function opencvdata = getOpencvData(userClassifierPlugin, trainDataDirs)
% getOpencvData:
%
% Returns structure of opencv data given the base directory for the training data.
%

% Loop over training data directories

opencvdata = [];
offk= 0;

for dirNum = 1:numel(trainDataDirs)
    
    dirName = trainDataDirs{dirNum};
    fprintf('processing: dirNum = %d, dirName = %s\n',dirNum, dirName);

    %datFiles = dir(fullfile(dirName,'*.txt'));
    %imgFiles = dir(fullfile(dirName,'*.png'));

    datFileHint = sprintf('%s%s*.txt',dirName,filesep);
    imgFileHint = sprintf('%s%s*.png',dirName,filesep);
    datFiles = dir(datFileHint);
    imgFiles = dir(imgFileHint);

    % Get label information - either from labeleddebugdata.mat file or from file name
    labeledDebugDataFile = sprintf('%slabeleddebugdata.mat',userClassifierPlugin.name);
    labeledDebugDataFile = fullfile(dirName,labeledDebugDataFile);

    if exist(labeledDebugDataFile,'file')
        hasFrameToLabelMap = true;
        % Load label from labeleddebugdata file
        loadStruct = load(labeledDebugDataFile);
        labeledDebugData = loadStruct.labeleddebugdata;
        frameToLabelMap = createFrameToLabelMap(labeledDebugData,userClassifierPlugin.labels);
    else
        % Get label from directory name
        hasFrameToLabelMap = false;

        found = false;
        for i = 1:numel(userClassifierPlugin.dirStr)
            dirStr = userClassifierPlugin.dirStr{i};
            dirStrLabel = userClassifierPluging.dirStrToLabelMap(dirStr);
            if strfind(lower(dirName,dirStr))
                label = dirStrLabel;
                found = true;
                break;
            end
        end
        if ~found
            error('label not found in directory name');
        end

    end


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

            % Set label information
            if hasFrameToLabelMap
                if frameToLabelMap.isKey(dataCurr.frame)
                    dataCurr.label = frameToLabelMap(dataCurr.frame);
                    %fprintf('out %1.0f, %s\n', dataCurr.frame, dataCurr.label);
                else
                    error('key %d not found in frameToLabelMap', dataCurr.frame);
                end
            else
                dataCurr.label = label;
            end

        else
            dataCurr = opencvdata(offk+k);
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
        
        opencvdata = structarrayset(opencvdata,offk+k,dataCurr);

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
        dataCurr = opencvdata(offk+k);
        dataCurr.cropim = fullfile(dirName,fileName);
        opencvdata = structarrayset(opencvdata,offk+k,dataCurr);
    end

    offk = offk + numel(baseNamesCurr);

    
end


function frameToLabelMap = createFrameToLabelMap(labeledDebugData, allowedLabels) 
% createFrameToLabelMap:
%
% Returns a containers.Map mapping frame numbers to manual label assignments.
%
frameToLabelMap = containers.Map('KeyType','double','ValueType','char');
for i = 1:numel(labeledDebugData)
    frameNumber = 1000*labeledDebugData(i).frame + labeledDebugData(i).count + 1;
    label = labeledDebugData(i).manuallabel;
    if ~isa(label,'char') 
        label = 'U';
    else
        label = upper(label);
        if ~sum(ismember(allowedLabels,label))
            label = 'U';
        end
    end
    %fprintf('%1.0f, %s\n', frameNumber, label);
    frameToLabelMap(frameNumber) = label;
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



