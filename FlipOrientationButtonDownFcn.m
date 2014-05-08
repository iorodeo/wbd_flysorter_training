function FlipOrientationButtonDownFcn(hObject,eventdata,i,hax,fromfile)

hfig = get(hax,'Parent');
seltype = get(hfig,'SelectionType');
posdatacurr = get(hax,'UserData');
if strcmpi(seltype,'alt'),
  if fromfile,
    posdatacurr(i) = nan;
  else
    posdatacurr(i).badim = true;
  end
else
  if fromfile,
    posdatacurr(i) = ~posdatacurr(i);
  else
    posdatacurr(i).theta = modrange(posdatacurr(i).theta+pi,-pi,pi);
  end
end
set(hax,'UserData',posdatacurr);

if strcmpi(seltype,'alt'),
  cdata = get(hObject,'CData');
  cdata = 0.25*cdata+.75*(max(cdata(:)));
else
  cdata = get(hObject,'CData');
  cdata = imrotate(cdata,180);
end
set(hObject,'CData',cdata);
