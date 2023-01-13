function [fsPath] = getDirPathFromEnv(type)
%GETDIRPATHFROMENV Returns a path from environment variable at the root of the invocing script
%   input: empty
%   output: filesystem path as char
%   
%   Usage examples: fsPath = getPathFromEnv();
%   

envExists = isfile('.env');                                 % check if environmental variable is set

if envExists                                                % read path from environment varibale if set
    fID = fopen(fullfile(cd,'.env'),'r');                   % open the file containing the env variable
    envPath = fscanf(fID,'%c');                             % parse the file contents, returns path stored in the env variable
else                                                        % create the env variable if not found, store the desired default path
    envPath = uigetdir("C:\",'Define default directory');   % open folder selection dialog box
    if isnumeric(envPath)
        error('User abort during selection of default path.\n');
    end
    fID = fopen('.env','w');                                % create the environmental variable in the root of the invocing script
    fprintf(fID,'%s',envPath);                              % write the desired default path to the env variable
end

switch type
    case 'folder'
        fsPath = uigetdir(envPath,'Select source directory');   % open the folder selection dialog box
    case 'file'
        filter = strcat(envPath,'\*.*');
        [filename, path] = uigetfile(filter,'Select source file');       % open the folder selection dialog box
        fsPath = fullfile(path,filename);
end

status = fclose(fID);                                       % close the file containing the environment varibale

end

