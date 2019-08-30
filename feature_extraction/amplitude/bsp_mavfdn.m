%% Function name....: bsp_mavfdn
% Date.............: November 22, 2012
% Author...........: Gustavo
% Description......:
%                    estimates the mean of the absolute values of the first
%                    diferences of normalized x
%
% Parameters.......: 
%                    x ..... -> input vector/signal
% Return...........:
%                    y ..... -> mean of the diferences
% Remarks..........: 

function [y] = bsp_mavfdn(x)
    N = length(x);
    acumulador = 0;
    xnorm = zeros(1,N);
    %Averaging (u)
    u = sum(x)/N;
    %Standard derivation (sigma)
    for i = 1:1:N
        acumulador = acumulador + (x(i) - u)^2;
    end
    sigma = (1/(N-1))*acumulador;
    %Normalized signal of x(n) (xnorm)
    for i = 1:1:N
        xnorm(i) = (x(i) - u)/sigma;
    end      
    %mavfdn (y)
    acumulador = 0;
    for i = 1:1:N-1
        acumulador = acumulador + abs(xnorm(i+1) - xnorm(i));
    end
    y = (1/(N-1))*acumulador;
end

