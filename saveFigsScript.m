%% Prepare folder name and path
addpath(genpath('Third party codes'));
% There must be higidos and parkinson folders in figures folder
addpath(genpath('figures'));

folderName = strsplit(fileName,'.');
folderName = folderName{1};

figPath = strsplit(pathName, '\');
figdir = ['figures/' figPath{end - 3} '/' figPath{end - 2}];
if(isdir(figdir))
    disp('Folder already present');
else
    mkdir(figdir);
    disp(['Created folder ' figdir]);
end
figdir = ['figures/' figPath{end - 3} '/' figPath{end - 2} '/' folderName];

% folderName = strsplit(fileName,'.');
% folderName = [folderName{1} '_figures'];
% figdir = [pathName folderName];
% figdir = strrep(figdir,'\','/');
% addpath(genpath(figdir));

%% Basic shortcut
disp('Saving open figures...');
if(exist('figdir','var') == 1)
    saveFigs(figdir);
else
    saveFigs();
end

%% Shortcut for PDF prints (300 DPI)
% disp('Saving open figures into PDFs @ 300 DPI...');
% if(exist('figdir','var') == 1)
%     saveFigs(figdir,'format','pdf','dpi',300);
% else
%     saveFigs('img','format','pdf','dpi',300);
% end

%% Shortcut for MATLAB figures named 'measurement-#'
disp('Saving open figures into MATLAB .fig...');
if(exist('figdir','var') == 1)
    saveFigs(figdir,'format','fig');
else
    saveFigs('img','format','fig');
end