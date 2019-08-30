% Time-frequency analysis
% Run after windowing1.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 23/01/2019
% Last modification: 31/01/2019
% Used in EMB 2019 congress

%% Load data mat file with preprocessed data
[matFileName, matPath] = uigetfile('.mat', ...
    'Select subject .mat file with preprocessed data');
load([matPath '/' matFileName]);

%% Fix possible PS signal length (backup step)
while(length(env_ps1_filtered) > length(env_ps2_filtered))
    env_ps2_filtered(end+1) = 0;
    ps2TimeFiltered(end+1) = ps2TimeFiltered(end) + 1/meanEnvSampleRate;
    disp('Fixing why ps1 has more points than ps2');
end
while(length(env_ps1_filtered) < length(env_ps2_filtered))
    env_ps1_filtered(end+1) = 0;
    ps1TimeFiltered(end+1) = ps1TimeFiltered(end) + 1/meanEnvSampleRate;
    disp('Fixing why PS2 has more points than PS1');
end

%% Plot all sensor signals (last figure of windowing1.m)
% to help during visual analysis
figAllSignals = figure;

% Plessey pair 1 (x-axis)
h6(1) = subplot(4,1,1);
plot(ps1TimeFiltered,env_ps1_filtered);
line([ps1TimeFiltered(ps1WindowsFiltered) ps1TimeFiltered(ps1WindowsFiltered)], ...
    [min(env_ps1_filtered) max(env_ps1_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Non-contact capacitive sensor (x-axis)','FontSize',20);
ylabel('Amplitude (V)','FontSize',20);
xlim([ps1TimeFiltered(1) ps1TimeFiltered(end)]);

% Tremsen Gyro.Z
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

% Tremsen Gyro.Y
h6(4) = subplot(4,1,4);
plot(tsTime,gyro3Y_filtered);
line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
    [min(gyro3Y_filtered) max(gyro3Y_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Gyroscope (y-axis)','FontSize',20);
ylabel('\circ/s','FontSize',20);

xlabel('Time (s)','FontSize',20);
linkaxes(h6,'x');

%% Choose task to be analyzed
% try
    %     close(figAllSignals);
% end
% To avoid bug in save figures algorithm
close all;
% T1 and T2 = Pose against gravity | T3 and T4 = left and right movement on
% x-axis of NCC | T5 and T6 = flexion and extesion movement on y-axis of
% NCC | T7 and T8 = same as T3 and T4, 15 times | T9 and T10 = same as T5
% and T6, 15 times
commandwindow;
% Flag to save XLS and .mat file
saveXLS = input('\nWould you like to save IMNF data(0 or 1)? '); 
rmHFNCC = input('\nWould you like to remove highest freq of NCC signal(0 or 1)? ');
for selectedTask = 2:10
    disp(['-------- TASK ' int2str(selectedTask) ' --------']);
    % NCC = Non-contact capacitive
    nccTaskWn = windowsFiltered(selectedTask):windowsFiltered(selectedTask+1);
    tsTaskWn = tsWindows(selectedTask):tsWindows(selectedTask+1);
    
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
    
    % Tremsen G?.Z
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
    
    % Tremsen G?.Y
    h7(4) = subplot(2,2,4);
    plot(tsTime(tsTaskWn),gyro3Y_filtered(tsTaskWn));
    % line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
    %     [min(gyro3Y_filtered) max(gyro3Y_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
    title(['Task ' num2str(selectedTask) ' - Gyroscope (y-axis)'],'FontSize',20);
    ylabel('\circ/s','FontSize',20);
    xlim([tsTime(tsTaskWn(1)) tsTime(tsTaskWn(end))]);
    
    xlabel('Time (s)','FontSize',20);
    linkaxes(h7,'x');
    
    %% Hilbert Spectrum analysis (using Andrade's methods)
    % addpath(genpath(['andrade_code' filesep 'EMD---Hilbert-Spectrum-master']));
    addpath(genpath(['andrade_code/EMD---Hilbert-Spectrum-master']));
    addpath(genpath('Third party codes'));
    rmHighestFreq = [rmHFNCC,0,rmHFNCC,0];
    plotFlag = 1;
    
    y = {env_ps1_filtered(nccTaskWn),gyro3Z_filtered(tsTaskWn),...
        env_ps2_filtered(nccTaskWn),gyro3Y_filtered(tsTaskWn)};
    label = {'NCC sensor (x-axis)','Gyroscope (z-axis)',...
        'NCC sensor (y-axis)','Gyroscope (y-axis)'};
    
    fs = [meanEnvSampleRate, tsFs, meanEnvSampleRate, tsFs];
    % Run IMNF function (wrap of IMNFSubjects script example)
    imnfs =[]; ds = {};
    for i = 1:length(y)
        [imnfs(:,i), ds{i}] = IMNFWrap(y{i}', fs(i), rmHighestFreq(i),...
            plotFlag, label{i});
    end
    %% Check median frequency to continue
    freqThreshold = mean([ds{2}.quartile(2),ds{4}.quartile(2)])*3;
    if ds{1}.quartile(2) > freqThreshold || ds{3}.quartile(2) > freqThreshold
        disp('Consider remove highest frequency from NCC signal...');
        commandwindow;
        input('[Enter to continue...]');
    end
    %% Organize data to be saved
    % Workaround for data that was processed before 31/01/2019
    % osInfo is a variable created today, all data processed before today was
    % processed in Windows plataform
    if exist('osInfo','var') == 1
        if osInfo == 1
            rawInfo = strsplit(filePath, '\'); % Win
        else rawInfo = strsplit(filePath, '/'); end % Non win
    else
        rawInfo = strsplit(filePath, '\');
        osInfo = 1;
    end
    
    subjectId = str2num(rawInfo{end - 2}(2:3));
    age = -1;
    
    limb = -1;
    aux = lower(strsplit(rawInfo{end},'_'));
    if aux{end}(1) == 'l', limb = 1; elseif aux{end}(1) == 'r', limb = 2; end
    
    group = -1;
    aux = lower(rawInfo{end - 3});
    if aux(1) == 'h', group = 1; elseif aux(1) == 'p', group = 2; end
    
    % selectedTask
    trial = strsplit(rawInfo{end},'_'); trial = str2num(trial{2});
    % 1 = X and 2 = Y
    axis = [1,1,2,2];
    % 1 = NCC and 2 = Gyro
    sensor = [1,2,1,2];
    
    frequencyAnalysis = [];
    for i = 1:length(ds)
        % Find bp_min (min value excluding outliers)
        if sum(imnfs(:,i) < ds{i}.iOutliers(1)) == 0
            bpMin = min(imnfs(:,i));
        else
            sortedImnf = sort(imnfs(:,i));
            aux = find(sortedImnf < ds{i}.iOutliers(1));
            bpMin = sortedImnf(aux(end)+1);
        end
        bpQ1 = ds{i}.quartile(1);
        bpMedian = ds{i}.quartile(2);
        bpQ3 = ds{i}.quartile(3);
        % Find bp_max (max value excluding outliers)
        if sum(imnfs(:,i) > ds{i}.iOutliers(2)) == 0
            bpMax = max(imnfs(:,i));
        else
            sortedImnf = sort(imnfs(:,i));
            aux = find(sortedImnf > ds{i}.iOutliers(2));
            bpMax = sortedImnf(aux(1)-1);
        end
        bpNOutliers = ds{i}.nOutliers;
        frequencyAnalysis(i,:) = ...
            [subjectId, age, limb, group, selectedTask, trial, axis(i), sensor(i),...
            bpMin, bpQ1, bpMedian, bpQ3, bpMax, bpNOutliers];
    end
    
    %% Write frequency analysis data in XLS file
    if saveXLS == 1
        poiPath = 'Third party codes/xlswrite/20130227_xlwrite/poi_library/';
        javaaddpath([poiPath 'poi-3.8-20120326.jar']);
        javaaddpath([poiPath 'poi-ooxml-3.8-20120326.jar']);
        javaaddpath([poiPath 'poi-ooxml-schemas-3.8-20120326.jar']);
        javaaddpath([poiPath 'xmlbeans-2.3.0.jar']);
        javaaddpath([poiPath 'dom4j-1.6.1.jar']);
        javaaddpath([poiPath 'stax-api-1.0.1.jar']);
        if ispc
            xlsPath = 'C:\Users\olive\OneDrive\Doutorado\Congressos\2019\41_EMB\';
        else
            xlsPath = '/Users/oliveirafhm/OneDrive/Doutorado/Congressos/2019/41_EMB/';
        end
        xlsFileName = 'frequency_analysis.xls';
        % Load first sheet (AnalysisV1) to get number of filled lines
        [~,~,rawXlsData] = xlsread([xlsPath xlsFileName],1);
        lastXlsLine = length(rawXlsData(:,1));
        
        xlwrite([xlsPath xlsFileName],frequencyAnalysis,1,...
            ['A' int2str(lastXlsLine+1)]);
    end
    %% Save figures
    baseName = ['T' num2str(selectedTask) '_' date];
    figureNames = {'_TaskSignal',...
        '_HS_NCC_X', '_Boxplot_IMNF_NCC_X', '_HS_Gyro_Z', '_Boxplot_IMNF_Gyro_Z',...
        '_HS_NCC_Y', '_Boxplot_IMNF_NCC_Y', '_HS_Gyro_Y', '_Boxplot_IMNF_Gyro_Y'};
    for i = 1:length(figureNames)
        figureNames{i} = [baseName figureNames{i}];
    end
    
    % Define path to save the figures and get all figure handles to save it
    saveFigsScript2;
    close all;
    
    %% Save time-frequency data in .mat
    if saveXLS == 1
        tfaFolderName = ['time_frequency_analysis_v1' '/' folderName];
        fullTFAPath = [pathName tfaFolderName];
        % Fix for diferent SO
        if osInfo ~= 1
           fullTFAPath = strrep(['C:' fullTFAPath],'oliveirafhm','olive');
        end
        if(isdir(fullTFAPath))
            disp('Folder already present');
        else
            mkdir(fullTFAPath);
            disp(['Created folder ' fullTFAPath]);
        end
        tfaFileName = [baseName '_TimeFrequencyData.mat'];
        fullTFAFilePath = [fullTFAPath '/' tfaFileName];
        save(fullTFAFilePath, 'fullTFAFilePath', 'baseName', 'figureNames',...
            'xlsPath', 'frequencyAnalysis',  'imnfs', 'ds', 'selectedTask', 'y', ...
            'label');
    end
    % clearvars -except fullTFAFilePath;
    %     baseName
end
%% Proceed to statistics analysis (run statsAnalysis.m)
clear all;
clc;
