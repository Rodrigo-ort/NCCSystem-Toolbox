% Run after windowing.m
% Author: Fabio Henrique (oliveirafhm@gmail.com)
% 06/04/2018
% Last mod: 19/04/2018
%% Load data .mat
close all;
clear all;
clc;

[matFileName2, matPathName] = uigetfile('.mat', ...
    'Select processed subject data');
matFilePath = strcat(matPathName, matFileName2);

load(matFilePath);
%% Find the delay between signals
% dt1 = finddelay(gyro3Z_filtered, env_ps1_filtered)
% dt2 = finddelay(gyro3Y_filtered, env_ps2_filtered)
% % Align signals
% % TODO in windowing file in order to improve signal sync
% gz = alignsignals(gyro3Z_filtered, env_ps1_filtered, [], 'truncate');
% gy = alignsignals(gyro3Y_filtered, env_ps2_filtered, [], 'truncate');
% 
% figure;
% ax(1) = subplot(4,1,1);
% plot(env_ps1_filtered);
% grid on;
% title('Plessey x-axis');
% axis tight
% ax(2) = subplot(4,1,2);
% plot(gz);
% grid on;
% title('Gyro Z');
% axis tight
% 
% ax(3) = subplot(4,1,3); 
% plot(env_ps2_filtered);
% grid on;
% title('Plessey y-axis');
% axis tight
% ax(4) = subplot(4,1,4); 
% plot(gy)
% grid on;
% title('Gyro Y');
% axis tight
% linkaxes(ax,'x');

%% Fix signals - Resampling
% The resample function applies an anti-aliasing (low-pass)
% FIR filter to the signal during the resampling process.
envPs1Fs = round(length(env_ps1_filtered) / ps1TimeFiltered(end),2);
envPs2Fs = round(length(env_ps2_filtered) / ps2TimeFiltered(end),2);
% envPsFs = envPs1Fs;
% aGzFs = round(length(gz)/tsTime(end),2);
% aGyFs = round(length(gy)/tsTime(end),2);

[P1, Q1] = rat(envPs1Fs/tsFs); % Rational fraction approximation
[P2, Q2] = rat(envPs2Fs/tsFs); % Rational fraction approximation

gyro3ZFilt_resampled = resample(gyro3Z_filtered, P1, Q1); % Change sampling rate by rational factor
tsTimeZ_resampled = 0:tsTime(end)/length(gyro3ZFilt_resampled):tsTime(end);
while length(tsTimeZ_resampled) > length(gyro3ZFilt_resampled)
    tsTimeZ_resampled(end) = [];
end

gyro3YFilt_resampled = resample(gyro3Y_filtered, P2, Q2); % Change sampling rate by rational factor
tsTimeY_resampled = 0:tsTime(end)/length(gyro3YFilt_resampled):tsTime(end);
while length(tsTimeY_resampled) > length(gyro3YFilt_resampled)
    tsTimeY_resampled(end) = [];
end

allLen = [length(env_ps1_filtered) length(env_ps2_filtered)...
    length(gyro3ZFilt_resampled) length(gyro3YFilt_resampled)];

ps1CorrSignal = env_ps1_filtered;
ps2CorrSignal = env_ps2_filtered;
gyroZCorrSignal = gyro3ZFilt_resampled;
gyroYCorrSignal = gyro3YFilt_resampled;

ps1TimeFiltered1 = ps1TimeFiltered;
ps2TimeFiltered1 = ps2TimeFiltered;
tsTimeZ_resampled1 = tsTimeZ_resampled;
tsTimeY_resampled1 = tsTimeY_resampled;

while length(ps1CorrSignal) < max(allLen), ps1CorrSignal(end+1) = 0; end
while length(ps2CorrSignal) < max(allLen), ps2CorrSignal(end+1) = 0; end
while length(gyroZCorrSignal) < max(allLen), gyroZCorrSignal(end+1) = 0; end
while length(gyroYCorrSignal) < max(allLen), gyroYCorrSignal(end+1) = 0; end

while length(ps1TimeFiltered1) < max(allLen), ps1TimeFiltered1(end+1) = ps1TimeFiltered1(end)+1/envPs1Fs; end
while length(ps2TimeFiltered1) < max(allLen), ps2TimeFiltered1(end+1) = ps2TimeFiltered1(end)+1/envPs1Fs; end
while length(tsTimeZ_resampled1) < max(allLen), tsTimeZ_resampled1(end+1) = tsTimeZ_resampled1(end)+1/envPs1Fs; end
while length(tsTimeY_resampled1) < max(allLen), tsTimeY_resampled1(end+1) = tsTimeY_resampled1(end)+1/envPs1Fs; end

% Validate signal length
% while length(gyroZCorrSignal) > length(ps1CorrSignal)
%     gyroZCorrSignal(end) = [];
%     tsTimeZ_resampled(end) = [];
% end
% while length(gyroYCorrSignal) > length(ps2CorrSignal)
%     gyroYCorrSignal(end) = [];
%     tsTimeY_resampled(end) = [];
% end

% length(gyroZCorrSignal)
% length(tsTimeZ_resampled)
% length(gyroYCorrSignal)
% length(tsTimeY_resampled)

%% Align signals
% TODO Do it in windowing file in order to improve signal sync
commandwindow;
alignS = input('Would you like to align the signals using xcorr method (0 or 1)? ');
if alignS == 1
    if finddelay(gyroZCorrSignal, ps1CorrSignal) > 0
        gyroZCorrSignal = alignsignals(gyroZCorrSignal, ps1CorrSignal, [], 'truncate');
    else
        ps1CorrSignal = alignsignals(ps1CorrSignal, gyroZCorrSignal, [], 'truncate');
    end
    
    if finddelay(gyroYCorrSignal, ps2CorrSignal) > 0
        gyroYCorrSignal = alignsignals(gyroYCorrSignal, ps2CorrSignal, [], 'truncate');
    else
        ps2CorrSignal = alignsignals(ps2CorrSignal, gyroYCorrSignal, [], 'truncate');
    end
end
% Check alignment (0 means OK - just report when not 0)
finddelay(gyroZCorrSignal, ps1CorrSignal)
finddelay(gyroYCorrSignal, ps2CorrSignal)

%% Plot sensor pair 1 (x-axis) and 2 (y-axis) plus audio beeps
%  along with tremsen analyzed sensors/axis
figure;
% Plessey pair 1 (x-axis)
ax(1) = subplot(4,1,1);
plot(ps1TimeFiltered1, ps1CorrSignal);
line([ps1TimeFiltered1(ps1WindowsFiltered) ps1TimeFiltered1(ps1WindowsFiltered)], ...
    [min(ps1CorrSignal) max(ps1CorrSignal)], 'Color',[1 0 0], 'LineStyle', '-.');
% grid on;
title('Plessey x-axis');
axis tight;
% Tremsem G3.Z
ax(2) = subplot(4,1,2);
plot(tsTimeZ_resampled1, gyroZCorrSignal);
line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
    [min(gyroZCorrSignal) max(gyroZCorrSignal)], 'Color',[1 0 0], 'LineStyle', '-.');
% grid on;
title('Gyro Z');
axis tight;

% Plessey pair 2 (y-axis)
ax(3) = subplot(4,1,3); 
plot(ps2TimeFiltered1, ps2CorrSignal);
line([ps2TimeFiltered1(ps2WindowsFiltered) ps2TimeFiltered1(ps2WindowsFiltered)], ...
    [min(ps2CorrSignal) max(ps2CorrSignal)], 'Color',[1 0 0], 'LineStyle', '-.');
% grid on;
title('Plessey y-axis');
axis tight;
% Tremsem G3.Y
ax(4) = subplot(4,1,4); 
plot(tsTimeY_resampled1, gyroYCorrSignal);
line([timeFiltered(windowsFiltered) timeFiltered(windowsFiltered)], ...
    [min(gyroYCorrSignal) max(gyroYCorrSignal)], 'Color',[1 0 0], 'LineStyle', '-.');
% grid on;
title('Gyro Y');
axis tight;

xlabel('Time (s)','FontSize',20);
linkaxes(ax,'x');

%% Cross-correlation
% [C1, lag1] = xcorr(gyroZCorrSignal, ps1CorrSignal,'coeff');
% [C2, lag2] = xcorr(gyroYCorrSignal, ps2CorrSignal, 'coeff');
% 
% figure
% ax(1) = subplot(2,1,1); 
% plot(lag1/envPs1Fs,C1,'k')
% ylabel('Amplitude')
% grid on
% title('Cross-correlation between Gyro Z and Plessey (x-axis)')
% ax(2) = subplot(2,1,2); 
% plot(lag2/envPs2Fs,C2,'r')
% ylabel('Amplitude') 
% grid on
% title('Cross-correlation between Gyro Y and Plessey (y-axis)')
% xlabel('Time(secs)') 
% 
% xlim(ax(1),[-(max(lag1)/envPs1Fs) max(lag1)/envPs1Fs]);
% xlim(ax(2),[-(max(lag1)/envPs1Fs) max(lag1)/envPs1Fs]);
% axis(ax(1:2),[-(max(lag1)/envPs1Fs) max(lag1)/envPs1Fs -max(C2) max(C2)])

%% Pearson correlation and statistical significance
nAxis = 2;
nTasks = 8;
nCols = 8;
corrData = NaN(nAxis * nTasks, nCols);
iLine = 1;
commandwindow;
subjectID = input('Type the subject ID: ');
nSourceFile = str2num(matFileName2(7:8));
Fs = round(envPs1Fs);
fprintf('\n------------------------------------------------------------\nSource file: %s\n',matFilePath);
fprintf('\n----------- Correlation analysis -----------\n');
for taskCorr = 1:8
    % Discarding rest and pose
    wn = windowsFiltered(taskCorr+2):windowsFiltered(taskCorr+3);
    
    signal_ps1_gyroZ = NaN(length(wn),nAxis);
    signal_ps2_gyroY = NaN(length(wn),nAxis);
    
    signal_ps1_gyroZ(:,1) = ps1CorrSignal(wn);
    signal_ps1_gyroZ(:,2) = gyroZCorrSignal(wn);
    
    signal_ps2_gyroY(:,1) = ps2CorrSignal(wn);
    signal_ps2_gyroY(:,2) = gyroYCorrSignal(wn);
    
    [R_ps1_gyroZ, PValue_ps1_gyroZ] = corr(signal_ps1_gyroZ(:,1),signal_ps1_gyroZ(:,2));
    [R_ps2_gyroY, PValue_ps2_gyroY] = corr(signal_ps2_gyroY(:,1),signal_ps2_gyroY(:,2));
    
    % Frequency (energy peak)    
    sig1 = signal_ps1_gyroZ(:,1);
    sig2 = signal_ps1_gyroZ(:,2);
    sig3 = signal_ps2_gyroY(:,1);
    sig4 = signal_ps2_gyroY(:,2);
    
    [P1, f1] = periodogram(sig1, [], [], Fs, 'power');
    [P2, f2] = periodogram(sig2, [], [], Fs, 'power');
    [P3, f3] = periodogram(sig3, [], [], Fs, 'power');
    [P4, f4] = periodogram(sig4, [], [], Fs, 'power');
    
    [pks1, locs1] = findpeaks(P1);
    [pks2, locs2] = findpeaks(P2);
    [pks3, locs3] = findpeaks(P3);
    [pks4, locs4] = findpeaks(P4);
    
    thresholdPks = 0.9999; % percentage of max amp
    
    locs1 = locs1(pks1 > (thresholdPks*max(pks1)));
    %     pks1 = pks1(pks1 > (thresholdPks*max(pks1)));
    locs2 = locs2(pks2 > (thresholdPks*max(pks2)));
    %     pks2 = pks2(pks2 > (thresholdPks*max(pks2)));
    locs3 = locs3(pks3 > (thresholdPks*max(pks3)));
    locs4 = locs4(pks4 > (thresholdPks*max(pks4)));
    
    % Save all data in a matrix
    corrData(iLine,:) = [subjectID; nSourceFile; 1; taskCorr; ...
        R_ps1_gyroZ; PValue_ps1_gyroZ; f1(locs1); f2(locs2)];
    corrData(iLine+1,:) = [subjectID; nSourceFile; 2; taskCorr; ...
        R_ps2_gyroY; PValue_ps2_gyroY; f3(locs3); f4(locs4)];
    iLine = iLine + 2;
    
%     fprintf('\n-- Sensors %s and %s for task %d --\n','Plessey1','GyroZ',taskCorr);
%     fprintf('R = %.2f\nP = %.2f\n',R_ps1_gyroZ, PValue_ps1_gyroZ);
%     
%     fprintf('\n-- Sensors %s and %s for task %d --\n','Plessey2','GyroY',taskCorr);
%     fprintf('R = %.2f\nP = %.2f\n',R_ps2_gyroY, PValue_ps2_gyroY);
end
% Copy and paste in Excel file
openvar('corrData');
 
% %% Comparing the frequency content of signals
% Fs = round(envPs1Fs);
% selectedAxis = 2;
% if selectedAxis == 1
%     sig1 = signal_ps1_gyroZ(:,1);
%     sig2 = signal_ps1_gyroZ(:,2);
% else
%     sig1 = signal_ps2_gyroY(:,1);
%     sig2 = signal_ps2_gyroY(:,2);
% end
% 
% [P1, f1] = periodogram(sig1, [], [], Fs, 'power');
% [P2, f2] = periodogram(sig2, [], [], Fs, 'power');
% 
% [pks1, locs1] = findpeaks(P1);
% [pks2, locs2] = findpeaks(P2);
% 
% thresholdPks = 0.99; % percentage of max amp
% 
% locs1 = locs1(pks1 > (thresholdPks*max(pks1)));
% pks1 = pks1(pks1 > (thresholdPks*max(pks1)));
% 
% locs2 = locs2(pks2 > (thresholdPks*max(pks2)));
% pks2 = pks2(pks2 > (thresholdPks*max(pks2)));
% 
% figure
% t = (0:numel(sig1)-1)/Fs;
% subplot(2,2,1)
% plot(t,sig1,'k')
% ylabel('s1')
% grid on
% title(['Time Series - Task ' num2str(taskCorr)])
% subplot(2,2,3)
% plot(t,sig2)
% ylabel('s2')
% grid on
% xlabel('Time (secs)')
% subplot(2,2,2)
% plot(f1,P1,'k', f1(locs1), pks1, 'or')
% ylabel('P1')
% grid on
% axis tight
% title('Power Spectrum')
% subplot(2,2,4)
% plot(f2,P2, f2(locs2), pks2, 'or')
% ylabel('P2')
% grid on
% axis tight
% xlabel('Frequency (Hz)')
% 
% f1(locs1)
% f2(locs2)

%% Coherence calculus
% [Cxy,f] = mscohere(sig1,sig2,[],[],[],Fs);
% Pxy     = cpsd(sig1,sig2,[],[],[],Fs);
% phase   = -angle(Pxy)/pi*180;
% [pks,locs] = findpeaks(Cxy,'MinPeakHeight',0.75);
% 
% figure
% subplot(2,1,1)
% plot(f,Cxy)
% title('Coherence Estimate')
% grid on
% hgca = gca;
% hgca.XTick = f(locs);
% hgca.YTick = 0.75;
% % axis([0 200 0 1])
% subplot(2,1,2)
% plot(f,phase)
% title('Cross-spectrum Phase (deg)')
% grid on
% hgca = gca;
% hgca.XTick = f(locs); 
% hgca.YTick = round(phase(locs));
% xlabel('Frequency (Hz)')
% % axis([0 200 -180 180])
