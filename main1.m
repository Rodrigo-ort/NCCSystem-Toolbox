% Author: Fabio Henrique (oliveirafhm@gmail.com)
% Creation date: 09/01/2019
% Mod date: xx/xx/2019
% Used in EMB 2019 congress
% Used in final paper of 2019

%% Load data
close all;
% clear all;
clearvars -except pathName lastPath;
clc;
% Keep last path to speed-up 
if ~exist('lastPath','var'), lastPath = 0; end

if lastPath == 0
    [fileName, pathName] = uigetfile('.csv', ...
        'Select plessey signal file');
else
    [fileName, pathName] = uigetfile([lastPath '*.csv'], ...
        'Select plessey signal file');
end

if pathName ~= 0, lastPath = pathName; end
%
filePath = strcat(pathName, fileName);
% commandwindow;
startRow = 3;%input('Type signal start row: '); % NCC hardware 1.1 and newer: row 3
try
    opts = detectImportOptions(filePath);
    opts.DataLines = [startRow Inf];
    data = readtable(filePath, opts);
    % data = csvread(filePath, startRow, 0);
    lData = length(data);
catch
    % Section for when overruns happen
    rCols = [1,2,3,4,5,6,7]; % Columns to be read
    data = importcsvfile(filePath, rCols, startRow+1);
    lData = length(data);
    % Fix possible overruns
    data(any(isnan(data),2),:) = [];
    lData = length(data) - lData;
end

%% Convert integer adc data to volts and other adjustments
adcResolution = 12; %bits
adcVoltage = 3.3;
factor = 2 ^ adcResolution;

time = data(:,1);
bS = data(:,2);
ps1 = data(:,3); % Sensor pair 1 - x-axis
ps2 = data(:,4); % Sensor pair 2 - y-axis
anaInA = data(:,5);
digInA = data(:,6);
digInB = data(:,7);

initTime = time(1)/1000000;
for i=1:length(time)
    time(i) = (time(i)/1000000) - initTime;
    bS(i) = (bS(i) * adcVoltage) / factor;
    ps1(i) = (ps1(i) * adcVoltage) / factor;
    ps2(i) = (ps2(i) * adcVoltage) / factor;
    anaInA(i) = (anaInA(i) * adcVoltage) / factor;
end
plesseySampleRate = round(length(ps1) / time(end),0);

% Calc signal-noise-ratio?

%% Get envelope of x-axis
% Envelope (peak) of 60Hz
envFrequency = 60;
% minPeakDistance = floor((1/envFrequency) * plesseySampleRate) - 3;
minPeakDistance = floor((1/envFrequency) * plesseySampleRate) - 3;

[upperEnv_ps1,upperEnvIndex_ps1,lowerEnv_ps1,lowerEnvIndex_ps1] = Envelope(ps1,minPeakDistance, 1);
[upperEnv_ps2,upperEnvIndex_ps2,lowerEnv_ps2,lowerEnvIndex_ps2] = Envelope(ps2,minPeakDistance, 1);

% Estimate plessey sample rate after envelope
meanEnvSampleRate = round(length(lowerEnv_ps1) / time(end),0);

%% Show the original signal, its envelope and trigger for x and y-axis
figure;

h0(1) = subplot(2,1,1);
plot(time,ps1,time(upperEnvIndex_ps1),upperEnv_ps1,'r-.',time(lowerEnvIndex_ps1),lowerEnv_ps1,'r-.',...
    time,digInA,'k'); hold on;
title(['Envelope vs the given signal data from Sensor pair 1 (x-axis) - ' fileName],'FontSize',18,...
    'Interpreter', 'none'); hold off;
ylabel('Raw sensor output (v)','FontSize',16);

h0(2) = subplot(2,1,2);
plot(time,ps2,time(upperEnvIndex_ps2),upperEnv_ps2,'r-.',time(lowerEnvIndex_ps2),lowerEnv_ps2,'r-.',...
    time,digInA,'k');
title(['Envelope vs the given signal data from Sensor pair 2 (y-axis) - ' fileName],'FontSize',18,...
    'Interpreter', 'none'); hold off;
ylabel('Raw sensor output (v)','FontSize',16);

xlabel('Time (s)','FontSize',16);
linkaxes(h0,'x');
% Only for resolution analysis
close;

%% Show the envelope alone for x and y-axis along with trigger
figure;

h00(1) = subplot(2,1,1);
plot(time(upperEnvIndex_ps1),upperEnv_ps1,'r-',time(lowerEnvIndex_ps1),lowerEnv_ps1,'r-',...
    time,digInA,'k'); hold on;
title(['The envelope of Sensor pair 1 (x-axis) - ' fileName],'FontSize',18,...
    'Interpreter', 'none'); hold off;
ylabel('Envelope of raw sensor output (v)','FontSize',16);

h00(2) = subplot(2,1,2);
plot(time(upperEnvIndex_ps2),upperEnv_ps2,'r-',time(lowerEnvIndex_ps2),lowerEnv_ps2,'r-',...
    time,digInA,'k'); hold on;
title(['The envelope of Sensor pair 2 (y-axis) - ' fileName],'FontSize',18,...
    'Interpreter', 'none'); hold off;
ylabel('Envelope of raw sensor output (v)','FontSize',16);

xlabel('Time (s)','FontSize',16);
linkaxes(h00,'x');

%% Run windowing1.m file to proceed