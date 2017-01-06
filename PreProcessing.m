% Clean start.
clear;

% Get file locations for VL Feat Toolbox and data.
file = fopen('config.txt');
DataLocation = fgetl(file);
vlToolboxLocation = fgetl(file);

% Bind VL Feat Toolbox to obtain SIFT feature descriptors.
run(vlToolboxLocation);

% Specifty cluster count for k-means and grid size.
ClusterCount = 500;
GridSize = 32; % Form 32x32 grids for feature detection.

% Construct clusters and codebook. Save the outputs.
[Clusters, Codebook] = generateCodebook(DataLocation, ClusterCount, GridSize);
save('Clusters', 'Clusters');
save('Codebook', 'Codebook');
