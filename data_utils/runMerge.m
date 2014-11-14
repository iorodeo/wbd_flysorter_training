function runMerge

%dirCell = {'tubby_training_data_raw'};
%labCell = {'T'};

dirCell = {
    ['dataset_2', filesep, 'tubby_training_data_raw'], 
    ['dataset_2', filesep, 'normal_training_data_raw']
    };
labCell = {'T', 'N'};

outputDir = ['dataset_2', filesep, 'merged_data'];
classifierName = 'tubby';

mergeDataSets(dirCell,labCell,outputDir,classifierName);

end
