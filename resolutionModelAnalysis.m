% Run after resolutionAnalysis.m
% Author: Fabio Henrique (oliveirafhm@gmail.com)
% Creation date: 09/06/2019
% Mod date: 14/06/2019

%% Load data (.xlsx or .mat)

load('C:\Users\olive\OneDrive\Doutorado\Thesis\Coletas\Coletas_08_2018\testes\resolucao_17_01_2019\analysis\Analysis_v1.mat');

%% Prepare data
dataModel = Analysisv1;
dataModel.Properties.VariableNames = lower(dataModel.Properties.VariableNames);
% Consider only x-axis (1) or y-axis (2)
dataModel = dataModel(dataModel.axis == 1,:);
% Delete some columns (unnecessary ones)
dataModel.endamp = []; dataModel.axis = []; dataModel.x2 = []; dataModel.y1 = [];

% Convert setup to categorical
dataModel.setup = categorical(dataModel.setup);
% Center x1 (displacement in mm)
dataModel.x1Centered = dataModel.x1 - mean(unique(dataModel.x1));
% Sorts data by x1 values
sDataModel = sortrows(dataModel, 3);

%% Shows all data
figure;
gscatter(sDataModel.x1, sDataModel.y2, sDataModel.setup);

%% Boxplot of data
figure;
boxplot(sDataModel.y2, sDataModel.x1);
title('Amplitude range distribution for each displacement value');
ylabel('Amplitude range (V)');
xlabel('Displacement (mm)');

%% Model design
% Model 0
formula0 = 'y2 ~ x1';
% formula0 = 'y2 ~ x1Centered';
lme0 = fitlme(sDataModel, formula0);
disp(lme0);

% Model 1 (for each mm sums 0.0031 in y - sensor response in volts)
formula1 = 'y2 ~ x1 + (1|setup)';
% formula1 = 'y2 ~ x1Centered + (1|setup)';
lme1 = fitlme(sDataModel, formula1);
disp(lme1);
% Equation of model 1: 
% y = x * 0.0030737 + 0.005097 + 0.0063101 - 0.0017668

% Model 2
formula2 = 'y2 ~ x1 + (1|trial) + (1|setup)';
% formula2 = 'y2 ~ x1Centered + (1|trial) + (1|setup)';
lme2 = fitlme(sDataModel, formula2);
disp(lme2);

%% Compare models
results = compare(lme0,lme1,'CheckNesting',true);
if results.pValue < 0.05
    disp('The second model is significantly better than the first one.\n> lme1 <');
else
    disp('The second model is not significantly better than the first one.\n> lme0 <');
end

% The p-value of 1 indicates that lme2 is a worse fit than lme1.
results = compare(lme1,lme2,'CheckNesting',true);
if results.pValue < 0.05
    disp('The second model is significantly better than the first one.\n> lme2 <');
else
    disp('The second model is not significantly better than the first one.\n> lme1 <');
end
% Choosen model to proceed with the analysis
bestLme = lme1;

%% Plot all data
figure;

setup1 = sDataModel.setup == '1';
subplot(2,2,1);
plot(sDataModel(setup1,:).x1,sDataModel(setup1,:).y2,'ro');
title('Setup 1');
xlabel('Displacement (mm)');
ylabel('Amplitude range (V)');

setup2 = sDataModel.setup == '2';
subplot(2,2,2);
plot(sDataModel(setup2,:).x1,sDataModel(setup2,:).y2,'ro');
title('Setup 2');
xlabel('Displacement (mm)');
ylabel('Amplitude range (V)');

subplot(2,2,[3,4]);
plot(sDataModel.x1,sDataModel.y2,'ro');
title('Setup 1 and 2');
xlabel('Displacement (mm)');
ylabel('Amplitude range (V)');

%% Plot the fitted response versus the observed response
F = fitted(bestLme);
R = response(bestLme);
figure();
% plot(R,F,'rx');
plotregression(R, F, ['Regression of ' formula1]);
% xlabel('Response');
% ylabel('Fitted');

%% Plot residuals
figure;
plotResiduals(bestLme, 'fitted');

figure;
plotResiduals(bestLme, 'histogram');

figure;
plotResiduals(bestLme, 'probability');

%% Correlation between (raw) - mm and v
% figure;
disp('> Correlation between displacement and amplitude range <');
[R,P] = corrcoef(sDataModel.x1,sDataModel.y2)

%% Regression and equation for target vs output
% output1 = sort(predict(lme1));
% figure;
% plotregression(sDataModel.y2, output1, 'Regression');

%% Linear relation - Setup 1 or 2
varSetup = 2;
x1 = 0:0.5:10;
newSetup = categorical(zeros(length(x1),1)+varSetup);
newData = table(newSetup, x1', 'VariableNames',{'setup', 'x1'});
output2 = sort(predict(bestLme, newData));

% x1 = unique(sort(sDataModel(setup1,:).x1));
% output2 = sort(predict(lme1));
% output2 = unique(output2(setup1));

% yCalc1 = b1*x;
figure;
% scatter(sDataModel(setup1,:).x1,sDataModel(setup1,:).y2)
gscatter(sDataModel.x1,sDataModel.y2, sDataModel.setup);
hold on;
plot(x1,output2);
xlabel('Displacement (mm)');
ylabel('Amplitude range (V)');
title('Linear Regression Relation Between Displacement & Amplitude Range');
grid on;

%% Comparison of model response using lme and equation
x2 = 0:0.5:10;
% newSetup = categorical(zeros(length(x2),1));
% newData = table(newSetup, x2', 'VariableNames',{'setup', 'x1'});
% yCalc1 = sort(predict(lme1, newData));

fe = fixedEffects(bestLme);
interceptCoeff = fe(1);
slopeCoeff = fe(2);
yCalc2 = [slopeCoeff * x2 + interceptCoeff]';

ci = coefCI(bestLme);
upperCi = ci(:,2);
lowerCi = ci(:,1);
yCalc2UpperCI = [upperCi(2) * x2 + upperCi(1)]';
yCalc2LowerCI = [lowerCi(2) * x2 + lowerCi(1)]';

figure;
plot(x2, yCalc2UpperCI, 'k--', x2, yCalc2, 'k-', x2, yCalc2LowerCI, 'k--');
xlabel('Displacement (mm)');
ylabel('Amplitude range (V)');
title('Linear Relation Between Displacement & Amplitude Range');
legend('Upper and lower CI','Estimated behavior', 'Location','best');
% set(gca,'xlim',[0 10]);
% set(gca,'XTickLabel',x2); 
grid on;

% Place equation in upper left of graph.
xl = xlim;
yl = ylim;
xt = 0.05 * (xl(2)-xl(1)) + xl(1);
yt = 0.90 * (yl(2)-yl(1)) + yl(1);
caption = sprintf('y = %f * x + %f',slopeCoeff, interceptCoeff);
text(xt, yt, caption, 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');

%% ANOVA and squared R
stats = anova(bestLme)

bestLme.Rsquared

%% Prepare data for curving fitting tool
% Y = sDataModel.y2;
% L = length(Y);
% X = sDataModel.x1;
% Z = ones(L,1);
% G = sDataModel.setup;
