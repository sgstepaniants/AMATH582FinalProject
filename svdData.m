clear all; close all; clc

%% Read in Image Files
X = [];
for imageFile = dir('01/*.jpg')'
    imageFile.name
    image = im2double(imread(strcat('01/', imageFile.name)));
    
    % take red channel from image
    imageRed = image(:, :, 1);
    
    % resample image
    F = griddedInterpolant(imageRed);
    xq = (0:1.55:size(imageRed, 1))';
    yq = (0:1.55:size(imageRed, 2))';
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

%% SVD Data Matrix
% [U, S, V] = svd(X, 'econ');

% %% Show Results
% for j = 1 : size(U, 2)
%     j
%     imshow(imadjust(reshape(U(:, j), height, width)));
%     hold on
%     drawnow
% end

%% Scree Plot
plot(100 * diag(S(1 : 50)) / sum(diag(S)), '*')

% %% Original Video
% for j = 1 : size(X, 2)
%     imshow(imadjust(reshape(X(:, j), height, width)));
%     hold on
%     drawnow
% end

%% Run FastICA
addpath(genpath('FastICA_25'))
[icasig] = fastica(X)

%% Resample
image = reshape(X(:, j), 1200, 1200);
subplot(2, 1, 1), imshow(image)
title('Normal Resolution')
F = griddedInterpolant(image);
xq = (0:1.55:size(image, 1))';
yq = (0:1.55:size(image, 2))';
vq = F({xq,yq});
subplot(2, 1, 2), imshow(vq)
title('Lower Resolution')
