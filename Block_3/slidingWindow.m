function [windowCandidates, windowMask] = slidingWindow(mask, PARAM)
%

% compute the integral image of pixelCandidates
maskIntegral = integralImage(mask);
            
windowCandidates = {};
windowMask = zeros(size(mask));
v_step      = PARAM.SW.steps;
v_width     = PARAM.SW.windowsW;
v_aspect    = PARAM.SW.windowsAR;

downSamplingRate    =  1;%PARAM.Window.downSampling;
% resize image in order to go faster
% mask = imresize(mask,downSamplingRate);
v_width     = floor(v_width .* downSamplingRate);

originalMask = mask;


imageWidth = size(mask, 2);
imageHeight = size(mask, 1);

% for each possible window size
for idx_window = 1:length(v_width)
    % window's size
    windowWidth = v_width(idx_window) + 1;
    windowHeight = floor((windowWidth - 1) / v_aspect(idx_window)) + 1;
    
    j = 1;
    % y (coordinate)
    while j < (imageHeight - windowHeight + 1)
        i = 1;
        % x (coordinate)
        while i < (imageWidth - windowWidth + 1)
            % define sliding window
            windowBox = [i j windowWidth windowHeight];
            maskCropIntegral = maskIntegral(j:j + windowHeight - 1, i:i + windowWidth - 1);
%             maskCrop = mask(j:j + windowHeight - 2, i:i + windowWidth - 2);
%             
%             subplot(1, 2, 1); imshow(maskCrop==1)
%             subplot(1, 2, 2); imshow(maskCropIntegral)
%             pause(0.1)
            
            % Do not consider windows with less than 1% of energy
            if PARAM.SW.fEnergy(maskCropIntegral) > 0.1% not valid for integral image -> sum(maskCrop(:))/(m*n) > 0.01

                isCandidate = filterCriteria(maskCropIntegral, idx_window, PARAM);

                if isCandidate
                    % Add window candidate to the list
                    candidate.x = (windowBox(1) + 1)/downSamplingRate;
                    candidate.y = (windowBox(2) + 1)/downSamplingRate;
                    candidate.w = (windowBox(3) - 1)/downSamplingRate;
                    candidate.h = (windowBox(4) - 1)/downSamplingRate;
%                     candidate.x = (windowBox(1) + windowBox_CC(1))/downSamplingRate;
%                     candidate.y = (windowBox(2) + windowBox_CC(2))/downSamplingRate;
%                     candidate.w = windowBox_CC(3)/downSamplingRate;
%                     candidate.h = windowBox_CC(4)/downSamplingRate;
                    windowCandidates = [windowCandidates; candidate];

                end
            end
        
            i = i + v_step(idx_window);
        end
        
        j = j + v_step(idx_window);
    end
    
end
windowCandidates = mergeOverlappingWindows(originalMask, windowCandidates, PARAM);


for idx_WC = 1:size(windowCandidates, 1)
    auxxX = windowCandidates(idx_WC).x;
    auxyY = windowCandidates(idx_WC).y;
    auxwW = windowCandidates(idx_WC).w;
    auxhH = windowCandidates(idx_WC).h;
    
    windowMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW) = ...
        originalMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW);
    
end
