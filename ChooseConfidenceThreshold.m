function minconfidence = ChooseConfidenceThreshold(yfit,y)

% Create sorted thresholds
[sortv,vorder] = sort(abs(yfit));
iscorrect = ones(size(y));
iscorrect(isnan(yfit)) = 0;
iscorrect(sign(yfit) ~= y & ~isnan(yfit)) = -1;
sortiscorrect = iscorrect(vorder);

figh = figure();
clf;
plot([0],[0], 'w'); % Dummy line for legend display
hold on
plot(find(sortiscorrect==1)/numel(sortiscorrect),sortv(sortiscorrect==1),'b.');
hold on;
plot(find(sortiscorrect==-1)/numel(sortiscorrect),sortv(sortiscorrect==-1),'r.');
ax = axis;
xlabel('Fraction of training data');
ylabel('Confidence');


% Loop over ginput for setting confidence threshold. 
done = false;
minconfidence = 0;
refLine = plot(ax(1:2),minconfidence+[0,0],'g-');
fracText = getFracText(yfit, y, minconfidence);
legend(fracText, 'location', 'North');

while ~done
    title('Select operation: s = set threshold, c = gui controls, q = quit'); 
    try
        rsp = waitforbuttonpress();
    catch ME
        done = true;
        continue;
    end
    if rsp == 1
        key = get(figh,'CurrentCharacter');
        if (key == 's')
            title('Enter threshold (left mouse button)')
            tmp = ginput(1);
            minconfidence = tmp(2);
            delete(refLine);
            refLine = plot(ax(1:2),minconfidence+[0,0],'g-');
            fracText = getFracText(yfit, y, minconfidence);
            legend(fracText, 'location', 'North');
        elseif (key == 'q')
            done = true;
            close(figh);
        elseif (key == 'c')
            title('GUI control mode - any key to return to main menu'); 
            pause;
            zoom off;
        end
    end
end


function fracText = getFracText(yfit, y, minconfidence)
[fe, fu] = getFrac(yfit, y, minconfidence);
fracText = sprintf('min confidence: %1.3f, ferrors: %1.3f, funknown: %1.3f', minconfidence, fe, fu);


function [fracErrors, fracUnknown] =  getFrac(yfit, y, minconfidence)
fracErrors = nnz(sign(yfit)~=sign(y) & ~isnan(yfit) & abs(yfit)>=minconfidence)/nnz(~isnan(yfit));
fracUnknown = nnz(abs(yfit)<=minconfidence)/nnz(~isnan(yfit));
