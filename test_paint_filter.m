close all;
clear all;

img = imread('road.jpg');
I = rgb2gray(img(150:end, :, :));

I = imfilter(I, fspecial('Gaussian', [30,30], 0.5), 'replicate');

paint_filter = [0 -1 1 1 -1 0];

Ix = imfilter(I, paint_filter, 'replicate');
Iy = imfilter(I, paint_filter', 'replicate');

% figure(1);
% imagesc(Ix);
% figure(2);
% imagesc(Iy);
% figure(3);
% imagesc(Ix+Iy);

Isum = im2double(Ix + Iy);
imagesc(Isum);
Ig = Isum;

BW = edge(Ig,'canny', 0.2);
imshow(BW);
[H,theta,rho] = hough(BW);

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength',7);

figure, imshow(I), hold on
fprintf('Number of lines: %d\n', length(lines));
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plotline(lines(k).point1, lines(k).point2, 'r');
end
