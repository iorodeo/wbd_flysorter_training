function [processeddebugdata,debugdata] = readDebugData(filename,debugimdir)

fid = fopen(filename,'r');
debugdata = [];
processeddebugdata = [];
isdebugimdir = nargin >= 2;


while true,
  
  s = fgetl(fid);
  if ~ischar(s),
    break;
  end
  if isempty(s),
    continue;
  end
  
  m = regexp(s,'^Frame: (\d+), count: (\d+)$','tokens','once');

  if isempty(m),
    s = fgetl(fid);
    debugdata = ReadDebugDataHelper(fid,0);
    break;
  end

  frame = str2double(m{1});
  count = str2double(m{2});

  % skip next line
  s = fgetl(fid);
  tmp = ReadDebugDataHelper(fid,0);
  if isempty(tmp) || isempty(fieldnames(tmp)),
    continue;
  end
  tmp.frame = frame;
  tmp.count = count;
  if isdebugimdir,
    imfile = fullfile(debugimdir,sprintf('bnd_frm_%d_cnt_%d.bmp',frame,count));
    if exist(imfile,'file'),
      tmp.im = imread(imfile);
    end
  end
    
  debugdata = structappend(debugdata,tmp);
      
end

fclose(fid);

for i = 1:numel(debugdata),
  
  tmp = debugdata(i);
  
  if isfield(tmp,'predictorData'),
    if isstruct(tmp.predictorData),
      tmp.label = tmp.predictorData.label;
      tmp.fit = tmp.predictorData.fit;
      tmp.PositionData = tmp.predictorData.PositionData;
    else
      tmp.label = nan;
      tmp.fit = nan;
    end
    tmp = rmfield(tmp,'predictorData');
  end
  
  if isfield(tmp,'PositionData'),
    if isstruct(tmp.PositionData),
      fns = fieldnames(tmp.PositionData);
      for j = 1:numel(fns),
        fn = fns{j};
        tmp.(['pos_',fn]) = tmp.PositionData.(fn);
      end
    end
    tmp = rmfield(tmp,'PositionData');
  end
  
  if isfield(tmp,'SegmentData'),
    if isstruct(tmp.SegmentData) && isfield(tmp.SegmentData,'blobData'),
      fns = fieldnames(tmp.SegmentData.blobData);
      for j = 1:numel(fns),
        fn = fns{j};
        tmp.(['blob_',fn]) = tmp.SegmentData.blobData.(fn);
      end
    end
    tmp = rmfield(tmp,'SegmentData');
  end
  
  processeddebugdata = structappend(processeddebugdata,tmp);
  
end

function debugdata = ReadDebugDataHelper(fid,nindentprev)

debugdata = [];

while true,

  pos = ftell(fid);
  s = fgetl(fid);
  if ~ischar(s),
    break;
  end
  if isempty(s),
    continue;
  end

  m = regexp(s,'^Frame: (\d+), count: (\d+)$','once');
  if ~isempty(m),
    fseek(fid,pos,'bof');
    break;
  end    
  
  m = regexp(s,'^(\s+)(\w+):\s*((\S.*)?)$','once','tokens');
  if isempty(m),
    %warning('Could not parse %s, skipping',s);
    continue;
  end
  
  nindentcurr = numel(m{1});
  var = m{2};
  val = m{3};
  
  if isempty(debugdata),
    debugdata = struct;
  end
  
  if isempty(val),
    %fprintf('Calling reader for %s\n',var);
    tmp = ReadDebugDataHelper(fid,nindentcurr);
    if isempty(tmp) || isempty(fieldnames(tmp)),
      %warning('Read nothing with helper');
      continue;
    end
    debugdata.(var) = tmp;
  elseif nindentcurr <= nindentprev,
    fseek(fid,pos,'bof');
    break;
  else
    %fprintf('%s = %s\n',var,val);
    valnum = str2double(val);
    if ~isnan(valnum),
      debugdata.(var) = valnum;
    else
      debugdata.(var) = val;
    end
  end
end
