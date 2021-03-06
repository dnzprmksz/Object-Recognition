% Add libraries.
addpath(genpath('lib/ncut/'));
addpath(genpath('lib/libsvm/'));

clear;
load('Codebook.mat');
load('SVM_models.mat');

ObjectCount = 8;
CodebookSize = size(Codebook, 1);
SegmentCountIndoor = 8;
SegmentCountOutdoor = 4;
GridSize = 32;

% Get file locations for VL Feat Toolbox and data.
file = fopen('config.txt');
DataLocation = fgetl(file);
vlToolboxLocation = fgetl(file);
run(vlToolboxLocation);

% Partition the dataset into two subsets as Training and Test.
[~, ~, test_images, test_masks] = partitionDataset(DataLocation);

AllProbabilityMaps = cell(size(test_images,2),1);
% Segment each image to detect objects. Compute their Bag of Words
% representation and use SVM classifier to recognize the objects.
for imageIndex = 1:size(test_images,2)
    
    imageType = test_images{2, imageIndex};
    image = test_images{1, imageIndex};
    grayscale = single(rgb2gray(image));
    height = size(image, 1);
    width = size(image, 2);
    
    % Select segment count by looking image is whether indoor or outdoor.
    % 0: Outdoor, 1: Indoor.
    if imageType == 0
        SegmentCount = SegmentCountOutdoor;
    else
        SegmentCount = SegmentCountIndoor;
    end
    
    % Compute image segments with normalized cuts.
    ncutImage = double(rgb2gray(image));
    [SegmentLabels, ~, ~, ~, ~, ~] = NcutImage(ncutImage, SegmentCount);

    % Show the segmented image. Adapted from library's demo.
    bw = edge(SegmentLabels, 0.01);
    J1 = showmask(ncutImage, imdilate(bw, ones(2,2)));
    % imagesc(J1); axis off
    filename = strcat('samples/segmentations/test-', int2str(imageIndex), '.png');
    imwrite(J1, filename);
    
    SegmentsBagOfWords = zeros(SegmentCount, CodebookSize);
    
    % Form regular grid to find interest points. Then build the Bag of
    % Words representation of each segment.
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
            grid = [x; y; GridSize; 0];
            
            % Get the descriptor of feature and corresponding codeword.
            [~, descriptor] = vl_sift(grayscale, 'frames', grid);
            codevectorIndex = vectorQuantizer(Codebook, double(transpose(descriptor)));
            segmentIndex = SegmentLabels(uint8(y), uint8(x));
            SegmentsBagOfWords(segmentIndex, codevectorIndex) = SegmentsBagOfWords(segmentIndex, codevectorIndex) + 1;
        end
    end
    
    % Use SVM classifier to compute the probability of each segment to
    % contain an instance of any object.
    
    probability = zeros(SegmentCount, ObjectCount);
    % Calculate the probability for each segment to include each object.
    for i = 1:SegmentCount
        for j = 1:ObjectCount
            [~, ~ , prob] = svmpredict(1, SegmentsBagOfWords(i, :), SVM_models{j}, '-b 1');
            probability(i, j) = prob(1, 1);
        end
    end
    
    ProbabilityMaps = cell(1, ObjectCount);
    % Construct the probability map of current image for each object.
    for i = 1:ObjectCount
        current_map = zeros(height, width);
        for j = 1:height
            for k = 1:width
                current_map(j, k) = probability(SegmentLabels(j, k), i);
            end
        end
        ProbabilityMaps{i} = current_map;
    end
    
    % Append current image's probability maps to the global list.
    AllProbabilityMaps{imageIndex, 1} = ProbabilityMaps;
end

save('AllProbabilityMaps', 'AllProbabilityMaps');
