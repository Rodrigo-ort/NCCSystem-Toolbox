% Win path example:
% C:\Users\olive\OneDrive\Doutorado\Thesis\Coletas\Coletas_08_2018\voluntarios\higidos\v15_adgmar_da_silva\plessey\

% function SaveFigsWrap(pathName, folderName, figureNames)
addpath(genpath('Third party codes'));
% There must be higidos and parkinson folders in figures folder
basePath = 'figures';
addpath(genpath(basePath));
% Prepare folder name and path
folderName = strsplit(fileName,'.');
folderName = folderName{1};
if osInfo == 1
    figPath = strsplit(pathName, '\');
else
    figPath = strsplit(pathName, '/');
end
figdir = [basePath '/' figPath{end - 3} '/' figPath{end - 2}];
if(isdir(figdir))
    disp('Folder already present');
else
    mkdir(figdir);
    disp(['Created folder ' figdir]);
end
figdir = [basePath '/' figPath{end - 3} '/' figPath{end - 2} '/' folderName];

%% Basic shortcut
disp('Saving open figures...');
if(exist('figdir','var') == 1)
    if(exist('figureNames','var') == 1)
        saveFigs(figdir, 'name', figureNames);
    else
        saveFigs(figdir);
    end
else
    saveFigs();
end

%% Shortcut for MATLAB figures
disp('Saving open figures into MATLAB .fig...');
if(exist('figdir','var') == 1)
    if(exist('figureNames','var') == 1)
        saveFigs(figdir,'format','fig', 'name', figureNames);
    else
        saveFigs(figdir,'format','fig');
    end
else
    saveFigs('img','format','fig');
end