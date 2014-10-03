classdef CurlyClassifierPlugin < ClassifierPluginBase 

    properties (Constant) 

        name = 'curly';
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
