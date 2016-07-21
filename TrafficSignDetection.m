function TrafficSignDetection(directory, pixel_method, morphological_method, window_method, decision_method, PARAM, OPT)

% TrafficSignDetection
% Perform detection of Traffic signs on images. Detection is performed first at the pixel level
% using a color segmentation. Then a morphological transformation is done to improve the segmentation. Then, using the color
% segmentation as a basis, the most likely window
% candidates to contain a traffic sign are selected using basic features (form factor, filling factor).
% Finally, a decision is taken on these windows using geometric heuristics (Hough) or template matching.
%
%    Parameter name              Value
%    --------------              -----
%    'directory'                 directory where the images to analize  (.jpg) reside
%    'pixel_method'              Name of the color space: 'opp', 'normrgb', 'lab', 'hsv', etc. (Weeks 2-5)
%    'morphological_method'      'Reconstruct', 'Opening' or 'TopHat'
%    'window_method'             'SegmentationCCL' or 'SlidingWindow' (Weeks 3-5)
%    'decision_method'           'GeometricHeuristics' or 'TemplateMatching' (Weeks 4-5)
%    'colorBlueVar'              HSV-REF: Reference hue blue color offset. Blue reference is 210 + colorBlueVar (º)
%                                YCbCr: Min Cb accepted offset. Min Cb = 0.5 + colorBlueVar. [0-1]
%                                HSV-TH: Hue color variance accepted. (º)
%    'colorRedVar'               HSV-REF: Reference hue red color offset. Blue reference is 210 + colorRedVar (º)
%                                YCbCr: Min Cr accepted offset. Min Cr = 0.5 + colorRedVar. [0-1]
%                                HSV-TH: Hue color variance accepted. (º)

    global CANONICAL_W;        CANONICAL_W = 64;
    global CANONICAL_H;        CANONICAL_H = 64;
    global SW_STRIDEX;         SW_STRIDEX = 8;
    global SW_STRIDEY;         SW_STRIDEY = 8;
    global SW_CANONICALW;      SW_CANONICALW = 32;
    global SW_ASPECTRATIO;     SW_ASPECTRATIO = 1;
    global SW_MINS;            SW_MINS = 1;
    global SW_MAXS;            SW_MAXS = 2.5;
    global SW_STRIDES;         SW_STRIDES = 1.2;

    %Min and Max color values accepted for YCbCr and HSV-TH
    global blueMin;
    global redMin;
    global blueMax;
    global redMax;

    %Reference colors for HSV-REF
    global redRef;
    global blueRef;

    % Load models
    global circleTemplate;
    global givewayTemplate;
    %     global stopTemplate;
    global rectangleTemplate;
    global triangleTemplate;
    global squareTemplate;

    if strcmp(decision_method, 'TemplateMatching')
        circleTemplate    = load('TemplateCircles.mat');
        givewayTemplate   = load('TemplateGiveways.mat');
        %        stopTemplate      = load('TemplateStops.mat');
        rectangleTemplate = load('TemplateRectangles.mat');
        triangleTemplate  = load('TemplateTriangles.mat');
        squareTemplate  = load('TemplateSquares.mat');
    end

    windowTP=0; windowFN=0; windowFP=0; windowDCO=0;% (Needed after Week 3)
    pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;


    %Define color values
    switch pixel_method

        case 'YCbCr'
            blue = 0.5;
            red = 0.5;
            blueMin = blue + colorBlueVar; %Min Cb value for blue.
            redMin = red + colorRedVar;    %Min Cr value for red.

        case 'HSV-TH'
            blue = 0.6;                         %Blue signals hue maximum [0-1]
            red = 0.0157;                       %Red signals hue maximum [0-1]
            blueMin = (blue - colorBlueVar/2);  %Min blue hue value
            blueMax = (blue + colorBlueVar/2);  %Max blue hue value
            redMin = (red - colorRedVar/2);     %Min red hue value
            redMax = (red + colorRedVar/2);     %Max red hue value

            %Normalize hue thresholds to [0-1]
            if blueMin < 0
                blueMin = 1 + blueMin;
            end
            if redMin < 0
                redMin = 1 + redMin;
            end

        case  'HSV-REF'
            blue = 210;                     %Blue signals hue maximum (º)
            red = 0;                        %Red signals hue maximum (º)
            blueRef = blue + PARAM.ColorSpace.colorBlueVar;  %Blue hue reference
            redRef = red + PARAM.ColorSpace.colorRedVar;     %Red hue reference
    end

    toRun = [OPT.colorSegmentation OPT.SLW OPT.TM]
    %Images segmentacion
    files = ListFiles(directory);
    for i=1:size(files,1)
        
        disp(['Image ' num2str(i) '  of ' num2str(size(files,1))]);

        % Read file
        im = imread(strcat(directory,filesep,files(i).name));

        if OPT.colorSegmentation
            %Color segmentation
            pixelCandidates = CandidateGenerationPixel_Color(im, pixel_method);
            %Morphological transformation
            pixelCandidates = morphologicalTransformation(pixelCandidates, morphological_method);
        else
            if toRun(1+1)==1
                % Read mask from disk
                pixelCandidates = imread([OPT.colorSegmentationPath2read ...
                    '/mask.HSV-REF.Reconstruct.'...
                    files(i).name(1:size(files(i).name,2)-3) 'png'])>0;
            end
        end
        
        if OPT.SLW
            % Candidate Generation (window)
            %%'SegmentationCCL' or 'SlidingWindow'  (Needed after Week 3)
            [windowCandidates, pixelCandidates] = ...
                CandidateGenerationWindow(im, ...
                pixelCandidates, window_method, PARAM);
            
            mkdir(OPT.SLWpath2save);
            % save results
            save([OPT.SLWpath2save filesep ...
                        files(i).name(1:size(files(i).name,2)-3) 'mat'], ...
                        'windowCandidates', 'pixelCandidates');
        else
            if toRun(2+1) == 1
                % Read window candidates from disk
                % para evaluar sobre el ground truth
%                 windowCandidates = LoadAnnotations(strcat(directory, ...
%                         filesep, 'gt', filesep, 'gt.', ...
%                         files(i).name(1:size(files(i).name,2)-3), 'txt'));
%                 pixelCandidates = imread(strcat(directory, ...
%                 '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), ...
%                 'png'))>0;
                windowSaved = load([OPT.SLWpath2read ...
                                filesep files(i).name(...
                                1:size(files(i).name,2)-3) 'mat']);
                windowCandidates = windowSaved.windowCandidates;
                pixelCandidates       = windowSaved.windowMask;  
            end
        end

        if OPT.TM
            % Template matching
            [windowCandidates, pixelCandidates] = ...
                CandidateMatchingWindow(im, decision_method, ...
                windowCandidates, pixelCandidates,PARAM);
            
            mkdir(OPT.TMpath2save);
            % save results
            save([OPT.TMpath2save filesep ...
                        files(i).name(1:size(files(i).name,2)-3) 'mat'], ...
                        'windowCandidates', 'pixelCandidates');
        else
%             % Read window candidates from disk
%             
%             windowSaved = load([OPT.TMpath2read ...
%                                 filesep files(i).name(...
%                                 1:size(files(i).name,2)-3) 'mat']);
%                 windowCandidates = windowSaved.windowCandidates;
%                 pixelCandidates       = windowSaved.windowMask;
            
        end

        % Accumulate pixel performance of the current image
        pixelAnnotation = imread(strcat(directory, ...
            '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), ...
            'png'))>0;
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = ...
            PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);

        pixelTP = pixelTP + localPixelTP;
        pixelFP = pixelFP + localPixelFP;
        pixelFN = pixelFN + localPixelFN;
        pixelTN = pixelTN + localPixelTN;

        % Accumulate object performance of the current image
        windowAnnotations = LoadAnnotations(strcat(directory, ...
            filesep, 'gt', filesep, 'gt.', ...
            files(i).name(1:size(files(i).name,2)-3), 'txt'), pixelAnnotation, 2);
        
        
        [localWindowTP, localWindowFN, localWindowFP, localDCO] = ...
            PerformanceAccumulationWindow(windowCandidates, windowAnnotations, 1);

        windowTP = windowTP + localWindowTP;
        windowFN = windowFN + localWindowFN;
        windowFP = windowFP + localWindowFP;
        windowDCO = windowDCO + localDCO;
        
    end


    % Pixel evaluation
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity, F]...
        = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity, F]
    [ pixelTP, pixelFP, pixelFN]

    
    
    t = 'currentTime';
    % Save to disk (pixel based evaluation
    e = {F, pixelPrecision, pixelAccuracy, pixelSpecificity,...
            pixelSensitivity, ...
            blue, PARAM.ColorSpace.colorBlueVar, ...
            red, PARAM.ColorSpace.colorRedVar, ...
            pixel_method, window_method, ...
            decision_method, PARAM.Matching.corrThreshold...
            pixelTP, pixelFP, pixelFN, pixelTN, t};
    load evaluation;
    newEvaluation = [evaluation;e];
    
    file2save = [OPT.pixelEvaluation '_pixel.mat']
%     mkdir(file2save);
    save(file2save,'newEvaluation');

    
    
    
    % Window evaluation
    [windowPrecision, windowSensitivity, windowAccuracy,  windowF] = ...
        PerformanceEvaluationWindow(windowTP, windowFN, windowFP);
    [windowPrecision, windowSensitivity, windowAccuracy,  windowF, windowDCO]
    
    
    
    % Save to disk (pixel based evaluation
    e = {windowF, windowPrecision, windowAccuracy, windowSensitivity, ...
        pixel_method, window_method, ...
        decision_method, PARAM.Matching.corrThreshold...
        windowTP, windowFP, windowFN, windowDCO};
    
    load templateWindEvaluation;
    templateWindEvaluation = [templateWindEvaluation;e];
    
    file2save = [OPT.windowEvaluation '_window.mat']
    
    save(file2save,'templateWindEvaluation');

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pixelCandidates] = CandidateGenerationPixel_Color(im, space)
%Calls the corresponding color segmentation algorithm

im=double(im);
im = im/255;    %Normalize RGB image [0-1]

switch space
    
    case 'YCbCr'
        pixelCandidates = YCbCrSegmentation(im);
        
    case 'HSV-TH'
        pixelCandidates = HSVTHSegmentation(im);
        
    case 'HSV-REF'
        pixelCandidates = HSVREFSegmentation(im);
        
    case 'K-means'
        pixelCandidates = KMeansSegmentation(im);
        
    otherwise
        error('Incorrect color space defined');
        return
end
end


function [pixelCandidates] = morphologicalTransformation(im, method)
%Calls the corresponding morphological transformation

switch method
    
    case 'Opening'
        % Method 1. Opening
        SE = double(ones(5,5));
        pixelCandidates = myopening(im,SE);
        
    case 'Reconstruct'
        % Method 2. Reconstruct
        SE = ones(7,7);
        imDilate = myerode(im,SE);
        pixelCandidates = reconstruct(im, imDilate);
        
    case 'TopHat'
        % Method 3
        SE = ones(15, 15);
        imTopHat = mytophat(im, SE);
        SE2 = ones(7, 7);
        imOpen = myerode(imTopHat,SE2);
        pixelCandidates = reconstruct(im, imOpen);
        
    otherwise
        error('Incorrect morphological tranformation defined');
        return
end

%Fill holes
pixelCandidates = fillHoles(pixelCandidates);

end


function [windowCandidates, windowMask] = CandidateGenerationWindow(im, pixelCandidates, window_method, PARAM)

switch window_method
    case 'SegmentationCCL'
        [windowCandidates, windowMask] = ConnectedComponentLabeling(pixelCandidates, PARAM);
        
    case 'SlidingWindow'
        [windowCandidates, windowMask] = slidingWindow(pixelCandidates, PARAM);
end
end



function [windowCandidates, windowMask] = CandidateMatchingWindow(im, decision_method, windowCandidates, windowMask, PARAM)

switch decision_method
    case 'TemplateMatching'
        switch PARAM.Matching.matchingType
            case 'Correlation'
                [windowCandidates, windowMask] = matchModels(windowCandidates, windowMask, PARAM);
          
            case 'distanceTransformation'
                [windowCandidates, windowMask] = ChamferMatching(im, windowCandidates, windowMask, PARAM);

        end
    case 'GeometricHeuristics'
        % Week 5
        [windowCandidates, windowMask] = matchHT(im, windowCandidates, windowMask, PARAM);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performance Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PerformanceEvaluationROC(scores, labels, thresholdRange)
% PerformanceEvaluationROC
%  ROC Curve with precision and accuracy

roc = [];
for t=thresholdRange,
    TP=0;
    FP=0;
    for i=1:size(scores,1),
        if scores(i) > t    % scored positive
            if labels(i)==1 % labeled positive
                TP=TP+1;
            else            % labeled negative
                FP=FP+1;
            end
        else                % scored negative
            if labels(i)==1 % labeled positive
                FN = FN+1;
            else            % labeled negative
                TN = TN+1;
            end
        end
    end
    
    precision = TP / (TP+FP+FN+TN);
    accuracy = TP / (TP+FN+FP);
    
    roc = [roc ; precision accuracy];
end

plot(roc);
end