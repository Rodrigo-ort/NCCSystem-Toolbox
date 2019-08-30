% Function name....: GetDir
% Date.............: Jun 16, 2019
% Mod date.........:
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                   Get dir elements (folder names or file names)
% Parameters.......:
%                   path
%                   folderOrFile -> 1 for folders or 2 for files
% Return...........:
%                   elementNames -> list of all element names
% Remarks..........:
%
function [elementNames] = GetDir(path, folderOrFile)
files = dir(path);
if folderOrFile == 1
    flags = [files.isdir];
else
    flags = ~[files.isdir];
end
elements = files(flags);
elementNames = {elements(:).name};

end

