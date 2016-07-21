function outputValues = getGTFileInfo(S, path_gt)
% getGTFileInfo. 
%
%
% For each signal type, determine the maximum and minimum size, 
% form factor and filling ratio
%
% Input parameters:
%    S          information of the annotations  
%    path_gt    directory where the ground truth is located
%
% Ouput parameters:
%    ouputValues    each row corresponds to a signal type.
%                  ID (min/max/mean) | FA (min/max/mean) | W (min/max/mean)
%                | H (min/max/mean) | A (min/max/mean) | FR (min/max/mean) 
%                | FF (min/max/mean)
%
outputValues=[]
num_signals_Train = 0;
nameSignals = {'A', 'B', 'C', 'D', 'E', 'F'};
FA      = [];
minFR   = []; maxFR   = []; avgFR   = [];
minFF   = []; maxFF   = []; avgFF   = [];
minA    = []; maxA    = []; avgA    = [];
minH    = []; maxH    = []; avgH    = [];
minW    = []; maxW    = []; avgW    = [];

for idx_type = 1:S.numSuperClasses
    
    pos_t = S.v_id_superclass == idx_type;
   
    % Annotation files for this type of signal
    annotFile_x_t   = S.fileName(ismember(pos_t, 1));
    % Annotations info for this type of signal
    annotations_x_t = S.annotation(ismember(pos_t, 1));

    xX = cell2mat(cellfun( @(x) x.x, annotations_x_t, 'UniformOutput', false ));
    yY = cell2mat(cellfun( @(x) x.y, annotations_x_t, 'UniformOutput', false ));
    wW = cell2mat(cellfun( @(x) x.w, annotations_x_t, 'UniformOutput', false ));
    hH = cell2mat(cellfun( @(x) x.h, annotations_x_t, 'UniformOutput', false ));
 
    FA(end+1) = length(annotations_x_t);
    num_signals_Train = num_signals_Train + FA(end);
    
    % compute filling ratio
    FR_x_t = getFillingRatio(annotFile_x_t, path_gt, xX, yY, wW, hH);
    
    % Distribution of FR in term of size
    size_x_t = max([wW; hH]);
    [size_x_t, i] = sort(size_x_t);
    sortFR_x_t = FR_x_t(i);
    
    plot(size_x_t, sortFR_x_t, 'o');
    title(nameSignals{idx_type});
    saveas(gcf, ['Block_1/results/' nameSignals{idx_type} '.fig']);
    saveas(gcf, ['Block_1/results/' nameSignals{idx_type} '.png']);
    
    minFF(end+1) = min(FR_x_t);
    maxFF(end+1) = max(FR_x_t); 
    avgFF(end+1) = mean(FR_x_t);
    
    % determine size
    minH(end+1) = min(hH);  minW(end+1) = min(wW);
    maxH(end+1) = max(hH);  maxW(end+1) = max(wW);
    avgH(end+1) = mean(hH); avgW(end+1) = mean(wW);
    
    % determine area
    area = prod([wW;hH]);
    minA(end+1) = min(area);
    maxA(end+1) = max(area);
    avgA(end+1) = mean(area);
    
    % determine aspect ratio
    aspRatio = wW./hH;
    minFR(end+1) = min(aspRatio);
    maxFR(end+1) = max(aspRatio);
    avgFR(end+1) = mean(aspRatio);
 
    fprintf('Signal Type: %s (%d)\n', nameSignals{idx_type}, idx_type);
    fprintf('            min       max        mean\n', minA(end), maxA(end), avgA(end));
    fprintf('     area:  %6.2f   %6.2f   %6.2f\n', minA(end), maxA(end), avgA(end));
    fprintf('     w:     %6.4f   %6.4f   %6.4f\n', minW(end), maxW(end), avgW(end));
    fprintf('     h:     %6.4f   %6.4f   %6.4f\n', minH(end), maxH(end), avgH(end));
    fprintf('     FR:    %6.4f    %6.4f     %6.4f\n', minFR(end), maxFR(end), avgFR(end));
    fprintf('     FF:    %6.4f    %6.4f     %6.4f\n', minFF(end), maxFF(end), avgFF(end));
    fprintf('\n');
    
end

FA = FA/num_signals_Train;
fprintf('FA: \n');
% disp(FA)
outputValues = [(1:6)' FA' minW' maxW' avgW' minH' maxH' avgH' minA' maxA' avgA'...
            minFF' maxFF' avgFF' minFR' maxFR' avgFR'];


    function FR = getFillingRatio(annotFile_x_t, path_gt, xX, yY, wW, hH)
        FR = [];
        for idx_signal = 1:length(annotFile_x_t)
            
            annotFileName   = annotFile_x_t{idx_signal};
            % read ground truth
            mask            = logical(...
                                imread(strrep(...
                                fullfile(path_gt, ...
                                'mask', ['mask.', annotFileName(4:end)]), ...
                                'txt', 'png')));
            % crop the mask
            maskCrop   = imcrop(mask, [xX(idx_signal) yY(idx_signal) ...
                                       wW(idx_signal) hH(idx_signal)]);
            [m, n] = size(maskCrop);
            FR(end+1) = sum(maskCrop(:))/(m*n);
        end
    end

end

