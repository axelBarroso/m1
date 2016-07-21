function B = myerode(A, SE)

center = floor((size(SE)+1)/2);

% Padding for the correlation
top_padding     = abs(1 - center(1));
bottom_padding  = size(SE, 1) - center(1);
left_padding    = abs(1 - center(2));
right_padding   = size(SE, 2) - center(2);

B = xcorr2(1-A, SE);
B = B(top_padding+1  : end-bottom_padding,...
                left_padding+1 : end-right_padding);

B = B==min(B(:));
B = double(B);
