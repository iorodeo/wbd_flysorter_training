classdef FlySorterTrainingImpl < handle


    properties (Constant)
        rcDir = '.flysorter_training_rc';
        savedStateFileName = 'flysorter_state.mat';
        saveFieldNames = {             ... 
            'numMatlabpoolCores',      ...
            'jabbaPath',               ...
            };
    end


    properties

        figureHandle = [];
        machineNumCores = 0;

        haveMatlabpool = false;
        numMatlabpoolCores = [];

        haveJabbaPath = false;
        jabbaPath = [];

        haveTrainingData = false;
        havePreProcessingData = false;
        haveOrientationData = false;
        haveGenderData = false;

    end


    properties (Dependent)
        handles;
        rcDirFullPath;
        savedStateFullPath;
        jabbaMiscPath;
        jabbaFileHandlingPath;
    end


    methods 
        

        function self = FlySorterTrainingImpl(figureHandle)
            %warning off MATLAB:Uipanel:HiddenImplementation;
            self.figureHandle = figureHandle;

            self.haveMatlabpool= checkForParaCompToolbox();
            self.initNumberOfCoresPopup()

            self.checkForRcDir();
            self.loadStateFromRcDir();

            self.setAllUiPanelEnable('off')
            self.updateAllUiPanelEnable()

            self.setJabbaPathText();
        end


        function delete(self)
            self.saveStateToRcDir();
            self.rmJabbaFromMatlabPath();
        end


        function setPoolEnable(self)
            isChecked = get(self.handles.poolEnableCheckbox,'value');
            if isChecked
                disp('enable pool')
            else
                disp('disable pool');
            end
        end


        function setNumberOfPoolCores(self)
            disp('setNumberOfPoolCores');
        end


        function setJabbaPathWithGui(self)
            startDir = self.getJabbaPathGuiStartDir();
            jabbaDirName = uigetdir(startDir, 'Select path to JABBA installation');
            if jabbaDirName ~= false
                self.updateJabbaPath(jabbaDirName);
                self.updateAllUiPanelEnable()
            end
        end


        function selectTrainingData(self)
            disp('selectTrainingData');
        end


        function clearTraingingData(self)
            disp('clearTrainingData');
        end


        function clearPreProcessing(self)
            disp('clearPreProcessing');
        end


        function runPreProcessing(self)
            disp('runPreProcessing')
        end


        function clearOrientationTraining(self)
            disp('clearOrientationTraining');
        end


        function runOrientationTraining(self)
            disp('runOrientationTraining');
        end


        function clearGenderTraining(self)
            disp('clearGenderTraining')
        end


        function runGenderTraining(self)
            disp('runGenderTraining');
        end


        function generateClassifierFiles(self)
            disp('generateClassifierFiles');
        end


        function generateJsonConfigFiles(self)
            disp('generateJsonConfigFiles');
        end


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

    end



    methods (Access=private)

        function updateJabbaPath(self,newJabbaPath)
            if nargin < 2
                newJabbaPath = self.jabbaPath;
            end
            self.rmJabbaFromMatlabPath();
            self.jabbaPath = newJabbaPath;
            self.haveJabbaPath = true;
            self.checkJabbaPath();
            self.addJabbaToMatlabPath();
            self.setJabbaPathText();
        end


        function setJabbaPathText(self)
            textPosition = get(self.handles.jabbaPathText1,'position');
            textLength = textPosition(3);
            if self.jabbaPath
                if length(self.jabbaPath) <= textLength
                    jabbaPathStr1 = self.jabbaPath;
                    jabbaPathStr2 = '';
                else
                    jabbaPathStr1 = self.jabbaPath(1:textLength);
                    jabbaPathRem = self.jabbaPath(textLength+1:end);
                    if length(jabbaPathRem) <= textLength
                        jabbaPathStr2 = jabbaPathRem;
                    else
                        jabbaPathStr2 = jabbaPathRem(1:textLength);
                    end
                end
            else
                jabbaPathStr1 = 'not set';
                jabbaPathStr2 = '';
            end
            set(self.handles.jabbaPathText1,'string', jabbaPathStr1);
            set(self.handles.jabbaPathText2,'string', jabbaPathStr2);
        end

        
        function updateAllUiPanelEnable(self)
            self.enableUiPanelOnTest(self.handles.matlabpoolPanel, self.haveMatlabpool);
            self.enableUiPanelOnTest(self.handles.jabbaPathPanel, true);
            self.enableUiPanelOnTest(self.handles.trainingDataPanel, self.haveJabbaPath);
            self.enableUiPanelOnTest(self.handles.preProcessingPanel, self.haveTrainingData);
            self.enableUiPanelOnTest(self.handles.orientationTrainingPanel, self.havePreProcessingData);
            self.enableUiPanelOnTest(self.handles.genderTrainingPanel, self.haveOrientationData);
            self.enableUiPanelOnTest(self.handles.generateFlySorterFilesPanel, self.haveGenderData);
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

                if self.jabbaPath
                    self.updateJabbaPath();
                else
                    self.haveJabbaPath = false;
                end


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


        function startDir = getJabbaPathGuiStartDir(self)
            if exist(self.jabbaPath,'dir')
                % Use current Jabba path if it exists
                startDir = self.jabbaPath;
            else
                % The current Jabba path doesn't exist - try and get directory 
                % in users home directory otherwise use users home directory.
                homeDir = getUserHomeDir();
                homeDirItems = dir(homeDir);
                startDir = homeDir;
                for i=1:numel(homeDirItems)
                    item  = homeDirItems(i);
                    if strcmp(item.name,'.') ||strcmp(item.name,'..')
                        continue;
                    end
                    if item.isdir
                        startDir = [startDir,filesep,item.name];
                        break;
                    end
                end
            end
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
                    h = errordlg(errorMsg, 'JABBA Path Error', 'modal');
                    uiwait(h);
                    self.jabbaPath = [];
                    self.haveJabbaPath = false;

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
                rmpath(self.jabbaMiscPath);
                rmpath(self.jabbaFileHandlingPath);
            end
        end




    end

end


% Utility Functions
% -----------------------------------------------------------------------------

function setUiPanelEnable(panelHandle,value)
    if ~( strcmp(value,'on') || strcmp(value,'off'))
        error('value must be either on or off');
    end
    childHandles = findall(panelHandle,'-property', 'enable');
    set(childHandles,'enable',value);
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




