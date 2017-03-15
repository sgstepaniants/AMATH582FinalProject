% clear all; close all; clc

%% Read in Image Files
% number of samples (will be later partitioned into training and testing)
numSamples = 500;

X = [];
for month = [12 1 : 11]
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

%% Classify Data into Four Seasons
% Train and Test cell arrays contain 5 matrices for storing photos
% where each matrix is a shuffle of the training and testing sets
TrainShuffle = {[], [], [], [], []};
TestShuffle = {[], [], [], [], []};
% the group vector that will be passed into classify to tell it how to
% group its training set
group = [];

% loop through 5 second music clips in each class and turn their
% spectrograms into columns, put spectograms together column by column into
% train and test matrices that are contained in TrainShuffle and
% TestShuffle

% loop through photos in each one of the seasons
for season = 1 : 4
    season
    pause(3)
    perm = randperm(numSamples / 4) + numSamples / 4 * (season - 1);

    for m = 1 : 5
        for num = 1 : numSamples / 4
            num
            data = X(:, perm(num));

            % set aside 1/5 of the entire set for testing and 
            % do this in 5 different ways
            if numSamples / 4 * (season - 1) + numSamples / 4 * (m - 1) / 5 < perm(num) && perm(num) <= numSamples / 4 * (season - 1) + numSamples / 4 * m / 5
                % add 1/5 of the sample spectrograms to testing data
                TestShuffle{m} = [TestShuffle{m} data];
            else
                % add to group vector 4 times in loop of 5
                if m == 1
                    group = [group; season];
                end

                % add 4/5 of the sample spectrograms to training data
                TrainShuffle{m} = [TrainShuffle{m} data];
            end
        end
    end
end

%% Show Training Data

% loop through the 5 testing groups that were shuffled in TrainShuffle and 
% TestShuffleand project each spectrogram onto the modes from the SVD
% (get the coordinates for each test sample in this new coordinate system)

% apply LDA to find which class each testing point is closest to and
% record it as either a 1, 2, or 3 in the classification matrix

% the classification matrix contains 5 rows and each row contains the
% classifications for each testing group
classMatrix = [];
trainError = [];
testError = [];

% low rank approximation that we chose
rank = 200;

n = size(TestShuffle{1}, 2);
% the gold standard for what the testing data should actually be classified
% as: first third should belong to group 1, second third should belong to 
% group 2, last third should belong to group 3
goldStandard = [ones(n / 4, 1); 2 * ones(n / 4, 1); 3 * ones(n / 4, 1); 4 * ones(n / 4, 1)];

figure(1)
for shuffle = 1 : size(TestShuffle, 2)
    % get training and testing data pair matrices from the five pairs that
    % are stored in TrainShuffle and TestShuffle
    trainData = TrainShuffle{shuffle};
    testData = TestShuffle{shuffle};
    
    % perform SVD on the training set data for each of the training groups
    [U, S, V] = svd(trainData, 'econ');
    
    % plot scree plots to determine the best cutoff for low-rank
    % approximation of the U vector returned by SVD
    %subplot(3, 1, 1), plot(diag(S), 'ko', 'LineWidth', [2]);
    %subplot(3, 1, 2), plot(diag(S) / sum(diag(S)), 'ko', 'LineWidth', [2]);
    
    plot(100 * diag(S) / sum(diag(S)), 'ko', 'LineWidth', [0.5], 'markers', 5);
    set(gca, 'FontSize', [15])
    xlabel('Eigenvalue Number', 'Fontsize', [15])
    ylabel('Percent Energy', 'Fontsize', [15])
    title('Scree Plot for Choice 1 of Training Data', 'Fontsize', [20])
    
    % apply LDA onto low-rank projected training and testing data
    [class, err] = classify((U(:, 1 : rank)' * testData)', (U(:, 1 : rank)' * trainData)', group);
    classMatrix = [classMatrix class];
    
    % error returned from LDA of training data that it misclassified
    trainError = [trainError err];
    % cross validate classification results in class matrix with actual results
    % first third should belong to group 1, second third should belong to
    % group 2, last third should belong to group 3
    testError = [testError sum(class ~= goldStandard) / n];
end

%% Plot Results
% print out percentage of training and testing data that was correctly
% classified
trainMean = mean(100 * (1 - trainError))
testMean = mean(100 * (1 - testError))

% plot a bar chart of classification results for all 5 test cases
figure(2)
subplot(5, 1, 1), bar(classMatrix(:, 1))
set(gca, 'FontSize', [12])
xlabel('Number of 5 second sample', 'Fontsize', [12])
ylabel('Classes', 'Fontsize', [12])
title('Bar Chart of Sample Classification Results for Test 1')
subplot(5, 1, 2), bar(classMatrix(:, 2))
xlabel('Number of 5 second sample', 'Fontsize', [12])
ylabel('Classes', 'Fontsize', [12])
title('Bar Chart of Sample Classification Results for Test 2')
subplot(5, 1, 3), bar(classMatrix(:, 3))
xlabel('Number of 5 second sample', 'Fontsize', [12])
ylabel('Classes', 'Fontsize', [12])
title('Bar Chart of Sample Classification Results for Test 3')
subplot(5, 1, 4), bar(classMatrix(:, 4))
xlabel('Number of 5 second sample', 'Fontsize', [12])
ylabel('Classes', 'Fontsize', [12])
title('Bar Chart of Sample Classification Results for Test 4')
subplot(5, 1, 5), bar(classMatrix(:, 5))
xlabel('Number of 5 second sample', 'Fontsize', [12])
ylabel('Classes', 'Fontsize', [12])
title('Bar Chart of Sample Classification Results for Test 5')