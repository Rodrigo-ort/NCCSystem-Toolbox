% Time-frequency analysis
% Run after windowing1.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 23/01/2019
% Last modification: xx/xx/2019
% Used in EMB 2019 congress

%% Load data mat file with preprocessed data

%% Choose task to be analyzed
% T1 and T2 = Pose against gravity | T3 and T4 = left and right movement on
% x-axis of NCC | T5 and T6 = flexion and extesion movement on y-axis of
% NCC | T7 and T8 = same as T3 and T4, 15 times | T9 and T10 = same as T5
% and T6, 15 times
commandwindow;
selectedTask = input('\nType the task number (1 - 10): ');
% NCC = Non-contact capacitive
nccTaskWn = windowsFiltered(selectedTask):windowsFiltered(selectedTask+1);
tsTaskWn = tsWindows(selectedTask):tsWindows(selectedTask+1);

% Plot all sensor signals (last figure of windowing1.m)
% to help during visual analysis

%% Plot selected task signal for both sensors (NCC and Gyro)
figure;

% Plessey pair 1 (x-axis)
h7(1) = subplot(2,2,1);
plot(ps1TimeFiltered(nccTaskWn),env_ps1_filtered(nccTaskWn));
% line([ps1TimeFiltered(ps1WindowsFiltered) ps1TimeFiltered(ps1WindowsFiltered)], ...
%     [min(env_ps1_filtered) max(env_ps1_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title(['Task ' num2str(selectedTask) ' - NCC sensor (x-axis)'],'FontSize',20);
ylabel('Amplitude (V)','FontSize',20);
xlim([ps1TimeFiltered(nccTaskWn(1)) ps1TimeFiltered(nccTaskWn(end))]);

% Tremsem G?.Z
h7(2) = subplot(2,2,3);
plot(tsTime(tsTaskWn),gyro3Z_filtered(tsTaskWn));
% line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
%     [min(gyro3Z_filtered) max(gyro3Z_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title(['Task ' num2str(selectedTask) ' - Gyroscope (z-axis)'],'FontSize',20);
ylabel('\circ/s','FontSize',20);
xlim([tsTime(tsTaskWn(1)) tsTime(tsTaskWn(end))]);

xlabel('Time (s)','FontSize',20);

% Plessey pair 2 (y-axis)
h7(3) = subplot(2,2,2);
plot(ps2TimeFiltered(nccTaskWn),env_ps2_filtered(nccTaskWn));
% line([ps2TimeFiltered(ps2WindowsFiltered) ps2TimeFiltered(ps2WindowsFiltered)], ...
%     [min(env_ps2_filtered) max(env_ps2_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title(['Task ' num2str(selectedTask) ' - NCC sensor (y-axis)'],'FontSize',20);
ylabel('Amplitude (V)','FontSize',20);
xlim([ps2TimeFiltered(nccTaskWn(1)) ps2TimeFiltered(nccTaskWn(end))]);

% Tremsem G?.Y
h7(4) = subplot(2,2,4);
plot(tsTime(tsTaskWn),gyro3Y_filtered(tsTaskWn));
% line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
%     [min(gyro3Y_filtered) max(gyro3Y_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title(['Task ' num2str(selectedTask) ' - Gyroscope (y-axis)'],'FontSize',20);
ylabel('\circ/s','FontSize',20);
xlim([tsTime(tsTaskWn(1)) tsTime(tsTaskWn(end))]);

xlabel('Time (s)','FontSize',20);
linkaxes(h7,'x');

%% Periodogram
frequencyLimits = 0.5:12;
figure;

% Plessey pair 1 (x-axis)
h8(1) = subplot(2,2,1);
periodogram(env_ps1_filtered(nccTaskWn), [], frequencyLimits, meanEnvSampleRate);
title('NCC sensor (x-axis)','FontSize',20);

% Tremsem Gyro.Z
h8(2) = subplot(2,2,3);
periodogram(gyro3Z_filtered(tsTaskWn), [], frequencyLimits, tsFs);
title('Gyroscope (z-axis)','FontSize',20);

% Plessey pair 2 (y-axis)
h8(3) = subplot(2,2,2);
periodogram(env_ps2_filtered(nccTaskWn), [], frequencyLimits, meanEnvSampleRate);
title('NCC sensor (y-axis)','FontSize',20);

% Tremsem Gyro.Y
h8(4) = subplot(2,2,4);
periodogram(gyro3Y_filtered(tsTaskWn), [], frequencyLimits, tsFs);
title('Gyroscope (y-axis)','FontSize',20);

%% Spectrogram
% If you specify window as empty,
% then spectrogram uses a Hamming window such that x is divided into eight segments with noverlap overlapping samples.

% Explanation about spectrogram function resolution:
% https://www.mathworks.com/matlabcentral/answers/12763-can-i-set-a-range-for-spectrogram-analysis

% In seconds (dont put less than 1 second - of samples in nfft,
% if so, you will get less than 1 Hz of resolution in the spectrogram plot)
wnFactor = 1;
if wnFactor > 0, nccWnLength = round(meanEnvSampleRate * wnFactor); else nccWnLength = []; end
if wnFactor > 0, tsWnLength = round(tsFs * wnFactor); else tsWnLength = []; end

wnOverlap = 0.9; % In percentage

nccMinThreshold = -80; % In dB
tsMinThreshold = -10;

specParams = ['Wn: ' num2str(wnFactor) 's Overlap: ' num2str(wnOverlap*100) '%'];

figure;

% Plessey pair 1 (x-axis)
h9(1) = subplot(2,2,1);
% spectrogram(env_ps1_filtered(nccTaskWn), nccWnLength, round(nccWnLength * wnOverlap),...
%     [], meanEnvSampleRate, 'yaxis', 'MinThreshold', nccMinThreshold, 'reassigned');
spectrogram(env_ps1_filtered(nccTaskWn), nccWnLength, round(nccWnLength * wnOverlap),...
    [], meanEnvSampleRate, 'yaxis', 'MinThreshold', nccMinThreshold);
ylim([frequencyLimits(1),frequencyLimits(end)]);
title([specParams ' - NCC sensor (x-axis)'],'FontSize',20);

% Tremsem Gyro.Z
h9(2) = subplot(2,2,3);
% spectrogram(gyro3Z_filtered(tsTaskWn), tsWnLength, round(tsWnLength * wnOverlap),...
%     [], tsFs, 'yaxis', 'MinThreshold', tsMinThreshold, 'reassigned');
spectrogram(gyro3Z_filtered(tsTaskWn), tsWnLength, round(tsWnLength * wnOverlap),...
    [], tsFs, 'yaxis', 'MinThreshold', tsMinThreshold);
ylim([frequencyLimits(1),frequencyLimits(end)]);
title('Gyroscope (z-axis)','FontSize',20);

% Plessey pair 2 (y-axis)
h9(3) = subplot(2,2,2);
% spectrogram(env_ps2_filtered(nccTaskWn), nccWnLength, round(nccWnLength * wnOverlap),...
%     [], meanEnvSampleRate, 'yaxis', 'MinThreshold', nccMinThreshold, 'reassigned');
spectrogram(env_ps2_filtered(nccTaskWn), nccWnLength, round(nccWnLength * wnOverlap),...
    [], meanEnvSampleRate, 'yaxis', 'MinThreshold', nccMinThreshold);
ylim([frequencyLimits(1),frequencyLimits(end)]);
title('NCC sensor (y-axis)','FontSize',20);

% Tremsem Gyro.Y
h9(4) = subplot(2,2,4);
% spectrogram(gyro3Y_filtered(tsTaskWn), tsWnLength, round(tsWnLength * wnOverlap),...
%     [], tsFs, 'yaxis', 'MinThreshold', tsMinThreshold, 'reassigned');
spectrogram(gyro3Y_filtered(tsTaskWn), tsWnLength, round(tsWnLength * wnOverlap),...
    [], tsFs, 'yaxis', 'MinThreshold', tsMinThreshold);
ylim([frequencyLimits(1),frequencyLimits(end)]);
title('Gyroscope (y-axis)','FontSize',20);

%% Hilbert Spectrum analysis (using Andrade's methods)

addpath(genpath('andrade_code\EMD---Hilbert-Spectrum-master'));
% 1 = x-axis | 2 = y-axis
selectedAxis = 2;
rmHighestFreq = [0,0];
plotFlag = 1;

if selectedAxis == 1
    y = {env_ps1_filtered(nccTaskWn),gyro3Z_filtered(tsTaskWn)};
    label = {'NCC sensor (x-axis)','Gyroscope (z-axis)'};
elseif selectedAxis == 2
    y = {env_ps2_filtered(nccTaskWn),gyro3Y_filtered(tsTaskWn)};
    label = {'NCC sensor (y-axis)','Gyroscope (y-axis)'};
end

fs = [meanEnvSampleRate, tsFs];
% Run IMNF function (wrap of IMNFSubjects script example)
imnfs =[]; ds = {};
for i = 1:length(y)
    [imnfs(:,i), ds{i}] = IMNFWrap(y{i}', fs(i), rmHighestFreq(i),...
        plotFlag, label{i});
end

%% Organize data to be saved
frequencyAnalysis = [];


%% Save figures and workspace data


%% Coherence analysis (TODO)

% [Cxy,F] = mscohere(x,y,hamming(100),80,100,Fs);
% plot(F,Cxy)
% title('Magnitude-Squared Coherence')
% xlabel('Frequency (Hz)')
% grid

