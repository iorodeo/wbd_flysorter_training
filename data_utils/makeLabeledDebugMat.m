function makeLabeledDebugMat(varargin)
% makeLabeledDebugMat:
%
% creates labeleddebugdata.mat from debug_data_log.txt. Assumes that 
% images are in the same directory as debug_data_log.txt file.

if numel(varargin) < 1
    rsp = uigetdir(pwd,'Select source directory');
    if rsp  == 0
        fprintf('no source directory selected\n');
        return;
    else
        directory = rsp;
    end
else
    directory = varargin{1};
end

dirArray = dir(directory);

for i = 1:numel(dirArray);
    if dirArray(i).isdir
        if strcmpi(dirArray(i).name, '.') || strcmp(dirArray(i).name, '..')
            continue;
        end
        debugLogDir = [directory, filesep, dirArray(i).name];
        debugLogFile = [debugLogDir, filesep, 'debug_data_log.txt'];
        if exist(debugLogFile)
            fprintf('processing: %s\n',debugLogFile);
            %[labeleddebugdata,~] = readDebugData(debugLogFile,debugLogDir);
            [labeleddebugdata,~] = readDebugData(debugLogFile);
            length(labeleddebugdata)

            %% Temp - for curly case where I had to make debug_data_log
            %for i=1:numel(labeleddebugdata)
            %    labeleddebugdata(i).frame = labeleddebugdata(i).frame/(1.0e3);
            %end


            matFileName = [debugLogDir,filesep,'labeleddebugdata.mat'];
            fprintf('creating: %s\n',matFileName);
            save(matFileName,'labeleddebugdata');
        end
    end
end 

