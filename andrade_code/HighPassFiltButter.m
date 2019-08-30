% Function name....: HighPassFiltButter
% Date.............: May 27, 2015
% Author...........: Adriano O. Andrade, PhD (aoandrade@feelt.ufu.br)
% Description......:
%                    applies a band -pass filter to the input time series y
% Parameters.......: 
%                    y -> input time-series
%                    UcutoffFreq -> upper cutoff frequency (Hz)
%                    order       -> filter order
%                    sampFreq    -> sampling frequency (Hz)
% Return...........:
%                    yfilt -> filtered signal
% Remarks..........:


function [yfilt] = HighPassFiltButter(y,UcutoffFreq,order,sampFreq)

   Wn = [UcutoffFreq]/(sampFreq/2);
   [b,a] = butter(order,Wn,'high'); %filter design
   yfilt = filtfilt(b,a,y); %zero-phase digital filtering (zero-phase distortion)
    
end