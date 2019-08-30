function c = bsp_corr(signal1, signal2)
%% Function name....: bsp_corr
% Date.............: July 25, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function estimate the correlation index between
%                    two vectors
% Parameters.......: 
%                    signal1 .....-> the first input series
%                    signal2 .....-> the series to compute the correlation
%                   
% Return...........:
%                    ldf .... -> aproximated entropy estimation
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    c = bsp_corr(y1,y2);
%                    c1 = bsp_corr(y1,y1);

u1 = mean(signal1);
u2 = mean(signal2);

c = (mean(signal1.*signal2) - u1*u2)/(sqrt(mean(signal1.^2) - u1^2)*sqrt(mean(signal2.^2) - u2^2));