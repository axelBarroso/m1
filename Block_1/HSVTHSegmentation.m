function [mask] = HSVTHSegmentation(im)
    
    %Generates a mask assigning value '1' to those pixels considered signals and '0' 
    %to others.
    %im: RGB normalized image [0-1]
    
    global blueMin;
    global redMin;
    global blueMax;
    global redMax;
    
    mask = zeros(length(im(:,1,1)),length(im(1,:,1)));  
    im = colorspace('HSV<-rgb',im); %Convert image to HSV
    im(:,:,1) = im(:,:,1) / 360;    %Normalize image [0-1]
    
    %Pixels with hue between colorMin and colorMax are considered signal
    mask((im(:,:,1) > blueMin & im(:,:,1) < blueMax)) = 1;
    mask((im(:,:,1) > redMin & im(:,:,1) < redMax)) = 1;
end

