% RealTimeHandGestureRecognition.m
% Recognize hand gestures in real time.
%   Author: Yuxuan Chen
%     Date: March 4, 2016

close all
clear all

video = videoinput('macvideo'); 
video.ReturnedColorspace = 'rgb';
figure(1)
start(video);
videoResolution = get(video, 'VideoResolution');
imgWidth  = videoResolution(1);
imgHeight = videoResolution(2);
numBands  = get(video, 'NumberOfBands');
gui = image(zeros(imgHeight, imgWidth, numBands));
preview(video, gui);

while(1)
  %% Segmentation
  Irgb = getsnapshot(video);
  Ihsv = rgb2hsv(Irgb);
  Iycbcr = rgb2ycbcr(Irgb); % Try out something different than RGB and HSV

  R  =   Irgb(:, :, 1);
  G  =   Irgb(:, :, 2);
  B  =   Irgb(:, :, 3);
  H  =   Ihsv(:, :, 1);
  V  =   Ihsv(:, :, 3);
  Cb = Iycbcr(:, :, 2);
  Cr = Iycbcr(:, :, 3);
  cond = R >= 50 & R <= 230 & ...
         G <= 200 & ...
         B <= 230 & ...
         (H <= 0.25 | H >= 0.75) & ...
         V >= 0.25 & V <= 0.9 & ...
         Cb >= 80 & Cb <= 145 & ...
         Cr >= 125 & Cr <= 160;
  cond = bwareaopen(cond, 1000, 8);

  % The location of the hand on the captured RGB image
  fig2 = figure(2);
  clf
  hold on
  set(gca, 'YDir', 'reverse')
  imagesc(Irgb)
  [x,y] = find(cond == 1);
  xmin = min(x) - 30;
  xmax = max(x) + 30;
  ymin = min(y) - 30;
  ymax = max(y) + 30;
  set(plot([ymin ymax ymax ymin ymin], [xmin xmin xmax xmax xmin], ...
      'yellow'), 'LineWidth',1)
  set(text(ymin, xmin - 20, 'Hand'), 'Color', 'yellow')
  hold off
  
  % Segmented image of the hand
  roi = cond(min(x): max(x), min(y): max(y), :);
  fig3 = figure(3);
  imshow(roi)
  
  iptwindowalign(fig2, 'bottom', fig3, 'top');
  
  %% Geometric Features
  
  % Area and perimeter
  roiArea = regionprops(roi, 'Area');
  roiPerim = regionprops(roi, 'Perimeter');
  
  % Height and width
  roiSize   = size(roi);
  roiHeight = roiSize(1);
  roiWidth  = roiSize(2);
  
  % Mass center
  roiCenter = regionprops(roi, 'Centroid');
  
  % Compactness
  %roiComp = roiPerim ^ 2 / roiArea;
  
  % Normalized compactness
  %roiNormComp = 1 - 4 * pi * roiArea / roiPerim ^ 2;
  
  % Major and minor axes lengths
  roiMajAxis = regionprops(roi, 'MajorAxisLength');
  roiMinAxis = regionprops(roi, 'MinorAxisLength');
  
  % Orientation
  roiOrient = regionprops(roi, 'Orientation');
  
  % Eccentricity
  roiEccent = regionprops(roi, 'Eccentricity');
end

stop(video);