function [newWindowCandidates, newWindowMask] = matchHT(im, windowCandidates, windowMask, PARAM)
newWindowCandidates = [];
num_peaks = 6;

Ig = rgb2gray(im);


% for each candidate window
for idx_sw = 1:length(windowCandidates)


    % triangles, squares, rectangles
    window = windowCandidates(idx_sw);
    wROI = Ig(window.y:window.y+window.h, ...
              window.x:window.x+window.w );
    % contour detection of the region of interest
    C = edge(wROI, 'canny', 0.2, 1.2);
%     imshowpair(wROI, C, 'montage')
    % Hough transform
    [H, theta, rho] = hough(C);
    peaks = houghpeaks(H, num_peaks);
    lines = houghlines(C, theta, rho, peaks);
   
    % lines: struct -> matrix
    M_lines = (reshape(struct2array(lines), [6, size(lines, 2)]))';
        
    if ~isempty(lines)
        
%         squares and rectangles
        isSquare = getSquares(M_lines);
        if isSquare
            newWindowCandidates =[ newWindowCandidates; window];
            continue;
        end
%         triangles
        isTriangle = getTriangles(M_lines);
        if isTriangle
            newWindowCandidates =[ newWindowCandidates; window];
            continue;
        end
        
    end
    %Circles
    isCircle = getCircles();
    if isCircle
        newWindowCandidates =[ newWindowCandidates; window];
        continue;
    end
    


end

newWindowMask = zeros(size(windowMask));
for idx_WC = 1:size(newWindowCandidates, 1)
    auxxX = newWindowCandidates(idx_WC).x;
    auxyY = newWindowCandidates(idx_WC).y;
    auxwW = newWindowCandidates(idx_WC).w;
    auxhH = newWindowCandidates(idx_WC).h;
    
    newWindowMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW) = ...
        windowMask(auxyY:auxyY+auxhH, auxxX:auxxX+auxwW);
end
%imshowpair(windowMask, newWindowMask, 'montage')

    function isTriangle = getTriangles(M_lines)
        isTriangle = 0;
        
        points = [M_lines(:, 1:2) ; M_lines(:, 3:4)];
        
        %
        maxDistCentroides = 5;
        maskClass = tril(dist(points, points') <= maxDistCentroides, -1);
        [idx_class, idy_class] = find(maskClass);
        
        vertex2remove = [];
        vertex2add = [];
        clusterMainNode = unique(idy_class);
        for idx = 1:length(clusterMainNode)
            posCluster  = find(idy_class==clusterMainNode(idx));
            vertexs     = [clusterMainNode(idx); idx_class(posCluster)];
            vertex2remove = [vertex2remove; vertexs];
            vertex2add    = [vertex2add; round(mean(points(vertexs, :), 1))];
        end
        vertex2remove   = unique(vertex2remove);
        mask2remove     = ~ismember([1:size(points, 1)], [vertex2remove]);
        points          = [vertex2add; points(mask2remove, :)];
        points          = unique(points, 'rows');
        
        if size(points, 1) < 3
            return;
        end
        % Define all possible combination
        connectivityList    = combntns(1:size(points, 1), 3);
        TR                  = triangulation(connectivityList,points);
        % compute incenter and circumcenter
        [IC, irad]          = incenter(TR);
        [CC, crad]          = circumcenter(TR);
        
        % Rcircumcenter = 2Rincenter if and only if the triangle...
        % is equilateral
        varCCvsIC           = 5;
        circumVSincircle    = @(x, y)bsxfun(@le, y, x/2 + varCCvsIC) & ...
            bsxfun(@ge, y, x/2 - varCCvsIC);
        candidateEquilaters = circumVSincircle(crad, irad);
        
        % The incenter and the circumcenter coincide if and only if ...
        % the triangle is equilateral
        distCenters     = dist(IC, CC');
        distCenters(~candidateEquilaters, ~candidateEquilaters) = 0;
        filterByCenter  = diag(distCenters);

        candidateEquilaters(filterByCenter > 2) = 0;

        % if there is any triangle ->
        if any(candidateEquilaters)
            isTriangle = 1;
        end
    end

    function isCircle = getCircles()
        isCircle = 0;
        
        minRad = round(window.w/2.5);
        maxRad = round(window.w/2);
        wROIAdjusted = imadjust(wROI);
        
        [circenB,~] = imfindcircles(wROIAdjusted,[minRad maxRad],  'ObjectPolarity', 'bright', 'Sensitivity', 0.97);
        [circenD,~] = imfindcircles(wROIAdjusted,[minRad maxRad],  'ObjectPolarity', 'dark', 'Sensitivity', 0.97);
        
        if ~isempty(circenB) || ~isempty(circenD)
                isCircle = 1;
        end
    end

    function isSquare = getSquares(M_lines)
        isSquare = 0;
        % First filter, discard lines which has not 0º or 90º degrees
        % diagonal lines 30 and 60 degrees
        M_lines((30 < abs(M_lines(:,5))) & (abs(M_lines(:,5)) < 60), :) = [];
        
        Points = [];
        IncrementAngle = 10;
        if size(M_lines, 1) < 3
            return;
        end
        % Find perpendicular lines
        for i = 1 : size(M_lines,1)
            for j = 1: size(M_lines,1)
                if((abs(M_lines(i, 5)-M_lines(j,5)) > (90 - IncrementAngle)) ...
                        && (abs(M_lines(i, 5)-M_lines(j,5)) < (90 + IncrementAngle)))
                    % This is a perpendicular lines, find his intersection point!
                    x1 = M_lines(i,1); y1 = M_lines(i, 2);
                    x2 = M_lines(i,3); y2 = M_lines(i,4);
                    
                    x3 = M_lines(j,1); y3 = M_lines(j, 2);
                    x4 = M_lines(j,3); y4 = M_lines(j,4);
                    
                    X = ((x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4))/...
                        ((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
                    Y = ((x1*y2 -y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4))/...
                        ((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
                    
                    Points = [Points; round(X) round(Y)];
                end
            end
        end
        
        if isempty(Points)
            return;
        end
        %Check if we detect more than one point in the same corner
        maxDistCentroides = 5;
        maskClass = tril(dist(Points, Points') <= maxDistCentroides, -1);
        [idx_class, idy_class] = find(maskClass);
        
        vertex2remove = [];
        vertex2add = [];
        clusterMainNode = unique(idy_class);
        while ~isempty(clusterMainNode)
            posCluster  = find(idy_class==clusterMainNode(1));
            vertexs     = [clusterMainNode(1); idx_class(posCluster)];
            vertex2remove = [vertex2remove; vertexs];
            vertex2add    = [vertex2add; round(mean(Points(vertexs, :), 1))];
            clusterMainNode(ismember(clusterMainNode, vertexs)) = [];
        end
        
        vertex2remove   = unique(vertex2remove);
        mask2remove     = ~ismember([1:size(Points, 1)], [vertex2remove]);
        Points          = [vertex2add; Points(mask2remove, :)];
        Points          = unique(Points, 'rows');
        
        
        %Extract all possible square combination with our points
        if size(Points,1) == 1
            return
        end
        combos = combntns(1:size(Points,1) , 4);
        
        maxMargin = 15; % 15%
        for i = 1: size(combos,1)
            
            pointsToCheck = Points(combos(i,:),:);
            
            posmean = mean(pointsToCheck, 1);
            xmean = round(posmean(1));
            ymean = round(posmean(2));
            
            UpLeft      = pointsToCheck( pointsToCheck(:,1) < xmean & pointsToCheck(:,2) > ymean,:);
            UpRight     = pointsToCheck( pointsToCheck(:,1) > xmean & pointsToCheck(:,2) > ymean,:);
            DownLeft    = pointsToCheck( pointsToCheck(:,1) < xmean & pointsToCheck(:,2) < ymean,:);
            DownRight   = pointsToCheck( pointsToCheck(:,1) > xmean & pointsToCheck(:,2) < ymean,:);
            
            if isempty(UpLeft) | isempty(UpRight) | isempty(DownLeft) | isempty(DownRight)
                continue;
            end
            %Check if the hypot theoretical is similar enough to our hypot
            %calculated
            a = round(dist(UpLeft, UpRight'));
            b = round(dist(UpLeft, DownLeft'));
            c = round(dist(UpLeft, DownRight'));
            c_Theoretical = sqrt(abs(a).^2 + abs(b).^2);
            
            c_Theoretical_UpperLimit = c_Theoretical + c_Theoretical * maxMargin;
            c_Theoretical_LowerLimit = c_Theoretical - c_Theoretical * maxMargin;
            
            if c_Theoretical_LowerLimit < c &&  c < c_Theoretical_UpperLimit
                isSquare = 1;
                
                %Just to show the figure 'cause Monica wants to
                imshow(C), hold on
                xy = [UpLeft; UpRight; UpLeft; DownLeft; UpRight; DownRight; DownLeft; DownRight];            
                for i = 1:2:8
                    plot(xy(i:i+1, 1), xy(i:i+1, 2),'LineWidth',2,'Color','green');
                end
                % Plot beginnings and ends of lines
                plot(xy(:,1),xy(:,2),'x','LineWidth',2,'Color','yellow');
                break;
                
            end
        end
        
    end
end