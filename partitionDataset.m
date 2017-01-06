function [train_images, train_masks, test_images, test_masks] = partitionDataset(DataLocation)
%PARTITIONDATASET partitions the dataset into two equal subsets as test and training.

    % Allocate for the training set
    train_images = cell(1,94);
    train_masks = cell(1,94);

    % Allocate for the testing set
    test_images = cell(1,94);
    test_masks = cell(1,94);

    % For partition, distribute one image and its mask to the training set
    % and the following image and its masks to the testing set.
    for i = 1:188
        load(strcat(DataLocation,int2str(i),'.mat'));
        current_image = imread(strcat(DataLocation, int2str(i), '.jpg'));
        if mod(i,2) == 1
            train_images{floor(i/2)+1} = current_image;
            train_masks{floor(i/2)+1} = masks;
        elseif mod(i,2) == 0
            test_images{(i/2)} = current_image;
            test_masks{(i/2)} = masks;
        end
    end      

end

