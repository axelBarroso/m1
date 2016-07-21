function [detections, resultingMask] = matchModels( windowCandidates, windowMask, PARAM )

global circleTemplate;
global givewayTemplate;       
global rectangleTemplate; 
global triangleTemplate;
global squareTemplate;

detections = [];
models = {circleTemplate.circleModel, givewayTemplate.givewayModel, rectangleTemplate.rectangleModel, triangleTemplate.triangleModel, squareTemplate.squareModel};

%For each window candidate
for i = 1:length(windowCandidates)
    window  = imcrop(windowMask, [windowCandidates(i).x windowCandidates(i).y ...
                           windowCandidates(i).w-1 windowCandidates(i).h-1]);
    %For each model
    s = windowCandidates(i).w / length(models{1});
    for m = 1:length(models)
        curModel = imresize(models{m},s);
        corr = corr2(curModel,window);
        if(corr > PARAM.Matching.corrThreshold)
            detections = [detections; windowCandidates(i)];
            break
        end
    end
    
end


%Generate mask with selected windows
resultingMask = zeros(size(windowMask));
for idx_WC = 1:size(detections, 1)
    auxxX = detections(idx_WC).x;
    auxyY = detections(idx_WC).y;
    auxwW = detections(idx_WC).w;
    auxhH = detections(idx_WC).h;
    
    resultingMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW) = ...
        windowMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW);
      
    if PARAM.Window.displayCandidateWindow
        candidateWindow = windowMask(auxyY:auxyY+auxhH, ...
        auxxX:auxxX+auxwW);
        subplot(1, 2, 1);imshow(windowMask);
        subplot(1, 2, 2);imshow(candidateWindow);
        pause(0.2)
    end
end

end

