function [ClassId] = getClassId(MaskClassName)
%GETCLASSID Takes a mask class name and returns the corresponding id value.
    
    switch MaskClassName
        case 'building'
            ClassId = 1;
        case 'car'
            ClassId = 2;
        case 'keyboard'
            ClassId = 3;
        case 'mouse'
            ClassId = 4;
        case 'mug'
            ClassId = 5;
        case 'person'
            ClassId = 6;
        case 'screen'
            ClassId = 7;
        case 'tree'
            ClassId = 8;
        otherwise
            ClassId = -1;
            warning('Given class name is not valid!');
    end
    
end

