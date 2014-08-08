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
            'trainingDataDateNumber',  ...
            'filePrefix',              ...
            'orientationHintFile',     ...
            'fileNameDateNumber',          ... 
            };

        % Output file base names
        preProcessingFileNameBase  = 'prepro';
        orientationFileNameBase    = 'orient';
        userClassifierFileNameBase = 'usrcls';

        editTextLengthSub = 14; % For setting text length in multi-line textboxes
        outFileTextLabel = 'Output File:';
        orientationHintTextLabel = 'Hint File:';
        
    end


    properties

        haveRcDir = true;
        figureHandle = [];
        machineNumCores = 0;
        numMatlabpoolCores = 0;
        jabbaPath = [];
        workingDir = [];
        trainingDataDirs = {};  
        trainingDataDateNumber = [];
        orientationHintFile = [];
        fileNameDateNumber = [];

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
        isOrientationHintFileChecked;

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

        filePrefix;
        preProcessingFileFullPath;
        orientationFileFullPath;
        userClassifierFileFullPath;

        fileNameDateTimeStr;
        trainingDataDateTimeStr;
        preProcessingDateTimeStr;


    end



    % -----------------------------------------------------------------------------------
    methods 
        

        function self = FlySorterTrainingImpl(figureHandle)
            self.figureHandle = figureHandle;
            self.initNumberOfCoresPopup()
            self.loadStateFromRcDir();
            self.updateUi();
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
                self.jabbaPath = jabbaPathTemp;
                self.updateUi();
            end
        end


        function setWorkingDirWithGui(self)
            startPath = getStartPathForUiGetDir(self.workingDir);
            workingDirTemp = uigetdir(startPath, 'Select path to working directory');
            if workingDirTemp ~= false
                self.workingDir = workingDirTemp;
                self.updateUi();
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
                trainingDataDirs = tempDirs(cellfun(@isdir,tempDirs)); 
                if ~isequal(trainingDataDirs, self.trainingDataDirs)
                    self.trainingDataDirs = trainingDataDirs;
                    self.trainingDataDateNumber = now();
                end
                self.updateUi();
            end
        end


        function clearTraingingData(self)
            question = 'Clear all training data selections?';
            dlgTitle = 'Clear Training Data';
            rsp = questdlg(question, dlgTitle, 'Yes', 'No', 'No');
            if strcmpi(rsp,'Yes')
                self.trainingDataDirs = {};
                self.trainingDataDateNumber = [];
                self.updateUi();
            end
        end


        function runPreProcessing(self)
            self.setAllUiPanelEnable('off')
            self.updateStatusBarText('Running Pre-Processing');
            drawnow;
            % need somethine here to make changes take effect ....
            processTrainingData(self.trainingDataDirs,self.preProcessingFileFullPath);
            self.updateUi();
        end


        function clearPreProcessing(self)
            question = sprintf('Delete existing pre-procesed data set %s',self.preProcessingFileName);
            dlgTitle = 'Clear Pre-Processed Data';
            rsp = questdlg(question, dlgTitle , 'Yes', 'No', 'No');
            if strcmpi(rsp,'Yes')
                delete(self.preProcessingFileFullPath);
                self.updateUi();
            end

        end


        function setOrientationHintFileWithGui(self)
            disp('setOrientationHintFileWithGui');
            self.isOrientationHintFileChecked
        end


        function setOrientationParamFileWithGui(self)
            disp('setOrientationParamFileWithGui')
        end


        function runOrientationTraining(self)
            disp('runOrientationTraining');
            self.setAllUiPanelEnable('off')
            % need somethine here to make changes take effect ....
            runOrientationTraining(self.preProcessingFileFullPath, self.orientationFileFullPath);
            self.updateUi();
        end


        function clearOrientationTraining(self)
            disp('clearOrientationTraining');
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


        function setDatetimeToNow(self)
            self.fileNameDateNumber = now();
            self.updateUi();
        end


        function setDatetimeWithGui(self)
            fileNameDateNumber = uigetdate(self.fileNameDateNumber);
            if ~isempty(fileNameDateNumber)
                self.fileNameDateNumber = fileNameDateNumber;
            end
        end


        function onOutputFileNameChange(self)
            self.updateUi();
        end

        % Setter/Getter methods
        % ---------------------------------------------------------------------

        function set.jabbaPath(self,value)
            self.rmJabbaFromMatlabPath();
            if self.checkJabbaPath(value)
                self.jabbaPath = value;
                self.addJabbaToMatlabPath();
            end
        end


        function set.workingDir(self,value)
            if self.checkWorkingDir(value);
                self.workingDir = value;
            else
                self.workingDir = [];
            end
        end

    
        % Setter/Getter methods for dependent properties
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
                jabbaMiscPath = getMiscPath(self.jabbaPath);
            else
                jabbaMiscPath = [];
            end
        end


        function jabbaFileHandlingPath = get.jabbaFileHandlingPath(self)
            if self.jabbaPath
                jabbaFileHandlingPath = getFileHandlingPath(self.jabbaPath);
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

        function isOrientationHintFileChecked = get.isOrientationHintFileChecked(self)
            isOrientationHintFileChecked = get(self.handles.orientationHintCheckbox,'Value');
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
            % --------------------------------------------------------------
            % NOT DONE  - might want a firmer check than just file existence 
            % --------------------------------------------------------------
            if exist(self.preProcessingFileFullPath)
                havePreProcessingData = true;
            else
                havePreProcessingData = false;
            end
        end


        function haveOrientationData = get.haveOrientationData(self)
            % --------------------------------------------------------------
            % NOT DONE  - might want a firmer check than just file existence 
            % --------------------------------------------------------------
            haveOrientationData = false;
            if exist(self.haveOrientationFileFullPath)
                haveOrientationData = true;
            else
                haveOrientationData = false;
            end
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


        function fileNameDateTimeStr = get.fileNameDateTimeStr(self) 
            fileNameDateTimeStr = self.getDateTimeStrForFileName(self.fileNameDateNumber);
        end


        function trainingDataDateTimeStr = get.trainingDataDateTimeStr(self)
            trainingDataDateTimeStr = self.getDateTimeStrForGui(self.trainingDataDateNumber);
        end


        function preProcessingDateTimeStr = get.preProcessingDateTimeStr(self)
            modDateNumber = getFileModDateNumber(self.preProcessingFileFullPath);
            preProcessingDateTimeStr = self.getDateTimeStrForGui(modDateNumber);
        end


    end


    % -------------------------------------------------------------------------
    methods (Access=protected)

        function updateUi(self)
            self.updateAllUiPanelEnable()
            self.updateUiText();

            % Temporary
            % -----------------------------------------------------
            set(self.handles.autoIncrementCheckbox,'Enable','off');
            % -----------------------------------------------------
        end


        function updateAllUiPanelEnable(self)
            if ~self.haveRcDir
                return;
            end
            % Configuration Panel
            self.enableUiPanelOnTest(self.handles.configurationPanel,true);
            self.enableUiPanelOnTest(self.handles.matlabpoolPanel, self.haveMatlabpool);
            self.enableUiPanelOnTest(self.handles.jabbaPathPanel, true);
            self.enableUiPanelOnTest(self.handles.outputFilesPanel, true);

            % Training Panel
            enableTest = self.haveWorkingDir & self.haveJabbaPath;
            self.enableUiPanelOnTest(self.handles.trainingPanel,enableTest);

            %  - Select data subpanel
            enableTest = enableTest & self.haveJabbaPath & self.haveWorkingDir;
            self.enableUiPanelOnTest(self.handles.selectDataPanel,enableTest);

            %  - Preprocessing subpanel
            enableTest = enableTest & self.haveTrainingData;
            self.enableUiPanelOnTest(self.handles.preProcessingPanel, enableTest);

            %  - Orientation subpanel
            enableTest = enableTest & self.havePreProcessingData;
            self.enableUiPanelOnTest(self.handles.orientationPanel, enableTest);

            %  - User Classifier subpanel
            self.enableUiPanelOnTest(self.handles.userClassifierPanel, false);

            %  - Generate Flysorter Files subpanel
            self.enableUiPanelOnTest(self.handles.generateFlySorterFilesPanel, false);
        end


        function updateUiText(self)

            % JABBA path panel
            self.setMultiLineEditText(self.handles.jabbaPathEditText, self.jabbaPath);

            % Working dir panel
            self.setMultiLineEditText(self.handles.workingDirEditText, self.workingDir);
            set(self.handles.dateTimeText, 'String', self.fileNameDateTimeStr);

            % Select data panel
            set(self.handles.selectDataDateTimeText,'String', self.trainingDataDateTimeStr);


            % Preprocessing panel
            preProcessingFileNameText = self.getOutputFileText(self.preProcessingFileName);
            set(self.handles.preProcessingOutFileText,'String',self.preProcessingFileName);
            set(self.handles.preProcessingDateTimeText, 'String', self.preProcessingDateTimeStr);

            % Orientation training panel
            hintFileText = self.getHintFileText();
            set(self.handles.orientationHintText,'String', hintFileText);

            orientationFileNameText = self.getOutputFileText(self.orientationFileName);
            set(self.handles.orientationOutFileText, 'String', self.orientationFileName);

            % User classifier training panel
            userClassifierFileText = self.getOutputFileText(self.userClassifierFileName);
            set(self.handles.userClassifierOutFileText,'String',userClassifierFileText);


            self.updateStatusBarText();
        end


        function updateStatusBarText(self,statusBarMsg)
            if nargin < 2
                if ~self.haveJabbaPath & ~self.haveWorkingDir
                   statusBarMsg = 'Set JABBA Path and Working Directory';
                elseif ~self.haveJabbaPath
                    statusBarMsg = 'Set JABBA Path';
                elseif ~self.haveWorkingDir
                    statusBarMsg = 'Set Working Directory';
                elseif ~self.haveTrainingData
                    statusBarMsg = 'Select Training Data';
                else
                    statusBarMsg = 'Ready';
                end
            end
            set(self.handles.statusBarText,'String',statusBarMsg);
        end


        function outFileText = getOutputFileText(self,outFileName)
            outFileText = sprintf('%s %s',self.outFileTextLabel,outFileName);
        end



        % TO DO -- change to property
        % ------------------------------------------------------------------------------
        function hintFileText = getHintFileText(self)
            if ~isempty(self.orientationHintFile)
                fileNameText = self.orientationHintFile;
            else
                fileNameText = 'none';
            end
            hintFileText = sprintf('%s %s', self.orientationHintTextLabel, fileNameText);
        end
        % --------------------------------------------------------------------------------




        function nameWithWorkingDir = addWorkingDirToName(self,name)
            nameWithWorkingDir = [self.workingDir, filesep, name];
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


        function haveRcDir = checkForRcDir(self,showDlg)
            % Checks for existance of resources directory - creates if not found.
            if nargin < 2
                showDlg = true;
            end
            haveRcDir = true;
            if ~exist(self.rcDirFullPath,'dir')
                fprintf('%s does not exist creating\n', self.rcDirFullPath);
                [status, message, ~] = mkdir(getUserHomeDir(), self.rcDir);
                if ~status & showDlg
                    haveRcDir = false;
                    errorMsg = sprintf('unable to create rc directory %s', message);
                    h = errordlg(errorMsg, 'Rsesource Error', 'modal');
                    uiwait(h);
                end
            end
        end


        function loadStateFromRcDir(self)

            % Get saved state information from file in rc directory
            self.haveRcDir = self.checkForRcDir();
            if ~self.haveRcDir;
                return;
            end
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
            else
                fprintf('no saved state information - using default values\n');
            end

            % Set dateNumber to now if is empty
            if isempty(self.fileNameDateNumber)
                self.fileNameDateNumber = now();
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


        function jabbaPathOk = checkJabbaPath(self,jabbaPath,showDlg)
            if nargin < 3
                showDlg = true;
            end
            jabbaPathOk = true;
            if ~isempty(jabbaPath)
                errorMsg = '';
                if ~exist(jabbaPath,'dir')
                    jabbaPathOk = false;
                    errorMsg = sprintf('JABBA path does not exist - %s', jabbaPath);
                else
                    % Check for jabba subdirectories misc and filehandling 
                    jabbaMiscPath = getMiscPath(jabbaPath);
                    if ~exist(jabbaMiscPath,'dir')
                        jabbaPathOk = false;
                        errorMsg = 'JABBA sub-directory "misc" is missing';
                    end
                    jabbaFileHandlingPath = getFileHandlingPath(jabbaPath);
                    if ~exist(jabbaFileHandlingPath,'dir')
                        jabbaPathOk = false;
                        errorMsgTmp = 'JABBA sub-directgory "filehandling" is missing';
                        if isempty(errorMsg)
                            errorMsg = errorMsgTmp;
                        else
                            errorMsg = [errorMsg, ', ', errorMsgTmp];
                        end
                    end
                end 
                if ~jabbaPathOk  & showDlg
                    self.jabbaPath = [];
                    h = errordlg(errorMsg, 'JABBA Path Error', 'modal');
                    uiwait(h);
                end
            end
        end


        function ok = checkWorkingDir(self,workingDir,showDlg)
            if nargin < 3
                showDlg = true;
            end
            ok = true;
            if ~isempty(workingDir)
                if ~exist(workingDir)
                    ok = false;
                    if showDlg
                        errorMsg = sprintf('Working Directory, %s, does not exist!', workingDir);
                        h = warndlg(errorMsg, 'FlySorter Working Directory Warning', 'modal');
                        uiwait(h);
                    end
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
                if ~isempty(self.filePrefix)
                    fileName = sprintf('%s_%s',self.filePrefix,fileName);
                end
            end
            if self.isAddDatetimeChecked
                fileName = sprintf('%s_%s', fileName, self.fileNameDateTimeStr);
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


        function dateTimeStr = getDateTimeStrForGui(self,dateNumber)
            if isempty(dateNumber)
                dateTimeStr = '<empty>';
            else 
                dd = datestr(dateNumber,'dd');
                mm = datestr(dateNumber,'mm');
                yy = datestr(dateNumber,'yy');
                HH = datestr(dateNumber,'HH');
                MM = datestr(dateNumber,'MM');
                SS = datestr(dateNumber,'SS');
                dateTimeStr = sprintf('%s/%s/%s %s:%s:%s',dd,mm,yy,HH,MM,SS);
            end
        end


        function dateTimeStr = getDateTimeStrForFileName(self,dateNumber)
            dd = datestr(dateNumber,'dd');
            mm = datestr(dateNumber,'mm');
            yy = datestr(dateNumber,'yy');
            HH = datestr(dateNumber,'HH');
            MM = datestr(dateNumber,'MM');
            dateTimeStr = sprintf('date_%s-%s-%s_time_%s-%s',mm,dd,yy,HH,MM);
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
            disp('hello')
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


function newFilePath = appendToFilePath(filePath, item)
    newFilePath = [filePath,filesep,item];
end


function miscPath = getMiscPath(basePath)
    miscPath = appendToFilePath(basePath, 'misc');
end


function fileHandlingPath = getFileHandlingPath(basePath)
    fileHandlingPath = appendToFilePath(basePath,'filehandling');
end


function dateNumber = getFileModDateNumber(fileName) 
    dateNumber = [];
    if exist(fileName)
        fileData = dir(fileName);
        dateNumber = fileData.datenum;
    end
end
