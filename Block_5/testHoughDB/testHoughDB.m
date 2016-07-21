%% triangle example
I = imread('00.001852.jpg');
I2 = rgb2gray(I);

[A, s] = LoadAnnotations('gt.00.001852.txt');

%% square
%% rectangle
%% Common procedure
maxDist = 10;
% select only region of interest
wROI = I2(A(1).y:A(1).y+A(1).h, A(1).x:A(1).x+A(1).w );
% contour detection of the region of interest
C = edge(wROI, 'canny', 0.2, 1.2);

figure; imshowpair(wROI,C,'montage')

% Hough transform
[H, theta, rho] = hough(C);

imshow(imadjust(mat2gray(H)),'XData',theta,'YData',rho,...
      'InitialMagnification','fit');
title('Hough transform of gantrycrane.png');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(hot);

num_peaks = 6;
peaks = houghpeaks(H, num_peaks);

lines = houghlines(C, theta, rho, peaks)


figure, imshow(C), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end

%% triangle detection
% lines: struct -> matrix 
M_lines = (reshape(struct2array(lines), [num_peaks, 6]))';

points = [M_lines(:, 1:2) ; M_lines(:, 3:4)];

% 
maxDistCentroides = 5;
maskClass = tril(dist(points, points') <= maxDistCentroides, -1);
[idx_class, idy_class] = find(maskClass);

vertex2remove = [];
vertex2add = [];
clusterMainNode = unique(idy_class) 
for idx = 1:length(clusterMainNode)
    posCluster  = find(idy_class==clusterMainNode(idx));
    vertexs     = [clusterMainNode(idx); idx_class(posCluster)];
    vertex2remove = [vertex2remove; vertexs];
    vertex2add    = [vertex2add; round(mean(points(vertexs, :), 1))]
end
vertex2remove   = unique(vertex2remove);
mask2remove     = ~ismember([1:size(points, 1)], [vertex2remove]);
points          = [vertex2add; points(mask2remove, :)]
points          = unique(points, 'rows')
% Define all possible combination
connectivityList = combntns(1:size(points, 1), 3);
TR = triangulation(connectivityList,points)
[IC, irad] = incenter(TR);
[CC, crad] = circumcenter(TR);

varCCvsIC = 4;
circumVSincircle = @(x, y)bsxfun(@le, y, x/2 + varCCvsIC) & ...
                          bsxfun(@ge, y, x/2 - varCCvsIC);
candidateEquilaters = circumVSincircle(crad, irad);

distCenters = dist(IC, CC');
distCenters(~candidateEquilaters, ~candidateEquilaters) = 0;
filterByCenter = diag(distCenters);

candidateEquilaters(filterByCenter>0.5) = 0;
% if there is any triangle -> 
if any(candidateEquilaters)
    
end


candidateTriangles = connectivityList(candidateEquilaters, :);
figure, imshow(C), hold on
for k = 1:length(candidateTriangles)
    triangle = candidateTriangles(k, :);
    pTriangle = points(triangle', :);
    for l=1:2
        xy = [pTriangle(l, :); pTriangle(l+1, :)];
        plot(xy(:,1), xy(:, 2), 'LineWidth',2,'Color','green');
    end
    xy = [pTriangle(3, :); pTriangle(1, :)];
    plot(xy(:,1), xy(:, 2), 'LineWidth',2,'Color','green');
        
   % Plot beginnings and ends of lines
   plot(xy(:,1),xy(:,2),'x','LineWidth',2,'Color','yellow');

end