function [filelist, filetable] = getFileList(fsPath,mode,extensions)
%GETFILELIST Get a list of files in a directory filtered by the file type extension
%   fsPath:     path of the directory in the filesystem
%   mode:       type of list selection: 'include', 'exclude', 'all'
%   extensions: list of file extensions to filter
%
%   examples:
%   getFileList(fsPath,'all')
%   getFileList(fsPath,'include',{'txt','ldx'})
%   getFileList(fsPath,'exclude','.stignore')

% if the shortcut call is used use the default mode 'all'
if nargin==1
    mode = 'all';
end
% if there is more than one output, create a table of the contents
createTable = false;
if nargout > 1
    createTable = true;
end

dircontents = dir(fsPath);                  % get the contents of the directory
returnmask = false(numel(dircontents),1);   % the returnmask is true for a file we want to return

for file = 1:numel(dircontents)             % loop over all files in the directory
    if dircontents(file).isdir              % only catch files, not sub-directories
        % if the 'isdir' flag of a dir content is true, skip it
        continue;
    end

    switch mode
        case 'all'                          % return all files in directory without filter
            returnmask(file,1) = true;
        case 'exclude'                      % return all files in directory without a specific file extensions
            if ~endsWith(dircontents(file).name,extensions)
                returnmask(file,1) = true;
            end
        case 'include'                      % return all files in directory with a specific file extensions
            if endsWith(dircontents(file).name,extensions)
                returnmask(file,1) = true;
            end
    end
end

fileindex = find(returnmask);               % get linear indices of files to return
nFiles = numel(fileindex);                  % number of files to return

% init the return variables
filelist = strings(nFiles,1);     % init the list of file names
if createTable
    folderList = strings(nFiles,1);
    bytesList = nan(nFiles,1);
    datenumList = nan(nFiles,1);
end

for file = 1:nFiles
    filelist(file) = dircontents(fileindex(file)).name;
    if createTable
        folderList(file) = dircontents(fileindex(file)).folder;
        bytesList(file) = dircontents(fileindex(file)).bytes;
        datenumList(file) = dircontents(fileindex(file)).datenum;
    end
end

if createTable
    filetable = table(filelist,folderList,bytesList,datenumList);
    filetable.Properties.VariableNames = {'name','folder','bytes', 'datenum'};
end

end
