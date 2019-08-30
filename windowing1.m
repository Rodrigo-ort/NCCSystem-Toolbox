% Signal windowing and filter (smooth and remove offset)
% Run after main1.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 10/01/2019
% Last modification: xx/xx/2019
% Used in EMB 2019 congress
% Used in final paper of 2019

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
% envelopeSide = input('Choose the envelope side to proceed with the analysis (1 - lower and 2 - upper): ');
envelopeSideX = input('Choose the envelope side for x-axis (1 - lower and 2 - upper): ');
if envelopeSideX == 2 % Upper
    envIndex_ps1 = upperEnvIndex_ps1;
    env_ps1 = upperEnv_ps1;    
elseif envelopeSideX == 1 % Lower
    envIndex_ps1 = lowerEnvIndex_ps1;
    env_ps1 = lowerEnv_ps1;    
end
envelopeSideY = input('Choose the envelope side for y-axis (1 - lower and 2 - upper): ');
if envelopeSideY == 2
    envIndex_ps2 = upperEnvIndex_ps2;
    env_ps2 = upperEnv_ps2;
elseif envelopeSideY == 1
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
% commandwindow;
% chosenOnset = input('\nType the known onset: ');%3;
chosenOnset = 3;
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
% plesseyTimeOnsets = plesseyTimeOnsets - (1.8); % seconds for PD
plesseyTimeOnsets = plesseyTimeOnsets - (1.5); % seconds for H
ps1Onsets = ones(size(plesseyTimeOnsets))*-1;
ps2Onsets = ones(size(plesseyTimeOnsets))*-1;
for i=1:length(ps1Onsets)
    ps1Onsets(i) = find(ps1EnvTime < plesseyTimeOnsets(i),1,'last');
    ps2Onsets(i) = find(ps2EnvTime < plesseyTimeOnsets(i),1,'last');
end

% Highlights the windows from each movement type
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

% Value to be used in the sync process with other hardware
initTimeTrash = ps1EnvTime(ps1SelectedWindows(1)-1); % In seconds

%% Signal filtering (remove offset and signal trash) - Plessey signal
plotFlag = 1;
% Cut-off frequency in Hz (used to estimate smooth parameters)
cutoff = 12;

env_ps1_filtered = SmoothFilter(ps1TimeFiltered, ...
    env_ps1(ps1SelectedWindows(1):ps1SelectedWindows(end)),plotFlag,'NCC x-axis',cutoff);
env_ps2_filtered = SmoothFilter(ps2TimeFiltered, ...
    env_ps2(ps2SelectedWindows(1):ps2SelectedWindows(end)),plotFlag,'NCC y-axis',cutoff);

disp([pathName fileName]);

% Band-pass filter?

%% Check PS signal length and fix it
diffPSSignal = length(env_ps1_filtered) - length(env_ps2_filtered);
if diffPSSignal ~= 0
    disp(['PS signal diff in points: ' int2str(diffPSSignal)]);
    while(length(env_ps1_filtered) > length(env_ps2_filtered))
        env_ps2_filtered(end+1) = 0;
        ps2TimeFiltered(end+1) = ps2TimeFiltered(end) + 1/meanEnvSampleRate;
    end
    while(length(env_ps1_filtered) < length(env_ps2_filtered))
        env_ps1_filtered(end+1) = 0;
        ps1TimeFiltered(end+1) = ps1TimeFiltered(end) + 1/meanEnvSampleRate;
    end
end

%% Load and prepare tremsen data ..
% [tsFileName, tsPathName] = uigetfile('.txt', ...
%     'Select tremsen signal file');
tsPathName = [pathName(1:end-length('plessey\')) 'tremsen' filesep];
tsFileName = [fileName(1:end-3) 'txt'];
tsFilePath = strcat(tsPathName, tsFileName);
tremsenData = importtremsenfile(tsFilePath);

commandwindow;
selectedCh = input('\nType used TremSen Channel (1, 2 or 3): ');
% selectedCh = 1;

gyroYCh = [3,6,9];
gyroZCh = [4,7,10];

tsTime = tremsenData(:,1);
gyro3Y = tremsenData(:,gyroYCh(selectedCh)); 
gyro3Z = tremsenData(:,gyroZCh(selectedCh));
pulseA = tremsenData(:,40);
pulseB = tremsenData(:,41);
tsFs = round(length(gyro3Y) / tsTime(end), 0);

commandwindow;
input('Do not close the following figure before select pulse.[Enter to continue]');
fig2 = figure;
h3(1) = subplot(2,1,1);
% plot(tsTime,gyro3Z,tsTime,pulseA);
plot(tsTime,gyro3Z,tsTime,pulseB);
title('Raw gyro 3 (z-axis)','FontSize',18);

h3(2) = subplot(2,1,2);
% plot(tsTime,gyro3Y,tsTime,pulseA);
plot(tsTime,gyro3Y,tsTime,pulseB);
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

gyro3Z_filtered = SmoothFilter(tsTime, gyro3Z, plotFlag,'Gyro Z',cutoff);
gyro3Y_filtered = SmoothFilter(tsTime, gyro3Y, plotFlag,'Gyro Y',cutoff);

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

% Tremsem Gyro.Z
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

% Tremsem Gyro.Y
h6(4) = subplot(4,1,4);
plot(tsTime,gyro3Y_filtered);
line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
    [min(gyro3Y_filtered) max(gyro3Y_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Gyroscope (y-axis)','FontSize',20);
ylabel('\circ/s','FontSize',20);

xlabel('Time (s)','FontSize',20);
linkaxes(h6,'x');

% Peak analysis (run peakAnalysis.m)

%% Save all figures and workspace data
% 1 = Windows | 0 = Mac or Linux
osInfo = ispc;
saveFigsScript1;
close all;

% Save all workspace data
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
% clear all;
% clc;

%% Feature analysis (run featureAnalysis.m), just after to save filtered signals

%% Time frequency analysis (run timeFrequencyAnalysis.m)
