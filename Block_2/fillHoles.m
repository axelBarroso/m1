function [ imFilled ] = fillHoles( im)

    %Fills holes of an image
    %im: Logical image [0,1]

    imComplement = imcomplement(logical(im));

    [m,n,z] = size(im);
    marker = ones(m,n,z);
    YY = zeros(m-2,n-2,z);
    marker(2:end-1,2:end-1,:)=YY;
    
    imFilled = reconstruct(imComplement, marker);
    imFilled = imcomplement(imFilled);

end

