classdef DemoClassifierPlugin < handle

% Demo class for user defining user classifier plugings
   
    properties (Constant) 

        fileNameBase = 'democls';
        paramFieldNames = {  ...
            'dummyField1',   ...
            'dummyField2',   ...
            'dummyField3',   ...
            'dummyField4',   ...
            'dummyField5',   ...
        };

    end  % properties (Constant)


    methods

        function self = DemoClassifierPlugin()
            fprintf('demo classifier plugin: running constructor\n');
        end

        
        function [ok,errMsg] = checkParam(self,param)
            fprintf('demo classifier plugin: checkParam\n');
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
            fprintf('demo classifier plugin: run\n')
            fprintf('  param\n');
            paramFieldNames = fieldnames(param);
            for i = 1:numel(paramFieldNames)
                fieldName = paramFieldNames{i};
                fieldValue = param.(fieldName);
                fprintf('    %s %f\n',fieldName,fieldValue);
            end
            fprintf('  inputFileName:  %s\n', inputFileName);
            fprintf('  outputFileName: %s\n', outputFileName);
        end


    end  % methods 

end  % classdef DemoClassifierPlugin
