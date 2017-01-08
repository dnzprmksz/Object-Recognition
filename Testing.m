% Add segmentation/ncut library.
addpath(genpath('lib/ncut/'));

clear;
load('Codebook.mat');
load('SVM_models.mat');

ObjectCount = 8;
CodebookSize = size(Codebook, 1);
SegmentCount = 6;
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
    
    image = test_images{1, imageIndex};
    grayscale = single(rgb2gray(image));
    height = size(image, 1);
    width = size(image, 2);
    
    % Compute image segments with normalized cuts.
    ncutImage = double(rgb2gray(image));
    [SegmentLabels, ~, ~, ~, ~, ~] = NcutImage(ncutImage, SegmentCount);

    % Show the segmented image. Adapted from library's demo.
    bw = edge(SegmentLabels, 0.01);
    J1 = showmask(ncutImage, imdilate(bw, ones(2,2))); imagesc(J1); axis off
    
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
            grid = [y; x; GridSize; 0];
            
            % Get the descriptor of feature and corresponding codeword.
            [~, descriptor] = vl_sift(grayscale, 'frames', grid);
            codevectorIndex = vectorQuantizer(Codebook, double(transpose(descriptor)));
            segmentIndex = SegmentLabels(uint8(y), uint8(x));
            SegmentsBagOfWords(segmentIndex, codevectorIndex) = SegmentsBagOfWords(segmentIndex, codevectorIndex) + 1;
        end
    end
    
    % Use SVM classifier to compute the probability of each segment to
    % contain an instance of any object.
    
    % Calculate the probability for each segment to include an object
    probability = zeros(SegmentCount, ObjectCount);
    
    for i=1:SegmentCount
        for j=1:ObjectCount
            [~, ~ , prob] = svmpredict([1], SegmentsBagOfWords(i,:), SVM_models{j}, '-b 1');
            probability(i,j) = prob(1,1);
        end
    end
    
    ProbabilityMaps = cell(1,ObjectCount);
    
    for i=1:ObjectCount
        current_map = zeros(height,width);
        for j=1:height
            for k=1:width
                current_map(j,k) = probability(SegmentLabels(j,k),i);
            end
        end
        ProbabilityMaps{i} = current_map;
    end
    AllProbabilityMaps{imageIndex,1} = ProbabilityMaps;
    save('AllProbabilityMaps','AllProbabilityMaps');
end
