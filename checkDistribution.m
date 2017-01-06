function [output_args] = checkDistribution(input_args, ProjectRoot)
%CHECKDISTRIBUTION Checks if the planned partition is balanced or not.

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

end

