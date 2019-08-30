% Cluster analysis
% Run after timeFrequencyAnalysis3.m or statsTFAnalysis1.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 24/06/2019
% Last modification: xx/xx/2019
% To be used in final paper of 06/2019

%% Load XLS file with frequency features
clear all;
% close all;

xlsPath = 'C:\Users\olive\OneDrive\Doutorado\Papers\2019\FinalPaper\';
xlsFileName = 'frequency_analysis.xlsx';

load('frequency_analysis_v3.mat');
freqAnalyTable = frequencyanalysis;

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

%% Filter by task, axis and sensor, and also normalize the data.
addpath(genpath('Third party codes'));
% Remove NaN occurrences
filtro = ~isnan(freqAnalyTable.q1);
FEATMATRIX = freqAnalyTable(filtro,:);

% Norm each group separately (0)
% Norm all groups together (1)
normMethod = 1;
nGroups = length(unique(FEATMATRIX.group));

% Choose which task will be analyzed (0 to all)
% 2 - Static hand against gravity
% 3 - Radial deviation (5x) | 4 - Ulnar deviation (5x)
% 5 - Wrist flexion (5x) | 6 - Wrist extension (5x)
% 7 - Radial deviation (15x) | 8 - Ulnar deviation (15x)
% 9 - Wrist flexion (15x) | 10 - Wrist extension (15x)
task = inputdlg('Type task number? 2 - 10');
task = str2double(task{1});

% Choose which axis will be analyzed (0 to all)
% 1 - X | 2 - Y
axis = inputdlg('Type axis number? 1 - X | 2 - Y');
axis = str2double(axis{1});

% Choose which sensor will be analyzed (0 to all)
% 1 - NCC | 2 - Gyro
sensor = inputdlg('Type sensor number? 1 - NCC | 2 - Gyro');
sensor = str2double(sensor{1});

% Before normalization
z = cell(nGroups,1);
% After normalization
Z = cell(nGroups,1);
clear t; clear filtro;

% Pick all IMNF features and - number of outliers
fDataColumn = 9;
varFilter = fDataColumn:length(FEATMATRIX.Properties.VariableNames)-1;

for i=1:nGroups    
    % Pick only non parkinson subjects (H) when i == 1
    % Pick only parkinson subjects (PD) when i == 2
    
    filtro = FEATMATRIX.group == i;
    
    if task ~= 0
        filtro = filtro & FEATMATRIX.task == task;
    end
    if axis ~= 0
        filtro = filtro & FEATMATRIX.axis == axis;
    end
    if sensor ~= 0
        filtro = filtro & FEATMATRIX.sensor == sensor;
    end
    
    iia{i} = find(filtro);
    
    if i == 1, t{i} = 'S_{H}';
    elseif i == 2, t{i} = 'S_{PD}';
    end
    
    z{i} = FEATMATRIX(iia{i},varFilter);
    Z{i} = zeros(size(z{i}));
    %
    if normMethod == 0
        % Data normalization using each individual group
        Z{i} = zscore(table2array(z{i}));
    
    elseif normMethod == 1 && i == nGroups
        % Data normalization using all groups together
        Z0 = [];
        for jj=1:nGroups
           Z0 = [Z0 ; table2array(z{jj})]; 
        end
%         Z0 = cell2mat(z);
        Z0 = zscore(Z0);
        zAux = [0];
        for j=1:nGroups
            zAux = [zAux ; zAux(j)+length(iia{j})];
            Z{j} =  Z0(zAux(j)+1:zAux(j+1),:);
        end
        clear Z0;
    end
end

%% Split data (train and test sets)
% percentOut =  0.1;
% percentIn = 1 - percentOut;
% rng('shuffle');
% clear ZOut ZIn;
% for i = 1:nGroups
%     % Sample size per class
%     nSamples = size(Z{i},1);
%     % Sample out size
%     nSamplesOut = ceil(nSamples * percentOut);
%     % Random select samples to stay out (test set)
%     outSamples{i} = randperm(nSamples, nSamplesOut)';
%     ZOut{i,1} = Z{i}(outSamples{i},:);
%     % Selects samples that will be used to train and cross-validate the model
%     samplesIndexes = (1:nSamples)';
%     aux = ~ismember(samplesIndexes, outSamples{i});
%     inSamples{i} = samplesIndexes(aux);
%     ZIn{i,1} = Z{i}(inSamples{i},:);
% end

%% Organize data
trainData = cell2mat(Z);
% testData = cell2mat(ZOut);
% % Generate labels, pick subject data and put everything together
trainLabels = []; %testLabels = [];
trainSubjectData = []; %testSubjectData = [];
for i=1:nGroups
    trainSubjectData = [trainSubjectData ; FEATMATRIX(iia{i}, 1:fDataColumn-1)];
%     testSubjectData = [testSubjectData ; FEATMATRIX(iia{i}(outSamples{i}), 1:5)];
    
    trainLabels = [trainLabels ; FEATMATRIX(iia{i},4)];
%     testLabels = [testLabels ; FEATMATRIX(iia{i}(outSamples{i}),4) + ...
%         FEATMATRIX(iia{i}(outSamples{i}),5) + 1];
end

%% t-SNE projection
addpath(genpath('Third party codes'));

% clear x1 x2;
% Z1 = trainData;
Z1 = trainData;

% t-SNE projection algorithm parameters
initial_dims = size(Z1, 2);
% https://lvdmaaten.github.io/tsne/
perplexity = inputdlg('Type perplexity param: (int between 5 - 50)');
perplexity = str2double(perplexity{1});

max_iter = inputdlg('Type max_inter param: (int between 1000 - 5000)');
max_iter = str2double(max_iter{1});

learning_rate = inputdlg('Type learning_rate param: (between 300 - 700)');
learning_rate = str2double(learning_rate{1});

[s, mappingInfo] = compute_mapping(Z1, 'tSNE', 2, initial_dims, perplexity,...
    max_iter, learning_rate,[]);
mappingInfo.iter = -1;

% Reassembly of data array with each individual data + projections
% instead of features
% Train subject data + DR projection
Y = [table2array(trainSubjectData) s];
% Projection + class (group)
x1 = [s table2array(trainLabels)];

%% Define baseName, resultsXlsName and titleBaseName vars
taskNames = {'All tasks','Static hand',...
    'Radial deviation (5x)','Ulnar deviation (5x)',...
    'Flexion (5x)','Extension (5x)',...
    'Radial deviation (15x)','Ulnar deviation (15x)',...
    'Flexion (15x)','Extension (15x)'};
axisNames = {'All axis','x-axis','y-axis'};
sensorNames = {'All sensors','NCC','Gyro'};
% 
baseName = '';
if task == 0, baseName = [baseName taskNames{task+1}];
else baseName = [baseName 'T' int2str(task) '_' taskNames{task}];
end
baseName = [baseName '_' axisNames{axis+1} '_' sensorNames{sensor+1}];
%
resultsXlsName = ['_t-SNE' '_MI_' int2str(max_iter) ...
    '_LR_' num2str(learning_rate) ...
    '_PE_' int2str(perplexity)];
baseName = [baseName resultsXlsName '_' date];
titleBaseName = strrep(baseName, '_', ' ');
%
%% Plot DR method projection
baseFontSize = 17;
markerSize = 10;
figure;
hold on;
% Last color will be used by test set points
gColors = ['b','k','r','m','g','c']; % for tasks
gMarkers = ['^','*','o']; % for groups
for i=1:nGroups    
    % Pick only non parkinson subjects when i == 1
    % Pick only parkinson subjects when i == 2
    filtro = Y(:,4) == i;    
    Y1 = Y(filtro,:);
    
    % Task x (var task was declared in the second section of this script)
    if task ~= 0
        iib = find(Y1(:,taskColumn) == task);
        plot(Y1(iib,9), Y1(iib,10), [gColors(i) gMarkers(i)], ...
            'MarkerSize',markerSize);
    else
        macroTasks = {[2,2],[3,7],[4,8],[5,9],[6,10]};
        % One color for each macro task
        for j=1:length(macroTasks)  
            filtro = Y1(:,taskColumn) == macroTasks{j}(1) | ...
                Y1(:,taskColumn) == macroTasks{j}(2);
            iib = find(filtro);
            plot(Y1(iib,9), Y1(iib,10), [gColors(j) gMarkers(i)], ...
                'MarkerSize',markerSize);
        end
    end
end
% For to plot test set points
% for i=1:nGroups
%     iib = find(testLabels == i);
%     plot(oos.projection(iib,1),oos.projection(iib,2), ...
%         [gColors(end) gMarkers(i)], 'MarkerSize',markerSize);
% end
title(titleBaseName, 'FontSize', baseFontSize+2);

legend(t{1},t{2},...
    'Location','Best','fontsize',baseFontSize);
xlabel('Dimension 1','fontsize',baseFontSize);
ylabel('Dimension 2','fontsize',baseFontSize);
set(gca,'fontsize',baseFontSize);
grid on;
hold off;
%

