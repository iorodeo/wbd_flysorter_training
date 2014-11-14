function splitDataSet(labelArray, numSplit, clsName, varargin)
% splitDataSet: 
%
% Splits dataset into numSplit dataset with roughly equal amounts
% of data from each label type.

useRandPerm = false;

if numel(varargin) > 0
    srcDir = varargin{1};
else
    srcDir = uigetdir(pwd,'Select source directory');
    if srcDir == 0
        fprintf('no source directory selected\n');
        return;
    end
end

if numel(varargin) > 1
    dstDir = varargin{2};
    if isemtpy(dstDir)
        distDir = pwd;
    end
else
    dstDir = uigetdir(pwd, 'Select destination directory');
    if dstDir == 0
        fprintf('no destination directory selected\n');
        return;
    end
end
if ~exist(dstDir)
    error('destination directory does not exist');
end

debugDataName = sprintf('%slabeleddebugdata.mat',clsName)

debugDataFile = sprintf('%s%s%s',srcDir,filesep,debugDataName);
fileLoad = load(debugDataFile);
debugDataArray = fileLoad.labeleddebugdata;

debugDataMap = getLabelToDataMap(debugDataArray, labelArray);
if useRandPerm
    labelToIndexMap = getLabelToPermMap(debugDataMap, labelArray);
else
    labelToIndexMap = getLabelToIndexMap(debugDataMap, labelArray);
end

splitDirNameArray = {};
for i = 1:numSplit
    % Create srcDir name, if srcDir exists delete contents, if not create
    splitDirName = sprintf('%s%sdataset_%d',dstDir,filesep,i);
    checkDirectory(splitDirName);
    splitDirNameArray{i} = splitDirName;
end

% Split into  numSplit data sets
for i = 1:numel(labelArray)
    label = labelArray{i};
    fprintf('label: %s\n', label);

    for j = 1:numSplit
        splitDirName = splitDirNameArray{j};
        fprintf('splitDirName: %s\n', splitDirName);
        labelDataArray = debugDataMap(label);
        labelIndArray = labelToIndexMap(label);
        splitIndArray= getSplitInd(j,numSplit,labelIndArray);
        splitDataArray = labelDataArray(splitIndArray);
        copyDataFiles(splitDataArray, srcDir,splitDirName);
        copyDebugData(debugDataName,splitDataArray,splitDirName);
    end
end

end


% -------------------------------------------------------------------------------------

function copyDebugData(debugDataName, splitDataArray, splitDirName) 
subsetDebugName = sprintf('%s%s%s',splitDirName,filesep,debugDataName);
fprintf('saving: %s\n', subsetDebugName);
if exist(subsetDebugName)
    fileLoad = load(subsetDebugName);
    labeleddebugdata = horzcat(fileLoad.labeleddebugdata,splitDataArray);
else
    labeleddebugdata = splitDataArray;
end
save(subsetDebugName, 'labeleddebugdata');
end

function copyDataFiles(dataArray,fromDir,toDir)
for i = 1:numel(dataArray)
    dataItem = dataArray(i);
    frameNum = dataItem.frame*1000 + dataItem.count+1;
    fileHint = sprintf('%s%sdata_frame_%d_*',fromDir, filesep,frameNum);
    dirStruct = dir(fileHint);
    for j = 1:numel(dirStruct)
        fprintf('copying: %s\n', dirStruct(j).name);
        srcFile = sprintf('%s%s%s',fromDir,filesep,dirStruct(j).name);
        dstFile = sprintf('%s%s%s',toDir,filesep,dirStruct(j).name);
        fprintf('src: %s\n', srcFile);
        fprintf('dst: %s\n', dstFile);
        copyfile(srcFile,dstFile);
        fprintf('\n');
    end
end
end


function splitIndArray = getSplitInd(splitInd,numSplit,indArray) 
numItems = numel(indArray);
numSplitItems = floor(numItems/numSplit);
n = max(1,(splitInd-1)*numSplitItems + 1); 
m = min(splitInd*numSplitItems,numItems);
splitIndArray = indArray(n:m);
fprintf('n: %d, m: %d\n', n, m);
end

function checkDirectory(dirName)
if exist(dirName)
    fileInfo = dir(dirName);
    for i=1:numel(fileInfo)
        if ~fileInfo(i).isdir
            fileName = sprintf('%s%s%s',dirName,filesep,fileInfo(i).name);
            delete(fileName);
        end
    end
else
    mkdir(dirName);
end
end


function debugDataMap = getLabelToDataMap(debugDataArray, labelArray)
debugDataMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
% Gather data by label
for i = 1:numel(labelArray)
    label = labelArray{i};
    ind = find(strcmpi({debugDataArray.manuallabel},label));
    debugDataWithLabel = debugDataArray(ind);
    debugDataMap(label) = debugDataWithLabel;
    fprintf('label: %s, numItems: %d\n', label, numel(debugDataWithLabel));
end
fprintf('\n');
end


function permutationMap = getLabelToPermMap(debugDataMap, labelArray)
% Get random permutations for different labels
permutationMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for i = 1:numel(labelArray)
    label = labelArray{i};
    permutationMap(label) = randperm(numel(debugDataMap(label)));
end
end


function labelToIndexMap = getLabelToIndexMap(debugDataMap, labelArray)
labelToIndexMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for i = 1:numel(labelArray)
    label = labelArray{i};
    labelToIndexMap(label) = [1:numel(debugDataMap(label))];
end
end


