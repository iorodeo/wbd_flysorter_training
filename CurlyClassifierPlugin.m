classdef CurlyClassifierPlugin < handle

    properties (Constant) 

        fileNameBase = 'curlycls';
        paramFieldNames = {  ...
            'padBorder',     ...
            'method',        ...
            'nlearn',        ...
            'learners',      ...
        };

        labels = {'N', 'C'};
        dirStr = {'normal', 'curly'};
        dirStrToLabelMap = containers.Map( ...
            CurlyClassifierPlugin.dirStr,  ...
            CurlyClassifierPlugin.labels   ...
            );

    end  

    methods

        function self = CurlyClassifierPlugin()
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
        end


    end  

end  
