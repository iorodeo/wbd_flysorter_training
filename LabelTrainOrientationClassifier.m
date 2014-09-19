function [fitparams,gtposdata,X,y,imis,featurenames] = ...
  LabelTrainOrientationClassifier(imfiles,segfiles,fitparams,varargin)

nperpage = [200,200,inf];
maxnshow = 500;

[nperpage,fromfile,datafiles,maxnshow] = myparse( ...
    varargin,                                     ...
    'nperpage',    nperpage,                      ...
    'fromfile',    false,                         ...  
    'datafiles',   {},                            ...
    'maxnshow',    maxnshow                       ...
    );


%[v,order] =

gtposdata = [];
isfirst = true;
starti = 1;
% for starti = 1:nperpage:numel(segfiles),
nperpagei = 1;

if fromfile,
  ndata = numel(datafiles);
else
  ndata = numel(segfiles);
end

while true,
  
  if starti > ndata,
    break;
  end
  
  endi = min(ndata,starti+nperpage(nperpagei)-1);
  ncurr = endi-starti+1;
  posdatacurr = [];
  fprintf('Gathering data for samples %d to %d...\n',starti,endi);
  for ii = 1:ncurr,
    if mod(ii,100) == 0,
      fprintf('Sample %d / %d\n',ii,ncurr);
    end
    i = starti+ii-1;
    if fromfile,
      [~,hogdata] = LoadHOGData(datafiles(i),{'hogdata'});
      posdatacurr(end+1) = FitPositionHogFile(hogdata,[],fitparams);
    else
      imraw = imread(imfiles{i});
      imluv = rgbConvert(imraw,'luv');
      segdata = load(segfiles{i});
      posdatacurr1 = FitPositionHog(segdata,imluv,fitparams);
      posdatacurr = structappend(posdatacurr,posdatacurr1);
    end
  end
  
  % show these flies
  if fromfile,
    
    cropims = cell(1,numel(posdatacurr));
    hpx = 0; wpx = 0;
    for ii = 1:numel(posdatacurr),
      i = starti+ii-1;
      cropim = LoadHOGData(datafiles(i),{'cropim'});
      cropims{ii} = cropim(:,:,3);
      hpx = hpx + size(cropims{ii},1);
      wpx = wpx + size(cropims{ii},2);
    end
    hpx = hpx / numel(posdatacurr);
    wpx = wpx / numel(posdatacurr);
    idxgood = 1:numel(posdatacurr);
    
  else
    idxgood = find([posdatacurr.isfly] & ~[posdatacurr.ismultipleflies]);
    meana = mean([posdatacurr(idxgood).a]);
    meanb = mean([posdatacurr(idxgood).b]);
    hpx = meana+fitparams.classifyparams.padborder+1;
    wpx = meanb+fitparams.classifyparams.padborder+1;
  end
    
  if ncurr > maxnshow,
    startisshow = round(linspace(1,ncurr+1,round(ncurr/maxnshow)+1));
    endisshow = startisshow(2:end)-1;
    startisshow = startisshow(1:end-1);
  else
    startisshow = 1;
    endisshow = ncurr;
  end

  for showi = 1:numel(startisshow),
    
    fighandle = figure();
    clf;
    hax = gca;
    hold on;
    set(hax,'UserData',posdatacurr);
    
    startishow = startisshow(showi);
    endishow = endisshow(showi);
    nshowcurr = endishow-startishow+1;
        
    ncax = ceil(sqrt(nshowcurr)*sqrt(hpx/wpx));
    nrax = ceil(nshowcurr/ncax);
  
    nrpx = 1+nrax*hpx;
    ncpx = 1+ncax*wpx;
  
    fprintf('Creating image of all %d flies...\n',nshowcurr);
    him = nan(1,nshowcurr);
    for iii = 1:nshowcurr,
      ii = startishow+iii-1;
      i = starti+idxgood(ii)-1;
      posdatacurr1 = posdatacurr(idxgood(ii));
      if fromfile,
        if posdatacurr1,
          imraw_rot = flipud(cropims{ii});
        else
          imraw_rot = cropims{ii};
        end
        imraw_rot = imresize(imraw_rot,[hpx,wpx],'bilinear');
        %imraw_rot = repmat(imraw_rot(:,:,3),[1,1,3]);
      else
        imraw = imread(imfiles{i});
        [nrcurr,nccurr,~] = size(imraw);
        
        theta = posdatacurr1.theta+pi/2;
        mu = [posdatacurr1.x,posdatacurr1.y];
        R = [cos(theta),-sin(theta),0
          sin(theta),cos(theta),0
          0,0,1];
        scalex = meanb/posdatacurr1.b;
        scaley = meana/posdatacurr1.a;
        S = [scalex,0,0;0,scaley,0;0,0,1];
        tform = maketform('affine',R*S);
        
        imraw_rot = imtransform(imraw,tform,...
          'UData',[1-mu(1),nccurr-mu(1)],...
          'VData',[1-mu(2),nrcurr-mu(2)],...
          'XData',(meanb+fitparams.classifyparams.padborder)*[-1,1],...
          'YData',(meana+fitparams.classifyparams.padborder)*[-1,1],...
          'FillValues',255);
      end
      
      [r,c] = ind2sub([nrax,ncax],iii);
      
      if size(imraw_rot,3) > 1,
        him(iii) = image((c-1)*wpx+[1,wpx-1],(r-1)*hpx+[1,hpx-1],imraw_rot,'Parent',hax);
      else
        him(iii) = imagesc((c-1)*wpx+[1,wpx-1],(r-1)*hpx+[1,hpx-1],imraw_rot,'Parent',hax);
      end
      set(him(iii),'ButtonDownFcn',{@FlipOrientationButtonDownFcn,idxgood(ii),hax,fromfile});
      
    end
    axis ij;
    axis image;
  
    title('Set all flies facing up and close figure when done (right-click to flip, left-click to reject)');

    % Set close reqeust to the uiresume is called on figure close
    set(fighandle,'CloseRequestFcn',@(srv,evnt)uiresume(fighandle))
    uiwait(fighandle);

    
    % Get data and actually close figure
    posdatacurr = get(hax,'UserData');
    set(fighandle,'CloseRequestFcn', '')
    delete(fighandle)
    
  end
  
  % update classifier
  if fromfile,
    gtposdata = [gtposdata,posdatacurr];
    datafilescurr = datafiles(starti:endi);
    imfilescurr = [];
  else
    gtposdata = structappend(gtposdata,posdatacurr);
    datafilescurr = [];
    imfilescurr = imfiles(starti:endi);
  end
    
  if isfirst,
    [fitparams.orientationclassifier,X,y,fitparams.featurenames] = TrainOrientationClassifier(posdatacurr,imfilescurr,fitparams,[],[],datafilescurr);
  else
    [fitparams.orientationclassifier,X,y,~,ens,labelfit,yfit] = TrainOrientationClassifier(posdatacurr,imfilescurr,fitparams,X,y,datafilescurr);
  end
  isfirst = false;
  
  starti = starti + nperpage(nperpagei);
  nperpagei = min(nperpagei+1,numel(nperpage));
  
end

if fromfile,
  idxgood = find(~isnan(gtposdata));

  %idxgood = 1:numel(gtposdata);
  imheight2 = hpx;
  imwidth2 = hpx;
  meana = hpx/6;
  meanb = wpx/6;
else
  idxgood = find([gtposdata.isfly]&~[gtposdata.ismultipleflies]&...
    (~isfield(gtposdata,'badim') || cellfun(@(x) ~isempty(x) && x,{gtposdata.badim})));
  
  %idxgood = find([gtposdata.isfly] & ~[gtposdata.ismultipleflies]);
  meana = mean([gtposdata(idxgood).a]);
  meanb = mean([gtposdata(idxgood).b]);
  
  imwidth2 = round(meanb*6);
  imheight2 = round(meana*2);
end
  
  
fitparams.meana = meana;
fitparams.meanb = meanb;
fitparams.imheight2 = imheight2;
fitparams.imwidth2 = imwidth2;

imis = repmat(idxgood,[4,1]);
imis = imis(:);
featurenames = fitparams.featurenames;
