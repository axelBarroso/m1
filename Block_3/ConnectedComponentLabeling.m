function [windowCandidates, windowMask] = ConnectedComponentLabeling(mask, PARAM) 
    
minAR = PARAM.CC.minAR;
maxAR = PARAM.CC.maxAR;
minFR = PARAM.CC.minFR;
maxFR = PARAM.CC.maxFR;



windowMask = mask;
windowCandidates = [];


CC = bwconncomp(mask);
% L = labelmatrix(CC);
% figure;imshow(label2rgb(L))

% Calculate properties of regions in the mask
stats =  regionprops(CC, 'Centroid', 'Area', 'Perimeter', ...
                         'BoundingBox', 'MajorAxisLength', ...
                         'MinorAxisLength', 'PixelList');
                     
Area            = cat(1, stats.Area);
Perimeter       = cat(1, stats.Perimeter);
boundingBox     = cat(1, stats.BoundingBox);



for idx_CC = 1:CC.NumObjects
    
    
    
    % compute width and height
    width_CC  = boundingBox(idx_CC, 4);
    height_CC = boundingBox(idx_CC, 3);
    
    % compute aspect ratio 
    aspectRatio_CC = width_CC / height_CC;
    AreaBox_CC = width_CC * height_CC;
    
    % if aspect ratio is out of range...
    if aspectRatio_CC > maxAR || aspectRatio_CC < minAR
        % ... discard CC as possible signal
        windowMask(CC.PixelIdxList{idx_CC}) = 0;
        if PARAM.CC.display
            subplot(1, 2, 1); imshow(mask), subplot(1, 2, 2); imshow(windowMask)
        end
        continue;

    end
    
    % compute filling ratio
    maskCrop   = imcrop(mask, [boundingBox(idx_CC, 1) boundingBox(idx_CC, 2) ...
                               boundingBox(idx_CC, 4) boundingBox(idx_CC, 3)]);
    [m, n] = size(maskCrop);
    fillingRatio_CC = sum(maskCrop(:))/(m*n);
    
    % if filling ratio is out of range...
    if fillingRatio_CC > maxFR || fillingRatio_CC < minFR
        % ... discard CC as possible signal
        windowMask(CC.PixelIdxList{idx_CC}) = 0;
        if PARAM.CC.display
            subplot(1, 2, 1); imshow(mask), subplot(1, 2, 2); imshow(windowMask)
        end
        continue;
    end
    
    % compute geometry
    CircleMetric = (Perimeter(idx_CC)^2)./(4*pi*Area(idx_CC)); 
    SquareMetric = aspectRatio_CC;    
    TriangleMetric = Area(idx_CC)/AreaBox_CC;  
    
    isCircle =   (CircleMetric < 1.1);
    isTriangle = ~isCircle & (TriangleMetric < 0.6);
    isSquare =   ~isCircle & ~isTriangle & (SquareMetric > 0.9);
    isRandom=    ~isCircle & ~isTriangle & ~isSquare; 
    
    if isRandom
            % ... discard CC as possible signal
        windowMask(CC.PixelIdxList{idx_CC}) = 0;
        if PARAM.CC.display
            subplot(1, 2, 1); imshow(mask), subplot(1, 2, 2); imshow(windowMask)
        end
        continue;
    end
    
%     % if width or height are very small (only for CC that fulfill FR and AS
%     % but are very small to be a signal)...
%     if width_CC < minW || height_CC < minH
%         % ... discard CC as possible signal
%         windowMask(CC.PixelIdxList{idx_CC}) = 0;
%         if PARAM.CC.display
%             subplot(1, 2, 1); imshow(mask), subplot(1, 2, 2); imshow(windowMask)
%         end
%         continue;
%     end
    
    
    % Add window candidate to the list
    candidate.x = boundingBox(idx_CC, 1);
    candidate.y = boundingBox(idx_CC, 2);
    candidate.w = boundingBox(idx_CC, 3);
    candidate.h = boundingBox(idx_CC, 4);
    windowCandidates = [windowCandidates; candidate];
end
