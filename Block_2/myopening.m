function B = myopening(A, SE)

% erosion
Be  = myerode(A, SE);

% dilation
B   = mydilate(Be, SE);