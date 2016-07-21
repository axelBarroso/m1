function B = myopening_v2(A, SE)

% erosion
Be  = myerode_v2(A, SE);

% dilation
B   = mydilate_v2(Be, SE);