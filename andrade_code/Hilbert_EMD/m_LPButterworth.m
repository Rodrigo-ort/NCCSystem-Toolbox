% Function name....: m_LPButterworth
% Date.............: September 11, 2003
% Author...........: Adriano de Oliveira Andrade 
%                    (aoandrade@eletrica.ufu.br)
% Description......:
%                    m_LPButterworth applies a low-pass Butterworth
%                    filter to the input signal without phase distortion
%                    
% Parameters.......: 
%                    x ..............-> input signal
%                    cutoffFreq......-> cut-off frequency (Hz)
%                    order...........-> filter order
%                    sampFreq........-> sampling frequency (Hz)
% Return...........:
%                    y....-> filtered signal
% 


function [y] = m_LPButterworth(x,cutoffFreq,order,sampFreq)

Wn = cutoffFreq/(sampFreq/2);
[b,a] = butter(order,Wn); %filter design
y = filtfilt(b,a,x); %zero-phase digital filtering (zero-phase distortion)