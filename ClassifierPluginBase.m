classdef ClassifierPluginBase < handle

    properties
        dirStrToLabelMap = containers.Map('KeyType','char','ValueType','char');
    end


    properties (Dependent)
        fileNameBase;
    end


    methods

        function self = ClassifierPluginBase()
            dirStrToLabelMap = containers.Map(self.dirStr,self.labels);
        end

        function [ok,errMsg] = checkParam(self,param)
            ok = true;
            errMsg = '';
            for i =1:numel(self.paramFieldNames)
                fieldName = self.paramFieldNames{i};
                if ~isfield(param, fieldName)
                    ok = false;
                    errMsg = sprintf('missing field %s',fieldName);
                end
            end
        end

        function run(self,param,inputFileName,outputFileName)
            allowedLabels = self.labels;
            runUserClassifierTraining(param,allowedLabels,inputFileName,outputFileName);
        end

        function fileNameBase = get.fileNameBase(self)
            if isprop(self,'name')
                fileNameBase = sprintf('%scls',self.name);
            else
                fileNameBase = 'basecls';
            end
        end
    end

end
