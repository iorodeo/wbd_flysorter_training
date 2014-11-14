function mergeDataSets(dirCell, labelCell, outputDir, classifierName)
% mergeDataSets
%
% created merged dataset. Takes as in put a cell array of top level 
% directories and and associated cell array of labels. For a given 
% top level directory the data in all subdirectories is merged and 
% given the specified label.

if ~checkOutputDir(outputDir);
    fprintf('output directory not empty - refusing to overwrite contents -done');
    return;
end

labelToDebugDataMap = getLabelToDebugDataMap(dirCell,labelCell);

newFrameNumber = 0;
labeleddebugdata = [];
for i =1:numel(labelCell)
    label = labelCell{i};
    fprintf('processing label %s\n', label);
    debugDataCell = labelToDebugDataMap(label);

    for j = 1:numel(debugDataCell)
        debugDataMatFile = debugDataCell{j};
        [dataDir,~,~] = fileparts(debugDataMatFile);
        fprintf(' debugDataMatFile: %s\n', debugDataMatFile);
        fprintf(' dataDir:          %s\n', dataDir);
        debugDataLoad = load(debugDataMatFile);

        for k = 1:numel(debugDataLoad.labeleddebugdata)
            frame = debugDataLoad.labeleddebugdata(k).frame;
            count = debugDataLoad.labeleddebugdata(k).count;
            isFly = debugDataLoad.labeleddebugdata(k).pos_isFly;
            isMultiple = debugDataLoad.labeleddebugdata(k).pos_isMultipleFlies;
            framePlusCount = frame*1.0e3 + count + 1;
            fileHint = sprintf('data_frame_%d',framePlusCount);
            infoStruct = dir([dataDir, filesep, fileHint, '*']);
            if isFly && ~isMultiple && ~isempty(infoStruct)
                fprintf('    framePlusCount: %d\n', framePlusCount);
                newFrameNumber = newFrameNumber + 1;
                newNamePrefix = sprintf('data_frame_%d',newFrameNumber*1.0e3 + 1);
                for n = 1:numel(infoStruct)
                    oldFileName = [dataDir,filesep,infoStruct(n).name];
                    newFileName = strrep(infoStruct(n).name,fileHint, newNamePrefix);
                    newFileName = [outputDir,filesep, newFileName];
                    fprintf('      src file: %s\n',oldFileName);
                    fprintf('      dst file: %s\n',newFileName);
                    copyfile(oldFileName,newFileName);
                end
                itemDebugData = debugDataLoad.labeleddebugdata(k);
                itemDebugData.manuallabel = label;
                itemDebugData.frame = newFrameNumber;
                itemDebugData.count = 0;
                if ~isfield(itemDebugData,'pos_orientationFit')
                    % Add missing field if required
                    itemDebugData.pos_orientationFit = NaN;
                end
                labeleddebugdata = [labeleddebugdata,itemDebugData];
            end
        end
    end
end

newLabeledDebugFile = sprintf('%slabeleddebugdata.mat',classifierName);
newLabeledDebugFile = [outputDir,filesep,newLabeledDebugFile];
fprintf('create lableded debug data file %s\n', newLabeledDebugFile);
save(newLabeledDebugFile, 'labeleddebugdata');


% ------------------------------------------------------------------------------

function ok = checkOutputDir(outputDir)
% checkOutputDir
%
% Checks whether or not output directory exists. If it doesn't it creates it if
% it doesn it check to see if it is empty. Ask user if it is ok to delete contents
% if it is not empty.
ok = false;
existVal = exist(outputDir);
if existVal ~= 7 
    mkdir(outputDir);
    ok = true;
elseif existVal == 7 
    dirArray = dir(outputDir); 
    if numel(dirArray) <= 2
        ok = true;
    else
        rsp = input('output directory exists and is not empty - delete contents y/n [y]? ','s');
        if isempty(rsp)
            rsp = 'y';
        end
        rsp = lower(rsp);
        if strcmp(rsp,'y')
            for i = 1:numel(dirArray)
                if ~dirArray(i).isdir
                    if strcmp(dirArray(i).name, '.') || strcmp(dirArray(i).name,'..')
                        continue
                    end
                    fullPathName = [outputDir,filesep,dirArray(i).name];
                    delete(fullPathName);
                end
            end
            ok = true;
        end
    end
end

function labelToDebugDataMap = getLabelToDebugDataMap(dirCell, labelCell)
% getLabelToDebugDataMap
% 
% Returns map of labels to labeleddebugdata files for the given cell arrays of 
% directories and thier corresponding labels.
labelToDebugDataMap = containers.Map('KeyType','char','ValueType', 'any');

% Create label to directory map
numLabel = numel(labelCell);
for i = 1:numLabel
    label = labelCell{i};
    labelDir = dirCell{i};
    subDirArray = getSubDirectories(labelDir);
    debugDataCell = {};
    for j=1:numel(subDirArray)
        subDirName = [labelDir,filesep,subDirArray(j).name];
        labeledDebugFile = [subDirName,filesep,'labeleddebugdata.mat'];
        if exist(labeledDebugFile)
            debugDataCell = {debugDataCell{:},labeledDebugFile};
        end
    end
    labelToDebugDataMap(label) = debugDataCell;
end


function printLabelToDebugDataMap(labelToDebugDataMap)
% printLabelToDebugDataMap
labelCell = labelToDebugDataMap.keys();
for i = 1:numel(labelCell)
    label = labelCell{i};
    debugDataCell = labelToDebugDataMap(label);
    fprintf('label: %s\n', label);
    for j = 1:numel(debugDataCell)
        debugDataMatFile = debugDataCell{j};
        fprintf('  debugDataMatFile: %s\n', debugDataMatFile)
    end
end


function subDirectories = getSubDirectories(directory)
% getSubDirectories  
%
% Returns structure array of subdirectory information for given directory
dirArray = dir(directory);
numFields = numel(fieldnames(dirArray));
subDirectories = [];
for i = 1:numel(dirArray)
    if ~dirArray(i).isdir
        continue;
    end
    if strcmpi(dirArray(i).name,'.') || strcmpi(dirArray(i).name,'..') 
        continue;
    end
    subDirectories = [subDirectories,dirArray(i)];
end


function fileArray = getFilesWithSubStr(directory,subStr)
% getFilesWithSubStr
%
% Returns sturcture array of directory informatinon for all files with in 
% the given directory whose name contains the given substring.
dirArray = dir(directory);
fileArray = [];
for i = 1:numel(dirArray)
    if dirArray(i).isdir
        continue;
    end
    if ~isempty(findstr(dirArray(i).name, subStr))
        fileArray = [fileArray,dirArray(i)];
    end
end













