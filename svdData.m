clear all; close all; clc

%% Read in Image Files
X = [];
for month = [1 : 12]
    month
    folder = dir(strcat(num2str(month, '%02i'), '/*.jpg'))';
    nummy = [42 42 41];
    sample = randsample(folder, nummy(mod(month, 3) + 1), false);
    
    for imageFile = sample
        image = im2double(imread(strcat(num2str(month, '%02i'), '/', imageFile.name)));

        % take red channel from image
        imageRed = image(:, :, 1);
        
        % resample image
        F = griddedInterpolant(imageRed);
        xq = (0:2:size(imageRed, 1))';
        yq = (0:2:size(imageRed, 2))';
        vq = F({xq,yq});

        height = size(vq, 1);
        width = size(vq, 2);

        reshaped = reshape(vq, numel(vq), 1);

        % put into data matrix
        X = [X reshaped];

        imshow(vq)
        hold on
        drawnow
    end
end

%% SVD Data Matrix
[U, S, V] = svd(X, 'econ');

%% Show Results
for j = 1 : size(U, 2)
    j
    imshow(imadjust(mat2gray((reshape(U(:, j), height, width)))));
    hold on
    drawnow
    pause(3)
end

%% Scree Plot
plot(diag(S) / sum(diag(S)), '*')

% %% Original Video
% for j = 1 : size(X, 2)
%     imshow(imadjust(reshape(X(:, j), height, width)));
%     hold on
%     drawnow
% end

%% Run FastICA
addpath(genpath('FastICA_25'))
[icasig] = fastica(X', 'numOfIC', 10);

%% Plot ICA Independent Components
for j = 1 : 10
    imshow(reshape(icasig(:, j), height, width))
    hold on
    drawnow
end
