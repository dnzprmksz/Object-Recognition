clear;
load('Codebook.mat');
load('Descriptors.mat');

% Find the closest descriptor for the codewords.
[~, DescriptorIndices] = pdist2(descriptors, Codebook, 'cosine', 'Smallest', 1);

% Read corresponding images for codewords and save them.
for index = 1:size(DescriptorIndices, 2)
    gridId = DescriptorIndices(index);
    
    filename = strcat('samples/grids/', int2str(gridId), '.png');
    image = imread(filename);
    
    filename = strcat('samples/codebook/', int2str(index), '.png');
    imwrite(image, filename)
end
