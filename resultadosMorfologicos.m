%%
clear all
directory       = 'DataSetDelivered/train/';
pixel_method    = 'HSV-REF';  %YCbCr %HSV-TH %HSV-REF %Lab
morphologicalMethod = {'Reconstruct','Opening','TopHat'}; %Opening %TopHat
window_method   = 'none';
decision_method = 'none';

% colorVar = 0.035; %Good for YCbCr
% colorVar = 0.028; %Good for HSV-TH
blueVar = 1; %for HSV-REF
redVar = 1;

%Empties evaluation datafile
load evaluation
evaluation = evaluation(1,:);
save evaluation

disp(['Images directory: ' directory]);
for k=1:length(morphologicalMethod)
    
    %for i=1:length(blueVar)
        %disp(['ColorVar ' num2str(colorVar)]);
    TrafficSignDetection(directory, pixel_method, morphologicalMethod(k), window_method, decision_method, blueVar, redVar);
    %end

end

%Saves data
load evaluation
date = datestr(datetime('today'));
fileName = strcat('evaluation-morphology-', date(1:11));
save(fileName,'evaluation');
disp(['File saved: ' fileName]);

% restore default values
evaluation = evaluation(1,:);
save('evaluation.mat','evaluation');
