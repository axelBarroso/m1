function B = myclosing(A, SE)

% dilation
Bd  = mydilat(A, SE);

% erosion
B   = myerode(Bd, SE);