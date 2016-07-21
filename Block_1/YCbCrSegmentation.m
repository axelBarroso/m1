function [mask] = YCbCrSegmentation(im)
    
    %Generates a mask assigning value '1' to those pixels considered signals and '0' 
    %to others.
    %im: RGB normalized image [0-1]
    
    global blueMin;
    global redMin;
    
    mask = zeros(length(im(:,1,1)),length(im(1,:,1))); %Generate mask 
    im = colorspace('YCbCr<-rgb',im); %Transform im to YCbCr
    
    %Normalize image [0-1]
    im(:,:,1) = (im(:,:,1) - 16) / (235 - 16);
    im(:,:,2) = (im(:,:,2) - 16) / (240 - 16);
    im(:,:,3) = (im(:,:,3) - 16) / (240 - 16);    
    
    %Pixels with Cb>blueMin and Cr <=0.5 are considered signal
    mask((im(:,:,2) > blueMin & im(:,:,3) <= 0.5)) = 1;
    %Pixels with Cr>redMin and Cb <=0.5 are considered signal
    mask((im(:,:,3) > redMin & im(:,:,2) <= 0.5)) = 1; 

end

