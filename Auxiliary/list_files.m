function files = list_files(directory, varargin)
% List files from a directory
%
% INPUT
% directory         path
% extension         OPTIONAL.  
%                   Given an extension, the function will return only 
%                   the files with this extension. If it is not indicated 
%                   the function will return all files. 
% 
% OUTPUT
% files             list of files
% 
% USAGE
% files = list_files(path); or 
% files = list_files(path, 'txt');

if nargin > 1
    ending = ['*.' varargin{1}];
    directory = fullfile(directory, ending);
end

files = dir(directory);
files = {files.name};
files(ismember(files, {'.', '..'}))=[];
