function plotROC(evaluation)
% Plot ROC Curve with precision and specificity given a evaluation file
% INPUT:
%    evaluation:    cell array [num_methods x 17] that contains the pixel 
%                   perfomance of each method tested

    roc = []; ranges = []; tp = []; fn = [];
    
    % for each method...
    for i = 2:length(evaluation(:,1))
        % Specificity
        ispecificity    = 1 - evaluation{i,4};
        % Sensitivity
        sensitivity     = evaluation{i,5};
        
        % Parameters that describe the method used 
        range           = evaluation{i,7};
        
        
        ranges          = [ranges ; range]; 
        roc = [roc ; ispecificity sensitivity];
        tp = [tp ;evaluation{i,13}];
        fn = [fn ;evaluation{i,15}];
        tp = [tp ;evaluation{i,13}];
        fn = [fn ;evaluation{i,15}];
    end
    
    % Plot ROC
    figure
    scatter(roc(:,1),roc(:,2));
    
    title(['ROC '  evaluation{2,10}]);
    axis([0 0.05 0 1]);

%     labels = num2str(ranges); 
    labels = ranges;
%   labels = cell2str(ranges);
%   labels =  {'Reconstruct','Opening','TopHat'};
    text(roc(:,1), roc(:,2), labels, 'horizontal','left', 'vertical','bottom');
    
    xlabel('1 - Specificity = 1 - (TN / (TN+FP)');
    ylabel('Sensitivity = TP / (TP+FN)');    
      
    
end