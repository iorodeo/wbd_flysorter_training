classdef GenderClassifierPlugin < handle

    properties (Constant) 

        fileNameBase = 'gendercls';
        paramFieldNames = {  ...
            'padBorder',     ...
            'method',        ...
            'nlearn',        ...
            'learners',      ...
        };

        labels = {'F','M'};
        dirStr = {'female', 'male'};
        dirStrToLabelMap = containers.Map(  ...
            GenderClassifierPlugin.dirStr,  ...
            GenderClassifierPlugin.labels   ...
            );
    end  



    methods


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
            runGenderTraining(param, inputFileName, outputFileName);
        end

    end  

end  
