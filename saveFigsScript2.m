%% Prepare folder name and path
addpath(genpath('Third party codes'));
% There must be higidos and parkinson folders in figures folder
basePath = 'figures';
addpath(genpath(basePath));

folderName = strsplit(fileName,'.');
folderName = folderName{1};
if osInfo == 1
    figPath = strsplit(pathName, '\');
else
    figPath = strsplit(pathName, '/');
end
% figdir = [basePath '/' figPath{end - 3} '/' figPath{end - 2}];
figdir = [basePath '/' figPath{end - 3} '/' figPath{end - 2} '/' folderName];
if(isdir(figdir))
    disp('Folder already present');
else
    mkdir(figdir);
    disp(['Created folder ' figdir]);
end
% figdir = [basePath '/' figPath{end - 3} '/' figPath{end - 2} '/' folderName];

%% Save figures 

figureHandles = findobj('Type', 'figure');
fHNumbers = [];
for i = 1:length(figureHandles)
   fHNumbers(i) = figureHandles(i).Number; 
end

for i = min(fHNumbers):max(fHNumbers)
   aux = find(fHNumbers == i);
   fH = figureHandles(aux);
   savefig(fH, [figdir '/' figureNames{i} '.fig']);
end

%% Basic shortcut
% disp('Saving open figures...');
% if(exist('figdir','var') == 1)
%     if(exist('figureNames','var') == 1)
%         saveFigs(figdir, 'name', figureNames);
%     else
%         saveFigs(figdir);
%     end
% else
%     saveFigs();
% end

%% Shortcut for MATLAB figures
% disp('Saving open figures into MATLAB .fig...');
% if(exist('figdir','var') == 1)
%     if(exist('figureNames','var') == 1)
%         saveFigs(figdir,'format','fig', 'name', figureNames);
%     else
%         saveFigs(figdir,'format','fig');
%     end
% else
%     saveFigs('img','format','fig');
% end