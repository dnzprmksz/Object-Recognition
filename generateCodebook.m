function [Clusters, Codebook] = generateCodebook(DataLocation, ClusterCount, GridSize)
%GENERATECODEBOOK Generates local features for images in 'DataLocation' and
%clusters all features into 'ClusterCount' different clusters.
    
    gridId = 1;
    descriptors = [];
    DescriptorStartIndices = zeros(188, 1);
    %Generate SIFT feature descriptor for each image and store in a matrix.
    for imagePostfix = 1:188 % Number of images.
        DescriptorStartIndices(imagePostfix) = gridId; % Store grids starting index.
        imageFilename = strcat(DataLocation, int2str(imagePostfix), '.jpg');
        
        image = imread(imageFilename);
        image = single(rgb2gray(image));
        
        height = size(image, 1);
        width = size(image, 2);
        
        % Form regular grid to find interest points.
        for i = 1:width/GridSize
           for j = 1:height/GridSize
               % Calculate grid's bounding box.
               x_start = (i-1)*GridSize + 1;
               y_start = (j-1)*GridSize + 1;
               x_end = i*GridSize;
               y_end = j*GridSize;
               
               % Extract grid/feature image and save.
               gridImage = uint8(image(y_start:y_end, x_start:x_end));
               filename = strcat('samples/grids/', int2str(gridId), '.png');
               imwrite(gridImage, filename);
               gridId = gridId + 1;
               
               % Calculate grid's coordinates.
               x = (x_start + x_end) / 2;
               y = (y_start + y_end) / 2;
               grid = [y; x; GridSize; 0];
               
               % Calculate its descriptor and concatenate to the matrix.
               [~,d] = vl_sift(image, 'frames', grid);
               descriptors = cat(2, descriptors, d);
           end
        end
    end

    % Cast descriptors matrix into double, since uint8 overflows.
    descriptors = double(transpose(descriptors));
    
    % Save descriptors for future usage.
    save('Descriptors', 'descriptors');
    save('DescriptorStartIndices', 'DescriptorStartIndices');
    
    % Cluster the descriptors matrix.
    [Clusters, Codebook] = kmeans(descriptors, ClusterCount);
end
