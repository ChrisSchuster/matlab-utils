function nameslist = getContents(path,flag)
%GETCONTENTS Returns list of directory contents
%   Type of contents may be specified using flag
%   Example: (returns all files in current directory)
%       list = getContents(cd,'isfile')

switch flag
    case 'isdir'
        flag = false;
    case 'isfile'
        flag = true;
end
fn = dir(path);                 % list information about folder
fn = fn(3:end);                 % disregard first two elemnts (pointers to current and parent dir)
fn = fn(xor(flag,[fn.isdir]));	% keep only a list of specified type
nameslist = {fn.name}';	        % keep only name value
end