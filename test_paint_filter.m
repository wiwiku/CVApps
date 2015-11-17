close all;
clear all;

img = imread('road.jpg');
I = rgb2gray(img(200:end, :, :));

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
% max_len = 0;
fprintf('Number of lines: %d\n', length(lines));
for k = 1:length(lines)
%     A = lines(k).point1;
%     B = lines(k).point2;
%     m = (B(2)-B(1))/(A(2)-A(1));
%     n = B(2)*m - A(2);
%     y1 = m*1000 + n;
%     y2 = m*-1000 + n;
%     line([1000, -1000], [y1, y2])
    
    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    plotline(lines(k).point1, lines(k).point2, 'r');

   % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
end

% highlight the longest line segment
% plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue');

