classdef FlySorterTrainingImpl < handle

    properties (Constant)
        rcDir = '.flysorter_training_rc';
    end

    properties

        figureHandle = [];
        numCores = 0;

        haveMatlabpool = false;
        haveJabbaPath = false;
        haveTrainingData = false;
        havePreProcessingData = false;
        haveOrientationData = false;
        haveGenderData = false;
    end

    properties (Dependent)
        handles;
        rcDirFullPath;
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


        function setJabbaPath(self)
            startDir = getUserHomeDir();
            dirName = uigetdir(startDir, 'Select path to JABBA installation' )

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

    end


    methods (Access=private)

        
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
            self.numCores = feature('numCores');
            numCoresCell = {};
            for i = 1:self.numCores
                numCoresCell{i} = num2str(i);
            end
            set(self.handles.numberOfCoresPopup, 'String', numCoresCell);
            set(self.handles.numberOfCoresPopup, 'Value', self.numCores);
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
        end

        function saveStateToRcDir(self)
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




