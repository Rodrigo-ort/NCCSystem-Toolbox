% Run after main1.m
% Author: Fabio Henrique (oliveirafhm@gmail.com)
% Creation date: 18/05/2019
% Mod date: xx/xx/2019

%% Load data
% Run main1.m to load data

%% Check file name to know which axis should be analyzed
% time
% digInA - trigger signal
fileNameParts = strsplit(fileName,'_');
setup = fileNameParts{end-1}(1);
analyzedAxis = fileNameParts{end}(1);
displacement = fileNameParts{1}(1:end-2); % x1
machineSpeed = -1;

%% Pick an envelope side
commandwindow;

if analyzedAxis == 'x'
    envelopeSideX = input('Choose the envelope side for x-axis (1 - lower and 2 - upper): ');
    if envelopeSideX == 2 % Upper
        envIndex_ps = upperEnvIndex_ps1;
        env_ps = upperEnv_ps1;    
    elseif envelopeSideX == 1 % Lower
        envIndex_ps = lowerEnvIndex_ps1;
        env_ps = lowerEnv_ps1;    
    end
    psEnvTime = time(envIndex_ps);
elseif  analyzedAxis == 'y'   
    envelopeSideY = input('Choose the envelope side for y-axis (1 - lower and 2 - upper): ');
    if envelopeSideY == 2
        envIndex_ps = upperEnvIndex_ps2;
        env_ps = upperEnv_ps2;
    elseif envelopeSideY == 1
        envIndex_ps = lowerEnvIndex_ps2;
        env_ps = lowerEnv_ps2;
    end
    psEnvTime = time(envIndex_ps);
end

%% Show 
figure;

% h1(1) = subplot(2,1,1);
plot(psEnvTime,env_ps,'r-',time,digInA,'k'); hold on;
title(['The envelope of sensor pair (' analyzedAxis '-axis) - ' fileName],'FontSize',18,...
    'Interpreter','none'); hold off;
ylabel('Envelope of raw sensor output (v)','FontSize',16);

% h1(2) = subplot(2,1,2);
% plot(time(upperEnvIndex_ps2),upperEnv_ps2,'r-',time(lowerEnvIndex_ps2),lowerEnv_ps2,'r-',...
%     time,digInA,'k'); hold on;
% title(['The envelope of Sensor pair 2 (y-axis) - ' fileName],'FontSize',18); hold off;
% ylabel('Envelope of raw sensor output (v)','FontSize',16);

xlabel('Time (s)','FontSize',16);
% linkaxes(h1,'x');

%% Detect activity window and plot
% commandwindow;
% humanReactionTime = input('Human reaction time: ');
humanReactionTime = 0.1;
[~, wnIndex] = GetActivityWn(time, digInA, psEnvTime, false,...
    humanReactionTime);

figure;
plot(psEnvTime,env_ps,'b-'); hold on;
line([psEnvTime(wnIndex) psEnvTime(wnIndex)],...
    [min(env_ps) max(env_ps)], 'Color',[1 0 0], 'LineStyle', '-.'); hold on;
title(['The envelope of sensor pair (' analyzedAxis '-axis) - ' fileName],'FontSize',18,...
    'Interpreter','none'); hold off;
ylabel('Envelope of raw sensor output (v)','FontSize',16);
xlabel('Time (s)','FontSize',16);

%% Catch signal trend to be used to estimate the resolution of the sensor
trend = smooth(psEnvTime,env_ps,0.1,'rloess');
figure;
plot(psEnvTime,env_ps,psEnvTime,trend); hold on;
line([psEnvTime(wnIndex) psEnvTime(wnIndex)],...
    [min(env_ps) max(env_ps)], 'Color',[1 0 0], 'LineStyle', '-.');
title('Smooth rloess','FontSize',18);

%% Fix trend and print voltage output response
trendRange = wnIndex(1):wnIndex(end);
trend = trend(trendRange);
trend = trend - mean(trend);
trend = trend + abs(min(trend));
figure;
plot(psEnvTime(trendRange),trend); hold on;
% hline = refline([0 0]);
% hline.Color = 'k';
line([psEnvTime(wnIndex) psEnvTime(wnIndex)],...
    [min(trend) max(trend)], 'Color',[1 0 0], 'LineStyle', '-.');
title(['Trend (' analyzedAxis '-axis) - ' fileName],'FontSize',18,...
    'Interpreter', 'none');
xlabel('Time (s)','FontSize',16);
ylabel('V','FontSize',16);

%% Get Y1, Y2 and Range
% Create a new wnIndex based on trend signal update
wnIndex1 = wnIndex - wnIndex(1) + 1;
nWindows = length(wnIndex1) / 2;
nCol = 8;
analysisMatrix = NaN(nWindows,nCol);

i = 1:nWindows;
j = 1:2:length(wnIndex1);
% Methods to find peak, minAmp and range
commandwindow;
method = input('Method (1 or 2): ');
for k = 1:nWindows
    ii = i(k); jj = j(k);
    analysisMatrix(ii,1) = str2double(setup);
    if analyzedAxis == 'x'; ax = 1; elseif analyzedAxis == 'y'; ax = 2; end;
    analysisMatrix(ii,2) = ax;
    analysisMatrix(ii,3) = ii;
    analysisMatrix(ii,4) = str2double(displacement);% X1
    analysisMatrix(ii,5) = machineSpeed;% X2
    
    y = trend(wnIndex1(jj):wnIndex1(jj+1));
    % Method 1
    if method == 1            
        [peak, loc] = findpeaks(y, 'NPeaks',1);% Y2
        minAmp = min(y(loc:end));% Y1
        ampRange = peak - minAmp;
    % Method 2
    elseif method == 2
        peak = max(y);
        loc = find(y == peak);
        minAmp = min(y);
        ampRange = peak - minAmp;
    end
    analysisMatrix(ii,6) = minAmp;
    analysisMatrix(ii,7) = peak;
    analysisMatrix(ii,8) = ampRange;
end
openvar('analysisMatrix');

%% Save all figures and workspace data
% 1 = Windows | 0 = Mac or Linux
osInfo = ispc;
saveFigsScript3;
% close all;

% Save all workspace data
matFileName = strsplit(fileName,'.');
if length(matFileName) == 3
    matFileName = [matFileName{1} '.' matFileName{2}];
else
    matFileName = matFileName{1};
end
matFileName = [pathName matFileName '.mat'];

save(matFileName);

%% Proceed to resolution model analysis (resolutionModelAnalysis.m)


