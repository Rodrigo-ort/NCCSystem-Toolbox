% Function name....: PeakFinder
% Date.............: May 03, 2016
% Mod date.........: Jan  12, 2019 (v2)
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                    Find local maxima
% Parameters.......: 
%                    inputSignal -> input time-series
%                    (optional param) minPeakDistance -> minimum peak
%                    separation in samples
%                    (optional param) windowing -> boolean flag to enable
%                    finding peaks using the carrier frequency information
% Return...........:
%                    pks -> vector with the local maxima (peaks) of the input signal vector
%                    locs -> indices at which the peaks occur
% Remarks..........:
%                    when windowing is true, minPeakDistance is used as a rectangular 
%                    window parameter to guide during finding peaks task. 
function [pks,locs] = PeakFinder(inputSignal, minPeakDistance, windowing)
pks = [];
locs = [];
if nargin == 1
   [pks,locs] = findpeaks(inputSignal);
elseif nargin == 2
   [pks,locs] = findpeaks(inputSignal,'MinPeakDistance',minPeakDistance); 
elseif nargin == 3  
   %inputSignal = ps2; %just for tests
   pks(1) = max(inputSignal(1:minPeakDistance));   
   locs(1) = find(inputSignal(1:minPeakDistance) == pks(1), 1, 'first');
   pos = locs(1);   
   while (pos + minPeakDistance * 1.5) < length(inputSignal)       
       pos = pos + round(minPeakDistance/2);
       pks(end + 1) = max(inputSignal(pos:pos+minPeakDistance));
       locs(end + 1) = find(inputSignal(pos:pos+minPeakDistance) == pks(end), 1, 'last') + pos - 1;
       pos = locs(end);
   end
%    figure;
%    plot(time,inputSignal,time(locs),pks,'o');
else
    error('Insufficient arguments');
    return;
end
% cycles = diff(locs);
% meanCycle = mean(cycles)
end

