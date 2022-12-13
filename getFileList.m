function [filelist] = getFileList(filesystemPath,fileTypeExtension)
%GETFILELIST Get a list of files in a directory filtered by the file type extension
%   filesystemPath:     path of the directory in the filesystem
%   fileTypeExternsion: string representation of the file type extension: ".pdf"

dircontents = dir(filesystemPath);          % get the contents of the directory
returnmask = false(numel(dircontents),1);   % the returnmask is true for a file we want to return

for file = 1:numel(dircontents)             % loop over all files in the directory
    if dircontents(file).isdir              % only catch files, not sub-directories
        % if the 'isdir' flag of a dir content is true, skip it
        continue;
    end

    if contains(dircontents(file).name,fileTypeExtension)
        returnmask(file,1) = true;
    end
end

fileindex = find(returnmask);               % get linear indices of files to return
filelist = strings(numel(fileindex),1);     % init the list of file names

for file = 1:numel(fileindex)
    filelist(file) = dircontents(fileindex(file)).name;
end
