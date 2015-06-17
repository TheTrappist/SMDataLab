function tempPath = SetFigurePath(path);

global figPath;

if nargin < 1
    if isempty(figPath)
        figPath = uigetdir();
    else
        figPath = uigetdir(figPath);
    end
else
    figPath = path;
end

tempPath = figPath;