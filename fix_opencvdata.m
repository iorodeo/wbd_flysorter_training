function fix_opencvdata
load opencvdata_full
for i=1:numel(opencvdata)
    if strcmp(opencvdata(i).sex, 'female')
        opencvdata(i).sex = 'F';
    end
    if strcmp(opencvdata(i).sex, 'male')
        opencvdata(i).sex = 'M';
    end
end
save('opencvdata_fixed.mat', 'opencvdata')
