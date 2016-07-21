function B = mydilate(A, SE)

center = floor((size(SE)+1)/2);

% padding for the convolution
top_padding     = abs(1 - center(1));
bottom_padding  = size(SE, 1) - center(1);
left_padding    = abs(1 - center(2));
right_padding   = size(SE, 2) - center(2);

Baux = conv2(double(A), double(SE));
B =  Baux(top_padding+1  : end-bottom_padding,...
                left_padding+1 : end-right_padding) ;
            
B = double(B);