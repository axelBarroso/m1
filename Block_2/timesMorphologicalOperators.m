function [Ef_D1, Ef_D2, Ef_E1, Ef_E2] = timesMorphologicalOperators(directory, ext)
files   = list_files(directory, ext);
num_files = length(files);

% define a structuring element
SE = [  1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1];

num_files = 100;

time_Dl_v1 = zeros(1,num_files);
time_Dl_v2 = zeros(1,num_files);
time_Dl_m  = zeros(1,num_files);

time_Er_v1 = zeros(1,num_files);
time_Er_v2 = zeros(1,num_files);
time_Er_m  = zeros(1,num_files);

for i=1:num_files
    i
    % read an image
    A = imread( char(files(i)) );    
    A(A<=30)  = 0;
    A(A>=220) = 255;
    
    % apply a morphological filter (dilation)
    % _v2 are expected to be faster
    tic;
    Dl = mydilate(A, SE);
    time_Dl_v1(i) = toc;
    
    tic;
    Dl_v2 = mydilate_v2(A, SE);
    time_Dl_v2(i) = toc;

    tic;
    Dl_m = imdilate(A,SE);
    time_Dl_m(i) = toc;

    % apply a morphological filter (erosion)
    tic;
    Er = myerode(A,SE);
    time_Er_v1(i) = toc;
    
    tic;
    Er_v2 = myerode_v2(A,SE);
    time_Er_v2(i) = toc;
    
    tic;
    Er_m = imerode(A,SE);
    time_Er_m(i) = toc;
    
    
    % compute the differences
    Diff_dl_v1 = logical(Dl) - logical(Dl_m);
    Diff_dl_v2 = logical(Dl_v2) - logical(Dl_m);
    Diff_Er_v1 = logical(Er) - logical(Er_m);
    Diff_Er_v2 = logical(Er_v2) - logical(Er_m);
    
    sum_diff_Dl_v1 = sum(Diff_dl_v1(:));
    sum_diff_Dl_v2 = sum(Diff_dl_v2(:));
    sum_diff_Er_v1 = sum(Diff_Er_v1(:));
    sum_diff_Er_v2 = sum(Diff_Er_v2(:));
    
    if any(sum_diff_Dl_v1)
       strcat('[ERROR] mydilate does not work on the image: ',num2str(i))
    end
    if any(sum_diff_Dl_v2)
        strcat('[ERROR] mydilate_v2 does not work on the image: ',num2str(i))
    end
    if any(sum_diff_Er_v1)
       strcat('[ERROR] myerode does not work on the image: ',num2str(i))
    end
    if any(sum_diff_Er_v2)
        strcat('[ERROR] myerode_v2 does not work on the image: ',num2str(i))
    end
    
%     % plot
%     figure; 
%     subplot(5,3,1); 
%     imshow(A);              % image readed
%     title('Original image');
%     
% %figure;
%     subplot(5,3,2); 
%     imshow(Dl_m);           % matlab dilatation
%     title('Matlab dilation')
%     
% %figure;
%     subplot(5,3,3); 
%     imshow(Er_m)            % matlab erosion
%     title('Matlab erosion');
% 
% %figure;
%     subplot(5,3,4); 
%     imshow(Dl);             % first version of dilatation
%     title('DilationV1');
%     subplot(5,3,5); 
%     imshow(Diff_dl_v1);     % difference map
%     
% %figure;
%     subplot(5,3,7); 
%     imshow(Dl_v2);          % optimized version for dilatation
%     title('DilationV2');
%     subplot(5,3,8); 
%     imshow(Diff_dl_v2);     % difference map 
%     
% %figure;
%     subplot(5,3,10); 
%     imshow(Er);            % first version of erosion
%     title('ErosionV1');
%     subplot(5,3,11); 
%     imshow(Diff_Er_v1);    % difference map    
%     
% %figure;
%     subplot(5,3,13); 
%     imshow(Er_v2);         % optimied version for erosion
%     title('ErosionV2');
%     subplot(5,3,14); 
%     imshow(Diff_Er_v2);    % difference map
    
end

x = 1:num_files;

figure;
subplot(2,1,1);
plot(x, time_Dl_v1, 'Red', x, time_Dl_v2, 'Green', x, time_Dl_m, 'Blue');
legend('mydilateV1', 'mydilateV2', 'imdilate');

subplot(2,1,2);
plot(x, time_Er_v1, 'Red', x, time_Er_v2, 'Green', x, time_Er_m, 'Blue');
legend('myerodeV1', 'myerodeV2', 'imerode');

% Efficiency
Ef_D1 = 100*mean(time_Dl_m)/mean(time_Dl_v1);
Ef_E1 = 100*mean(time_Er_m)/mean(time_Er_v1);
Ef_D2 = 100*mean(time_Dl_v2)/mean(time_Dl_m);
Ef_E2 = 100*mean(time_Er_v2)/mean(time_Er_m);