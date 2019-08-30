% Function name....: Envelope
% Date.............: May 03, 2016
% Mod date.........: Jan  12, 2019 (v2)
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                    Envelope estimates upper and lower envelopes of time-series.
% Parameters.......:
%                    inputSignal -> input time-series
%                    (optional param) minPeakDistance -> minimum peak (and valley) separation
%                    (optional param) windowing -> boolean flag to enable
%                    finding peaks using the carrier frequency information
% Return...........:
%                    upperEnv -> upper envelope
%                    upperEnvIndex -> upper envelope indexes
%                    lowerEnv -> lower envelope
%                    lowerEnvIndex -> lower envelope indexes
% Remarks..........:
%                    Envelope uses the PeakFinder (non matlab function) function to estimate the
%                    local maxima and minima of the input signal. This
%                    function do not use interpolation methods.
function [upperEnv,upperEnvIndex,lowerEnv,lowerEnvIndex] = Envelope(inputSignal,minPeakDistance,windowing)
upperEnv = [];
upperEnvIndex = [];
lowerEnv = [];
lowerEnvIndex = [];

if nargin == 1
    [upperEnv,upperEnvIndex] = PeakFinder(inputSignal);
    [lowerEnv,lowerEnvIndex] = PeakFinder(-inputSignal);
elseif nargin == 2
    [upperEnv,upperEnvIndex] = PeakFinder(inputSignal, minPeakDistance);
    [lowerEnv,lowerEnvIndex] = PeakFinder(-inputSignal, minPeakDistance);
elseif nargin == 3
    [upperEnv,upperEnvIndex] = PeakFinder(inputSignal, minPeakDistance, windowing);
    [lowerEnv,lowerEnvIndex] = PeakFinder(-inputSignal, minPeakDistance, windowing);
else
    error('Insufficient arguments');
    return;
end
% Adjust lower envelope
lowerEnv = -lowerEnv;
end

