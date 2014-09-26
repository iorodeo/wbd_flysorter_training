classdef CurlyClassifierPlugin < ClassifierPluginBase 

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


    end  

end   
