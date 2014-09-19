classdef GenderClassifierPlugin < handle

    properties (Constant) 

        fileNameBase = 'gendercls';
        paramFieldNames = {  ...
            'padBorder',     ...
            'method',        ...
            'nlearn',        ...
            'learners',      ...
        };

    end  % properties (Constant)


    methods

        function [ok,errMsg] = checkParam(self,param)
            % Current just makes sure that all the expected parameters are present
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


        function run(self,param,inputFileName,outpuFileName)
        end


    end  % methods 

end  % classdef GenderClassifierPlugin
