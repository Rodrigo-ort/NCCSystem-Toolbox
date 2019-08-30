% Function name....: PeakFeatures
% Date.............: Feb 02, 2018
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                    
% Parameters.......:
%                    pks -> 
%                    locs -> in seconds
%                    printFlag -> 
% Return...........:
%                    mpi -> median peak interval
%                    mpa -> median peak amplitude
%                    extremesDiff -> difference between last and first
%                    peaks
% Remarks..........:
%                    
function [nPeaks, mpi, mpa, extremesDiff] = PeakFeatures(pks, locs, printFlag)
nPeaks = length(pks);

% Calc median lag between peaks
%tLocs = locs/fs;
mpi = median(diff(locs));

% Calc median amp peaks
mpa = median(pks);

% Calc time between last and first peak
extremesDiff = locs(end) - locs(1);

if printFlag
   fprintf('\nNumber of peaks = %d\n', nPeaks); 
   fprintf('Median peak interval = %.3f\n', mpi); 
   fprintf('Median peak amp = %.3f\n', mpa);
   fprintf('Last Peak - First Peak = %.3f\n', extremesDiff);
end

end

