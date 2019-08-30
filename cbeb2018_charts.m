% Run after all iterations of correlationAnalysis.m
% Author: Fabio Henrique (oliveirafhm@gmail.com)
% 19/04/2018
% Last mod: 19/04/2018

%% Load xls file or mat file

%% Filter and organize data in a matrix
xlsData = CorrelationAnalysisV2;

% Pick only non-outliers
xlsData = xlsData(xlsData(:,2) == 0,:);

xIdx = find(xlsData(:,5) == 1); % x-axis data
yIdx = find(xlsData(:,5) == 2); % y-axis data
axisIdx = {xIdx, yIdx};
xAxisData = xlsData(axisIdx{1},:);
yAxisData = xlsData(axisIdx{2},:);
axisData = {xAxisData, yAxisData};

nTasks = 8;
nAxis = 2;
corrSamplesN = max([length(xIdx) length(yIdx)]) / nTasks;

% Create a 3D matrix for corr table (corr x axis x task)
corrMatrix = NaN(corrSamplesN, nAxis, nTasks);
% Organize data in a 3D matrix
for ax = 1:nAxis
    nSamplesTask = length(axisIdx{ax}) / nTasks;
    for t = 1:nTasks
        tIdx = find(xlsData(axisIdx{ax},6) == t);
        % abs in corr to avoid bad boxplot
        corrMatrix(1:nSamplesTask, ax, t) = abs(axisData{ax}(tIdx, 7));
    end
end

percentPR = length(find(xlsData(:,8) < 0.05)) / length(xlsData) * 100;
fprintf('\nIn %.2f percent of the cases the correlation is significantly different from zero.\n',percentPR);

%% Mean, std and median calc
meanCorrMatrix = reshape(nanmean(corrMatrix),[nAxis,nTasks]);
medianCorrMatrix = reshape(nanmedian(corrMatrix),[nAxis,nTasks]);
stdCorrMatrix = reshape(nanstd(corrMatrix),[nAxis,nTasks]);

% Bar plot could better represent these data 
figure;
% hold on;
% plot(1:8, meanCorrMatrix(1,:), 1:8, meanCorrMatrix(2,:));
bar(1:8, meanCorrMatrix');
% errorbar(1:8,meanCorrMatrix,stdCorrMatrix,'.')
xlabel('Task');
ylabel('Mean R value');

figure;
% plot(1:8, medianCorrMatrix(1,:), 1:8, medianCorrMatrix(2,:));
bar(1:8, medianCorrMatrix');
xlabel('Task');
ylabel('Median R value');

%% Boxplot of corr (task by task per axis)
addpath(genpath('Third party codes'));
boxplot2 = @iosr.statistics.boxPlot;

factor = 10;
gLabels = {'x-axis','y-axis'};
labels = {'T1' 'T2' 'T3' 'T4' 'T5' 'T6' 'T7' 'T8'};

figure;
boxplot2(gLabels, corrMatrix, 'notch', false, ...
    'symbolColor','k',...
    'medianColor','k',...
    'theme', 'default',...
    'outlierSize', 36+factor,...
    'style','hierarchy',...
    'xSeparator',true,...
    'groupLabels',{labels});

box on;

%% Boxplot of R values only for x and y-axis (without consider any tasks)

xyCorrData = NaN(max([length(xIdx) length(yIdx)]),2);
xyCorrData(1:length(xIdx), 1) = abs(xAxisData(:, 7));
xyCorrData(1:length(yIdx), 2) = abs(yAxisData(:, 7));

figure;
boxplot2(xyCorrData, ...
    'medianColor','k',...
    'theme', 'default');
box on;

%% Boxplot of R values of 5 times and 15 times tasks for each corresponded axis
gTask = 2;
corrMatrixT = NaN(max([length(xIdx) length(yIdx)]), nAxis, gTask);

xAxisTasks = [1,2,5,6];
yAxisTasks = [3,4,7,8];

g1x = find(xAxisData(:, 6) == xAxisTasks(1) | xAxisData(:, 6) == xAxisTasks(2));
g2x = find(xAxisData(:, 6) == xAxisTasks(3) | xAxisData(:, 6) == xAxisTasks(4));

g1y = find(yAxisData(:, 6) == yAxisTasks(1) | yAxisData(:, 6) == yAxisTasks(2));
g2y = find(yAxisData(:, 6) == yAxisTasks(3) | yAxisData(:, 6) == yAxisTasks(4));

corrMatrixT(1:length(g1x), 1, 1) = abs(xAxisData(g1x, 7));
corrMatrixT(1:length(g2x), 1, 2) = abs(xAxisData(g2x, 7));

corrMatrixT(1:length(g1y), 2, 1) = abs(yAxisData(g1y, 7));
corrMatrixT(1:length(g2y), 2, 2) = abs(yAxisData(g2y, 7));

gLabels = {'x-axis','y-axis'};
labels = {'5 times' '15 times'};

figure;
boxplot2(gLabels, corrMatrixT, 'notch', false, ...
    'symbolColor','k',...
    'medianColor','k',...
    'theme', 'default',...
    'outlierSize', 36+factor,...
    'style','hierarchy',...
    'xSeparator',true,...
    'groupLabels',{labels});

box on;

%% Histogram
% nBins = (0:.1:1);
% h = histc(corrMatrix(:,1,1),nBins);
% figure;stem(nBins,h);
% figure;plot(nBins,h);

%% Frequency peak analysis

% only per axis
figure; plotregression(xAxisData(:, 10), xAxisData(:, 9), 'x-axis');
figure; plotregression(yAxisData(:, 10), yAxisData(:, 9), 'y-axis');

% per axis and group of tasks
figure; plotregression(xAxisData(g1x, 10), xAxisData(g1x, 9), 'x-axis | 5 times tasks');
figure; plotregression(xAxisData(g2x, 10), xAxisData(g2x, 9), 'x-axis | 15 times tasks');

figure; plotregression(yAxisData(g1y, 10), yAxisData(g1y, 9), 'y-axis | 5 times tasks');
figure; plotregression(yAxisData(g2y, 10), yAxisData(g2y, 9), 'y-axis | 15 times tasks');