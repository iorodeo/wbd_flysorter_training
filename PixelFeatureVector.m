function [X,featurenames] = PixelFeatureVector(im,varargin)

BODYIDX = 1;
if ~isempty(varargin) && ~ischar(varargin{1}),
  warning('segim no longer used in PixelFeatureVector');
  varargin = varargin(2:end);
end

edges_col = [
  0           0           0
  0.2510943   0.3135227   0.4994996
  0.2709672   0.3162611   0.5043570
  0.2850360   0.3181373   0.5068931
  0.2927038   0.3213659   0.5119556
  0.3014454   0.3250251   0.5217634
  0.3122305   0.3280643   0.5441338
  0.3233073   0.3335537   0.5617753
  0.3317617   0.3394488   0.5740660
  0.3351096   0.3517826   0.5846382
  2           2           2
  ];
edges_gradmag = [
  0 
  0.0999999493360519 
  0.447888605296612 
  0.717480659484863 
  1.08998268842697 
  100
  ];
centers_grador = [
  0.523598775598299 
  1.5707963267949 
  2.61799387799149
  ];



[fillvalue,nbins_loc,edges_col,edges_gradmag,centers_grador,isluv] = ...
  myparse(varargin,'fillvalue',[],...
  'nbins_loc',[ 1, 5; 3, 5; 3, 1 ],...
  'edges_col',edges_col,...
  'edges_gradmag',edges_gradmag,...
  'centers_grador',centers_grador,...
  'isluv',false);

if isempty(fillvalue),
  if isluv,
    fillvalue = luvfill;
  else
    fillvalue = 255;
  end
end

dooutputnames = nargout > 1;

sz = size(im);
npx = sz(1)*sz(2);
nbins_col = size(edges_col,1)-1;
nbins_gradmag = numel(edges_gradmag)-1;
nbins_grador = numel(centers_grador);
% gradient parameters
normRad = 5; % normalization radius for gradient
normConst = .005; % normalization constant for gradient

if numel(fillvalue) == 1,
  missingdata = all(im==fillvalue,3);
else
  missingdata = all(bsxfun(@eq,im,reshape(fillvalue,[1,1,3])),3);
end
missingdata_grad = imdilate(missingdata,strel('disk',2));

% % gradient histogram parameters
% binSize = 1; % spatial bin size (if > 1 chns will be smaller)
% nOrients = 6; % number of orientation channels
% softBin = 0; % if true use "soft" bilinear spatial binning
% useHog = 0; % if true perform 4-way hog normalization/clipping
% clipHog = .2; % value at which to clip hog histogram bins
%sigma = [.5,1.5,2.5,5,10];

if isluv,
  imluv = im;
else
  imluv = rgbConvert(im,'luv');
end
nchannels = size(im,3);

M = zeros(sz,'single');
O = zeros(sz,'single');
for i = 1:nchannels,
  [M(:,:,i),O(:,:,i)] = gradientMag( imluv(:,:,i), 0, normRad, normConst );
end
M = reshape(M,[npx,nchannels]);
M(missingdata_grad,:) = nan;
M = reshape(M,sz);
[m,idx] = max(M,[],3);
O = reshape(O,[npx,nchannels]);
O(missingdata_grad,:) = nan;
o = reshape(O(sub2ind([npx,nchannels],1:npx,idx(:)')),sz(1:2));
imluv = reshape(imluv,[npx,nchannels]);
imluv(missingdata,:) = nan;
imluv = reshape(imluv,sz);

% take average and histogram
meanm = [];
meancolor = [];
histcolor = [];
histmag = [];
histor = [];

if dooutputnames,
  featurenames_meanm = {};
  featurenames_meancolor = {};
  featurenames_histcolor = {};
  featurenames_histmag = {};
  featurenames_histor = {};
end


for i = 1:size(nbins_loc,1),
  nbinsx = nbins_loc(i,1);
  nbinsy = nbins_loc(i,2);
  x1s = round(linspace(1,sz(2)+1,nbinsx+1));
  y1s = round(linspace(1,sz(1)+1,nbinsy+1));
  for binx = 1:nbinsx,
    for biny = 1:nbinsy,
      
      % gradient mag
      tmp = m(y1s(biny):y1s(biny+1)-1,x1s(binx):x1s(binx+1)-1);
      meanm(end+1) = nanmean(tmp(:)); %#ok<AGROW>
      if dooutputnames,
        featurenames_meanm{end+1} = sprintf('gradientmag_mean_s%d_x%d_y%d',i,binx,biny); %#ok<AGROW>
      end

      counts = histc(tmp(:),edges_gradmag);
      frac = counts(1:end-1)/sum(counts(1:end-1));
      histmag(end+1:end+nbins_gradmag) = frac;
      if dooutputnames,
        for tmpi = 1:numel(edges_gradmag)-1,
          featurenames_histmag{end+1} = sprintf('gradientmag_hist_s%d_x%d_y%d_v%d',i,binx,biny,tmpi); %#ok<AGROW>
        end
      end


      % gradient orientation
      tmpo = o(y1s(biny):y1s(biny+1)-1,x1s(binx):x1s(binx+1)-1);
      counts = myhist(tmpo(:),centers_grador,'weights',tmp(:));
      frac = counts/sum(counts);
      histor(end+1:end+nbins_grador) = frac;
      if dooutputnames,
        for tmpi = 1:numel(centers_grador),
          featurenames_histor{end+1} = sprintf('gradientor_hist_s%d_x%d_y%d_v%d',i,binx,biny,tmpi); %#ok<AGROW>
        end
      end
      
      % color
      tmp = imluv(y1s(biny):y1s(biny+1)-1,x1s(binx):x1s(binx+1)-1,:);
      sztmp = size(tmp);
      tmp = reshape(tmp,[sztmp(1)*sztmp(2),sztmp(3)]);
      meancolor(end+1:end+nchannels) = nanmean(tmp,1);
      if dooutputnames,
        for tmpi = 1:nchannels,
          featurenames_meancolor{end+1} = sprintf('color_mean_s%d_x%d_y%d_c%d',i,binx,biny,tmpi); %#ok<AGROW>
        end
      end
      
      for j = 1:nchannels,
        counts = histc(tmp(:,j),edges_col(:,j));
        counts = counts(1:end-1);
        frac = counts / sum(counts);
        histcolor(end+1:end+nbins_col) = frac;
      end
      if dooutputnames,
        for j = 1:nchannels,
          for tmpi = 1:nbins_col,
            featurenames_histcolor{end+1} = sprintf('color_hist_s%d_x%d_y%d_c%d_v%d',i,binx,biny,j,tmpi); %#ok<AGROW>
          end
        end
      end
      
%       % body width
%       tmp = segim(y1s(biny):y1s(biny+1)-1,x1s(binx):x1s(binx+1)-1,BODYIDX);
%       sztmp = size(tmp);
%       if numel(sztmp) < 3,
%         sztmp(3) = 1;
%       end
%       tmp = reshape(tmp,[sztmp(1)*sztmp(2),sztmp(3)]);
%       meancolor(end+1:end+sztmp(3)) = nanmean(tmp,1);      
%       if dooutputnames,
%         for tmpi = 1:sztmp(3),
%           featurenames_meancolor{end+1} = sprintf('seg_mean_s%d_x%d_y%d_c%d',i,binx,biny,tmpi); %#ok<AGROW>
%         end
%       end
      
    end
  end
end

X = [
  meanm(:)
  meancolor(:)
  histcolor(:)
  histmag(:)
  histor(:)
  ];

if dooutputnames,
  featurenames = [
    featurenames_meanm(:)
    featurenames_meancolor(:)
    featurenames_histcolor(:)
    featurenames_histmag(:)
    featurenames_histor(:)];
end


% hog


% 
% X = imluv;
% X = cat(3,X,m,o);
% 
% for i = 1:numel(sigma),
%   fil = fspecial('gaussian',ceil(sigma(i)*3),sigma(i));
%   X = cat(3,X,imfilter(imluv,fil,'replicate','same'));
%   X = cat(3,X,max(imfilter(M,fil,0,'same'),[],3));
% end

% mm = m;
% mm(isnan(m)) = 0;
% oo = o;
% oo(isnan(o)) = 0;
% oquant = gradientHist( mm,oo,1,2,0,0);
