% Bind VL Feat Toolbox to obtain SIFT feature descriptors.
run('c:/Users/Berkcan/Desktop/vlfeat-0.9.20/toolbox/vl_setup');

% Clean start.
clear;

% Specifty project root for file imports and cluster count for k-means.
ProjectRoot = 'c:/Users/Berkcan/Desktop/Object-Recognition/data/';
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

% Check if the planned partition is balanced or not
%{
screen = 0;
keyboard = 0;
mouse = 0;
mug = 0;
car = 0;
tree = 0;
person = 0;
building = 0;

for i=1:188
    if mod(i,2) == 0
        load(strcat(ProjectRoot,int2str(i),'.mat'));
        l = length(masks);
        for j=1:l
            name = masks(j).class_name;
            if strcmp(name,'screen') == 1
                screen = screen + 1;
            elseif strcmp(name,'keyboard') == 1
                keyboard = keyboard + 1;
            elseif strcmp(name,'mouse') == 1
                mouse = mouse + 1;
            elseif strcmp(name,'mug') == 1
                mug = mug + 1;
            elseif strcmp(name,'car') == 1
                car = car + 1;
            elseif strcmp(name,'tree') == 1
                tree = tree + 1;
            elseif strcmp(name,'person') == 1
                person = person + 1;
            elseif strcmp(name,'building') == 1
                building = building + 1;
            end
        end
    end
end
%}

% Allocate for the training set
train_images = cell(1,94);
train_masks = cell(1,94);

% Allocate for the testing set
test_images = cell(1,94);
test_masks = cell(1,94);

% For partition, distribute one image and its mask to the training set
% and the following image and its masks to the testing set
for i=1:188
    load(strcat(ProjectRoot,int2str(i),'.mat'));
    current_image = imread(strcat(ProjectRoot, int2str(i), '.jpg'));
    if mod(i,2) == 1
        train_images{floor(i/2)+1} = current_image;
        train_masks{floor(i/2)+1} = masks;
    elseif mod(i,2) == 0
        test_images{(i/2)} = current_image;
        test_masks{(i/2)} = masks;
    end
end        