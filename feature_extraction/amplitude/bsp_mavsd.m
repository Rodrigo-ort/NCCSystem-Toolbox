%% Function name....: bsp_mavsd
% Date.............: November 22, 2012
% Author...........: Gustavo
% Description......:
%                    estimates the mean of the absolute values of the
%                    second diferences of x
%
% Parameters.......: 
%                    x ..... -> input vector/signal
% Return...........:
%                    y ..... -> mean of the diferences
% Remarks..........: 
function [y] = bsp_mavsd(x)
    N = length(x);
    acumulador = 0;
    for i =1:1:N-2
        acumulador = acumulador + abs(x(i+2) - x(i));
    end
    y = (1/(N-2))*acumulador;
end