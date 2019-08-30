% Function name....: AudioOnset
% Date.............: May 04, 2016
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                    --
% Parameters.......:
%                    inputSignal ->
%                    sampleFrequency ->
%                    threshold ->
%                    timeSkip -> in seconds
% Return...........:
%                    onsets -> indices of calculated onsets
%
% Remarks..........:

function [onsets] = AudioOnset(inputSignal, sampleFrequency, threshold, timeSkip)
onsets = [];

if nargin < 4
    error('Insufficient arguments');
    return;
end

pointsSkip = timeSkip * sampleFrequency;
onsets(1) = find(inputSignal > threshold, 1);
nextIndex = onsets(1)+pointsSkip;
inputSignalLength = length(inputSignal);
while nextIndex < inputSignalLength
    onsets(end+1) = (nextIndex + find(inputSignal(nextIndex:end) > threshold, 1));
    nextIndex = onsets(end) + pointsSkip;
end

end

