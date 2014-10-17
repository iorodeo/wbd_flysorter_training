function splitDataSet(directory, labelArray, numSplit, clsName)

debugDataName = sprintf('%slabeleddebugdata.mat',clsName)

debugDataFile = sprintf('%s%s%s',directory,filesep,debugDataName);
fileLoad = load(debugDataFile);
debugDataArray = fileLoad.labeleddebugdata;

debugDataMap = getLabelToDataMap(debugDataArray, labelArray);
permutationMap = getLabelToPermMap(debugDataMap, labelArray);

splitDirNameArray = {};
for i = 1:numSplit
    % Create directory name, if directory exists delete contents, if not create
    splitDirName = sprintf('dataset_%d',i);
    splitDirName
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
        labelPermutation = permutationMap(label);
        subsetPermutation = getSubsetPermutation(j,numSplit,labelDataArray,labelPermutation);
        subsetDataArray = labelDataArray(subsetPermutation);
        copyDataFiles(subsetDataArray, directory,splitDirName);
        copyDebugData(debugDataName,subsetDataArray,splitDirName);
    end
end

end


% -------------------------------------------------------------------------------------

function copyDebugData(debugDataName, subsetDataArray, splitDirName) 
subsetDebugName = sprintf('%s%s%s',splitDirName,filesep,debugDataName);
fprintf('saving: %s\n', subsetDebugName);
if exist(subsetDebugName)
    fileLoad = load(subsetDebugName);
    labeleddebugdata = horzcat(fileLoad.labeleddebugdata,subsetDataArray);
else
    labeleddebugdata = subsetDataArray;
end
save(subsetDebugName, 'labeleddebugdata');
end

function copyDataFiles(dataArray,fromDir,toDir)
for i = 1:numel(dataArray)
    dataItem = dataArray(i);
    frameNum = dataItem.frame*1000 + dataItem.count+1;
    fileHint = sprintf('%s%sdata_frame_%d*',fromDir, filesep,frameNum);
    dirStruct = dir(fileHint);
    for j = 1:numel(dirStruct)
        fprintf('copying: %s\n', dirStruct(j).name);
        srcFile = sprintf('%s%s%s',fromDir,filesep,dirStruct(j).name);
        dstFile = sprintf('%s%s%s,',toDir,filesep,dirStruct(j).name);
        fprintf('src: %s\n', srcFile);
        fprintf('dst: %s\n', dstFile);
        copyfile(srcFile,dstFile);
        fprintf('\n');
    end
end
end

function subsetPermutation = getSubsetPermutation(splitInd,numSplit,labelDataArray,permutation) 
numLabelItems = numel(labelDataArray);
numSubsetItems = floor(numLabelItems/numSplit);
ind0 = max(1,(splitInd-1)*numSubsetItems); 
ind1 = min(splitInd*numSubsetItems,numLabelItems);
subsetPermutation = permutation(ind0:ind1);
fprintf('  ind0: %d, ind1: %d\n', ind0, ind1);
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

