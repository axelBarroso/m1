function isCandidate = filterCriteria(maskCrop, idx_windowSize, PARAM )

% maskCrop      Integral image

isCandidate = 1;

minFR = PARAM.SW.minFR(idx_windowSize);
maxFR = PARAM.SW.maxFR(idx_windowSize);

fillingRatio_SW = PARAM.SW.fEnergy(maskCrop);

% if filling ratio is out of range...
if ~(minFR < fillingRatio_SW && fillingRatio_SW < maxFR) 
    % ... discard CC as possible signal
    isCandidate = 0;
    return;
end



