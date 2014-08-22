classdef UserClassifierBase < handle

    properties (Constant) 

        fileNameBase = 'usrcls';
        paramFieldNames = {  ...
            'dummyField1',   ...
            'dummyField2',   ...
            'dummyField3',   ...
            'dummyField4',   ...
            'dummyField5',   ...
        };

    end  % properties (Constant)


    methods

        
        function [ok,errMsg] = checkParam(self,param)
            ok = true;
            errMsg = '';
            for i =1:numel(self.paramFieldNames)
                fieldName = self.paramfieldNames{i};
                if ~isfield(param, fieldName)
                    ok = false;
                    errMsg = sprintf('missing field %s',fieldName);
                end
            end
        end


        function run(self,param,inputFileName,outpuFileName)
        end


    end  % methods 

end  % classdef UserClassifierBase
