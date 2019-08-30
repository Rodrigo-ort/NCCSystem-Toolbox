% Run this file after filtering all signals
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 03/02/2018

%% Load peak features

%% Descriptive statistics of the features
data = Analysisv3;
% infoData = data(:,1:8);
% featData = data(:,9:end);
infoData = data(:,1:8);
featData = data(:,9:end);

nH = length(find(data(:,2) == 0));
nPD = length(find(data(:,2) == 1));

indexH = find(data(:,2) == 0);
indexPD = find(data(:,2) == 1);
indexes = {indexH,indexPD};

tasks = unique(infoData(:,5));
% Filter by same n of repetition (index of each group)
n_5{1} = sort([find(data(indexH,5)==3);find(data(indexH,5)==4);...
    find(data(indexH,5)==5);find(data(indexH,5)==6)]);
n_5{2} = sort([find(data(indexPD,5)==3);find(data(indexPD,5)==4);...
    find(data(indexPD,5)==5);find(data(indexPD,5)==6)]);

n_15{1} = sort([find(data(indexH,5)==7);find(data(indexH,5)==8);...
    find(data(indexH,5)==9);find(data(indexH,5)==10)]);
n_15{2} = sort([find(data(indexPD,5)==7);find(data(indexPD,5)==8);...
    find(data(indexPD,5)==9);find(data(indexPD,5)==10)]);

groups = {'H','PD'};
% featColumns = {'npeaksps1';'npeaksgyroY';'npeaksgyroZ';...
%     'mpips1';'mpigyroY';'mpigyroZ';...
%     'mpaps1';'mpagyroY';'mpagyroZ';...
%     'tflps1';'tflgyroY';'tflgyroZ'};
featColumns = {'mpi_{ps1}';'mpi_{gyroY}';'mpi_{gyroZ}';...
    'mpa_{ps1}';'mpa_{gyroY}';'mpa_{gyroZ}';...
    'tfl_{ps1}';'tfl_{gyroY}';'tfl_{gyroZ}'};

%% zscore per class (h and pd)
% z1 = zscore(featData(indexH,:));
% z2 = zscore(featData(indexPD,:));
% featData = [z1;z2];
zfeatData = zscore(featData);

%% zscore per class and task


%% Correlation
corrHData = array2table(featData(indexH,:),...
    'VariableNames',featColumns);
corrPDData = array2table(featData(indexPD,:),...
    'VariableNames',featColumns);
% Pearson's linear correlation coefficient
[RH, PValueH] = corrplot(corrHData,'testR','on');
% title(['H group'],'FontSize',18);
[RPD, PValuePD] = corrplot(corrPDData,'testR','on');
% title(['PD group'],'FontSize',18);

%% Boxplot
addpath(genpath('Third party codes'));
boxplot2 = @iosr.statistics.boxPlot;

factor = 10;
% labels = {'median_peak_interval','median_amp_peak','time_firstpeak_lastpeak'};
% labels = {'1','2'};
% only feats related to time
colTimeFeats = [1 2 3 7 8 9];
timeFeatData = featData(:,colTimeFeats);
nFeats = 6;
startFeat = 1;
bpData1 = NaN(max(nH,nPD),nFeats,length(groups));
for feat = 1:nFeats
    bpData1(1:nH,feat,1) = timeFeatData(indexH,feat+startFeat-1);% healthy
    bpData1(1:nPD,feat,2) = timeFeatData(indexPD,feat+startFeat-1);% pd
end
figure;
boxplot2(featColumns(colTimeFeats), bpData1, 'notch', false, ...
    'symbolColor','k',...
    'medianColor','k',...
    'theme', 'default',...
    'outlierSize', 36+factor,...
    'style','hierarchy',...
    'xSeparator',true,...
    'groupLabels',{groups});
%     'groupLabelFontSize', 9+factor,...
%     title(['Feat ' featColumns{feat}],'FontSize',18);
box on;

%% Boxplot of 5 times mpi feat and 15 times mpi feat 
nFeats = 3;
nTimes = 2;% 5 or 15
colTimeFeats = [1 2 3];%only mpi
timeFeatData = featData(:,colTimeFeats);
bpData2 = NaN(max(nH,nPD),nFeats,length(groups),nTimes);
for feat = 1:nFeats
    for g = 1:2
        bpData2(1:length(n_5{g}),feat,g,1) = timeFeatData(indexes{g}(n_5{g}),feat);
        bpData2(1:length(n_15{g}),feat,g,2) = timeFeatData(indexes{g}(n_15{g}),feat);
    end
end
figure;
boxplot2(featColumns(colTimeFeats), bpData2(:,:,:,2), 'notch', false, ...
    'symbolColor','k',...
    'medianColor','k',...
    'theme', 'default',...
    'outlierSize', 36+factor,...
    'style','hierarchy',...
    'xSeparator',true,...
    'groupLabels',{groups});
%     'groupLabelFontSize', 9+factor,...
%     title(['Feat ' featColumns{feat}],'FontSize',18);
box on;


%% DR projection
addpath(genpath('Third party codes'));

initial_dims = 9;
perplexity = 15;
max_iter = 2000;
learning_rate = 500;

markers = ['o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '+'];
colors = ['b','r'];

%% 5 or 15 times task
%absolute index of 15 times tasks
pN = [indexH(n_15{1});indexPD(n_15{2})];
% pN = [indexH(n_5{1});indexPD(n_5{2})];
tempInfo = infoData(pN,:);
tempIndexes = {find(tempInfo(:,2)==0),find(tempInfo(:,2)==1)};

%t-SNE
[map, mappingInfo] = compute_mapping(zfeatData(pN,:), 'tSNE', 2, initial_dims, perplexity, max_iter, learning_rate,[]);


figure;
hold on;
for i=1:length(groups)
    plot(map(tempIndexes{i},1), map(tempIndexes{i}, 2), ...
        markers(i),'MarkerSize',10, 'Color',colors(i));
end
title(['t-SNE mapping'],'FontSize', 18);
hold off;

%% All feats
drLabels = {'t-SNE' 'Sammons' 'PCA'};
drMethod = 3;
if drMethod == 1
    % t-SNE
    [map, mappingInfo] = compute_mapping(zfeatData, 'tSNE', 2, initial_dims, perplexity, max_iter, learning_rate,[]);
elseif drMethod == 2
    % Sammon's
    opts = sammon;
    opts.Initialisation = 'pca';
    [map, mappingInfo] = compute_mapping(zfeatData, 'Sammon', 2, opts);
elseif drMethod == 3
    % PCA
    [map, mappingInfo] = compute_mapping(zfeatData, 'PCA', 2);
end

figure;
hold on;
for i=1:length(groups)
    plot(map(indexes{i},1), map(indexes{i}, 2), ...
        markers(i),'MarkerSize',14, 'Color',colors(i));
end
t = infoData(:,5);
for i=tasks(1):tasks(end)
    text(map(t == i, 1), map(t == i, 2), num2str(i-2), 'Color', 'k', ...
        'FontSize', 16, ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
end
title([drLabels{drMethod}],'FontSize', 18);
hold off;
pbaspect([1 1 1]);