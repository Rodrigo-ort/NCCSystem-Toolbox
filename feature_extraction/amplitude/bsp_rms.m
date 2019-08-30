%% Function name....: bsp_rms
% Date.............: November 15, 2009
% Author...........: Adriano O. Andrade, PhD (aoandrade@yahoo.com.br)
% Description......:
%                    estimates a mean absolute value of the vector x
%
% Parameters.......: 
%                    x ..... -> input vector/signal
% Return...........:
%                    y ..... -> root mean square value
% Remarks..........: 

function [y] = bsp_rms(x)

    y = sqrt(sum(x.^2)/length(x));
    
end