%Empty evaluation datafile
clear all;
load('evaluation.mat');
evaluation = evaluation(1,:);
save('evaluation.mat','evaluation');

[S, dataFile] = read_annotations('DataSetDelivered/train/gt');
colorSpaces = {'HSV-REF'};
% colorSpaces = {'HSV-REF'};
blueVar = (-5:2:10); %for HSV-REF
redVar = (0:2:15);


for c=1:length(colorSpaces)
    directory       = 'DataSetDelivered/train/';
    pixel_method    =  colorSpaces(c);
    window_method   = 'none';
    decision_method = 'none';

    for j=1:length(blueVar)
        for i=1:length(redVar)       
            TrafficSignDetection(directory, pixel_method, window_method, decision_method, blueVar(j), redVar(i));
        end
    end

    %Saves data

    load evaluation    
    date = datestr(datetime('today'));
    fileName = strcat('evaluation-', pixel_method, '-', date(1:11))
    save(fileName{1},'evaluation');
    %Empty evaluation datafile
    evaluation = evaluation(1,:);
    save('evaluation.mat','evaluation');
end
