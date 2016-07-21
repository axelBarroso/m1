%% triangle example
I = imread('00.001232.jpg');
I2 = rgb2gray(I);

[A, s] = LoadAnnotations('gt.00.001232.txt');

[accum, circen, cirrad] = CircularHough_Grd(I2, [27 200]);
figure(1); imagesc(accum); axis image;
title('Accumulation Array from Circular Hough Transform');
figure(2); imshow(wROI); %colormap('gray'); axis image;
hold on;
plot(circen(:,1), circen(:,2), 'r+');
for k = 1 : size(circen, 1),
    DrawCircle(circen(k,1), circen(k,2), cirrad(k), 32, 'g*-');
end
hold off;
title(['Raw Image with Circles Detected ', ...
    '(center positions and radii marked)']);
figure(3); surf(accum, 'EdgeColor', 'none'); axis ij;
title('3-D View of the Accumulation Array');
