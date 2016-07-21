path_images = './DataSetDelivered/train/';
path_gt = './DataSetDelivered/train/mask';
path_segMor = './masks/mask HSV-REF.REconstruct';
path_maskSW = './masks/window_v1_SlidingWindow';
files = list_files(path_images, 'jpg');

usefulImages = ones(1, length(files));
for idx_file = 1:length(files)
   
    name = files{idx_file}(1:end-3)
%     I = imread([path_images name 'jpg']);
%     
    maskgt = imread([path_gt '/mask.' name 'png' ]);
    maskgt = maskgt ==1;
    if min(maskgt(:)) == max(maskgt(:))
        usefulImages(idx_file) = 0;
    end
%     maskSegMor = imread([path_segMor '/mask.HSV-REF.Reconstruct.' name 'jpg']);
%     maskSegMor = maskSegMor > 100;
%     
%     maskSW = imread([path_maskSW '/' name 'png']);
%     
%     subplot(2, 2, 1); imshow(I)
%     subplot(2, 2, 2); imshow(maskgt~=0)
%     subplot(2, 2, 3); imshow(maskSegMor);
%     subplot(2, 2, 4); imshow(maskSW);
%     pause(1)
end