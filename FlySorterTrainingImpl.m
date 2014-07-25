classdef FlySorterTrainingImpl < handle


    properties (Constant)
        
        rcDir = '.flysorter_training_rc';
        savedStateFileName = 'flysorter_state.mat';
        saveFieldNames = {             ... 
            'numMatlabpoolCores',      ...
            'jabbaPath',               ...
            'workingDir',              ...
            'isFilePrefixChecked',     ...
            'isAutoIncrementChecked',  ...
            'isAddDatetimeChecked',    ...
            'trainingDataDirs',        ...
            'filePrefix',              ...
            };

        % Output file base names
        preProcessingFileNameBase  = 'prepro';
        orientationFileNameBase    = 'orient';
        userClassifierFileNameBase = 'usrcls';

        editTextLengthSub = 14; % For setting text length in multi-line textboxes

    end


    properties

        figureHandle = [];
        machineNumCores = 0;
        numMatlabpoolCores = 0;
        jabbaPath = [];
        workingDir = [];
        trainingDataDirs = {};  

    end


    properties (Dependent)

        handles;
        rcDirFullPath;
        savedStateFullPath;
        jabbaMiscPath;
        jabbaFileHandlingPath;

        isPoolEnableChecked;
        isFilePrefixChecked;
        isAddDatetimeChecked;
        isAutoIncrementChecked;

        haveMatlabpool;
        haveJabbaPath;
        haveWorkingDir;
        haveTrainingData;
        havePreProcessingData;
        haveOrientationData;
        haveUserClassifierData;

        preProcessingFileName;
        orientationFileName;
        userClassifierFileName;

        preProcessingFileFullPath;
        orientationFileFullPath;
        userClassifierFileFullPath;

        filePrefix;


    end

    properties (Dependent, Access=protected)

        preProcessingOutFileText;
        orientationOutFileText;
        userClassifierOutFileText;

    end



    % -----------------------------------------------------------------------------------
    methods 
        

        function self = FlySorterTrainingImpl(figureHandle)
            self.figureHandle = figureHandle;
            self.initNumberOfCoresPopup()
            self.loadStateFromRcDir();
            self.setAllUiPanelEnable('off')

            self.updateAllUiPanelEnable()
            self.updateOutFileNames()

            % Temporary
            % -----------------------------------------------------
            set(self.handles.autoIncrementCheckbox,'Enable','off');
            % -----------------------------------------------------

        end


        function delete(self)
            self.saveStateToRcDir();
            self.rmJabbaFromMatlabPath();
        end


        function onPoolEnableChangle(self)
            if self.isPoolEnableChecked
                disp('enable pool')
            else
                disp('disable pool');
            end
        end


        function setNumberOfPoolCores(self)
            disp('setNumberOfPoolCores');
        end


        function setJabbaPathWithGui(self)
            startPath = getStartPathForUiGetDir(self.jabbaPath);
            jabbaPathTemp = uigetdir(startPath, 'Select path to JABBA installation');
            if jabbaPathTemp ~= false
                self.updateJabbaPath(jabbaPathTemp);
                self.updateAllUiPanelEnable()
            end
        end


        function setWorkingDirWithGui(self)
            disp('setWorkingDirWithGui');
            startPath = getStartPathForUiGetDir(self.workingDir);
            workingDirTemp = uigetdir(startPath, 'Select path to working directory');
            if workingDirTemp ~= false
                self.updateWorkingDir(workingDirTemp);
                self.updateAllUiPanelEnable();
            end
        end


        function selectTrainingData(self)
            userHomeDir = getUserHomeDir();
            tempDirs = uipickfiles(         ... 
                'FilterSpec',   userHomeDir,             ...
                'REFilter',     '^',                     ...
                'Prompt',       'Select Training Data',  ...
                'Append',       self.trainingDataDirs,   ...
                'Output',       'cell'                   ...
                );

            if isa(tempDirs,'cell') 
                self.trainingDataDirs = tempDirs(cellfun(@isdir,tempDirs)); 
                self.updateAllUiPanelEnable()
            end
        end


        function clearTraingingData(self)
            question = 'Clear all training data selections?';
            dlgTitle = 'Clear Training Data';
            rsp = questdlg(question, dlgTitle, 'Yes', 'No', 'No');
            if strcmpi(rsp,'Yes')
                self.trainingDataDirs = {};
                self.updateAllUiPanelEnable()
            end
        end


        function runPreProcessing(self)
            self.setAllUiPanelEnable('off')
            % need somethine here to make changes take effect ....
            processTrainingData(self.trainingDataDirs,self.preProcessingFileFullPath);
            self.updateAllUiPanelEnable()
        end


        function clearPreProcessing(self)
            question = sprintf('Delete existing pre-procesed data set %s',self.preProcessingFileName);
            dlgTitle = 'Clear Pre-Processed Data';
            rsp = questdlg(question, dlgTitle , 'Yes', 'No', 'No');
            if strcmpi(rsp,'Yes')
                % ----------------
                % TO DO
                % -----------------
                disp('deleting pre-processed data - not implemented yet');
                self.updateAllUiPanelEnable()
            end
        end



        function clearOrientationTraining(self)
            disp('clearOrientationTraining');
        end


        function runOrientationTraining(self)
            disp('runOrientationTraining');
        end


        function clearUserClassifierTraining(self)
            disp('clearUserClassifierTraining')
        end


        function runUserClassifierTraining(self)
            disp('runUserClassifierTraining');
        end


        function generateClassifierFiles(self)
            disp('generateClassifierFiles');
        end


        function generateJsonConfigFiles(self)
            disp('generateJsonConfigFiles');
        end


        function onOutFileNameChange(self)
            self.updateOutFileNames();
        end

    
        % Getter/Setter methods for dependent properties
        % ---------------------------------------------------------------------

        function handles = get.handles(self)
            handles = guidata(self.figureHandle);
        end


        function rcDirFullPath = get.rcDirFullPath(self)
            rcDirFullPath = [getUserHomeDir(), filesep, self.rcDir];
        end


        function savedStateFullPath = get.savedStateFullPath(self)
            savedStateFullPath = [self.rcDirFullPath, filesep, self.savedStateFileName];
        end


        function jabbaMiscPath = get.jabbaMiscPath(self)
            if self.jabbaPath
                jabbaMiscPath = [self.jabbaPath, filesep, 'misc'];
            else
                jabbaMiscPath = [];
            end
        end


        function jabbaFileHandlingPath = get.jabbaFileHandlingPath(self)
            if self.jabbaPath
                jabbaFileHandlingPath = [self.jabbaPath, filesep, 'filehandling'];
            else
                jabbaFileHandlingPath = [];
            end
        end


        function isPoolEnableChecked = get.isPoolEnableChecked(self)
            isPoolEnableChecked = get(self.handles.poolEnableCheckbox,'value');
        end


        function isFilePrefixChecked = get.isFilePrefixChecked(self)
            isFilePrefixChecked= get(self.handles.filePrefixCheckbox,'value');
        end

        function set.isFilePrefixChecked(self, value)
            set(self.handles.filePrefixCheckbox,'value', value) 
        end

       
        function isAddDatetimeChecked = get.isAddDatetimeChecked(self)
            isAddDatetimeChecked = get(self.handles.addDatetimeCheckbox,'value');
        end

        function set.isAddDatetimeChecked(self,value)
            set(self.handles.addDatetimeCheckbox,'value', value);
        end


        function isAutoIncrementChecked = get.isAutoIncrementChecked(self)
            isAutoIncrementChecked = get(self.handles.autoIncrementCheckbox,'value');
        end


        function set.isAutoIncrementChecked(self,value)
            set(self.handles.autoIncrementCheckbox, 'value', value);
        end


        function haveMatlabpool = get.haveMatlabpool(self)
            haveMatlabpool= checkForParaCompToolbox();
        end


        function haveJabbaPath = get.haveJabbaPath(self)
            haveJabbaPath =  ~isempty(self.jabbaPath);
        end


        function haveWorkingDir = get.haveWorkingDir(self)
            haveWorkingDir = ~isempty(self.workingDir);
        end


        function haveTrainingData = get.haveTrainingData(self)
            haveTrainingData = ~isempty(self.trainingDataDirs);
        end
        

        function havePreProcessingData = get.havePreProcessingData(self)
            % -----------------------------------------------------------
            % NOT DONE  - probably want firmer checks than this
            % -----------------------------------------------------------
            if exist(self.preProcessingFileFullPath)
                havePreProcessingData = true;
            else
                havePreProcessingData = false;
            end
        end


        function haveOrientationData = get.haveOrientationData(self)
            % ---------
            % NOT DONE
            % ---------
            haveOrientationData = false;
        end


        function haveUserClassifierData = get.haveUserClassifierData(self)
            haveUserClassifierData = fasle;
        end


        function preProcessingFileName = get.preProcessingFileName(self)
            preProcessingFileName = self.getOutputFileName(self.preProcessingFileNameBase);
        end


        function orientationFileName = get.orientationFileName(self)
            orientationFileName = self.getOutputFileName(self.orientationFileNameBase);
        end


        function userClassifierFileName = get.userClassifierFileName(self)
            userClassifierFileName = self.getOutputFileName(self.userClassifierFileNameBase);
        end


        function preProcessingFileFullPath = get.preProcessingFileFullPath(self)
            preProcessingFileFullPath = self.addWorkingDirToName(self.preProcessingFileName);
        end


        function orientationFileFullPath = get.orientationFileFullPath(self)
            orientationFileFullPath = self.addWorkingDirToName(self.orientationFileName);
        end


        function userClassifierFileFullPath = get.userClassifierFileFullPath(self)
            userClassifierFileFullPath = self.addWorkingDirToName(self.userClassifierFileName);
        end


        function filePrefix = get.filePrefix(self)
            filePrefix = get(self.handles.filePrefixEditText, 'String');
        end

        
        function set.filePrefix(self, value)
            set(self.handles.filePrefixEditText, 'String', value);
        end



        function set.preProcessingOutFileText(self,value)
            set(self.handles.preProcessingOutFileText,'String',value);
        end



        function set.orientationOutFileText(self, value)
            set(self.handles.orientationOutFileText, 'String', value);
        end


        function set.userClassifierOutFileText(self,value)
            set(self.handles.userClassifierOutFileText,'String',value);
        end


    end



    % -------------------------------------------------------------------------
    methods (Access=protected)


        function updateJabbaPath(self,newJabbaPath)
            if nargin < 2
                newJabbaPath = self.jabbaPath;
            end
            self.rmJabbaFromMatlabPath();
            self.jabbaPath = newJabbaPath;
            self.checkJabbaPath();
            self.addJabbaToMatlabPath();
            self.setJabbaPathText();
        end


        function updateWorkingDir(self,newWorkingDir)
            if nargin == 2
                self.workingDir = newWorkingDir;
            end
            self.checkWorkingDir();
            self.setWorkingDirText();
        end


        function updateOutFileNames(self)
            self.preProcessingOutFileText = self.preProcessingFileName;
            self.orientationOutFileText = self.orientationFileName;
            self.userClassifierOutFileText = self.userClassifierFileName;
        end


        function nameWithWorkingDir = addWorkingDirToName(self,name)
            nameWithWorkingDir = [self.workingDir, filesep, name];
        end


        function setJabbaPathText(self)
            self.setMultiLineEditText(self.handles.jabbaPathEditText, self.jabbaPath);
        end


        function setWorkingDirText(self)
            self.setMultiLineEditText(self.handles.workingDirEditText, self.workingDir);
        end


        
        function updateAllUiPanelEnable(self)
            self.enableUiPanelOnTest(self.handles.matlabpoolPanel, self.haveMatlabpool);
            self.enableUiPanelOnTest(self.handles.jabbaPathPanel, true);
            self.enableUiPanelOnTest(self.handles.outputFilesPanel, true);
            self.enableUiPanelOnTest(self.handles.selectDataPanel, self.haveJabbaPath & self.haveWorkingDir);
            self.enableUiPanelOnTest(self.handles.preProcessingPanel, self.haveTrainingData);
            self.enableUiPanelOnTest(self.handles.orientationPanel, self.havePreProcessingData);
            %self.enableUiPanelOnTest(self.handles.genderTrainingPanel, self.haveOrientationData);
            %self.enableUiPanelOnTest(self.handles.generateFlySorterFilesPanel, self.haveGenderData);
        end


        function enableUiPanelOnTest(self, panelHandle, test)
            enable = 'off';
            if test 
                enable = 'on';
            end
            setUiPanelEnable(panelHandle,enable);

        end


        function setAllUiPanelEnable(self,value)
            figureChildren = get(self.figureHandle,'Children');
            for i = 1:length(figureChildren)
                child = figureChildren(i);
                childType = get(child,'Type');
                if strcmpi(childType,'uipanel')
                    setUiPanelEnable(child,value);
                end
            end
        end


        function initNumberOfCoresPopup(self)
            self.machineNumCores = feature('numCores');
            numCoresCell = {};
            for i = 1:self.machineNumCores
                numCoresCell{i} = num2str(i);
            end
            set(self.handles.numberOfCoresPopup, 'String', numCoresCell);
            set(self.handles.numberOfCoresPopup, 'Value', self.machineNumCores);
        end


        function checkForRcDir(self)
            % Checks for existance of resources directory - creates if not found.
            if ~exist(self.rcDirFullPath,'dir')
                fprintf('%s does not exist creating\n', self.rcDirFullPath);
                [status, message, ~] = mkdir(getUserHomeDir(), self.rcDir);
                if ~status
                    error('unable to create rc directory %s', message);
                end
            end
        end


        function loadStateFromRcDir(self)
            % Get saved state information from file in rc directory
            self.checkForRcDir();
            haveSavedStateData = false;
            savedStateStruct = [];
            if exist(self.savedStateFullPath,'file')
                fprintf('loading state from %s\n',self.savedStateFullPath);
                fileData = load(self.savedStateFullPath);
                if isfield(fileData,'savedStateStruct')
                    savedStateStruct = fileData.savedStateStruct;
                    haveSavedStateData = true;
                end
            end
            % Set field values using saved state data
            if haveSavedStateData
                for i=1:numel(self.saveFieldNames)
                    fieldName = self.saveFieldNames{i};
                    if isfield(savedStateStruct, fieldName)
                        self.(fieldName) = savedStateStruct.(fieldName);
                    end
                end
                self.updateJabbaPath();
                self.updateWorkingDir();
            else
                fprintf('no saved state information - using default values\n');
            end
        end


        function saveStateToRcDir(self)
            savedStateStruct = [];
            for i = 1:numel(self.saveFieldNames)
                fieldName = self.saveFieldNames{i};
                savedStateStruct.(fieldName) = self.(fieldName);
            end
            save(self.savedStateFullPath, 'savedStateStruct');
        end



        function checkJabbaPath(self)
            if self.haveJabbaPath
                jabbaPathOk = true;
                errorMsg = '';
                if ~exist(self.jabbaPath,'dir')
                    jabbaPathOk = false;
                    errorMsg = sprintf('JABBA path does not exist - %s', self.jabbaPath);
                else
                    % Check for misc and filehandling sub-directories as we are going to add 
                    % these to the matlab path.
                    fileHandlingDir = [self.jabbaPath, filesep, 'filehandling'];
                    if ~exist(self.jabbaMiscPath,'dir')
                        jabbaPathOk = false;
                        errorMsg = 'JABBA sub-directory "misc" is missing';
                    end
                    if ~exist(self.jabbaFileHandlingPath,'dir')
                        jabbaPathOk = false;
                        errorMsgTmp = 'JABBA sub-directgory "filehandling" is missing';
                        if isempty(errorMsg)
                            errorMsg = errorMsgTmp;
                        else
                            errorMsg = [errorMsg, ', ', errorMsgTmp];
                        end
                    end
                end 
                if ~jabbaPathOk 
                    self.jabbaPath = [];
                    h = errordlg(errorMsg, 'JABBA Path Error', 'modal');
                    uiwait(h);
                end
            end
        end


        function checkWorkingDir(self)
            if self.haveWorkingDir
                if ~exist(self.workingDir)
                    self.workingDir = [];
                    errorMsg = 'Working Directory does not exist!';
                    h = warndlg(errorMsg, 'FlySorter Working Directory Warning', 'modal');
                    uiwait(h);
                end
            end
        end


        function addJabbaToMatlabPath(self)
            if self.haveJabbaPath
                addpath(self.jabbaMiscPath);
                addpath(self.jabbaFileHandlingPath);
            end
        end


        function rmJabbaFromMatlabPath(self)
            if self.haveJabbaPath
                if ~isempty(strfind(path, self.jabbaMiscPath))
                    rmpath(self.jabbaMiscPath);
                end
                if ~isempty(strfind(path, self.jabbaFileHandlingPath))
                    rmpath(self.jabbaFileHandlingPath);
                end
            end
        end


        function fileName = getOutputFileName(self,baseFileName)
            fileName = baseFileName;
            if self.isFilePrefixChecked
                fileName = sprintf('%s_%s',self.filePrefix,fileName);
            end
            if self.isAddDatetimeChecked
                currTime = now;
                dd = datestr(currTime,'dd');
                mm = datestr(currTime,'mm');
                yy = datestr(currTime,'yy');
                HH = datestr(currTime,'HH');
                MM = datestr(currTime,'MM');
                dateStamp = sprintf('d_%s-%s-%s_t_%s-%s',dd,mm,yy,HH,MM);
                fileName = sprintf('%s_%s', fileName, dateStamp);
            end
            if self.isAutoIncrementChecked
            end
            fileName = sprintf('%s.mat',fileName);
        end


        function setMultiLineEditText(self, editTextHandle, editTextString)
            textPosition = get(editTextHandle,'position');
            editTextLength = textPosition(3) - self.editTextLengthSub;
            if editTextString
                editTextCell = {};
                while length(editTextString) > 0 
                    if length(editTextString) > editTextLength
                        subString = editTextString(1:editTextLength);
                        editTextString = editTextString(editTextLength+1:end);
                    else
                        subString = editTextString(1:end);
                        editTextString = [];
                    end
                    editTextCell{length(editTextCell)+1} = subString;
                end
            else
                editTextCell = {'empty'};
            end 
            set(editTextHandle,'string',editTextCell);
        end

    end

end  % FlySorterTrainingImpl


% Utility Functions
% -----------------------------------------------------------------------------

function setUiPanelEnable(panelHandle,value)
    if ~( strcmp(value,'on') || strcmp(value,'off'))
        error('value must be either on or off');
    end
    childHandles = findall(panelHandle,'-property', 'enable');
    for i = 1:numel(childHandles) 
        child = childHandles(i);
        childType = get(child,'Type');
        if strcmpi(childType,'uipanel')
            setUiPanelEnable(child,value)
        else
            set(child,'enable',value);
        end

    end
end


function found = checkForParaCompToolbox()
    verInfo = ver();
    found = false;
    for i =1:length(verInfo)
        if strcmpi('Parallel Computing Toolbox', verInfo(i).Name)
            found = true;
        end
    end
end


function userDir = getUserHomeDir()
    if ispc 
        userDir= getenv('USERPROFILE'); 
    else 
        userDir= getenv('HOME'); 
    end
end


function startPath = getStartPathForUiGetDir(currPath) 
    if exist(currPath,'dir')
        startPath = currPath;
    else
        % if current path doesn't exist - try and get directory 
        % in users home directory otherwise use users home directory.
        homeDir = getUserHomeDir();
        homeDirItems = dir(homeDir);
        startPath = homeDir;
        for i=1:numel(homeDirItems)
            item  = homeDirItems(i);
            if strcmp(item.name,'.') ||strcmp(item.name,'..')
                continue;
            end
            if item.isdir
                startPath = [startPath,filesep,item.name];
                break;
            end
        end
    end
end



