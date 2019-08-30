%% Function name....: bsp_peak
% Date.............: November 22, 2012
% Author...........: Gustavo
% Description......:
%                    estimates the maximun value of the vector x
%
% Parameters.......: 
%                    x ..... -> input vector/signal
% Return...........:
%                    maximun ..... -> maximun value of the vector
% Remarks..........: indexmax .... -> index of the maximun value

function [maximun,indexmax] = bsp_peak(x)
    maximun = max(x);
    for i=1:length(x)
        if maximun == x(i)
            indexmax = i;
        end
    end
end