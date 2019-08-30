% Run this file after filtering all signals
% PhD student - F?bio Henrique (oliveirafhm@gmail.com) - 30/01/2018

%% Load and prepare data for feature extraction (amplitude)
clear;
% Load filtered signals .mat
matFileNames = uigetfile('*.mat','Choose .mat files to load filtered signals', 'MultiSelect','on');
if (class(matFileNames) == 'cell')
    for i=1:length(matFileNames)
        load(matFileNames{i});
    end
else
    load(matFileNames);
end
% Convert all .mat loaded into a struct
varsToStruct = who('-regexp', 'FilteredSignal_\w');
FilteredSignals = [eval([varsToStruct{1}])];
if (length(varsToStruct) > 1)
    for i=2:length(varsToStruct)
        FilteredSignals(i) = eval([varsToStruct{i}]);
    end
end
% Cleanup varsToStruct
clear(varsToStruct{:});

%% Feature extraction
input('Pay attention to fill with correct subject, iteration, ... [Enter to continue]');
subject = 1;
iterations = [1,2];
sensors = [2,4];
ffnLength = length(iterations)*length(sensors);
featureFileNames = cell(ffnLength,1);
featureFileNames(:) = {''};
% Pay attention to fill with correct iteration, ...
% FeatExtraction(inputSignal,windows,subject,iteration,sensorName)
j = 1;
for i=1:length(iterations)
    [~, fileName, header] = FeatExtraction(FilteredSignals(i).upperEnv_ps2_filtered, ...
        FilteredSignals(i).windowsFiltered, subject, iterations(i), sensors(1));
    featureFileNames(j) = {fileName};
    [~, fileName] = FeatExtraction(FilteredSignals(i).upperEnv_ps4_filtered, ...
        FilteredSignals(i).windowsFiltered, subject, iterations(i), sensors(2));
    featureFileNames(j+1) = {fileName};
    j = j + 2;
end