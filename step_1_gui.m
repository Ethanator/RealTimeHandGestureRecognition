% Computer Vision Course (CSE 40535/60535)
% University of Notre Dame
% __________________________________________
% Toan Nguyen and Adam Czajka, February 2016
% http://zbum.ia.pw.edu.pl/EN/node/55

function varargout = step_1_gui(varargin)
% STEP_1_GUI MATLAB code for step_1_gui.fig
%      STEP_1_GUI, by itself, creates a new STEP_1_GUI or raises the existing
%      singleton*.
%
%      H = STEP_1_GUI returns the handle to a new STEP_1_GUI or the handle to
%      the existing singleton*.
%
%      STEP_1_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEP_1_GUI.M with the given input arguments.
%
%      STEP_1_GUI('Property','Value',...) creates a new STEP_1_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before step_1_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to step_1_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help step_1_gui

% Last Modified by GUIDE v2.5 10-Feb-2016 15:35:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @step_1_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @step_1_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before step_1_gui is made visible.
function step_1_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to step_1_gui (see VARARGIN)

% Choose default command line output for step_1_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes step_1_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = step_1_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in preview_button.
function preview_button_Callback(hObject, eventdata, handles)
    start(handles.vid);
    vidRes = get(handles.vid, 'VideoResolution');
    imWidth = vidRes(1);
    imHeight = vidRes(2);
    nBands = get(handles.vid, 'NumberOfBands');
    I = image(zeros(imHeight, imWidth, nBands), 'parent', handles.axes1);
    preview(handles.vid, I);
        
% hObject    handle to preview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in capture_button.
function capture_button_Callback(hObject, eventdata, handles)
% hObject    handle to capture_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)  
    I = getsnapshot(handles.vid);
    figure(1)
    hold on
    title('Snapshot')
    imshow(I);
    rect = round(getrect); % xmin, ymin, width, height
    hold off
    
    roi = I(rect(2): rect(2) + rect(4), rect(1): rect(1) + rect(3), :);
    figure(2)
    imshow(roi);
    title('Selected ROI')
    
    % calculate RGB histograms
    [hist1rgb, x1rgb] = imhist(roi(:, :, 1));
    [hist2rgb, x2rgb] = imhist(roi(:, :, 2));
    [hist3rgb, x3rgb] = imhist(roi(:, :, 3));
    
    % calculate HSV histograms
    roiHSV = rgb2hsv(roi);
    [hist1hsv, x1hsv] = imhist(roiHSV(:, :, 1));
    [hist2hsv, x2hsv] = imhist(roiHSV(:, :, 2));
    [hist3hsv, x3hsv] = imhist(roiHSV(:, :, 3));
    
    roiYcbcr = rgb2ycbcr(roi);
    [hist1ycbcr, x1ycbcr] = imhist(roiYcbcr(:, :, 1));
    [hist2ycbcr, x2ycbcr] = imhist(roiYcbcr(:, :, 2));
    [hist3ycbcr, x3ycbcr] = imhist(roiYcbcr(:, :, 3));
    

    figure(3)
    set(plot(x1rgb, hist1rgb, 'r', x2rgb, hist2rgb, 'g', x3rgb, hist3rgb, 'b'),'LineWidth',2);
    set(gca,'XTick',0:10:250);
    axis([0 255 0 max([max(hist1rgb) max(hist2rgb) max(hist3rgb)])])
    title('Histograms of image components (RGB)')
    legend('RED channel','GREEN channel','BLUE channel')
    
    figure(4)
    set(plot(x1hsv, hist1hsv, 'r', x2hsv, hist2hsv, 'g', x3hsv, hist3hsv, 'b'),'LineWidth',2);
    set(gca,'XTick',0:0.05:1);
    axis([0 1 0 max([max(hist1hsv) max(hist2hsv) max(hist3hsv)])])
    title('Histograms of image components (HSV)')
    legend('Hue','Saturation','Value')
    
    figure(5)
    set(plot(x2ycbcr, hist2ycbcr, 'b', x3ycbcr, hist3ycbcr, 'r'),'LineWidth',2);
    set(gca,'XTick',90:5:160);
    axis([90 160 0 max([max(hist2ycbcr) max(hist3ycbcr)])])
    title('Histograms of image components (Ycbcr)')
    legend('Cb','Cr')
    