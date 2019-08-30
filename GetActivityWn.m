% Function name....: GetActivityWn
% Date.............: May 19, 2019
% Mod date.........: 
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                   Get activity windows based on y (trigger signal)
% Parameters.......:
%                   x -> time
%                   y -> signal (trigger signal)
%                   ref -> reference time-signal(adjust wnIndex for
%                   different sample rate)
% Return...........:
%                   wnTime  -> Initial time and end time of each window
%                   wnIndex -> Initial and end index of each window
% Remarks..........:
%                    
function [wnTime, wnIndex] = GetActivityWn(x, y, refTime, plotFlag, humanReactionTime)
% x = time;
% y = digInA;
% refTime = psEnvTime;
% Invert signal if the initial state starts with 1 (high level)
if y(1) == 1
    y = y * -1;
end
initialState = y(1);
% figure;findpeaks(y);
% figure;findpeaks(y * -1);
[~,locs1] = findpeaks(y);
[~,locs2] = findpeaks(y * -1);
locs = sort(cat(1,locs1,locs2));
locs(end+1) = find(y > initialState, 1, 'last');

% wnIndex = locs;
wnIndex = [];
% humanReationTime = 0.25; % seconds
hrtIndex = round(humanReactionTime * (length(y) / x(end)),0);
for i = 1:length(locs)
    % Init of window
    if mod(i,2) ~= 0
        wnIndex(end+1) = locs(i) - hrtIndex;
    % End of the window
    else
        % Test
        wnIndex(end+1) = locs(i) - hrtIndex;
    end
end
wnIndex = unique(wnIndex);
wnTime = x(wnIndex);

if plotFlag
    figure;
    plot(x,y,'k-',x(wnIndex),y(wnIndex),'ro');
end

if length(refTime) ~= 0
%     wnTime = wnTime;
    wnIndex2 = [];
    for i = 1:length(wnTime)
        idx = find(refTime > wnTime(i)-0.01 & ...
            refTime < wnTime(i)+0.01);
        wnIndex2(end+1) = idx(1);
    end
    wnIndex = unique(wnIndex2);
%     wnTime = x(wnIndex);
end

end

