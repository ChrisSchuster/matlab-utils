function [fsPath] = getPathFromEnv(type)
%GETDIRPATHFROMENV Returns a path from environment variable at the root of the invoking script
%   input: empty
%   output: filesystem path as char
%
%   Usage examples: fsPath = getPathFromEnv();
%

version = '0.1';                % version of the environmental variable file
envExists = isfile('.env');     % check if environmental variable is set
caller = dbstack();             % get the function call stack
caller = caller(2).name;        % get the name of the function that invoked getPathFromEnv()

%% look for and read the environmental variable
if envExists
    % an environment varibale was found, read path from it
    [isOld, envPath] = isOldstyleEnv();
    if isOld
        % the env variable was formatted in the oldstyle (plain text)
        % create a new env variable (overwriting the old one) in the new format
        createEnvXML(caller,envPath, version);
    else
        % the env varibale is well formed
        % read from it the desired path
        envs = readstruct(fullfile(cd,'.env'),"FileType","xml");
        numberEnvs = numel(envs.env);
        callers = strings(1,numberEnvs);
        for env = 1:numberEnvs
            callers(env) = envs.env(env).caller;
        end
        callerIndex = matches(callers,caller);
        if ~any(callerIndex)
            % the caller was not found in the env
            % add it and store the desired path
            envPath = selectEnvPath();
            newEnvIndex = numberEnvs+1;
            envs.env(newEnvIndex).caller = caller;
            envs.env(newEnvIndex).path = envPath;
            writestruct(envs,fullfile(cd,'.env'),"FileType","xml");
        else
            % the caller was found in the env, return the path
            envPath = envs.env(callerIndex).path;
        end
    end

else
    % an env variable was not found, create it and store the desired
    % default path in it
    envPath = selectEnvPath();
    createEnvXML(caller, envPath, version);
end

%% display the folder/file selection dialog
% return either a user specified folder or file
switch type
    case 'folder'
        fsPath = uigetdir(envPath,'Select source directory');   % open the folder selection dialog box
    case 'file'
        filter = strcat(envPath,'\*.*');
        [filename, path] = uigetfile(filter,'Select source file');       % open the folder selection dialog box
        fsPath = fullfile(path,filename);
end

end

function [isTxtFlag,path] = isOldstyleEnv()
% returns false if the env is an XML file
% returns true and the path if file is not XML
isTxtFlag = true;
fID = fopen(fullfile(cd,'.env'),'r');               % open the file containing the env variable
path = fscanf(fID,'%c');                            % parse the file contents, returns path stored in the env variable
if startsWith(path,'<?xml version="1.0"')        % check for beginning of XML file
    isTxtFlag = false;
    path = [];                                      % return empty path, need to identify the path through different means
end
fclose(fID);                                        % close the file
end

function createEnvXML(caller, path, version)
% create an XML env from a provided caller and path value
env = struct();
env.caller = caller;
env.path = path;
envs.env = env;
envs.version = version;
writestruct(envs,fullfile(cd,'.env'),"FileType","xml","StructNodeName","environmentalVariables");
end

function envPath = selectEnvPath()
% open folder selection dialoge, to select the path to be stored in the env
envPath = uigetdir("C:\",'Define default directory');   % open folder selection dialog box
if isnumeric(envPath)
    error('User abort during selection of default path.\n');
end
end
