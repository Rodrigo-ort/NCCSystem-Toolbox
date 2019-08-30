% Statistics of time-frequency analysis
% Run after timeFrequencyAnalysis1.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 01/02/2019
% Last modification: xx/xx/2019
% Used in EMB 2019 congress

%% Load XLS file with frequency data
% [xlsFileName, xlsPath] = uigetfile('.xlsx', ...
%     'Select frequency data file');
% [~,~,rawXlsData] = xlsread([xlsPath xlsFileName],1);
% xlsHeader = rawXlsData(1,:);
% xlsData = rawXlsData(2:end,:);
% Create table...

% Use import tool of matlab (import as table)
frequencyanalysis = frequencyanalysiscorrected;
%% ------------ (Analysis 1 - Separate groups) ------------
%% Filter data for boxplot
task = 2;
fa = frequencyanalysis; idx = {};
idx{1} = fa.task == task & fa.group == 1; % Healthy
idx{2} = fa.task == task & fa.group == 2; % PD
H = fa(idx{1},:); PD = fa(idx{2},:);
% data = fa(idx,{'group','task'});
fDataColumn = 9;

%% Boxplot (matlab)
axis = {'x-axis','y-axis'};
sensor = {'NCC','Gyroscope'};
varFilter = fDataColumn:length(fa.Properties.VariableNames)-1;
variableNames = fa.Properties.VariableNames(varFilter);
figure; j = 0;
for i = 1:2
    j = j+1;
    titleInfo = [' | Task ' int2str(task) ' | ' axis{i}];
    h8(j) = subplot(2,2,j);
    boxplot(H{H.axis == i,varFilter},variableNames);
    title(['Healthy IMNF' titleInfo]);
    xlabel('Variables');
    ylabel('Instantaneous mean frequency (Hz)');
    
    j = j+1;
    h8(j) = subplot(2,2,j);
    boxplot(PD{PD.axis == i,varFilter},variableNames);
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
disp(variableNames);
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
%% Filter data for boxplot
task = 2;
fa = frequencyanalysis; idx = {};
idx{1} = fa.task == task & fa.sensor == 1; % NCC
idx{2} = fa.task == task & fa.sensor == 2; % Gyro
NCC = fa(idx{1},:); gyro = fa(idx{2},:);
fDataColumn = 9;

%% Organize data to be plotted 
axis = {'x-axis','y-axis'};
sensor = {'NCC','Gyro'};
group = {'Healthy','PD'};
varFilter = fDataColumn:length(fa.Properties.VariableNames)-1;
variableNames = fa.Properties.VariableNames(varFilter);

% Create a 4D matrix for frequency data (sample x freqVariable x axis x group)
freqDataNCC = NaN(sum(NCC.axis == 1 & NCC.group == 1), length(varFilter),...
    length(axis), length(group));
freqDataGyro = NaN(sum(gyro.axis == 1 & gyro.group == 1), length(varFilter),...
    length(axis), length(group));

% Organize freqData in a 4D matrix
for i = 1:length(group)
   for j = 1:length(axis)
       freqDataNCC(:,:,j,i) = NCC{(NCC.axis == j & NCC.group == i),varFilter};
       freqDataGyro(:,:,j,i) = gyro{(gyro.axis == j & gyro.group == i),varFilter};
   end
end

%% Boxplot using third party code
addpath(genpath('Third party codes'));
boxplot2 = @iosr.statistics.boxPlot;

factor = 10;
group1Labels = {'x-axis','y-axis'};
disp(variableNames);
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

%% One-sample Kolmogorov-Smirnov test
% 0 = normal distribution
% 1 = non-normal distribution

% group x freqVariable x axis
normalityDataNCC = NaN(length(group), length(varFilter), length(axis));
normalityDataGyro = NaN(length(group), length(varFilter), length(axis));

for a = 1:length(axis)
    for v = 1:length(varFilter)
        for g = 1:length(group)
            %                                sample x axis x freqVariable x group
            normalityDataNCC(g,v,a) = kstest(fdNCC(:,a,v,g));
            normalityDataGyro(g,v,a) = kstest(fdGyro(:,a,v,g));
        end
    end
end

%% Wilcoxon rank sum test (for non-normal distributions)
% 0 = Equal medians
% 1 = Non-equal medians

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

openvar('pDataNCC');
openvar('hDataNCC');
openvar('pDataGyro');
openvar('hDataGyro');