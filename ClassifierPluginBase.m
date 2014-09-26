classdef ClassifierPluginBase < handle

    properties
        dirStrToLabelMap = containers.Map('KeyType','char','ValueType','char');
    end

    methods

        function self = ClassifierPluginBase()
            dirStrToLabelMap = containers.Map(self.dirStr,self.labels);
        end

        function run(self,param,inputFileName,outputFileName)
            allowedLabels = self.labels;
            runUserClassifierTraining(param,allowedLabels, orientDataFileName, outputFileName);
        end

    end

end
