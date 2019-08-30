% Peak analysis
% Run after windowing.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 10/01/2019
% Last modification: xx/xx/2019
% Used in World Congress 2018

%% Estimate peaks (for plessey and tremsen signal)
nPeaksPerTask = [0 0 5 5 5 5 15 15 15 15];
commandwindow;
analysisWn = input('\n\nType the window number (task) for analysis (1-10): ');
maxPeaks = nPeaksPerTask(analysisWn);
nPeaksFlag = 0;
peakProminence = 0;
invertPlesseyFlag = 0;
plotFlag = 1;
sensorName = {'Plessey1','Gyro3Y','Gyro3Z'};

% Peak params
% min peak dist - same value for all sensors
if maxPeaks == 5
    mpd = 1.2;
elseif maxPeaks == 15
    mpd = 0.30;
end
mphP = 0.2; % min peak height
mphGY = 0.15;
mphGZ = 0.2;

% Plessey
window = windowsFiltered(analysisWn):windowsFiltered(analysisWn+1);
wnPlesseySig = env_ps1_filtered(window);
if max(wnPlesseySig) < abs(min(wnPlesseySig))*0.9 || invertPlesseyFlag
    wnPlesseySig = wnPlesseySig * -1; 
end
% fprintf('\n-- %s --\n',sensorName{1});
[pks{1}, locs{1}] = PeakFinder1(wnPlesseySig, meanEnvSampleRate,...
    mpd, mphP, maxPeaks, nPeaksFlag, peakProminence, plotFlag);
if plotFlag, title([sensorName{1} ' signal peaks of task ' num2str(analysisWn)],'FontSize',18); end

% Tremsen
tsWindow = tsWindows(analysisWn):tsWindows(analysisWn+1);

% fprintf('\n-- %s --\n',sensorName{2});
[pks{2}, locs{2}] = PeakFinder1(gyro3Y_filtered(tsWindow), tsSampleRate,...
    mpd, mphGY, maxPeaks, nPeaksFlag, peakProminence, plotFlag);
if plotFlag, title([sensorName{2} ' signal peaks of task ' num2str(analysisWn)],'FontSize',18); end

% fprintf('\n-- %s --\n',sensorName{3});
[pks{3}, locs{3}] = PeakFinder1(gyro3Z_filtered(tsWindow), tsSampleRate,...
    mpd, mphGZ, maxPeaks, nPeaksFlag, peakProminence, plotFlag);
if plotFlag, title([sensorName{3} ' signal peaks of task ' num2str(analysisWn)],'FontSize',18); end

close(2:4)

%% Estimate features based on peaks
printFlag = 1;
fprintf('\nSource file: %s\n',fileName);
for i = 1:length(sensorName)
    fprintf('\n-- Features of %s sensor of task %d --\n',sensorName{i}, analysisWn);
    [~,~,~,~] = PeakFeatures(pks{i}, locs{i}, printFlag);
end
