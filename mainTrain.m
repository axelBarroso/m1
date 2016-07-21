%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MainTrain. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Read the annotations from the txt files in the directory selected
%

[S, dataFile] = read_annotations('DataSetDelivered/train/gt');

%%
%
% Get histogram, mean and standard desviation for red and blue signalss
% 

PARAM.directory     = '/DataSetDelivered/train';
PARAM.space         = 'HSV';
red = [1 2 3 5]; blue = [4 6];
PARAM.color = red; %blue
[H, mM, stdSTD, centers] = compute_histogram(S, PARAM)

% HSV get max of Hue component
[~ , pos] = max(H(1, :))
centers(pos)

%%
%
% That section is responsible  to execute trafficSignDetection with several
% configurations. For instance, this code will run HSV-REF as a
% pixel_method using many variances. That allows us determinate with
% approach is optimal. 
%

directory       = 'DataSetDelivered/train/';
pixel_method    = 'HSV-REF';  %YCbCr %HSV-TH %HSV-REF %Lab
morphological_method = 'Reconstruct'; %Opening %TopHat
window_method   = 'none';
decision_method = 'none';

blueVar = 9; %9 for HSV-REF % 0.035 for YCbCr % 0.028 for HSV-TH
redVar = 0;  %0 for HSV-REF % 0.035 for YCbCr % 0.028 for HSV-TH

%Empties evaluation datafile
% load evaluation
% evaluation = evaluation(1,:);
% save evaluation

      
TrafficSignDetection(directory, pixel_method, morphological_method, window_method, decision_method, blueVar, redVar);


%Saves data
load evaluation
date = datestr(datetime('today'));
fileName = strcat('evaluation-', pixel_method, '-', morphological_method, '-', date(1:11));
save(fileName,'evaluation');
disp(['File saved: ' fileName]);

%% Plot P-R

plotROC(evaluation);

