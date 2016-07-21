function [mask] = HSVREFSegmentation(im)
    
    %Generates a mask assigning value '1' to those pixels considered signals and '0' 
    %to others.
    %im: RGB normalized image [0-1]
    
    global blueRef;
    global redRef;
    
    mask = zeros(length(im(:,1,1)),length(im(1,:,1)));  
    
    %Generate colors with the reference color and a luminance of 0.9
    referenceRed = [redRef 0.9];
    referenceBlue = [blueRef 0.9];

    im = colorspace('HSV<-rgb',im);     %Convert image to HSV
    L = im(:,:,3);
    th = exp(-mean(L(:)));

    [m, n, z] = size(im);
    v_A = reshape(im, [m*n, z]);
    v_B = zeros([m*n, 1]);

    % Red segmentation
    v_rred =repmat(referenceRed, [m*n, 1]);
    % Euclidean distance between red reference color and color of all pixels of the
    % image
    dist_red = sqrt( ...
    (v_A(:,2).*cosd(v_A(:,1)) - v_rred(:,2).*cosd(v_rred(:,1))).^2 ...
    + (v_A(:,2).*sind(v_A(:,1)) - v_rred(:,2).*sind(v_rred(:,1))).^2);
    % Get only the pixels that keep the condition
    v_B(dist_red <= th) = 1;

    % Blue segmentation
    v_rblue =repmat(referenceBlue, [m*n, 1]);
    % Euclidean distance between blue reference color and color of all pixels of the
    % image
    dist_blue = sqrt( ...
    (v_A(:,2).*cosd(v_A(:,1)) - v_rblue(:,2).*cosd(v_rblue(:,1))).^2 ...
    + (v_A(:,2).*sind(v_A(:,1)) - v_rblue(:,2).*sind(v_rblue(:,1))).^2);
    % Get only the pixels that keep the condition
    v_B(dist_blue <= th) = 1;
    mask = reshape(v_B, [m, n]);

end

