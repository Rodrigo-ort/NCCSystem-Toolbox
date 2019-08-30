function r = bsp_range(signal)
%% Function name....: bsp_range
% Date.............: July 26, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes the range of the data
% Parameters.......: 
%                    signal .....-> the input series
%                   
% Return...........:
%                    r .... -> the difference betwen the maximum observed
%                    value and the minimum
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    r = bsp_range(y1);
%                    r2 = bsp_range(y2);

signal = sort(signal);
r = signal(length(signal)) - signal(1);