function resultim = ShowAlignedFliesFile(opencvdata,gtposdata)

cropims = cell(1,numel(opencvdata));
hpx = 0; wpx = 0;
minv = inf;
maxv = -inf;
for i = 1:numel(opencvdata),
  cropim = LoadHOGData(opencvdata(i),{'cropim'});
  cropims{i} = cropim(:,:,3);
  if gtposdata(i).doflip,
    cropims{i} = flipud(cropims{i});
  end
  hpx = hpx + size(cropims{i},1);
  wpx = wpx + size(cropims{i},2);
  minv = min(minv,prctile(cropims{i}(:),1));
  maxv = max(maxv,prctile(cropims{i}(:),99));
end
hpx = round(hpx / numel(opencvdata));
wpx = round(wpx / numel(opencvdata));
minv = double(minv);
maxv = double(maxv);

n = numel(opencvdata);

ncax = ceil(sqrt(n)*sqrt(hpx/wpx));
nrax = ceil(n/ncax);

nrpx = 1+nrax*hpx;
ncpx = 1+ncax*wpx;

offc = 0;
offr = 0;
resultim = repmat(uint8(255),[nrpx,ncpx]);
for i = 1:n,

  imraw = uint8(max(0,min(255,round(255*(double(cropims{i})-minv)/(maxv-minv)))));
  imraw_scale = imresize(imraw,[hpx,size(imraw,2)*hpx/size(imraw,1)],'bilinear');
  
  wcurr = size(imraw_scale,2);
  if offc+wcurr > ncpx,
    offr = offr + hpx;
    offc = 0;
    
    if offr+hpx > nrpx,
      resultim(offr+1:offr+hpx,:,:) = 255;
    end
    
  end
  
  resultim(offr+1:offr+hpx,offc+1:offc+wcurr,:) = imraw_scale;
  offc = offc+wcurr;
    
end

resultim = resultim(1:offr+hpx,:,:);