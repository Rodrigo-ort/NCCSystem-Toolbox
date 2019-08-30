% Function name....: SmoothFilter
% Date.............: Feb 01, 2018
% Mod date.........: Jan  13, 2019
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%
% Parameters.......:
%
%
% Return...........:
%
%
% Remarks..........:
%                    https://dsp.stackexchange.com/questions/9966/what-is-the-cut-off-frequency-of-a-moving-average-filter
%                    (for moving average)span = (1 / cut-off frequency) *
%                    sample frequency
function [y3] = SmoothFilter(x, y, plotFlag, signalLabel, cutOff)
% Round to nearest odd integer
% function y=fun(x)
%     y = 2*floor(x/2)+1;
% end

% Defining ideal smooth factor based on cut-off frequency
maSpan = (1 / cutOff) * (1/mean(diff(x)));
maSpan = 2*floor(maSpan/2)+1

y1 = smooth(x,y,maSpan,'moving');
% y1 = smoothdata(y,'movmedian',5);
% y1 = smooth(x,y,0.001,'rloess');%'loess');

y2 = smooth(x,y,0.1,'rloess');%'loess');

y3 = y1 - y2;

if plotFlag
    figure;
    h(1) = subplot(3,1,1);
    plot(x,y,x,y1);
    title(['Smooth moving - ' signalLabel ' - Cut-off: ' num2str(cutOff) 'Hz'],'FontSize',18);
    
    h(2) = subplot(3,1,2);
    plot(x,y,x,y2);
    title('Smooth rloess','FontSize',18);
    
    h(3) = subplot(3,1,3);
    plot(x,y3);
    hline = refline([0 0]);
    hline.Color = 'k';
    title('moving - rloess','FontSize',18);
    
    xlabel('Time (s)','FontSize',16);
    linkaxes(h,'x');
end

end

