%GRANULOMETRY returns in B vector de pecstrum of an
% image A.
%
% B = GRANULOMETRY(A, type_SE, steps) performs a
% succesive morphological opening and closing of the
% grayscale image A with increasing sizes until steps
% size of the structuring element of SE_type
% (pe.: ‘disk’, ‘square’, ‘rectangle’, ...).
%
% SE_type are types allowed by STREL function.

directory = '..\DataSetDelivered\train\mask';
types_SE = {'square', 'triangle', 'line', 'cross'};
steps = 5;

files = ListFiles(directory);
x = (-steps:1:steps-1);

for k=1:size(types_SE,2)    
    tic;
    
    granulometryValues = [];
    SE = zeros(100,100);
    
    if strcmp(types_SE(1,k), 'square')
        %case 'square'
            SE(50 -2 : 50 + 2, 50 -2 : 50 + 2) = ...
                [0 0 0 0 0; ...
                 0 1 1 1 0; ...
                 0 1 1 1 0; ...
                 0 1 1 1 0; ...
                 0 0 0 0 0];
    elseif strcmp(types_SE(1,k), 'triangle')
        %case 'triangle'
            SE(50 -2 : 50 + 2, 50 -2 : 50 + 2) = ....
                [0 0 0 0 0; ...
                 0 0 1 0 0; ... 
                 0 1 1 1 0; ...
                 1 1 1 1 1; ...
                 0 0 0 0 0];
    elseif strcmp(types_SE(1,k), 'line')
        %case 'line'
            SE(50 -2 : 50 + 2, 50 -2 : 50 + 2) = ...
                [0 0 0 0 0; ...
                 0 0 0 0 0; ...
                 1 1 1 1 1; ... 
                 0 0 0 0 0; ...
                 0 0 0 0 0];
    elseif strcmp(types_SE(1,k), 'cross')
        %case 'cross'
            SE(50 -2 : 50 + 2, 50 -2 : 50 + 2) = ...
                [0 0 0 0 0; ...
                 0 0 1 0 0; ...
                 0 1 1 1 0; ...
                 0 0 1 0 0; ...
                 0 0 0 0 0];
    end

    SE_before_loop_ = SE;

    for j=1:steps
        SE_before_loop_ = mydilate_v2(SE_before_loop_, SE);
    end

    for i=1:2 %size(files,1)
        im = logical(imread(strcat(directory,'/',files(i).name)));
        SE_loop = SE_before_loop_;

        for counter = 1:steps
            i
            counter
            SE_loop = mydilate_v2(SE_loop, SE);
            remain = myopening_v2(im, SE_loop);
            %imshow(remain);
            pecstrumA(counter) = sum(remain(:));
            remain = myclosing_v2(im, SE_loop);
            pecstrumB(counter) = sum(remain(:));
        end
        pecstrum = cat(2,fliplr(pecstrumB), pecstrumA);
        granulometryValues = [granulometryValues ; pecstrum];
    end


    figure
    meanGranulometry = mean(granulometryValues, 1);
    subplot(1 ,2 , 1)
    plot(x,meanGranulometry);
    title(['Mean Granulometry with a ' types_SE(1,k) ' SE  Image']);

    y = -size(x,2)/2+1:size(x,2)/2-1;
    subplot(1 ,2 , 2)
    plot(y,abs(diff(meanGranulometry)));
    title(['Mean Diff Granulometry with a ' types_SE(1,k) ' SE  Image']);

    time = toc;
    filename = strcat(strcat(strcat(strcat('gran_',num2str(i)),'_'),types_SE(1,k)),'.mat');

    save( char(filename) );
end




