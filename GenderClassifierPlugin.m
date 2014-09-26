classdef GenderClassifierPlugin < ClassifierPluginBase

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

    end  

end  
