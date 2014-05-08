function [doflip,x] = FitPositionHogFile(hogdata,hogdata_flip,params,varargin)

x = hogdata;
doflip = false;

%% no classifier yet?

if ~isfield(params,'orientationclassifier') || isempty(params.orientationclassifier),
  return;
end

%% classify

[orlabelfit,posdata.orientation_score] = FastBinaryPredict(params.orientationclassifier,x(:)');
doflip = orlabelfit == -1;
if doflip,
  if nargout >= 2,
    x = hogdata_flip;
  end
end
