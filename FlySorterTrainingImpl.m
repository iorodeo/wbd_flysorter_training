classdef FlySorterTrainingImpl < handle

    properties

        figureHandle = [];
        numCores = 0;

        %haveMatlabPool = false;
        %haveJabbaPath = false;
        %haveTrainingData = false;
        %havePreprocessedData = false;
        %haveOrientationData = false;
        %haveGenderData = false;
    end

    properties (Dependent)
        handles;
    end


    methods 
        

        function self = FlySorterTrainingImpl(figureHandle)
            %warning off MATLAB:Uipanel:HiddenImplementation;
            self.figureHandle = figureHandle;
            self.initNumberOfCoresPopup()
            %self.setAllUiPanelEnable('off')
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
            disp('setJabbaPath')
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

    end


    methods (Access=private)

        
        function updateUiPanelEnable(self)
        end


        function setAllUiPanelEnable(self,value)
            figureChildren = get(self.figureHandle,'Children')
            for i = 1:length(figureChildren)
                child = figureChildren(i);
                childType = get(child,'Type');
                if strcmpi(childType,'uipanel')
                    setUiPanelEnable(child,value);
                end
            end
        end


        function initNumberOfCoresPopup(self)
            disp('initNumberOfCoresPopup');
            self.numCores = feature('numCores');
            numCoresCell = {};
            for i = 1:self.numCores
                numCoresCell{i} = num2str(i);
            end
            set(self.handles.numberOfCoresPopup, 'String', numCoresCell);
            set(self.handles.numberOfCoresPopup, 'Value', self.numCores);
        end


    end

end


% Utility Functions
% -----------------------------------------------------------------------------

% --- Sets enable ('on', 'off') for uipanel
function setUiPanelEnable(panelHandle,value)
    if ~( strcmp(value,'on') || strcmp(value,'off'))
        error('value must be either on or off');
    end
    childHandles = findall(panelHandle,'-property', 'enable');
    set(childHandles,'enable',value);
end




