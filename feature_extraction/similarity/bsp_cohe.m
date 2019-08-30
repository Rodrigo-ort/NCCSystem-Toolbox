function [c, f] = bsp_cohe(signal1, signal2, Fs)
%% Function name....: bsp_ap_en
% Date.............: July 25, 2013
% Author...........: Nicolai Diniz Linhares
% Description......:
%                    This function estimate the coerence index for each
%                    frequency of the signals
% Parameters.......: 
%                    signal1 .....-> the first input series
%                    signal2 .....-> the series to compute the correlation
%                    Fs .......-> the sampling frequency
%                   
% Return...........:
%                    ldf .... -> aproximated entropy estimation
% Usage............:
%                    t = (0:500)*0.001; 
%                    x = cos(2*pi*t*200)+randn(size(t));
%                    y = cos(2*pi*t*100)+randn(size(t));
%                    [c f] = bsp_core(x,y,Fs);
%                    bsp_core(x,y,Fs);

[pxy f] = cpsd(signal1,signal2, [], [], [], Fs);
[pxx f] = pwelch(signal1, [], [], [], Fs);
[pyy f] = pwelch(signal2, [], [], [], Fs);

c = pxy./(sqrt(pxx.*pyy));
 if nargout == 0
     plot(f,c);
     ylabel('Coherence');
     xlabel('Frequency (Hz)');
 end