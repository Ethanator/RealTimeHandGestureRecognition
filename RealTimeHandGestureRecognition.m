% RealTimeHandGestureRecognition.m
% Recognize different hand gestures in real time.
%   Author: Ethan Chen
%     Date: May 9, 2016

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

% Gesture Codes
gestures = containers.Map;
gestures('0') = 'Fist';
gestures('1') = 'One';
gestures('2') = 'Two';
gestures('3') = 'Three';
gestures('4') = 'Four';
gestures('5') = 'Five';
gestures('6') = 'Call Me';
gestures('7') = 'Loser';
gestures('8') = 'Hook ''em Horns';
gestures('9') = 'Middle Finger';
gestures('10') = 'Thumbs Up';
gestures('11') = 'Thumbs Down';
gestures('12') = 'I Love You';
gestures('13') = 'OK';

% Train
% gesture = 13;
% ouf = fopen(strcat(int2str(gesture), '.txt'), 'wt');

% Classify
load('baggedTreesClassifier.mat')

while(1)
  %% Segmentation
  Irgb   = getsnapshot(video);
  Ihsv   = rgb2hsv(Irgb);
  Iycbcr = rgb2ycbcr(Irgb);
  H  = Ihsv(:, :, 1);
  S  = Ihsv(:, :, 2);
  V  = Ihsv(:, :, 3);
  cb = Iycbcr(:, :, 2);
  cr = Iycbcr(:, :, 3);
  cond = (H < 0.1 | H > 0.75) & S > 0.1 & S < 0.6 & V > 0.4 & ...
      cb > 90 & cb < 140 & cr > 130;
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
  
  % Major and minor axes lengths
  roiMajAxis = regionprops(roi, 'MajorAxisLength');
  roiMajAxis = getfield(roiMajAxis, 'MajorAxisLength');
  roiMinAxis = regionprops(roi, 'MinorAxisLength');
  roiMinAxis = getfield(roiMinAxis, 'MinorAxisLength');
  
  % Orientation
  roiOrient = regionprops(roi, 'Orientation');
  roiOrient = getfield(roiOrient, 'Orientation');
  
  % Eccentricity
  roiEccent = regionprops(roi, 'Eccentricity');
  roiEccent = getfield(roiEccent, 'Eccentricity');
  
  % Hu Moments
  hu_moments = HuMoments(roi);
  
  data = table;
  data.Height       = roiHeight;
  data.Width        = roiWidth;
  data.CenterX      = roiCenter(1);
  data.CenterY      = roiCenter(2);
  data.Area         = roiArea;
  data.Perimeter    = roiPerim;
  data.Compactness  = roiNormComp;
  data.MajorAxis    = roiMajAxis;
  data.MinorAxis    = roiMinAxis;
  data.Orientation  = roiOrient;
  data.Eccentricity = roiEccent;
  data.HuMoment1    = hu_moments(1);
  data.HuMoment2    = hu_moments(2);
  data.HuMoment3    = hu_moments(3);
  data.HuMoment4    = hu_moments(4);
  data.HuMoment5    = hu_moments(5);
  data.HuMoment6    = hu_moments(6);
  data.HuMoment7    = hu_moments(7);

  % Classify
  gesture = gestures(int2str(baggedTreesClassifier.predictFcn(data)))
  
  % Train
  % fprintf(ouf, '%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%0.12f\t%d\n', ...
  %   [data, gesture]);
end

% Train
% fclose(ouf);

stop(video);