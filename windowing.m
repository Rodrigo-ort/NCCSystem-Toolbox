% Signal windowing and filter (smooth and remove offset)
% Run after start.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 30/01/2018
% Last modification: 05/04/2018
%% Load audio
[audioSignal, audioFS] = audioread('experiment beeps.mp3');
audioSignalLength = length(audioSignal);
timeAudio = (0:1/audioFS:audioSignalLength/audioFS)';
timeAudioLength = length(timeAudio);
% Fix different size vectors
if (audioSignalLength > timeAudioLength)
    aDiff = audioSignalLength - timeAudioLength;
    for i = 1:aDiff
        timeAudio(timeAudioLength+i) = 0;
    end
elseif (audioSignalLength < timeAudioLength)
    aDiff = timeAudioLength - audioSignalLength;
    for i = 1:aDiff
        audioSignal(audioSignalLength+i) = 0;
    end
end
% Play audio
%sound(audioSignal, audioFs);

%% Get audio onset
thresholdValue = 0.01; % y value
timeSkip = 0.6; % s
onsets = AudioOnset(audioSignal, audioFS, thresholdValue, timeSkip);
figure;
plot(timeAudio,audioSignal,timeAudio(onsets),audioSignal(onsets),'or');
title('Audio beeps','FontSize',18);
xlabel('Time (s)','FontSize',16);
ylabel('Normalized audio data','FontSize',16);
audioOnset = audioSignal(onsets);
timeOnsets = onsets/audioFS; % onset in seconds
close;

%% Show the oneside envelope alone
commandwindow;
envelopeSide = input('Choose the envelope side to proceed with the analysis (1 - lower and 2 - upper): ');
if envelopeSide == 2 % Upper
    envIndex_ps1 = upperEnvIndex_ps1;
    env_ps1 = upperEnv_ps1;
    envIndex_ps2 = upperEnvIndex_ps2;
    env_ps2 = upperEnv_ps2;
elseif envelopeSide == 1 % Lower
    envIndex_ps1 = lowerEnvIndex_ps1;
    env_ps1 = lowerEnv_ps1;
    envIndex_ps2 = lowerEnvIndex_ps2;
    env_ps2 = lowerEnv_ps2;
end

input('Do not close the first figure before windowing.[Enter to continue]\n');
fig1 = figure; % fig1: used to get points to sync with audio

% x-axis
h2(1) = subplot(2,1,1);
plot(time(envIndex_ps1),env_ps1,'r-');
title('The envelope of Sensor pair 1 (x-axis)','FontSize',18);
ylabel('Envelope of raw sensor output (v)','FontSize',16);

% y-axis
h2(2) = subplot(2,1,2);
plot(time(envIndex_ps2),env_ps2,'r-');
title('The envelope of Sensor pair 2 (y-axis)','FontSize',18);
ylabel('Envelope of raw sensor output (v)','FontSize',16);

xlabel('Time (s)','FontSize',16);

linkaxes(h2,'x');


%% Get points to sync with audio (should be executed only after x-axis envelope)
commandwindow;
chosenOnset = input('\nType the known onset: ');%3;
[xOnset, yOnset] = getpts(fig1);
plesseyTimeOnsets = ones(size(timeOnsets))*-1;
plesseyTimeOnsets(chosenOnset) = xOnset;
i = chosenOnset;
while i > 1
    plesseyTimeOnsets(i-1) = plesseyTimeOnsets(i) - (timeOnsets(i) - timeOnsets(i-1));
    i = i-1;
end
i = find(plesseyTimeOnsets == -1, 1);
while i <= length(timeOnsets)
    plesseyTimeOnsets(i) = plesseyTimeOnsets(i-1) + (timeOnsets(i) - timeOnsets(i-1));
    i = i+1;
end

ps1EnvTime = time(envIndex_ps1);
ps2EnvTime = time(envIndex_ps2);

% Delays the onsets, to better fit our experiment
% The delay was calculated based on audio beeps and human reaction time to
% sound
plesseyTimeOnsets = plesseyTimeOnsets - (2 + 0.2); % seconds
ps1Onsets = ones(size(plesseyTimeOnsets))*-1;
ps2Onsets = ones(size(plesseyTimeOnsets))*-1;
for i=1:length(ps1Onsets)
    ps1Onsets(i) = find(ps1EnvTime < plesseyTimeOnsets(i),1,'last');
    ps2Onsets(i) = find(ps2EnvTime < plesseyTimeOnsets(i),1,'last');
end

%% Highlights the windows from each movement type
% Audio onset index below the mean, used to exclude repeated movements
audioOnsetMean = find(audioOnset < mean(audioOnset));
ps1SelectedWindows = ps1Onsets(audioOnsetMean); %index of each window
ps2SelectedWindows = ps2Onsets(audioOnsetMean); 

% Plot sensor pair 1 (x-axis) and 2 (y-axis) windowed envelope
figure;

h5(1) = subplot(2,1,1);
plot(ps1EnvTime(ps1SelectedWindows(1):ps1SelectedWindows(end)),...
    env_ps1(ps1SelectedWindows(1):ps1SelectedWindows(end)));
line([ps1EnvTime(ps1SelectedWindows) ps1EnvTime(ps1SelectedWindows)],...
    [min(env_ps1) max(env_ps1)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Sensor pair 1 windowed envelope (x-axis)','FontSize',18);
ylabel('Envelope of raw sensor output (v)','FontSize',16);

h5(2) = subplot(2,1,2);
plot(ps2EnvTime(ps2SelectedWindows(1):ps2SelectedWindows(end)),...
    env_ps2(ps2SelectedWindows(1):ps2SelectedWindows(end)));
line([ps2EnvTime(ps2SelectedWindows) ps2EnvTime(ps2SelectedWindows)],...
    [min(env_ps2) max(env_ps2)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Sensor pair 2 windowed envelope (y-axis)','FontSize',18);
ylabel('Envelope of raw sensor output (v)','FontSize',16);

xlabel('Time (s)','FontSize',16);
linkaxes(h5,'x');

%% Fix time and windows
ps1TimeFiltered = ps1EnvTime(ps1SelectedWindows(1):...
    ps1SelectedWindows(end)) - ps1EnvTime(ps1SelectedWindows(1));
ps2TimeFiltered = ps2EnvTime(ps2SelectedWindows(1):...
    ps2SelectedWindows(end)) - ps2EnvTime(ps2SelectedWindows(1));
timeFiltered = ps1TimeFiltered; %test

ps1WindowsFiltered = ps1SelectedWindows - ps1SelectedWindows(1)+1;
ps2WindowsFiltered = ps2SelectedWindows - ps2SelectedWindows(1)+1;
windowsFiltered = ps1WindowsFiltered; %test

% Value to be used in the sync process with other hardwares
initTimeTrash = ps1EnvTime(ps1SelectedWindows(1)-1); % In seconds

%% Signal filtering (remove offset and signal trash) - Plessey signal
plotFlag = 1;
% TODO: Fix smooth params to keep tremor signal
env_ps1_filtered = SmoothFilter(ps1TimeFiltered, ...
    env_ps1(ps1SelectedWindows(1):ps1SelectedWindows(end)),plotFlag);
env_ps2_filtered = SmoothFilter(ps2TimeFiltered, ...
    env_ps2(ps2SelectedWindows(1):ps2SelectedWindows(end)),plotFlag);

fileName
%% Load and prepare tremsen data ..
[tsFileName, tsPathName] = uigetfile('.txt', ...
    'Select tremsen signal file');
tsFilePath = strcat(tsPathName, tsFileName);
tremsenData = importtremsenfile(tsFilePath);

commandwindow;
selectedCh = input('\nType used TremSen Channel (1, 2 or 3): ');

gyroYCh = [3,6,9];
gyroZCh = [4,7,10];

tsTime = tremsenData(:,1);
gyro3Y = tremsenData(:,gyroYCh(selectedCh)); 
gyro3Z = tremsenData(:,gyroZCh(selectedCh));
pulseA = tremsenData(:,40);
% pulseB = tremsenData(:,41);
tsFs = round(length(gyro3Y) / tsTime(end), 0);

commandwindow;
input('Do not close the following figure before select pulse.[Enter to continue]');
fig2 = figure;
h3(1) = subplot(2,1,1);
plot(tsTime,gyro3Z,tsTime,pulseA);
title('Raw gyro 3 (z-axis)','FontSize',18);

h3(2) = subplot(2,1,2);
plot(tsTime,gyro3Y,tsTime,pulseA);
title('Raw gyro 3 (y-axis)','FontSize',18);

xlabel('Time (s)','FontSize',16);
linkaxes(h3,'x');

%% Delete signal trash from selected sensor/axis of tremsen
[tsXOnset, tsYOnset] = getpts(fig2);

pulseFlag = tsXOnset;
tLag = pulseFlag + initTimeTrash;

gyro3Y = gyro3Y(tsTime > tLag);
gyro3Z = gyro3Z(tsTime > tLag);
tsTime = tsTime(tsTime > tLag);
tsTime = tsTime - tLag;

% endTime = timeFiltered(windowsFiltered(end));%Detected by means of the audio beeps
endTime = timeFiltered(end);

gyro3Y = gyro3Y(tsTime <= endTime);
gyro3Z = gyro3Z(tsTime <= endTime);
tsTime = tsTime(tsTime <= endTime);

figure;
h4(1) = subplot(2,1,1);
plot(tsTime,gyro3Z);
title('Cropped raw gyro 3 (z-axis)','FontSize',18);

h4(2) = subplot(2,1,2);
plot(tsTime,gyro3Y);
title('Cropped raw gyro 3 (y-axis)','FontSize',18);

xlabel('Time (s)','FontSize',16);
linkaxes(h4,'x');

% Fix window marks for tremsen
d = abs(bsxfun(@minus,tsTime,timeFiltered(windowsFiltered)'));
[~, tsWindows] = min(d);
% Estimate sample rate of tremsen
tsSampleRate = round(length(gyro3Y) / tsTime(end),0);

%% Signal filtering (remove offset and smooth signal) - Tremsen signal
plotFlag = 1;

gyro3Y_filtered = SmoothFilter(tsTime, gyro3Y, plotFlag);
gyro3Z_filtered = SmoothFilter(tsTime, gyro3Z, plotFlag);

%% Plot sensor pair 1 (x-axis) and 2 (y-axis) windowed envelope 
%  along with tremsen analyzed sensors/axis
figure;

% Plessey pair 1 (x-axis)
h6(1) = subplot(4,1,1);
plot(ps1TimeFiltered,env_ps1_filtered);
line([ps1TimeFiltered(ps1WindowsFiltered) ps1TimeFiltered(ps1WindowsFiltered)], ...
    [min(env_ps1_filtered) max(env_ps1_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Non-contact capacitive sensor (x-axis)','FontSize',20);
ylabel('Amplitude (V)','FontSize',20);
xlim([ps1TimeFiltered(1) ps1TimeFiltered(end)]);

% Tremsem G3.Z
h6(2) = subplot(4,1,2);
plot(tsTime,gyro3Z_filtered);
line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
    [min(gyro3Z_filtered) max(gyro3Z_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Gyroscope (z-axis)','FontSize',20);
ylabel('\circ/s','FontSize',20);

% Plessey pair 2 (y-axis)
h6(3) = subplot(4,1,3);
plot(ps2TimeFiltered,env_ps2_filtered);
line([ps2TimeFiltered(ps2WindowsFiltered) ps2TimeFiltered(ps2WindowsFiltered)], ...
    [min(env_ps2_filtered) max(env_ps2_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Non-contact capacitive sensor (y-axis)','FontSize',20);
ylabel('Amplitude (V)','FontSize',20);
xlim([ps2TimeFiltered(1) ps2TimeFiltered(end)]);

% Tremsem G3.Y
h6(4) = subplot(4,1,4);
plot(tsTime,gyro3Y_filtered);
line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
    [min(gyro3Y_filtered) max(gyro3Y_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Gyroscope (y-axis)','FontSize',20);
ylabel('\circ/s','FontSize',20);

xlabel('Time (s)','FontSize',20);
linkaxes(h6,'x');

%% Estimate peaks (for plessey and tremsen signal)
% nPeaksPerTask = [0 0 5 5 5 5 15 15 15 15];
% commandwindow;
% analysisWn = input('\n\nType the window number (task) for analysis (1-10): ');
% maxPeaks = nPeaksPerTask(analysisWn);
% nPeaksFlag = 0;
% peakProminence = 0;
% invertPlesseyFlag = 0;
% plotFlag = 1;
% sensorName = {'Plessey1','Gyro3Y','Gyro3Z'};
% 
% % Peak params
% % min peak dist - same value for all sensors
% if maxPeaks == 5
%     mpd = 1.2;
% elseif maxPeaks == 15
%     mpd = 0.30;
% end
% mphP = 0.2; % min peak height
% mphGY = 0.15;
% mphGZ = 0.2;
% 
% % Plessey
% window = windowsFiltered(analysisWn):windowsFiltered(analysisWn+1);
% wnPlesseySig = env_ps1_filtered(window);
% if max(wnPlesseySig) < abs(min(wnPlesseySig))*0.9 || invertPlesseyFlag
%     wnPlesseySig = wnPlesseySig * -1; 
% end
% % fprintf('\n-- %s --\n',sensorName{1});
% [pks{1}, locs{1}] = PeakFinder2(wnPlesseySig, meanEnvSampleRate,...
%     mpd, mphP, maxPeaks, nPeaksFlag, peakProminence, plotFlag);
% if plotFlag, title([sensorName{1} ' signal peaks of task ' num2str(analysisWn)],'FontSize',18); end
% 
% % Tremsen
% tsWindow = tsWindows(analysisWn):tsWindows(analysisWn+1);
% 
% % fprintf('\n-- %s --\n',sensorName{2});
% [pks{2}, locs{2}] = PeakFinder2(gyro3Y_filtered(tsWindow), tsSampleRate,...
%     mpd, mphGY, maxPeaks, nPeaksFlag, peakProminence, plotFlag);
% if plotFlag, title([sensorName{2} ' signal peaks of task ' num2str(analysisWn)],'FontSize',18); end
% 
% % fprintf('\n-- %s --\n',sensorName{3});
% [pks{3}, locs{3}] = PeakFinder2(gyro3Z_filtered(tsWindow), tsSampleRate,...
%     mpd, mphGZ, maxPeaks, nPeaksFlag, peakProminence, plotFlag);
% if plotFlag, title([sensorName{3} ' signal peaks of task ' num2str(analysisWn)],'FontSize',18); end
% 
% % close(2:4)

%% Estimate features based on peaks
% printFlag = 1;
% fprintf('\nSource file: %s\n',fileName);
% for i = 1:length(sensorName)
%     fprintf('\n-- Features of %s sensor of task %d --\n',sensorName{i}, analysisWn);
%     [~,~,~,~] = PeakFeatures(pks{i}, locs{i}, printFlag);
% end

%% Save all figures
saveFigsScript;
close all;

%% Save all workspace data
matFileName = strsplit(fileName,'.');
matFileName = matFileName{1};
matFileName = [pathName matFileName '.mat'];

save(matFileName);
%% Save filtered signal to later feature analysis

% File name convention = name_subject_iteration
% fsFileName = input('Enter file name to save filtered signal and its windows: ', 's');
% % Example: FilteredSignal_1_1.mat
% eval([fsFileName '=' 'struct' ';']);
% eval([fsFileName '.' 'env_ps1_filtered' '=' 'env_ps1_filtered' ';']);
% eval([fsFileName '.' 'env_ps2_filtered' '=' 'env_ps2_filtered' ';']);
% eval([fsFileName '.' 'timeFiltered' '=' 'timeFiltered' ';']);
% eval([fsFileName '.' 'windowsFiltered' '=' 'windowsFiltered' ';']);
% eval([fsFileName '.' 'initTimeTrash' '=' 'initTimeTrash' ';']);
% save([fsFileName '.mat'], fsFileName);

%%
clear all;
clc;

%% Run featureAnalysis.m file to proceed

