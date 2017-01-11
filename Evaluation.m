clear;
load('AllProbabilityMaps.mat');

file = fopen('config.txt');
DataLocation = fgetl(file);
[~, ~, ~, test_masks] = partitionDataset(DataLocation);

ObjectCount = 8;
threshold = 0.6;

% Rows are objects and columns are Positives Correctly Detected, Total
% Positives, Negatives Incorrectly Detected, Total Negatives respectively
% Last two columns are TPR and FPR
ROC = zeros(ObjectCount,6);

for i = 1:size(test_masks, 2)
    current_mask = test_masks{1,i};
    num_of_objects = length(current_mask);
    for j = 1:num_of_objects
        className = current_mask(j).class_name;
        mask = current_mask(j).mask;
        classId = getClassId(className);
        probMask = AllProbabilityMaps{i,1}{1,classId};
        decisionMask = probMask > threshold;
        height = size(mask, 1);
        width = size(mask, 2);
        for m = 1:height
            for n = 1:width
                if mask(m,n) == 1 % positive pixel
                    ROC(classId,2) = ROC(classId,2) + 1;
                    if decisionMask(m,n) == 1 % true positive
                        ROC(classId,1) = ROC(classId,1) + 1;
                    end
                elseif mask(m,n) == 0 % negative pixel
                    ROC(classId,4) = ROC(classId,4) + 1;
                    if decisionMask(m,n) == 1 % incorrect negative
                        ROC(classId,3) = ROC(classId,3) + 1;
                    end
                end
            end
        end
    end
end

for i = 1:ObjectCount
    ROC(i,5) = ROC(i,1)/ROC(i,2); % true positive rate (TPR)
    ROC(i,6) = ROC(i,3)/ROC(i,4); % false positive rate (FPR)
end
