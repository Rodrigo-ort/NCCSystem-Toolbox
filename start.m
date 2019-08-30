% Load data, envelope and visualization
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 30/01/2018
% Last mod: 21/03/2018
% Last used in CBEB 2018 paper

%% Load data..
close all;
clear all;
clc;

[fileName, pathName] = uigetfile('.csv', ...
    'Select plessey signal file');
filePath = strcat(pathName, fileName);
commandwindow;
startRow = input('Type signal start row: ');
try
    data = csvread(filePath, startRow, 0);
    lData = length(data);
catch
    % Section for when overruns happen
    rCols = [1,2,3,4,5,6,7];%,8,9]; % Columns to be read
    data = importcsvfile(filePath, rCols, startRow+1);
    lData = length(data);
    % Fix possible overruns
    data(any(isnan(data),2),:) = [];
    lData = length(data) - lData;
end

%% Convert integer adc data to volts and other adjustments
adcResolution = 12; %bits
factor = 2 ^ adcResolution;

time = data(:,1);
bS = data(:,2);
ps1 = data(:,3); % Sensor pair 1
ps2 = data(:,4); % Sensor pair 2
anaInA = data(:,5);
digInA = data(:,6);
digInB = data(:,7);
% Workaround (we forgot to update arduino firmware) - Remove after firmware
% update
% anaInA = data(:,7);
% digInA = data(:,8);
% digInB = data(:,9);

initTime = time(1)/1000000;
for i=1:length(time)
    time(i) = (time(i)/1000000) - initTime;
    bS(i) = (bS(i) * 3.3) / factor;
    ps1(i) = (ps1(i) * 3.3) / factor;
    ps2(i) = (ps2(i) * 3.3) / factor;
    anaInA(i) = (anaInA(i) * 3.3) / factor;
end
plesseySampleRate = round(length(ps1) / time(end),0);

%% Get envelope of x-axis
% Envelope (peak) of 60Hz
envFrequency = 60;
minPeakDistance = floor((1/envFrequency) * plesseySampleRate) - 3;

[upperEnv_ps1,upperEnvIndex_ps1,lowerEnv_ps1,lowerEnvIndex_ps1] = Envelope(ps1,minPeakDistance);
[upperEnv_ps2,upperEnvIndex_ps2,lowerEnv_ps2,lowerEnvIndex_ps2] = Envelope(ps2,minPeakDistance);

% Estimate plessey sample rate after envelope
meanEnvSampleRate = round(length(lowerEnv_ps1) / time(end),0);

%% Show the original signal, its envelope and trigger for x and y-axis
figure;

h0(1) = subplot(2,1,1);
plot(time,ps1,time(upperEnvIndex_ps1),upperEnv_ps1,'r-.',time(lowerEnvIndex_ps1),lowerEnv_ps1,'r-.',...
    time,digInA,'k'); hold on;
title('Envelope vs the given signal data from Sensor pair 1 (x-axis)','FontSize',18); hold off;
ylabel('Raw sensor output (v)','FontSize',16);

h0(2) = subplot(2,1,2);
plot(time,ps2,time(upperEnvIndex_ps2),upperEnv_ps2,'r-.',time(lowerEnvIndex_ps2),lowerEnv_ps2,'r-.',...
    time,digInA,'k');
title('Envelope vs the given signal data from Sensor pair 2 (y-axis)','FontSize',18); hold off;
ylabel('Raw sensor output (v)','FontSize',16);

xlabel('Time (s)','FontSize',16);
linkaxes(h0,'x');

%% Show the envelope alone for x and y-axis along with trigger
figure;

h00(1) = subplot(2,1,1);
plot(time(upperEnvIndex_ps1),upperEnv_ps1,'r-',time(lowerEnvIndex_ps1),lowerEnv_ps1,'r-',...
    time,digInA,'k'); hold on;
title(['The envelope of Sensor pair 1 (x-axis) - ' fileName],'FontSize',18); hold off;
ylabel('Envelope of raw sensor output (v)','FontSize',16);

h00(2) = subplot(2,1,2);
plot(time(upperEnvIndex_ps2),upperEnv_ps2,'r-',time(lowerEnvIndex_ps2),lowerEnv_ps2,'r-',...
    time,digInA,'k'); hold on;
title(['The envelope of Sensor pair 2 (y-axis) - ' fileName],'FontSize',18); hold off;
ylabel('Envelope of raw sensor output (v)','FontSize',16);

xlabel('Time (s)','FontSize',16);
linkaxes(h00,'x');

%% Filter test
% addpath(genpath('andrade_code'));
% 
% yfilt1 = FiltSig(lowerEnv_ps1, meanEnvSampleRate);
% yfilt2 = FiltrarSinal(lowerEnv_ps1, 0.1, -1, meanEnvSampleRate);
% % figure;
% % plot(time(lowerEnvIndex_ps1),lowerEnv_ps1,'r-', time(lowerEnvIndex_ps1), yfilt, 'b-');
% 
% figure;
% h1(1) = subplot(3,1,1);
% plot(time(lowerEnvIndex_ps1),lowerEnv_ps1); hold on;
% title('Original','FontSize',18); hold off;
% 
% h1(2) = subplot(3,1,2);
% plot(time(lowerEnvIndex_ps1), yfilt1); hold on;
% title('FiltSig','FontSize',18); hold off;
% 
% h1(3) = subplot(3,1,3);
% plot(time(lowerEnvIndex_ps1), yfilt2); hold on;
% title('FiltrarSinal','FontSize',18); hold off;
% 
% linkaxes(h1,'x');

%% Run windowing.m file to proceed