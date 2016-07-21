function imReconstructed = reconstruct(im, marker)
% Dual reconstruction

% Binarize the image
im = logical(im);

% Define structural element of 3x3 (square)
SE = ones(3,3);

equal = 0;
while(equal == 0)
    markerPrevious = marker;
    markerdilate = mydilate(marker, SE);
    marker = markerdilate & im;
    
    if(markerPrevious == marker)
        equal = 1;
    end    
end

imReconstructed = marker;
