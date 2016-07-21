function [S, dataFile] = read_annotations(directory)
% Read annotations files and save the data in S struct
% INPUT
%    directory    directory where annotations are saved (.txt)

% Get all txt files
files   = list_files(directory, 'txt');

% Pattern to identify each class (14 classes are considered)
pattern_classes = { 'A.{2}\>', 'B1\>', 'B17\>', 'B21\>', 'B3\>', ...
                    'C1\>', 'C3\>', 'C.{2,}\>', 'D.{1,2}\>',  'E1\>', ...
                    'E3\>', 'E7\>', 'E9.{1,}\>', 'F.{2}\>'};
% Pattern to identify each superclass, [A-F]                
pattern_superclass = {'A', 'B', 'C', 'D', 'E', 'F'};

S                   = [];
v_annotation        = [];
v_Sign              = {};
v_id_subclass       = [];
v_id_superclass     = [];
v_fileName          = {};

% for each annotation file...
for i = 1:length(files)
    % Read file
    filePath = fullfile(directory, files{i});
    [annotations Signs] = LoadAnnotations(filePath);
     
    % For each annotation...
    for idx_lines = 1:size(annotations, 2)
        % Find the class to which belongs...
        for idx_p = 1:length(pattern_classes)
            
            s = regexp(Signs{idx_lines}, pattern_classes{idx_p} );
            if ~isempty(s)
                % ... and save the annotation in the S struct
                v_fileName{end+1}       = files{i};
                v_id_subclass(end+1)    = idx_p;
                v_Sign{end+1}           = Signs{idx_lines};
                v_annotation{end+1}     = annotations(idx_lines);
                
                % if the class is B21, change its superclass to F 
                % because B21 are blue signals and class B are red signals
                if strcmp(Signs{idx_lines}, 'B21')
                    index = 6;
                else
                    str_superclass = Signs{idx_lines}(1);
                    index = strfind(pattern_superclass,str_superclass);
                    index = find(not(cellfun('isempty', index)));
                end
                v_id_superclass(end+1) = index;
            end
        end
    end 
end

S.fileName          = v_fileName;
S.v_id_subclass     = v_id_subclass;
S.v_id_superclass   = v_id_superclass;
S.Sign              = v_Sign;
S.annotation        = v_annotation;
S.numSubClasses     = 14;
S.numSuperClasses   = 6;


xX = cell2mat(cellfun( @(x) x.x, v_annotation, 'UniformOutput', false ));
yY = cell2mat(cellfun( @(x) x.y, v_annotation, 'UniformOutput', false ));
wW = cell2mat(cellfun( @(x) x.w, v_annotation, 'UniformOutput', false ));
hH = cell2mat(cellfun( @(x) x.h, v_annotation, 'UniformOutput', false ));
dataFile = [xX' yY' wW' hH'];