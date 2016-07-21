function mergeWindowCandidates = mergeOverlappingWindows(mask, windowCandidates, PARAM)


mergeWindowCandidates = [];

if(size(windowCandidates) == 0)
    return;
end

%

xX = cell2mat(cellfun( @(x) x.x, windowCandidates, 'UniformOutput', false ));
yY = cell2mat(cellfun( @(x) x.y, windowCandidates, 'UniformOutput', false ));
wW = cell2mat(cellfun( @(x) x.w, windowCandidates, 'UniformOutput', false ));
hH = cell2mat(cellfun( @(x) x.h, windowCandidates, 'UniformOutput', false ));
windowBoxes = [xX yY wW hH];

%windowBoxes = [ 10 10 4 4; 11 11 6 6; 14 15 2 2; 20 11 4 4];

% definition of when two windows intersect
leftOverlap = @(x, y)bsxfun(@ge, x(:, 1), y(:,1)') & ...
    bsxfun(@le, x(:, 1), (y(:,1)+y(:,3)-1)');
rightOverlap = @(x, y)bsxfun(@ge, x(:, 1)+x(:,3)-1, y(:,1)') & ...
    bsxfun(@le, x(:, 1), y(:,1)');
topOverlap = @(x, y)bsxfun(@ge, x(:, 2), y(:,2)') & ...
    bsxfun(@le, x(:, 2), (y(:,2)+y(:,4)-1)');
bottomOverlap = @(x, y)bsxfun(@ge, x(:, 2)+x(:,4)-1, y(:,2)') & ...
    bsxfun(@le, x(:, 2), y(:,2)');

idx_CW = 1;
reducedWindowBoxes = [];
% while ~isempty(windowBoxes)%(idx_CW < size(windowBoxes, 2))

sizeSW = unique(windowBoxes(:, 3:4), 'rows');
for idx_sizeSW = 1:size(sizeSW, 1)
    % Select windows of the same size 
    OverlappingCandidates = windowBoxes(...
        ismember(windowBoxes(:,3:4), ...
        sizeSW(idx_sizeSW, :), 'rows'), ...
        :);
    
    while ~isempty(OverlappingCandidates)
        % Check if there are windows that are overlapping
        matchSW = ( leftOverlap(OverlappingCandidates(idx_CW,:), OverlappingCandidates) | ...
            rightOverlap(OverlappingCandidates(idx_CW,:), OverlappingCandidates) ) & ...
            ( topOverlap(OverlappingCandidates(idx_CW,:), OverlappingCandidates) | ...
            bottomOverlap(OverlappingCandidates(idx_CW,:), OverlappingCandidates) );
        
        % Select the windows that are overlapping
        subOverlapCand = OverlappingCandidates(matchSW, :);
        
        % Get the mean center position
        xmin    = min(subOverlapCand(:, 1));
        xmax    = max(subOverlapCand(:, 1) + subOverlapCand(:,3));
        xcenter = mean([xmin xmax]);
        
        ymin    = min(subOverlapCand(:, 2));
        ymax    = max(subOverlapCand(:, 2) + subOverlapCand(:,4));
        ycenter = mean([ymin ymax]);
        
        % Define new window (center position)
        reducedWindowBoxes(end+1,:) = [xcenter-(sizeSW(idx_sizeSW, 1)/2) ...
            ycenter-(sizeSW(idx_sizeSW, 2)/2) ...
            sizeSW(idx_sizeSW, 1) ...
            sizeSW(idx_sizeSW, 2)];
        
        OverlappingCandidates(matchSW, :) = [];
    end
    
end

% Define window candidates
for idx_cSW = 1:size(reducedWindowBoxes, 1)
    mergeCandidate.x = reducedWindowBoxes(idx_cSW, 1);
    mergeCandidate.y = reducedWindowBoxes(idx_cSW, 2);
    mergeCandidate.w = reducedWindowBoxes(idx_cSW, 3);
    mergeCandidate.h = reducedWindowBoxes(idx_cSW, 4);
    %If the resulting window is not too big, it's a signal
    %     if (mergeCandidate.w < maxW) && (mergeCandidate.h < maxH)
    mergeWindowCandidates = [mergeWindowCandidates; mergeCandidate];
    %     end
end

