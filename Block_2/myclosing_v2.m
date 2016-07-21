function B = myclosing_v2(A, SE)

% dilation
Bd  = mydilate_v2(A, SE);

% erosion
B   = myerode_v2(Bd, SE);