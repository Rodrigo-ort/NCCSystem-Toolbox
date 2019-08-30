% Time-frequency analysis
% Run after windowing1.m
% PhD student - Fabio Henrique (oliveirafhm@gmail.com) - 23/01/2019
% Last modification: 21/08/2019
% To be used in final paper of 06/2019

clear all;
clc;
%% Load sheet with subjects data and organize it to be used
% [sdXlsFileName, sdXlsPath] = uigetfile('.xlsx', ...
%     'Select subjects .xlsx data file');
if ispc
    sdXlsPath = 'C:\Users\olive\OneDrive\Doutorado\Thesis\Coletas\Coletas_08_2018\voluntarios\';
else
    sdXlsPath = '/Users/oliveirafhm/OneDrive/Doutorado/Thesis/Coletas/Coletas_08_2018/voluntarios/';
end
sdXlsFileName = 'DadosColetas.xlsx';

tic
while 1
    [~,~,rawSDXls] = xlsread([sdXlsPath sdXlsFileName],3);
    
    % Create table for the loaded data
    sdTable = cell2table(rawSDXls(2:end,:),...
        'VariableNames',rawSDXls(1,:));
    % If there is no more data to process, stop it
    if length(sdTable(sdTable.FinalPaperStatus == 0,:).UniqueID) < 1
       break; 
    end
    % Pick subject index to work with
    % subjectIndex = input('\nType subject unique ID: ');
    % Alternative way - Pick first index of FinalPaperStatus column == 0
    subjectIndex = sdTable(sdTable.FinalPaperStatus == 0,:).UniqueID(1);
    
    % hasPD = 1;
    % subjectIndex = find(not(cellfun('isempty',strfind(sdTable.ID, subjectID))));
    % if length(subjectID) > 1
    %     subjectIndex = subjectIndex(sdTable.Parkinson(subjectIndex) == hasPD);
    % end
    
    % Unique subject ID and subjects' experiment ID
    faData.uniqueId = sdTable.UniqueID(subjectIndex);
    faData.subjectID = char(sdTable.ID(subjectIndex));
    
    % Calc subject age
    d1 = datetime(sdTable.Birthdate(subjectIndex),'InputFormat','dd/MM/yyyy');
    d2 = datetime(sdTable.CollectionDate(subjectIndex),'InputFormat','dd/MM/yyyy');
    faData.age = year(d2 - d1);
    
    % Subject limb
    if strcmp(sdTable.EvaluatedLimb(subjectIndex), 'MSE'), faData.limb = 1;
    else faData.limb = 2; end
    
    % Group (1 - H and 2 - PD)
    faData.group = sdTable.Parkinson(subjectIndex) + 1;
    
    % Load data mat file with preprocessed data
    groupFolders = {'higidos', 'parkinson'};
    matPath = [sdXlsPath  groupFolders{faData.group}];
    % Filter folder
    subFoldersNames = GetDir(matPath, 1);
    folderIndex = strfind(subFoldersNames, faData.subjectID);
    folderIndex = find(not(cellfun('isempty',folderIndex)));
    folderName = subFoldersNames{folderIndex};
    f = filesep;
    matPath = [matPath f folderName f 'plessey'];
    % Filter .mat file to be loaded
    fileNames = GetDir(matPath, 2);
    matFiles = strfind(fileNames, '.mat');
    matFiles = find(not(cellfun('isempty',matFiles)));
    matFiles = fileNames(matFiles);
    
%     commandwindow;
    % Flags to save XLS and .mat file
    saveXLS = 0; saveMat = 1; saveFigs = 1;
    % Flags to remove highest frequency component and task signal trend
    rmHF = 0; rmTrend = 1;
    
    continueCounter = 0;
    
    %% Get file name of a specific trial
    for trial = 1:3
        disp(['********** Trial ' int2str(trial) ' **********']);
        faData.trial = trial;
        trialFile = strfind(matFiles, ['0' num2str(trial)]);
        trialFile = find(not(cellfun('isempty',trialFile)));
        trialFile = matFiles{trialFile};
        
        % Load mat file
        matFileName = trialFile;
        load([matPath f matFileName]);
        
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
        %     figAllSignals = figure;
        %
        %     % Plessey pair 1 (x-axis)
        %     h6(1) = subplot(4,1,1);
        %     plot(ps1TimeFiltered,env_ps1_filtered);
        %     line([ps1TimeFiltered(ps1WindowsFiltered) ps1TimeFiltered(ps1WindowsFiltered)], ...
        %         [min(env_ps1_filtered) max(env_ps1_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
        %     title('Non-contact capacitive sensor (x-axis)','FontSize',20);
        %     ylabel('Amplitude (V)','FontSize',20);
        %     xlim([ps1TimeFiltered(1) ps1TimeFiltered(end)]);
        %
        %     % Tremsen Gyro.Z
        %     h6(2) = subplot(4,1,2);
        %     plot(tsTime,gyro3Z_filtered);
        %     line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
        %         [min(gyro3Z_filtered) max(gyro3Z_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
        %     title('Gyroscope (z-axis)','FontSize',20);
        %     ylabel('\circ/s','FontSize',20);
        %
        %     % Plessey pair 2 (y-axis)
        %     h6(3) = subplot(4,1,3);
        %     plot(ps2TimeFiltered,env_ps2_filtered);
        %     line([ps2TimeFiltered(ps2WindowsFiltered) ps2TimeFiltered(ps2WindowsFiltered)], ...
        %         [min(env_ps2_filtered) max(env_ps2_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
        %     title('Non-contact capacitive sensor (y-axis)','FontSize',20);
        %     ylabel('Amplitude (V)','FontSize',20);
        %     xlim([ps2TimeFiltered(1) ps2TimeFiltered(end)]);
        %
        %     % Tremsen Gyro.Y
        %     h6(4) = subplot(4,1,4);
        %     plot(tsTime,gyro3Y_filtered);
        %     line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
        %         [min(gyro3Y_filtered) max(gyro3Y_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
        %     title('Gyroscope (y-axis)','FontSize',20);
        %     ylabel('\circ/s','FontSize',20);
        %
        %     xlabel('Time (s)','FontSize',20);
        %     linkaxes(h6,'x');
        
        disp(fileName);
        %% Select task to be analyzed
        % To avoid bug in save figures algorithm
        close all;
        % T1 and T2 = Pose against gravity | T3 and T4 = left and right movement on
        % x-axis of NCC | T5 and T6 = flexion and extesion movement on y-axis of
        % NCC | T7 and T8 = same as T3 and T4, 15 times | T9 and T10 = same as T5
        % and T6, 15 times
        
        % Parse valid tasks
        if trial == 1, tasks = sdTable.Trial_1(subjectIndex);
        elseif trial == 2, tasks = sdTable.Trial_2(subjectIndex);
        elseif trial == 3, tasks = sdTable.Trial_3(subjectIndex);
        end
        % Skip this execution, because there is no valid task to be processed
        if strcmp(tasks, '-1')
            continueCounter = continueCounter + 1;
            continue;
        end
        % Remove spaces
        tasks = tasks(~isspace(tasks));
        % Split
        tasks = regexp(tasks, '&', 'split');
        sTasks = [];
        for ti = 1:length(tasks{1})
            t = tasks{1}{ti};
            t = regexp(t, '-', 'split');
            if length(t) == 2
                sTasks = [sTasks str2num(t{1}):str2num(t{2})];
            else
                sTasks = [sTasks str2num(t{1})];
            end
        end
        faData.tasks = sTasks;
        
        for t = 1:length(sTasks)
            %% Select task to be analyzed
            selectedTask = sTasks(t);
            disp(['-------- TASK ' int2str(selectedTask) ' --------']);
            % NCC = Non-contact capacitive
            nccTaskWn1 = ps1WindowsFiltered(selectedTask):ps1WindowsFiltered(selectedTask+1);
            nccTaskWn2 = ps2WindowsFiltered(selectedTask):ps2WindowsFiltered(selectedTask+1);
            tsTaskWn = tsWindows(selectedTask):tsWindows(selectedTask+1);
            
            %% Plot selected task signal for both sensors (NCC and Gyro)
            figure;
            
            % Plessey pair 1 (x-axis)
            h7(1) = subplot(2,2,1);
            plot(ps1TimeFiltered(nccTaskWn1),env_ps1_filtered(nccTaskWn1));
            % line([ps1TimeFiltered(ps1WindowsFiltered) ps1TimeFiltered(ps1WindowsFiltered)], ...
            %     [min(env_ps1_filtered) max(env_ps1_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
            title(['Task ' num2str(selectedTask) ' - NCC sensor (x-axis)'],'FontSize',20);
            ylabel('Amplitude (V)','FontSize',20);
            xlim([ps1TimeFiltered(nccTaskWn1(1)) ps1TimeFiltered(nccTaskWn1(end))]);
            
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
            plot(ps2TimeFiltered(nccTaskWn2),env_ps2_filtered(nccTaskWn2));
            % line([ps2TimeFiltered(ps2WindowsFiltered) ps2TimeFiltered(ps2WindowsFiltered)], ...
            %     [min(env_ps2_filtered) max(env_ps2_filtered)], 'Color',[1 0 0], 'LineStyle', '-.');
            title(['Task ' num2str(selectedTask) ' - NCC sensor (y-axis)'],'FontSize',20);
            ylabel('Amplitude (V)','FontSize',20);
            xlim([ps2TimeFiltered(nccTaskWn2(1)) ps2TimeFiltered(nccTaskWn2(end))]);
            
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
            
            %% Signal filtering (remove offset and signal trash) - Plessey signal
            if rmTrend
                plotFlag = 1;
                % Cut-off frequency in Hz (used to estimate smooth parameters)
                %     cutoff = 12;
                % NCC
                env_ps1_filtered_task = SmoothFilter1(ps1TimeFiltered(nccTaskWn1), ...
                    env_ps1_filtered(nccTaskWn1),...
                    plotFlag,['NCC x-axis Task ' num2str(selectedTask)],cutoff);
                env_ps2_filtered_task = SmoothFilter1(ps2TimeFiltered(nccTaskWn2), ...
                    env_ps2_filtered(nccTaskWn2),...
                    plotFlag,['NCC y-axis Task ' num2str(selectedTask)],cutoff);
                % Gyro
                gyro3Z_filtered_task = SmoothFilter1(tsTime(tsTaskWn), ...
                    gyro3Z_filtered(tsTaskWn),...
                    plotFlag,['Gyro Z Task ' num2str(selectedTask)],cutoff);
                gyro3Y_filtered_task = SmoothFilter1(tsTime(tsTaskWn), ...
                    gyro3Y_filtered(tsTaskWn),...
                    plotFlag,['Gyro Y Task ' num2str(selectedTask)],cutoff);
                % Temp to test
                %             commandwindow;
                %             input('[Enter to continue...]');
            end
            
            %% Hilbert Spectrum analysis (using Andrade's methods)
            % addpath(genpath(['andrade_code' filesep 'EMD---Hilbert-Spectrum-master']));
            addpath(genpath(['andrade_code/EMD---Hilbert-Spectrum-master']));
            addpath(genpath('Third party codes'));
            rmHighestFreq = [rmHF,rmHF,rmHF,rmHF];
            plotFlag = 1;
            
            if rmTrend
                y = {env_ps1_filtered_task,gyro3Z_filtered_task,...
                    env_ps2_filtered_task,gyro3Y_filtered_task};
            else
                y = {env_ps1_filtered(nccTaskWn1),gyro3Z_filtered(tsTaskWn),...
                    env_ps2_filtered(nccTaskWn2),gyro3Y_filtered(tsTaskWn)};
            end
            label = {'NCC sensor (x-axis)','Gyroscope (z-axis)',...
                'NCC sensor (y-axis)','Gyroscope (y-axis)'};
            
            % Calc adjusted NCC sample frequency (assume that ps1 has same
            % length of ps2)
            tTemp = ps1TimeFiltered(nccTaskWn1(end)) - ps1TimeFiltered(nccTaskWn1(1));
            adjNCCFs = round(length(ps1TimeFiltered(nccTaskWn1)) / tTemp, 0);
            %
            fs = [adjNCCFs, tsFs, adjNCCFs, tsFs];
            % Run IMNF function (wrap of IMNFSubjects script example)
            imnfs =[]; ds = {}; hfFreq = [];
            for i = 1:length(y)
                [imnfs(:,i), ds{i}, hfFreq(i)] = IMNFWrap1(y{i}', fs(i), rmHighestFreq(i),...
                    plotFlag, label{i});
            end
            %% Check median frequency to continue
            freqThreshold = mean([ds{2}.quartile(2),ds{4}.quartile(2)])*3;
            if ds{1}.quartile(2) > freqThreshold || ds{3}.quartile(2) > freqThreshold
                disp('Consider remove highest frequency from NCC signal...');
%                 commandwindow;
%                 input('[Enter to continue...]');
            end
            %% Organize data to be saved
            % Workaround for data that was processed before 31/01/2019
            % osInfo is a variable created today, all data processed before today was
            % processed in Windows plataform
            %     if exist('osInfo','var') == 1
            %         if osInfo == 1
            %             rawInfo = strsplit(filePath, '\'); % Win
            %         else rawInfo = strsplit(filePath, '/'); end % Non win
            %     else
            %         rawInfo = strsplit(filePath, '\');
            %         osInfo = 1;
            %     end
            
            subjectId = faData.uniqueId;
            age = faData.age;
            
            limb = faData.limb;
            %     aux = lower(strsplit(rawInfo{end},'_'));
            %     if aux{end}(1) == 'l', limb = 1; elseif aux{end}(1) == 'r', limb = 2; end
            
            group = faData.group;
            %     aux = lower(rawInfo{end - 3});
            %     if aux(1) == 'h', group = 1; elseif aux(1) == 'p', group = 2; end
            
            %     trial = strsplit(rawInfo{end},'_'); trial = str2num(trial{2});
            
            % 1 = X and 2 = Y
            axis = [1,1,2,2];
            faData.axis = axis;
            
            % 1 = NCC and 2 = Gyro
            sensor = [1,2,1,2];
            faData.sensor = sensor;
            
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
                % TEST
%                 bpQ1 = ds{i}.quartile{1};
%                 bpMedian = ds{i}.quartile{2};
%                 bpQ3 = ds{i}.quartile{3};
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
                    [subjectId, age, limb, group, trial, selectedTask, axis(i), sensor(i),...
                    bpMin, bpQ1, bpMedian, bpQ3, bpMax, bpNOutliers, hfFreq(i)];
            end
            
            %% Write frequency analysis data in XLS file
            poiPath = 'Third party codes/xlswrite/20130227_xlwrite/poi_library/';
            javaaddpath([poiPath 'poi-3.8-20120326.jar']);
            javaaddpath([poiPath 'poi-ooxml-3.8-20120326.jar']);
            javaaddpath([poiPath 'poi-ooxml-schemas-3.8-20120326.jar']);
            javaaddpath([poiPath 'xmlbeans-2.3.0.jar']);
            javaaddpath([poiPath 'dom4j-1.6.1.jar']);
            javaaddpath([poiPath 'stax-api-1.0.1.jar']);
            if ispc
                xlsPath = 'C:\Users\olive\OneDrive\Doutorado\Papers\2019\FinalPaper\';
            else
                xlsPath = '/Users/oliveirafhm/OneDrive/Doutorado/Papers/2019/FinalPaper/';
            end
            xlsFileName = 'frequency_analysis.xlsx';
            if saveXLS == 1
                % Load first sheet (AnalysisVx) to get number of filled lines
                [~,~,rawXlsData] = xlsread([xlsPath xlsFileName],1);
                lastXlsLine = length(rawXlsData(:,1));
                
                xlwrite([xlsPath xlsFileName],frequencyAnalysis,1,...
                    ['A' int2str(lastXlsLine+1)]);
            end
            %% Save figures
            baseName = ['T' num2str(selectedTask) '_' date];
            if rmTrend
                figureNames = {'_TaskSignal', '_NCC_X_TrendRemoval', '_NCC_Y_TrendRemoval',...
                    '_Gyro_Z_TrendRemoval', '_Gyro_Y_TrendRemoval',...
                    '_HS_NCC_X', '_Boxplot_IMNF_NCC_X', '_HS_Gyro_Z', '_Boxplot_IMNF_Gyro_Z',...
                    '_HS_NCC_Y', '_Boxplot_IMNF_NCC_Y', '_HS_Gyro_Y', '_Boxplot_IMNF_Gyro_Y'};
            else
                figureNames = {'_TaskSignal',...
                    '_HS_NCC_X', '_Boxplot_IMNF_NCC_X', '_HS_Gyro_Z', '_Boxplot_IMNF_Gyro_Z',...
                    '_HS_NCC_Y', '_Boxplot_IMNF_NCC_Y', '_HS_Gyro_Y', '_Boxplot_IMNF_Gyro_Y'};
            end
            for i = 1:length(figureNames)
                figureNames{i} = [baseName figureNames{i}];
            end
            
            % Define path to save the figures and get all figure handles to save it
            if saveFigs == 1, saveFigsScript2; end
            close all;
            
            %% Save time-frequency data in .mat
            if saveMat == 1
                tfaFolderName = ['time_frequency_analysis_v3' f folderName];
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
                fullTFAFilePath = [fullTFAPath f tfaFileName];
                save(fullTFAFilePath, 'fullTFAFilePath', 'baseName', 'figureNames',...
                    'xlsPath', 'frequencyAnalysis',  'imnfs', 'ds', 'selectedTask', 'y', ...
                    'label', 'faData');
            end
            % clearvars -except fullTFAFilePath;
            %     baseName
            % Temp to test
            %         commandwindow;
            %         input('[Enter to continue...]');
        end
    end
    %% Update FinalPaperStatus    
    if continueCounter == 3
        xlwrite([sdXlsPath sdXlsFileName],-1,3,...
            ['O' int2str(faData.uniqueId+1)]);
    else
        xlwrite([sdXlsPath sdXlsFileName],1,3,...
            ['O' int2str(faData.uniqueId+1)]);
    end
end
toc
%% Proceed to statistics analysis (run statsTFAnalysis1.m)
% clear all;
% clc;
