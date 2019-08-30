function var = bsp_var(signal)
%% Function name....: bsp_var
% Date.............: July 26, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes the variance of the input
%                    series
% Parameters.......: 
%                    signal .....-> the input series
%                   
% Return...........:
%                    var .... -> the variance estimation
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    r = bsp_var(y1);
%                    r2 = bsp_var(y2);

var = sum((signal - mean(signal)).^2)/(length(signal)-1);