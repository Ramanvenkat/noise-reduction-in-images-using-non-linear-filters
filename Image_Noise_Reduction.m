clc;    % Clear command window.
clear;  % Delete all variables.
close all;  % Close all figure windows except those created by imtool.
imtool close all;   % Close all figure windows created by imtool.
workspace;  % Make sure the workspace panel is showing.
fontSize = 15;
 
 
% Read the path of the image %%%%% Change the path of the image and the name as desired 
inputImage = imread('autumn.tif');
[rows, columns, numberOfColorBands] = size(inputImage);
h1 = figure;
figure(h1);
% Display the original image.
subplot(2, 2, 1);
imshow(inputImage);
title('Original Image', 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize'));
 
%noise image
noisyImage= imnoise(inputImage,'salt & pepper', 0.5);
noiseOnly = single(noisyImage) - single(inputImage);
 
% Calculate the signal to noise ratio
snrImage = abs(noiseOnly) ./ double(inputImage);
 
% Get the mean SNR
snrMean = mean2(snrImage);
subplot(2, 2, 2);
imshow(noisyImage);
title('Image with Salt and Pepper Noise', 'FontSize', fontSize);
xlabel(['The mean Signal-to-Noise Ratio is ',num2str(snrMean)],'FontSize', fontSize);
 
 
if numberOfColorBands == 3
    %
    % That's a RGB image
    %
    % Extract the individual red, green, and blue color channels from the noisy RGB image.
    
    redChannel = noisyImage(:, :, 1); % Red channel
    greenChannel = noisyImage(:, :, 2); % Green channel
    blueChannel = noisyImage(:, :, 3); % Blue channel
 
    % Normally, the above variables are gray scaled
    % so we define new images just to display the channels in their correct colors
    % calculate SNR of red, blue, green channels
    
    a = zeros(size(inputImage, 1), size(inputImage, 2));
    just_red = cat(3, redChannel, a, a);
    noiseOnly_r = single(just_red) - single(inputImage);
    snrImage_r = abs(noiseOnly_r) ./ double(inputImage);
    snrMean_r = mean2(snrImage_r);
 
    just_green = cat(3, a, greenChannel, a);
    noiseOnly_g = single(just_green) - single(inputImage);
    snrImage_g = abs(noiseOnly_g) ./ double(inputImage);
    snrMean_g = mean2(snrImage_g);
 
    just_blue = cat(3, a, a, blueChannel);
    noiseOnly_b = single(just_blue) - single(inputImage);
    snrImage_b = abs(noiseOnly_b) ./ double(inputImage);
    snrMean_b = mean2(snrImage_b);
 
 
    % Create another figure just for the 3 channels preview
    h2 = figure;
    figure(h2);
    set(gcf, 'Position', get(0,'Screensize'));
    % Display the individual red, green, and blue color channels (w/o noise).
    subplot(2, 2, 1);
    imshow(just_red);
    title('Red Channel', 'FontSize', fontSize);
    xlabel(['The mean Signal-to-Noise Ratio is ',num2str(snrMean_r)],'FontSize', fontSize);
    subplot(2, 2, 2);
    imshow(just_green);
    title('Green Channel', 'FontSize', fontSize);
    xlabel(['The mean Signal-to-Noise Ratio is  ',num2str(snrMean_g)],'FontSize', fontSize);
    subplot(2, 2, 3);
    imshow(just_blue);
    title('Blue Channel', 'FontSize', fontSize);
    xlabel(['The mean Signal-to-Noise Ratio is ',num2str(snrMean_b)],'FontSize', fontSize);
 
    % Median Filter the channels:
    redMF = medfilt2(redChannel, [10 10]);
    greenMF = medfilt2(greenChannel, [10 10]);
    blueMF = medfilt2(blueChannel, [10 10]);
 
    % Order-Statistics Filter the image (try and error with filter order)
    redOS = ordfilt2(redChannel,10,true(10));
    greenOS = ordfilt2(greenChannel,10,true(10));
    blueOS = ordfilt2(blueChannel,10,true(10));
 
    % Find the noise in the red.
    noisePixels = (redChannel == 0 | redChannel == 255);
    % Get rid of the noise in the red by replacing with median.
    noiseFreeRed1 = redChannel;
    noiseFreeRed1(noisePixels) = redMF(noisePixels);
    % Get rid of the noise in the red by replacing with Order-statistics
    noiseFreeRed2 = redChannel;
    noiseFreeRed2(noisePixels) = redOS(noisePixels);
 
    % Find the noise in the green.
    noisePixels = (greenChannel == 0 | greenChannel == 255);
    % Get rid of the noise in the green by replacing with median.
    noiseFreeGreen1 = greenChannel;
    noiseFreeGreen1(noisePixels) = greenMF(noisePixels);
    % Get rid of the noise in the green by replacing with Order-statistics
    noiseFreeGreen2 = greenChannel;
    noiseFreeGreen2(noisePixels) = greenOS(noisePixels);
 
    % Find the noise in the blue.
    noisePixels = (blueChannel == 0 | blueChannel == 255);
    % Get rid of the noise in the blue by replacing with median.
    noiseFreeBlue1 = blueChannel;
    noiseFreeBlue1(noisePixels) = blueMF(noisePixels);
    % Get rid of the noise in the blue by replacing with Order-statistics
    noiseFreeBlue2 = blueChannel;
    noiseFreeBlue2(noisePixels) = blueOS(noisePixels);
 
 
    % Reconstruct the noise free RGB image (Median)
    noiseFreeImage1 = cat(3, noiseFreeRed1, noiseFreeGreen1, noiseFreeBlue1);
    noiseOnly1 = single(noiseFreeImage1) - single(inputImage);
    snrImage1 =  abs(noiseOnly1)./ double(inputImage);
    snrMean1 = mean2(snrImage1);
 
 
    % Reconstruct the noise free RGB image (Order-statistics)
    noiseFreeImage2 = cat(3, noiseFreeRed2, noiseFreeGreen2, noiseFreeBlue2);
 
 
    noiseOnly2 = single(noiseFreeImage2) - single(inputImage);
    snrImage2 = abs(noiseOnly2) ./ double(inputImage);
    snrMean2 = mean2(snrImage2);
 
 
elseif numberOfColorBands == 1
    %
    % it's a grayscale image
    %
    % Median Filter the image:
    medianFilteredImage = medfilt2(noisyImage, [10 10]);
    % Order-Statistics Filter the image (try and error with filter order)
    osFilteredImage = ordfilt2(noisyImage,10,true(10));
 
    % Find the noise.  It will have a gray level of either 0 or 255.
    noisePixels = (noisyImage == 0 | noisyImage == 255);
 
    % Get rid of the noise by replacing with median.
    noiseFreeImage1 = noisyImage; % Initialize
    noiseFreeImage1(noisePixels) = medianFilteredImage(noisePixels); % Replace.
 
    % Get rid of the noise by replacing with order-statistics
    noiseFreeImage2 = noisyImage; %Initialize
    noiseFreeImage2(noisePixels) = osFilteredImage(noisePixels);
 
end
 
 
% Back to the first figure to display the restored image (Median Filter)
figure(h1);
% Display the image.
subplot(2, 2, 3);
imshow(noiseFreeImage1);
title('Restored Image using Median Filter', 'FontSize', fontSize);
xlabel(['The mean Signal-to-Noise Ratio is ',num2str(snrMean1)],'FontSize', fontSize);
 
% Back to the first figure to display the restored image (order-statistics Filter)
figure(h1);
% Display the image.
subplot(2, 2, 4);
imshow(noiseFreeImage2);
title('Restored Image using order-statistics Filter', 'FontSize', fontSize);
xlabel(['The mean Signal-to-Noise Ratio is ',num2str(snrMean2)],'FontSize', fontSize);
