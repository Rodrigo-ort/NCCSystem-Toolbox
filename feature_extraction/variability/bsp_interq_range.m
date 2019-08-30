function r = bsp_interq_range(signal)
%% Function name....: bsp_interq_range
% Date.............: July 26, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function computes the interquatile range of the
%                    data
% Parameters.......: 
%                    signal .....-> the input series
%                   
% Return...........:
%                    r .... -> the difference betwen the median of the
%                    upper part of the data and the median of the lower
%                    part
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t) + 0.8*sin(2*pi*80*t);
%                    y2 = sin(2*pi*120*t) + 0.7*sin(2*pi*140*t);
%                    r = bsp_interq_range(y1);
%                    r2 = bsp_interq_range(y2);

signal = sort(signal);
l = length(signal);

if(rem(l,2) == 0)
    lind = l/2;
    uind = lind + 1;
else
    lind = floor(l/2);
    uind = lind + 2;
end

lower = signal(1:lind);
upper = signal(uind:l);
r = median(upper) - median(lower);