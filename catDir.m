function [A, shape] = catDir(dirname)
    directory = dir(dirname)';
    directory = directory(3:end);
    frame = load(strcat(directory(1).folder, '/', directory(1).name));
    frame = rgb2gray(frame.q);
    shape = size(frame);
    A = double(reshape(frame, [], 1));
    
    for image = directory(2:end)
        frame = load(strcat(image.folder, '/', image.name));
        frame = rgb2gray(frame.q);
        A = [A, double(reshape(frame, [], 1))];
    end