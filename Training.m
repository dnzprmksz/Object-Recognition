% Clean start.
clear;

load('Codebook.mat');

ObjectCount = 8;
CodebookSize = size(Codebook, 1);
GridSize = 32;
ObjectHistograms = cell(ObjectCount, 1);

% Get file locations for VL Feat Toolbox and data.
file = fopen('config.txt');
DataLocation = fgetl(file);
vlToolboxLocation = fgetl(file);

% Bind VL Feat Toolbox to obtain SIFT feature descriptors.
run(vlToolboxLocation);

% Partition the dataset into two subsets as Training and Test.
[train_images, train_masks, ~, ~] = partitionDataset(DataLocation);

% Create the Bag of Words representation of each object.
for imageIndex = 1:size(train_images, 2)
    imageMasks = train_masks{1, imageIndex};
    
    image = single(rgb2gray(train_images{1, imageIndex}));
    height = size(image, 1);
    width = size(image, 2);
    
    % Traverse the grid for each mask/object and build its histogram.
    for maskIndex = 1:size(imageMasks, 1)
        className = imageMasks(maskIndex).class_name;
        mask = imageMasks(maskIndex).mask;
        classId = getClassId(className);
        
        % Initialize histogram for object/mask and store its index in cell.
        maskHistogram = zeros(1, CodebookSize);
        ObjectHistograms{classId} = cat(1, ObjectHistograms{classId}, maskHistogram);
        maskHistogramIndex = size(ObjectHistograms{classId}, 1);
        
        % Form regular grid to find interest points.
        for i = 1:width/GridSize
            for j = 1:height/GridSize
                x_start = (i-1)*GridSize + 1;
                y_start = (j-1)*GridSize + 1;
                x_end = i*GridSize;
                y_end = j*GridSize;
                % Extract grid/feature and calculate its descriptor.
                % gridImage = uint8(image(y_start:y_end, x_start:x_end));
                x = (x_start + x_end) / 2;
                y = (y_start + y_end) / 2;
                grid = [y; x; GridSize; 0];
                
                gridSum = sum(sum(mask(y_start:y_end, x_start:x_end)));
                if gridSum > 0 % Mask touches to the grid, find and increment class id in histogram.
                    [~, descriptor] = vl_sift(image, 'frames', grid);
                    codevectorIndex = vectorQuantizer(Codebook, double(transpose(descriptor)));
                    ObjectHistograms{classId}(maskHistogramIndex, codevectorIndex) = ...
                        ObjectHistograms{classId}(maskHistogramIndex, codevectorIndex) + 1;
                end
            end
        end
    end
end

save('ObjectHistograms', 'ObjectHistograms');

% Train SVM classifier for each object and save the models.

