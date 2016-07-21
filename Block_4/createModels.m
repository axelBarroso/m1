function [ ] = createModels(  )
s = 400;

squareModel = zeros(s,s);
xCoords = [20 s-20 s-20 20];
yCoords = [0 0 s s];
mask = poly2mask(xCoords, yCoords, s, s);
squareModel(mask) = 1;
save Block_4/models/TemplateSquares.mat squareModel

rectangleModel = zeros(s,s);
xCoords = [50 s-50 s-50 50];
yCoords = [0 0 s s];
mask = poly2mask(xCoords, yCoords, s, s);
rectangleModel(mask) = 1;
save Block_4/models/TemplateRectangles.mat rectangleModel

radius = 199.5;
[X, Y] = meshgrid(-radius:radius, -radius:radius);
circleModel = zeros(2*radius+1);
circleModel(sqrt(X.^2 + Y.^2) <= radius) = 1;
save Block_4/models/TemplateCircles.mat circleModel

givewayModel = zeros(s, s);
xCoords = [0 s/2 s];
yCoords = [0 s 0];
mask = poly2mask(xCoords, yCoords, s, s);
givewayModel(mask) = 1;
save Block_4/models/TemplateGiveways.mat givewayModel

triangleModel = imrotate(givewayModel,180);
save Block_4/models/TemplateTriangles.mat triangleModel

end

