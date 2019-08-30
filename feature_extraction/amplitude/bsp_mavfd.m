%% Function name....: bsp_mavfd
% Date.............: November 22, 2012
% Author...........: Gustavo
% Description......:
%                    estimates the mean of the absolute values of the first
%                    diferences of x
%
% Parameters.......: 
%                    x ..... -> input vector/signal
% Return...........:
%                    y ..... -> mean of the diferences
% Remarks..........: 
function [y] = bsp_mavfd(x)
    N = length(x);
    acumulador = 0;
    for i =1:1:N-1
        acumulador = acumulador + abs(x(i+1) - x(i));
    end
    y = (1/(N-1))*acumulador;
end
