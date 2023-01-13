function [fsPath] = getPathFromEnv()
%GETPATHFROMENV Returns a path from .env file at the root of the invocing script
%   input: empty
%   output: filesystem path as char
%   
%   Usage examples: fsPath = uigetdir(getPathFromEnv());
%   
%   ToDo: handle missing .env file -> creating it

envExists = isfile('.env');

if envExists
    fID = fopen(fullfile(cd,'.env'),'r');
    fsPath = fscanf(fID,'%c');
    status = fclose(fID);
end

end

