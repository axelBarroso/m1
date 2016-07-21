%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compute_histogram. Compute Histogram calculates the different histograms
% depending on his incoming parameters. 
%
% PARAM.directory     . Directory
% PARAM.space         . Color Space  (CbCr, HSV, Lab)
% PARAM.color         . Color's component selected (blue, red) 
% 
% After the execution, it returns the histogram, mean and
% standard desviation for red and blue signals.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [H, mM, stdSTD, centers] = compute_histogram(S, PARAM)

totalFirstComp   = []; totalSecondComp = []; totalThirdComp  = [];

totalMean   = [];
totalStd    = [];

pos_color = ismember(S.v_id_superclass, PARAM.color);

% Annotation files of the signals with specified color
annotFile_x_t   = S.fileName(pos_color);
% Annotations of the signals with specified color
annotations_x_t = S.annotation(pos_color);

FirstValues   = []; SecondValues = []; ThirdValues  = [];
    
for idx_signal = 1:length(annotFile_x_t)
    
histXsignal = [];
    % read original image
    annotFileName   = annotFile_x_t{idx_signal};
    Im              = imread(strrep(...
                      fullfile(PARAM.directory, annotFileName(4:end)), ...
                      'txt', 'jpg'));
    % Normalize image
    Im = double(Im);
    Im = Im/255;
    
    % read ground truth
    mask            = imread(strrep(...
                      fullfile(PARAM.directory, ...
                      'mask', ['mask.', annotFileName(4:end)]), ...
                      'txt', 'png'));
    mask = logical(mask);
    
    % Crop the image and ground truth
    ImCrop = imcrop(Im, [annotations_x_t{idx_signal}.x ...
                        annotations_x_t{idx_signal}.y ...
                        annotations_x_t{idx_signal}.w ...
                        annotations_x_t{idx_signal}.h]);
    MaskCrop = imcrop(mask, [annotations_x_t{idx_signal}.x ...
                            annotations_x_t{idx_signal}.y ...
                            annotations_x_t{idx_signal}.w ...
                            annotations_x_t{idx_signal}.h]);

    
    % convert 3D matrix to 3D vector keeping only the values of the signal
    % and discarding those values that belongs to the background
    v_ImCrop    = reshape(ImCrop, [1, size(ImCrop, 1)*size(ImCrop, 2), 3]);
    v_MaskCrop  = reshape(MaskCrop, [1, size(MaskCrop, 1)*size(MaskCrop, 2)]);
    
    tmp = [];
    for i=1:3
        component = v_ImCrop(:,:,i);
        component(v_MaskCrop==0) =[];
        tmp(:,:,i) = component;
    end
    v_ImCrop = tmp; % 3D matrix [1 size(ImCrop) 3]
    
    % Transform to the specified colorspace
    switch PARAM.space
        case 'RGB'
            v_transIm = v_ImCrop;
        case 'YCbCr'
            v_transIm = colorspace('YCbCr<-rgb', v_ImCrop);
            v_transIm(:,:,1) = (v_transIm(:,:,1) - 16) / (235 - 16);
            v_transIm(:,:,2) = (v_transIm(:,:,2) - 16) / (240 - 16);
            v_transIm(:,:,3) = (v_transIm(:,:,3) - 16) / (240 - 16);
        case 'HSV'
            v_transIm = colorspace('HSV<-rgb', v_ImCrop);
            v_transIm(:,:,1) = v_transIm(:,:,1)/360;
        case 'Lab'
            v_transIm = colorspace('Lab<-rgb', v_ImCrop);
            v_transIm(:,:,1) = v_transIm(:,:,1)/100;
            v_transIm(:,:,2) = (v_transIm(:,:,2) + 90) / 180;
            v_transIm(:,:,3) = (v_transIm(:,:,3) + 90) / 180;
    end
    
    for idx_col = 1:3
        [histXsignal(:,idx_col), binLoc] = imhist(v_transIm(:,:,idx_col));
    end
    FirstValues      = [FirstValues; histXsignal(:,1)'];
    SecondValues     = [SecondValues; histXsignal(:,2)'];
    ThirdValues      = [ThirdValues; histXsignal(:,3)'];
    
    totalMean   = [totalMean; reshape(mean(v_transIm, 2), [1 3])];
    totalStd    = [totalStd; reshape(std(v_transIm, 0, 2), [1 3])];
    
end


yFirstComp    = mean(FirstValues, 1);
ySecondComp  = mean(SecondValues, 1);
yThirdComp   = mean(ThirdValues, 1);
H = [yFirstComp; ySecondComp; yThirdComp];

mM = mean(totalMean, 1);
stdSTD = mean(totalStd, 1);
centers = binLoc;

end
