function varargout = gui_FCSrepresenta(varargin)
% GUI_FCSREPRESENTA MATLAB code for gui_FCSrepresenta.fig
%      GUI_FCSREPRESENTA, by itself, creates a new GUI_FCSREPRESENTA or raises the existing
%      singleton*.
%
%      H = GUI_FCSREPRESENTA returns the handle to a new GUI_FCSREPRESENTA or the handle to
%      the existing singleton*.
%
%      GUI_FCSREPRESENTA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FCSREPRESENTA.M with the given input arguments.
%
%      GUI_FCSREPRESENTA('Property','Value',...) creates a new GUI_FCSREPRESENTA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_FCSrepresenta_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_FCSrepresenta_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_FCSrepresenta

% Last Modified by GUIDE v2.5 21-Apr-2015 12:52:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_FCSrepresenta_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_FCSrepresenta_OutputFcn, ...
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


% --- Executes just before gui_FCSrepresenta is made visible.
function gui_FCSrepresenta_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_FCSrepresenta (see VARARGIN)

variables.FCSIntervalos=varargin{1};
variables.GIntervalos=varargin{2};
variables.deltaT=varargin{3};
variables.tipoCorrelacion=varargin{4};
variables.hfig=varargin{5};

variables.showing=1;

[variables.hinf variables.hsup variables.hfig]=FCS_representa (variables.FCSIntervalos(:, :,variables.showing), variables.GIntervalos(:, :, variables.showing), variables.deltaT, variables.tipoCorrelacion, variables.hfig);
set (variables.hfig, 'NumberTitle', 'off', 'Name', ['Curve: ' num2str(variables.showing)])
setappdata (handles.figure1, 'v', variables);  %Convierte v en datos de la aplicación con el nombre v

% Choose default command line output for gui_FCSrepresenta
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_FCSrepresenta wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_FCSrepresenta_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_retrocedeImagen.
function pushbutton_retrocedeImagen_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_retrocedeImagen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v=getappdata (handles.figure1, 'v'); %Recupera variables

v.showing=v.showing-1;
if v.showing==0
    v.showing=1;
end
set (handles.edit_showingCurve, 'String', num2str(v.showing))
[v.hinf v.hsup v.hfig]=FCS_representa (v.FCSIntervalos(:, :,v.showing), v.GIntervalos(:, :, v.showing), v.deltaT, v.tipoCorrelacion, v.hfig);
set (v.hfig, 'NumberTitle', 'off', 'Name', ['Curve: ' num2str(v.showing)])
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --- Executes on button press in pushbutton_avanzaImagen.
function pushbutton_avanzaImagen_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_avanzaImagen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v=getappdata (handles.figure1, 'v'); %Recupera variables

v.showing=v.showing+1;
set (handles.edit_showingCurve, 'String', num2str(v.showing))
[v.hinf v.hsup v.hfig]=FCS_representa (v.FCSIntervalos(:, :,v.showing), v.GIntervalos(:, :, v.showing), v.deltaT, v.tipoCorrelacion, v.hfig);
set (v.hfig, 'NumberTitle', 'off', 'Name', ['Curve: ' num2str(v.showing)])
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


function edit_showingCurve_Callback(hObject, eventdata, handles)
% hObject    handle to edit_showingCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_showingCurve as text
%        str2double(get(hObject,'String')) returns contents of edit_showingCurve as a double


% --- Executes during object creation, after setting all properties.
function edit_showingCurve_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_showingCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
