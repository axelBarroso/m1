
directory               = 'DataSetDelivered/train/';
% directory               = 'DataSetDelivered/test/';
pixel_method            = 'HSV-REF';  %YCbCr %HSV-TH %HSV-REF %Lab
morphological_method    = 'Reconstruct'; %Opening %TopHat %Reconstruct
window_method           = 'SlidingWindow' ; %'SlidingWindow';%SegmentationCCL %SlidingWindow
decision_method         = 'GeometricHeuristics'; %TemplateMatching  %GeometricHeuristics
[PARAM, OPT] = setUp();


TrafficSignDetection(directory, pixel_method, morphological_method, ...
                     window_method, decision_method, PARAM, OPT);



