function [ds, f] = bsp_ds(signal, Fs, window, noverlap, nfft)
%% Function name....: bsp_ds
% Date.............: February 20, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function calculates the degree of stationarity
%                    for a period T
% Parameters.......: 
%                    signal .....-> input series
%                    Fs ..-> sampling frequency
%                    window(optional) ..-> hamming window size for energy
%                    estimation
%                    noverlap(optional) ..-> number o points of the
%                    previous window that will be used in the next
%                    nfft(optional) ..-> number of points of fft for energy estmation
% Return...........:
%                    ds .... -> the median of the results for each
%                    frequency
% Usage............:
%                    t = (0:500)*0.001; 
%                    y1 = sin(2*pi*60*t);
%                    ds = bsp_ds(y1,1000);
if nargin < 3
    window = [];
end
if nargin < 4
    noverlap = [];
end
if nargin < 5
    nfft = 256;
end

[H, f, t] = spectrogram(signal, window, noverlap, nfft, Fs);
H = abs(H);
h = sum(H,2);
T = numel(signal)*(1/Fs);
for k = 1:numel(t)
    H(:,k) = H(:,k)./(h/T);
end
H = ((1 - H).^2)/T;
ds = sum(H,2)';
