function [CodevectorIndex] = vectorQuantizer(Codebook, FeatureVector)
%VECTORQUANTIZER takes a feature vector and maps it to the index of the
% nearest codevector in a codebook and returns the assigned codevector index.

    [~, CodevectorIndex] = pdist2(Codebook, FeatureVector, 'cosine', 'Smallest', 1);
end
