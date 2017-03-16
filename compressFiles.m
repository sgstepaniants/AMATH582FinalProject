mkdir('FullMats');

for j = 1:12
    month = dir(num2str(j, '%02i'))';
    for file = month(3:end)
        images = imread(strcat(file.folder, '/', file.name));
        q = imresize(images, 0.25);
        save(strcat('FullMats/', file.name(1:end - 3), 'mat'), 'q');
    end
end