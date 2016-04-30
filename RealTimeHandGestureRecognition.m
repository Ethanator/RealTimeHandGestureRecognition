% RealTimeHandGestureRecognition.m
% Recognize hand gestures in real time.
%   Author: Yuxuan Chen
%     Date: March 4, 2016

%% Main program
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

% Train
% gesture = 7
% ouf = fopen(strcat(int2str(gesture), '.txt'), 'wt');

% Gesture Codes
gestures = containers.Map;
gestures('1') = 'Rock';
gestures('2') = 'Scissors';
gestures('3') = 'OK';
gestures('4') = 'Metalhead';
gestures('5') = 'Paper';
gestures('6') = 'Phone';
gestures('7') = 'Pistol';

% Classify
load('baggedTreesClassifier.mat')

while(1)
  %% Segmentation
  tic
  Irgb = getsnapshot(video);
  toc
  
  tic
  Ihsv = rgb2hsv(Irgb);
  
  R  =   Irgb(:, :, 1);
  G  =   Irgb(:, :, 2);
  B  =   Irgb(:, :, 3);
  H  =   Ihsv(:, :, 1);
  S  =   Ihsv(:, :, 2);
  V  =   Ihsv(:, :, 3);
  % cond = R >= 100 & R <= 160 & ...
         % G >= 100 & G <= 150 & ...
         % B >= 100 & B <= 150;
  cond = (H <= 0.1 | H >= 0.8) & ...
         S >= 0.1 & S <= 0.25 & ...
         V >= 0.3 & V <= 0.7;
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
  
  toc
  
  tic
  fig3 = figure(3);
  imshow(roi, 'InitialMagnification', 'fit')
  
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
  check_roiArea = size(roiArea);
  if check_roiArea(1) == 0
      continue
  end
  
  roiCenter = regionprops(roi, 'Centroid');
  roiCenter = getfield(roiCenter, 'Centroid');
  
  % Compactness
  roiArea = getfield(roiArea, 'Area');
  roiPerim = getfield(roiPerim, 'Perimeter');
  
  % Normalized compactness
  roiNormComp = 1 - 4 * pi * roiArea / roiPerim ^ 2;
  
  roiMinAxis = regionprops(roi, 'MinorAxisLength');
  roiMinAxis = getfield(roiMinAxis, 'MinorAxisLength');
  % Major and minor axes lengths
  % roiMajAxis = regionprops(roi, 'MajorAxisLength');
  % roiMajAxis = getfield(roiMajAxis, 'MajorAxisLength');
  
  % roiMinAxis = regionprops(roi, 'MinorAxisLength');
  % roiMinAxis = getfield(roiMinAxis, 'MinorAxisLength');
  
  % Orientation
  % roiOrient = regionprops(roi, 'Orientation');
  % roiOrient = getfield(roiOrient, 'Orientation');
  
  % Eccentricity
  % roiEccent = regionprops(roi, 'Eccentricity');
  % roiEccent = getfield(roiEccent, 'Eccentricity');
  
  % Hu Moments
  hu_moments = HuMoments(roi);
  
  % Classify
  data = [roiHeight, roiWidth, roiCenter(1), roiCenter(2), roiArea, roiPerim, roiNormComp, hu_moments(1), hu_moments(2), hu_moments(3), hu_moments(4), hu_moments(5), hu_moments(6), hu_moments(7)];
  toc
  
  tic
  gesture = gestures(int2str(baggedTreesClassifier.predict(data)))
  toc
  
  % Train
  % fprintf(ouf, '%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%d\n', ...
  %   [data, gesture]);
end

% Comment out when not collecting data
% fclose(ouf);
stop(video);