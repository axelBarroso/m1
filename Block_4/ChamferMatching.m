function [windowResultants, concludingMask] = ChamferMatching( im, windowCandidates, windowMask, PARAM )

global circleTemplate;
global givewayTemplate;
global rectangleTemplate;
global triangleTemplate;
global squareTemplate;

windowResultants = [];
models = {circleTemplate.circleModel, givewayTemplate.givewayModel, rectangleTemplate.rectangleModel, triangleTemplate.triangleModel, squareTemplate.squareModel};

for i=1:5
models{i} = padarray(models{i} ,[5 5], 'both');
end

Ig = rgb2gray(im);
%For each window candidate
for i = 1:length(windowCandidates)
    
    window  = imcrop(Ig, [windowCandidates(i).x windowCandidates(i).y ...
        windowCandidates(i).w-1 windowCandidates(i).h-1]);
    
    %For each model
     
    % A canny edge detector with 0.02 threshold and 1.4 sigma is used.    [edgeWindow,thresh] = edge(window,'canny', 0.02,1.4);
    [edgeWindow,thresh] = edge(window,'canny', 0.02, 1.4);
    Dist_Window = bwdist(edgeWindow);
    
    Dist_Window = padarray(Dist_Window,[5 5], 'both');
    
    sizeWindow = size(Dist_Window);%ceil(windowCandidates(i).w) / ceil(length(models{1}));
   
    
    for m = 1:length(models)
        
        curModel = imresize(models{m},sizeWindow);
        [edgecurModel,thresh] = edge(curModel,'canny', 0.02,1.4);
        
        D = (Dist_Window.*edgecurModel);
        
        sumD = sum(D(:)); %normalizar
        
        den = sum(edgecurModel(:));
        
        averageChamferDistance = sumD / den;
        
        % si es cero match perfecto
        if(averageChamferDistance < PARAM.Matching.ChamferDThreshold)
            windowResultants = [windowResultants; windowCandidates(i)];
            break
        end
    end
end


%Generate mask with selected windows
concludingMask = zeros(size(windowMask));
for idx_WC = 1:size(windowResultants, 1)
    auxxX = windowResultants(idx_WC).x;
    auxyY = windowResultants(idx_WC).y;
    auxwW = windowResultants(idx_WC).w;
    auxhH = windowResultants(idx_WC).h;
    
    concludingMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW) = ...
        windowMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW);

end

end