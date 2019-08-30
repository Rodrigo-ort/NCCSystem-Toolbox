function std = bsp_std(signal)
%% Function name....: bsp_std
% Date.............: July 26, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes the standard deviation of the input
%                    series
% Parameters.......: 
%                    signal .....-> the input series
%                   
% Return...........:
%                    var .... -> the standard deviation estimation
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    r = bsp_std(y1);
%                    r2 = bsp_std(y2);

var = sum((signal - mean(signal)).^2)/(length(signal)-1);
std = sqrt(var);