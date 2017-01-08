% Add SVM library
addpath(genpath('lib/libsvm/'));

load('ObjectHistograms.mat');

total_rows = 0;
for i=1:size(ObjectHistograms)
    current_cell = ObjectHistograms{i,1};
    total_rows = total_rows + size(current_cell,1);
end

% Create the instance matrix and object labels
instance_matrix = zeros(total_rows,500);
object_labels = cell(8,1);

for i=1:size(object_labels)
    object_labels{i,1} = zeros(total_rows,1);
    object_labels{i,1}(:,1) = -1;
end

rowcount = 1;

for i=1:size(ObjectHistograms)
    current_cell = ObjectHistograms{i,1};
    histogram_size = size(current_cell,1);
    for j=1:histogram_size
        instance_matrix(rowcount,:) = current_cell(j,:);
        object_labels{i}(rowcount,1) = 1;
        rowcount = rowcount + 1;
    end
end

SVM_models = cell(8,1);

for i=1:8
    SVM_models{i,1} = svmtrain(object_labels{i,1}, instance_matrix,  '-t 0 -b 1');
end

save('SVM_models','SVM_models');