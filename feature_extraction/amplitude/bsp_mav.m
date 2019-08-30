%% Function name....: bsp_mav
% Date.............: November 15, 2009
% Author...........: Adriano O. Andrade, PhD (aoandrade@yahoo.com.br)
% Description......:
%                    estimates a mean absolute value of the vector x
%
% Parameters.......: 
%                    x ..... -> input vector/signal
% Return...........:
%                    m ..... -> mean absolute value
% Remarks..........: 

function [m] = bsp_mav(x)
    m = sum(abs(x))/length(x);
end


