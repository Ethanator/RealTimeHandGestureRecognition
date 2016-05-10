% Computer Vision Course (CSE 40535/60535)
% University of Notre Dame
% __________________________________________
% Toan Nguyen and Adam Czajka, February 2016
% http://zbum.ia.pw.edu.pl/EN/node/55

%{
This is a rather dirty script to help you preview your webcam feed,
capture an image, select a Region of Interest on captured image,
and display that region's histogram.

1/ Open a live webcam feed. 
2/ Hold an M&M candy in front of the webcam. 
3/ Press Preview to see a preview.
4/ Press Capture to capture an image. Then use your mouse to select 
a rectangle inside image to collect the histogram of that rectangle.

Here, specifically we want to select a (as big as possible) rectangle
inside the M&M candy.

%}

close all
clear all
% please use here your own adaptor
% see the name of your adaptor using command imaqhwinfo
% in this example the adaptor is 'macvideo', you will have
% to change it if your code is not running on a MacBook
vid = videoinput('macvideo');
vid.ReturnedColorspace = 'rgb';

gui = step_1_gui;
gui_handles = guihandles(gui);
gui_handles.vid = vid;
guidata(gui, gui_handles);