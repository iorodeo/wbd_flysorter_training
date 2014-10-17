function stepThruData(directory, labelSelector, prompt)
% stepThruData.m - step through training data and examine images.
%
% directory       - training data  step through
% labelselector   - label to examine, '' for all labels
% prompt          - true/false for prompt ater each image 
%                   with matching selector. Note, if false 
%                   images will be saved to directories by label


if ~isempty(labelSelector)
    haveLabelSelector = true;
else
    haveLabelSelector = false;
end

if haveLabelSelector
    saveDir  = sprintf('%s%simages_label_%s', pwd, filesep, labelSelector);
else
    saveDir = sprintf('%s%simages_all_label', pwd, filesep);
end

if ~prompt
    if ~exist(saveDir)
        mkdir(saveDir);
    end
end

dataFile = sprintf('%s%scurlylabeleddebugdata.mat',directory,filesep);
fileLoad = load(dataFile);
dataArray = fileLoad.labeleddebugdata;

for i=1:numel(dataArray)
   dataItem = dataArray(i);
   imgNum = dataItem.frame*1000 + dataItem.count+1;
   fprintf('\n');
   fprintf('index:     %d\n', i);
   fprintf('frame:     %d\n', dataItem.frame);
   fprintf('count:     %d\n', dataItem.count);
   fprintf('label:     %s\n', dataItem.manuallabel);
   fprintf('imgNum:    %d\n', imgNum);

   if isempty(dataItem.manuallabel)
       fprintf('manuallabel is empty - skipping\n');
       continue;
   end
   if strcmp(dataItem.manuallabel, '?')
       fprintf('manuallabel == ? - skipping\n');
       continue;
   end
   if haveLabelSelector
       if ~strcmpi(dataItem.manuallabel,labelSelector)
           fprintf('manuallabel does not match selector - skipping\n');
           continue;
       end
   end

   imgFileHint = sprintf('%s%sdata_frame_%d*.png',directory,filesep,imgNum);
   dirStruct = dir(imgFileHint);

   if length(dirStruct) == 0
       fprintf('*** image file not found = skipping\n');
       continue;
   end

   if length(dirStruct) > 1
       fprintf('*** more than one image file found - skipping\n');
       continue;
   end

   imgFile = sprintf('%s%s%s',directory,filesep,dirStruct(1).name);
   img = imread(imgFile);
   img = img(:,:,3);
   minv = double(prctile(img(:),1));
   maxv = double(prctile(img(:),99));
   img = uint8(max(0, min(255,255*((double(img)-minv)/(maxv-minv)))));
   if dataItem.pos_flipped == 1
       img = flipud(img);
   end
   if prompt
       figh  = figure();
       imshow(img);
       rsp = input('next (q to quit): ', 's');
       try
           close(figh);
       end
       if strcmpi(rsp,'q')
           break;
       end
   else
       saveFile = sprintf('%s%sframe_%d.png',saveDir, filesep, imgNum);
       fprintf('saveFile:  %s\n',saveFile);
       imwrite(img, saveFile,'PNG');
   end

end



end
