%% Test file
% Load saved figures
c=hgload('C:\Users\olive\OneDrive\Doutorado\Congressos\2018\World Congress on Medical Physics and Biomedical engineering\fullpaper\figures\signals_healthy_subject.fig');
k=hgload('C:\Users\olive\OneDrive\Doutorado\Congressos\2018\World Congress on Medical Physics and Biomedical engineering\fullpaper\figures\signals_PD_subject.fig');
% Prepare subplots
figure
h(1)=subplot(1,2,1);
h(2)=subplot(1,2,2);
% Paste figures on the subplots
copyobj(allchild(get(c,'CurrentAxes')),h(1));
copyobj(allchild(get(k,'CurrentAxes')),h(2));
% Add legends
l(1)=legend(h(1),'LegendForFirstFigure')
l(2)=legend(h(2),'LegendForSecondFigure')