function [cropim,hogdata,hogdata_flipud,hogdata_fliplr,hogdata_flipudlr] = LoadHOGData(datafiles,filestoload)

cropim = [];
hogdata = [];
hogdata_flipud = [];
hogdata_fliplr = [];
hogdata_flipudlr = [];

if nargin < 2,
  filestoload = {'cropim','hogdata','hogdata_flipud','hogdata_fliplr','hogdata_flipudlr'};
end

if isfield(datafiles,'cropim') && ismember('cropim',filestoload),
  fprintf('%s\n',datafiles.cropim)
  cropim = imread(datafiles.cropim);
end

if isfield(datafiles,'hogdata') && ismember('hogdata',filestoload),
  hogdata = LoadCSVMat(datafiles.hogdata);
end

if isfield(datafiles,'hogdata_flipud') && ismember('hogdata_flipud',filestoload),
  hogdata_flipud = LoadCSVMat(datafiles.hogdata_flipud);
end

if isfield(datafiles,'hogdata_fliplr') && ismember('hogdata_fliplr',filestoload),
  hogdata_fliplr = LoadCSVMat(datafiles.hogdata_fliplr);
end

if isfield(datafiles,'hogdata_flipudlr') && ismember('hogdata_flipudlr',filestoload),
  hogdata_flipudlr = LoadCSVMat(datafiles.hogdata_flipudlr);
end
