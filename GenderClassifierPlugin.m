classdef GenderClassifierPlugin < ClassifierPluginBase

    properties (Constant) 

        name = 'gender';
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
