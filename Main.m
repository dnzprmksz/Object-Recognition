% Bind VL Feat Toolbox to obtain SIFT feature descriptors.
run('~/Documents/lib/vlfeat/toolbox/vl_setup');

% Clean start.
clear;

% Specifty project root for file imports and cluster count for k-means.
ProjectRoot = '~/Documents/MATLAB/Project/Object-Recognition/data/';
ClusterCount = 2000;
descriptors = [];

% Generate SIFT feature descriptor for each image and store in a matrix.
for imagePostfix = 1:188 % Number of images.
    imageFilename = strcat(ProjectRoot, int2str(imagePostfix), '.jpg');
    
    image = imread(imageFilename);
    image = single(rgb2gray(image));
    [~,d] = vl_sift(image);
    
    descriptors = cat(2, descriptors, d);
end

% Cast descriptors matrix into double, since uint8 overflows.
descriptors = double(transpose(descriptors));

% Cluster the descriptors matrix or load a pre-clustered one. Comment out
% one of lines below for that.
% [Clusters, ~] = kmeans(descriptors, ClusterCount);
load('Clusters2000.mat')
