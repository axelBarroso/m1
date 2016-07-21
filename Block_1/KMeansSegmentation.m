function [mask] = KMeansSegmentation(im)
    
    %Generates a mask assigning value '1' to those pixels considered signals and '0' 
    %to others.
    %im: RGB normalized image [0-1]

    mask = zeros(length(im(:,1,1)),length(im(1,:,1)));  
    imLab = colorspace('Lab<-rgb', im);
    imab = double(imLab(:,:,2:3));
    [m, n ,z] = size(imab);
    imab = reshape(imab, m*n,2);
    k = 5;

    [idx, C] = kmeans(imab,k, 'Replicates', 5);
    cluster_image = reshape(idx, m, n);
    imshow(cluster_image);
    finalImages = cell(1,3);

    for i = 1:k
        logicalIm = cluster_image;
        logicalIm(cluster_image ~= i) = 0;
        logicalIm(cluster_image == i) = 1;
        finalImages{i} = logical(logicalIm);
    end

    %Which components are red and blue?
    mask =  finalImages{1} + finalImages{4};
end

