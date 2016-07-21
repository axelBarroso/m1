%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% task1   Calculate the Histogram Average of a specific Type
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [yRed yGreen yBlue] = HistogramAverage(directory, type)

%directory = 'DataSetDelivered\train';
%type = 'A';

files = ListFiles(directory);

Redvalues = []; Greenvalues = []; Bluevalues = [];

for i=1:size(files)
       
    [annotations Signs] = LoadAnnotations(strrep(strcat(directory,'/gt/gt.',files(i).name), 'jpg','txt'));
    
    for lines=1:size(annotations,1)
        
        if((strncmpi(Signs{lines}(1),type,1) && isstrprop(Signs{lines}(1),'upper')))

            if(strncmpi(Signs{lines},'B21',3))
                continue;
            end
                
            Im = imread(strcat(directory,'/',files(i).name));    
            mask = imread(strrep(strcat(directory,'/mask/mask.',files(i).name), 'jpg','png'));
            Im(:,:,1) = Im(:,:,1).*mask;
            Im(:,:,2) = Im(:,:,2).*mask;
            Im(:,:,3) = Im(:,:,3).*mask;
            Im = imcrop(Im,[annotations(lines).x annotations(lines).y annotations(lines).w annotations(lines).h]); 
            %What we wanna do with these data ? One by one, average? 
            [Red Green Blue] = rgbhist(Im);
            
            Redvalues = [Redvalues; Red' ];
            Greenvalues = [Greenvalues; Green' ];
            Bluevalues = [Bluevalues; Blue' ];
            
        end
    
    end
    
end

%Plot the average in one plot of a specific figure type
x = 1:256;
yRed = mean(Redvalues,1);
yGreen = mean(Greenvalues,1);
yBlue = mean(Bluevalues,1);
figure
plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');
title(strcat('Histogram Traffic Signal type', type));






