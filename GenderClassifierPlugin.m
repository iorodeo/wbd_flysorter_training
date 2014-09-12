classdef GenderClassifierPlugin < handle

    properties (Constant) 

        fileNameBase = 'gendercls';
        paramFieldNames = {  ...
            'dummyField1',   ...
            'dummyField2',   ...
            'dummyField3',   ...
            'dummyField4',   ...
            'dummyField5',   ...
        };

    end  % properties (Constant)


    methods

        function self = GenderClassifierPlugin()
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


        function run(self,param,inputFileName,outpuFileName)
        end


    end  % methods 

end  % classdef GenderClassifierPlugin