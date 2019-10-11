% Statistics of time-frequency analysis
% Run after timeFrequencyAnalysis3.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 01/02/2019
% Last modification: 05/10/2019
% To be used in final paper of 06/2019

%% Load XLS file with frequency data (features)
clear all;
clc;
% [xlsFileName, xlsPath] = uigetfile('.xlsx', 'Select frequency data file');
if ispc
    xlsPath = 'C:\Users\olive\OneDrive\Doutorado\Papers\2019\FinalPaper\';
else
    xlsPath = '/Users/oliveirafhm/OneDrive/Doutorado/Papers/2019/FinalPaper/';
end
xlsFileName = 'frequency_analysis.xlsx';
% [~,~,rawXlsData] = xlsread([xlsPath xlsFileName],1);
% xlsHeader = rawXlsData(1,:);
% xlsData = rawXlsData(2:end,:);
% Create table...
% freqAnalyTable = cell2table(xlsData, 'VariableNames', xlsHeader);

% load('frequency_analysis_v4.mat');
freqAnalyTable = frequencyanalysis;
saveFig = 0; saveMat = 0;

% Fix of task code for left-handed subjects
taskColumn = 6;
leftHandedTable = freqAnalyTable(freqAnalyTable.limb == 1, taskColumn);

idxT3 = leftHandedTable.task == 3;
idxT4 = leftHandedTable.task == 4;
idxT7 = leftHandedTable.task == 7;
idxT8 = leftHandedTable.task == 8;

leftHandedTable.task(idxT3) = 4;
leftHandedTable.task(idxT4) = 3;
leftHandedTable.task(idxT7) = 8;
leftHandedTable.task(idxT8) = 7;

freqAnalyTable(freqAnalyTable.limb == 1, taskColumn).task = leftHandedTable.task;

%% ------------ (Analysis 1 - Separate groups) ------------
% Filter data for boxplot
tasks = unique(freqAnalyTable.task);
for t = 1:length(tasks)
    %%
%     t = 9;% to test
    task = tasks(t);
    fa = freqAnalyTable; idx = {};
    idx{1} = fa.task == task & fa.group == 1; % Healthy
    idx{2} = fa.task == task & fa.group == 2; % PD
    H = fa(idx{1},:); PD = fa(idx{2},:);
    % data = fa(idx,{'group','task'});
    fDataColumn = 9;
    
    %% Boxplot (matlab)
    axis = {'x-axis','y-axis'};
    sensor = {'NCC','Gyroscope'};
    varFilter = fDataColumn:length(fa.Properties.VariableNames)-2;
    variableNames = fa.Properties.VariableNames(varFilter);
    figure; j = 0; maxYLim = ceil(max([max(H.max) max(PD.max)]));
    for i = 1:2
        j = j+1;
        titleInfo = [' | Task ' int2str(task) ' | ' axis{i}];
        h8(j) = subplot(2,2,j);
        boxplot(H{H.axis == i,varFilter},variableNames);
        ylim([0 maxYLim]);
        title(['Healthy IMNF' titleInfo]);
        xlabel('Variables');
        ylabel('Instantaneous mean frequency (Hz)');
        
        j = j+1;
        h8(j) = subplot(2,2,j);
        boxplot(PD{PD.axis == i,varFilter},variableNames);
        ylim([0 maxYLim]);
        title(['PD IMNF' titleInfo]);
        xlabel('Variables');
        ylabel('Instantaneous mean frequency (Hz)');
    end
    
    %% Organize data to be plotted
    % Create a 4D matrix for frequency data (sample x freqVariable x axis x sensor)
    freqDataH = NaN(sum(H.axis == 1 & H.sensor == 1), length(varFilter),...
        length(axis), length(sensor));
    freqDataPD = NaN(sum(PD.axis == 1 & PD.sensor == 1), length(varFilter),...
        length(axis), length(sensor));
    
    % Organize freqData in a 4D matrix
    for i = 1:length(sensor)
        for j = 1:length(axis)
            freqDataH(:,:,j,i) = H{(H.axis == j & H.sensor == i),varFilter};
            freqDataPD(:,:,j,i) = PD{(PD.axis == j & PD.sensor == i),varFilter};
        end
    end
    
    %% Boxplot using third party code
    addpath(genpath('Third party codes'));
    boxplot2 = @iosr.statistics.boxPlot;
    
    %   BOXPLOT can draw boxes for data in Y for an arbitrary number of
    %   dimensions. If Y is an N-by-P-by-G-by-I-by-J... array then G*I*J*...
    %   boxes are plotted hierarchically for each column P; i.e. J boxes are
    %   plotted for each index of I, and J*I boxes are plotted for each index
    %   of G.
    factor = 10;
    group1Labels = {'x-axis','y-axis'};
%     disp(variableNames);
    group2Labels = {'min','q1','median','q3','max'};
    boxLabels = {'NCC','Gyro'};
    
    % Boxplot of Healthy group
    % Permute matrix dimensions to better draw the boxplot
    % Default order: (sample x freqVariable x axis x sensor)
    % fdh = freqDataH;
    % New order: sample x axis x freqVariable x sensor
    fdH = permute(freqDataH,[1 3 2 4]);
    
    figure;
    % h9(1) = subplot(2,1,1);
    boxplot2(group1Labels, fdH, 'notch', false, ...
        'symbolColor','k',...
        'medianColor','k',...
        'theme', 'default',...
        'outlierSize', 36+factor,...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{group2Labels,boxLabels});
    box on;
    title(['Healthy IMNF' ' | Task ' int2str(task)]);
    ylabel('Instantaneous mean frequency (Hz)');
    
    % Boxplot of PD group
    % New order: sample x axis x freqVariable x sensor
    fdPD = permute(freqDataPD,[1 3 2 4]);
    
    figure;
    % h9(2) = subplot(2,1,2);
    boxplot2(group1Labels, fdPD, 'notch', false, ...
        'symbolColor','k',...
        'medianColor','k',...
        'theme', 'default',...
        'outlierSize', 36+factor,...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabels',{group2Labels,boxLabels});
    box on;
    title(['PD IMNF' ' | Task ' int2str(task)]);
    ylabel('Instantaneous mean frequency (Hz)');
    
    %% ------------ (Analysis 2 - Separate sensors) ------------
    % Filter data for boxplot
    task = tasks(t);
    fa = freqAnalyTable; idx = {};
    idx{1} = fa.task == task & fa.sensor == 1; % NCC
    idx{2} = fa.task == task & fa.sensor == 2; % Gyro
    NCC = fa(idx{1},:); gyro = fa(idx{2},:);
    fDataColumn = 9;
    
    %% Organize data to be plotted
    axis = {'x-axis','y-axis'};
    sensor = {'NCC','Gyro'};
    group = {'Healthy','PD'};
    varFilter = fDataColumn:length(fa.Properties.VariableNames)-2;
    variableNames = fa.Properties.VariableNames(varFilter);
    
    % Create a 4D matrix for frequency data (sample x freqVariable x axis x group)
    freqDataNCC = NaN(sum(NCC.axis == 1 & NCC.group == 2), length(varFilter),...
        length(axis), length(group));
    freqDataGyro = NaN(sum(gyro.axis == 1 & gyro.group == 2), length(varFilter),...
        length(axis), length(group));
    
    % Organize freqData in a 4D matrix
    for i = 1:length(group)
        for j = 1:length(axis)
            nccAux = NCC{(NCC.axis == j & NCC.group == i),varFilter};
            nccSize = size(nccAux);
            freqDataNCC(1:nccSize(1),:,j,i) = nccAux;
            
            gyroAux = gyro{(gyro.axis == j & gyro.group == i),varFilter};
            gyroSize = size(gyroAux);
            freqDataGyro(1:gyroSize(1),:,j,i) = gyroAux;
        end
    end
    
    %% Boxplot using third party code
    addpath(genpath('Third party codes'));
    boxplot2 = @iosr.statistics.boxPlot;
    
    factor = 10;
    group1Labels = {'x-axis','y-axis'};
    % disp(variableNames);
    group2Labels = {'min','q1','median','q3','max'};
    boxLabels = {'H','PD'};
    
    % Boxplot of NCC sensor
    % New order: sample x axis x freqVariable x group
    fdNCC = permute(freqDataNCC,[1 3 2 4]);
    
    figure;
    % h9(1) = subplot(2,1,1);
    boxplot2(group1Labels, fdNCC, 'notch', false, ...
        'symbolColor','k',...
        'medianColor','k',...
        'theme', 'default',...
        'outlierSize', 36+factor,...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabelFontSize',9+factor/2,...
        'groupLabels',{group2Labels,boxLabels});
    box on;
    title(['NCC sensor | IMNF' ' | Task ' int2str(task)]);
    ylabel('Instantaneous mean frequency (Hz)');
    
    % Boxplot of Gyro sensor
    % New order: sample x axis x freqVariable x group
    fdGyro = permute(freqDataGyro,[1 3 2 4]);
    
    figure;
    % h9(2) = subplot(2,1,2);
    boxplot2(group1Labels, fdGyro, 'notch', false, ...
        'symbolColor','k',...
        'medianColor','k',...
        'theme', 'default',...
        'outlierSize', 36+factor,...
        'style','hierarchy',...
        'xSeparator',true,...
        'groupLabelFontSize',9+factor/2,...
        'groupLabels',{group2Labels,boxLabels});
    box on;
    title(['Gyro sensor | IMNF' ' | Task ' int2str(task)]);
    ylabel('Instantaneous mean frequency (Hz)');
    
    %% Save figures
    basePath = 'C:\Users\olive\OneDrive\Doutorado\Papers\2019\FinalPaper\';
    folderName = ['Figures' filesep 'Task_' num2str(task)];
    baseName = ['T' num2str(task) '_' date];
    figureNames = {'_H_PD_IMNF',...
        '_Sensor_comparison_H_IMNF', '_Sensor_comparison_PD_IMNF',...
        '_Group_comparison_NCC_IMNF', '_Group_comparison_Gyro_IMNF'};
    
    for i = 1:length(figureNames)
        figureNames{i} = [baseName figureNames{i}];
    end
    
    % Define path to save the figures and get all figure handles to save it
    if saveFig == 1, saveFigsScript4; end
    close all;
    
    %% One-sample Kolmogorov-Smirnov test
    % 0 = normal distribution
    % 1 = non-normal distribution
    
    % group x freqVariable x axis
    normalityDataNCC = NaN(length(group), length(varFilter), length(axis));
    normalityDataGyro = NaN(length(group), length(varFilter), length(axis));
    
    for a = 1:length(axis)
        for v = 1:length(varFilter)
            for g = 1:length(group)
                %                         sample x axis x freqVariable x group
                normalityDataNCC(g,v,a) = kstest(fdNCC(:,a,v,g));
                normalityDataGyro(g,v,a) = kstest(fdGyro(:,a,v,g));
            end
        end
    end
%     openvar('normalityDataNCC');
%     openvar('normalityDataGyro');
    %% Wilcoxon rank sum test (for non-normal distributions)
    % 0 = Equal medians
    % 1 = Non-equal medians
    if mean(mean(mean(normalityDataNCC))) && mean(mean(mean(normalityDataGyro)))
        disp('Wilcoxon rank sum test');
        % freqVariable x axis
        pDataNCC = NaN(length(varFilter), length(axis));
        hDataNCC = NaN(length(varFilter), length(axis));
        pDataGyro = NaN(length(varFilter), length(axis));
        hDataGyro = NaN(length(varFilter), length(axis));
        
        for a = 1:length(axis)
            for v = 1:length(varFilter)
                %                                sample x axis x freqVariable x group
                [pDataNCC(v,a),hDataNCC(v,a)] = ranksum(fdNCC(:,a,v,1),fdNCC(:,a,v,2));
                [pDataGyro(v,a),hDataGyro(v,a)] = ranksum(fdGyro(:,a,v,1),fdGyro(:,a,v,2));
            end
        end
        
        % XLS write
        poiPath = 'Third party codes/xlswrite/20130227_xlwrite/poi_library/';
        javaaddpath([poiPath 'poi-3.8-20120326.jar']);
        javaaddpath([poiPath 'poi-ooxml-3.8-20120326.jar']);
        javaaddpath([poiPath 'poi-ooxml-schemas-3.8-20120326.jar']);
        javaaddpath([poiPath 'xmlbeans-2.3.0.jar']);
        javaaddpath([poiPath 'dom4j-1.6.1.jar']);
        javaaddpath([poiPath 'stax-api-1.0.1.jar']);
        %
        linesXls = 5:9:77;
        xlwrite([xlsPath xlsFileName],pDataNCC,2,...
            ['B' int2str(linesXls(t))]);
        xlwrite([xlsPath xlsFileName],hDataNCC,2,...
            ['E' int2str(linesXls(t))]);
        
        xlwrite([xlsPath xlsFileName],pDataGyro,2,...
            ['I' int2str(linesXls(t))]);
        xlwrite([xlsPath xlsFileName],hDataGyro,2,...
            ['L' int2str(linesXls(t))]);
        %
    end
    
    %% Save workspace data in .mat
    if saveMat == 1
        fileName = [baseName '_FrequencyAnalysis.mat'];
        fullPath = [basePath filesep fileName];
        save(fullPath);
    end
end

%% Statistical test for age (data from DadosColetas sheet)
% TODO: Improve to pick data directly from .xlsx
h_age = [62;53;48;76;75;71;48;57;48;60;65;55;69;54;54;73;71;67;62;66;63;58;61;48;61;60;54;NaN;NaN;NaN];
pd_age = [63;54;47;76;74;70;48;56;48;60;64;55;69;53;50;73;72;67;62;66;62;78;56;61;49;62;60;72;55;82];

kstest(h_age)
kstest(pd_age)

% if 1 for the two kstests, sample is non-normal
[p,h] = ranksum(h_age,pd_age)

%% Next: clusterAnalysis.m
% clear all;
% clc;
