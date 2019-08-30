% Function name....: PeakFinder1
% Date.............: Feb 01, 2018
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                    Find local maxima
% Parameters.......:
%                    y -> input time-series
%                    fs -> sample rate
%                    mpd -> minimum peak distance in seconds
%                    mph -> minimum peak height (percent of max height) 0-1
%                    maxPeaks -> maximum accepted number of peaks
%                    nPeaksFlag ->
%                    peakProminence ->
%                    plotFlag ->
% Return...........:
%                    pks -> vector with the local maxima (peaks) of the input signal vector
%                    locs -> indices at which the peaks occur
% Remarks..........:
%                    
function [pks, locs] = PeakFinder1(y, fs, mpd, mph, maxPeaks, nPeaksFlag, peakProminence, plotFlag)
time = 0:1/fs:length(y)/fs;
difts = length(time) - length(y);
if difts > 0
    time(end - difts+1:end) = [];
elseif difts < 0
    error('Error vector time construction.');
end

maxAmp = max(y);
if nPeaksFlag
[pks,locs] = findpeaks(y,fs,'MinPeakDistance',mpd, ...
    'MinPeakHeight', maxAmp * mph, 'NPeaks', maxPeaks, ...
    'MinPeakProminence', peakProminence);
else
   [pks,locs] = findpeaks(y,fs,'MinPeakDistance',mpd, ...
    'MinPeakHeight', maxAmp * mph, ...
    'MinPeakProminence', peakProminence); 
end

% TODO: Make possible delete final peaks too.
if maxPeaks ~= 0 && maxPeaks < length(pks)
   pks = pks(end - maxPeaks+1:end);
   locs = locs(end - maxPeaks+1:end);
end

if plotFlag
    figure;
    plot(time,y,locs,pks,'o');
end

end

