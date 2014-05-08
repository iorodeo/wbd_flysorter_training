function res = LoadCSVMat(filename)

fid = fopen(filename,'r');
if fid < 1,
  error('Could not open file %s for reading',filename);
end

res = textscan(fid,'%f',1,'Delimiter',',','CollectOutput',true);
ndims = res{1}(1);
res = textscan(fid,'%f',ndims,'Delimiter',',','CollectOutput',true);
sz = res{1}(:)';
if ndims == 1,
  sz = [sz,1];
end

n = prod(sz);
res = textscan(fid,'%f',n,'Delimiter',',','CollectOutput',true);
res = reshape(res{1},sz);

fclose(fid);