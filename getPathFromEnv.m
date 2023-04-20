function [fsPath] = getPathFromEnv(type)
%GETDIRPATHFROMENV Returns a path from environment variable at the root of the invoking script
%   input: empty
%   output: filesystem path as char
%
%   Usage examples: fsPath = getPathFromEnv();
%

version = '0.1';                % version of the environmental variable file
caller = dbstack();             % get the function call stack
path2env = fileparts(which(caller(2).file));
path2env = fullfile(path2env,'.env');

caller = caller(2).name;        % get the name of the function that invoked getPathFromEnv()
envExists = isfile(path2env);     % check if environmental variable is set

%% look for and read the environmental variable
if envExists
    % an environment varibale was found, read path from it
    [isOld, payloadPath] = isOldstyleEnv(path2env);
    if isOld
        % the env variable was formatted in the oldstyle (plain text)
        % create a new env variable (overwriting the old one) in the new format
        createEnvXML(caller, payloadPath, version, path2env);
    else
        % the env varibale is well formed
        % read from it the desired path
        envs = readstruct(path2env, "FileType", "xml");
        numberEnvs = numel(envs.env);
        callers = strings(1,numberEnvs);
        for env = 1:numberEnvs
            callers(env) = envs.env(env).caller;
        end
        callerIndex = matches(callers,caller);
        if ~any(callerIndex)
            % the caller was not found in the env
            % add it and store the desired path
            payloadPath = selectEnvPath();
            newEnvIndex = numberEnvs+1;
            envs.env(newEnvIndex).caller = caller;
            envs.env(newEnvIndex).path = payloadPath;
            writestruct(envs, path2env, "FileType", "xml");
        else
            % the caller was found in the env, return the path
            payloadPath = envs.env(callerIndex).path;
        end
    end

else
    % an env variable was not found, create it and store the desired
    % default path in it
    payloadPath = selectEnvPath();
    createEnvXML(caller, payloadPath, version, path2env);
end

%% display the folder/file selection dialog
% return either a user specified folder or file
switch type
    case 'folder'
        fsPath = uigetdir(payloadPath,'Select source directory');   % open the folder selection dialog box
    case 'file'
        filter = strcat(payloadPath,'\*.*');
        [filename, path] = uigetfile(filter,'Select source file');       % open the folder selection dialog box
        fsPath = fullfile(path,filename);
end

end

function [isTxtFlag, payloadPath] = isOldstyleEnv(path2env)
% returns false if the env is an XML file
% returns true and the path if file is not XML
isTxtFlag = true;
fID = fopen(path2env, 'r');               % open the file containing the env variable
payloadPath = fscanf(fID,'%c');                            % parse the file contents, returns path stored in the env variable
if startsWith(payloadPath,'<?xml version="1.0"')        % check for beginning of XML file
    isTxtFlag = false;
    payloadPath = [];                                      % return empty path, need to identify the path through different means
end
fclose(fID);                                        % close the file
end

function createEnvXML(caller, payloadPath, version, path2env)
% create an XML env from a provided caller and path value
env = struct();
env.caller = caller;
env.path = payloadPath;
envs.env = env;
envs.version = version;
writestruct(envs, path2env, "FileType", "xml", "StructNodeName", "environmentalVariables");
end

function payloadPath = selectEnvPath()
% open folder selection dialoge, to select the path to be stored in the env
payloadPath = uigetdir("C:\",'Define default directory');   % open folder selection dialog box
if isnumeric(payloadPath)
    error('User abort during selection of default path.\n');
end
end
