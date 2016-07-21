function PARAM = setUp()

% --> Parameters for pixel evaluation
    
    PARAM.ColorSpace.colorBlueVar 	= 9; %9 for HSV-REF % 0.035 for YCbCr % 0.028 for HSV-TH
    PARAM.ColorSpace.colorRedVar    = 0; %0 for HSV-REF % 0.035 for YCbCr % 0.028 for HSV-TH
    PARAM.Morphological.saveMask    = 0;  
% <--


% --> Parameters for window evaluation
    % Parameters obtained from B1 Task1
    
    % Specific parameters for CCL
    PARAM.CC.minAR = 0.6; %0.70;
    PARAM.CC.maxAR = 1.4; %1.3;
    PARAM.CC.minFR = 0.5; %0.4;
    PARAM.CC.maxFR = 0.8; %1;
    
    % Specific parameter for SW
    PARAM.SW.fEnergy     = @(x) (  x(1, 1) + x(end, end) ...
                                - x(1, end) - x(end, 1)) ...
                                / ((size(x, 1) - 1)*(size(x, 2)-1)); 

    PARAM.SW.windowsAR  = [   1     1      1     1      1     1      1      1];
    PARAM.SW.windowsW   = [  40    50     90   120    150   200    250    300];
    PARAM.SW.steps      = [   2     4      8     8      8     8     10     10];
    PARAM.SW.minFR      = [ 0.5   0.4   0.40   0.4   0.40   0.5   0.50   0.60];
    PARAM.SW.maxFR      = [ 0.7   0.7   0.75   0.8   0.85   0.9   0.99   0.99]; 
% <--

% --> Matching
PARAM.Matching.matchingType = 'distanceTransformation'; %Correlation %distanceTransformation
PARAM.Matching.corrThreshold = 0.5
PARAM.Matching.ChamferDThreshold = 0.5
% <--

end

