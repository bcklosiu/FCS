function varargout = gui_binning(varargin)
% GUI_BINNING MATLAB code for gui_binning.fig
%      GUI_BINNING, by itself, creates a new GUI_BINNING or raises the existing
%      singleton*.
%
%      H = GUI_BINNING returns the handle to a new GUI_BINNING or the handle to
%      the existing singleton*.
%
%      GUI_BINNING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_BINNING.M with the given input arguments.
%
%      GUI_BINNING('Property','Value',...) creates a new GUI_BINNING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_binning_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_binning_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_binning

% Last Modified by GUIDE v2.5 05-Jan-2017 10:34:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_binning_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_binning_OutputFcn, ...
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


% --- Executes just before gui_binning is made visible.
function gui_binning_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_binning (see VARARGIN)

% Choose default command line output for gui_binning
pat=varargin{1};
pat_Mtmt=pat.MacroMicroTime;
pat_c=pat.channel;
channels=unique(pat_c)+1;
tMax=ceil(pat_Mtmt(end,1)+pat_Mtmt(end,2));
handles.output = hObject;
set(handles.t0_edit, 'String', 0)
set(handles.tf_edit, 'String', tMax)
set(handles.binFreq_edit, 'String', 1)
set(handles.channel_edit, 'String', channels(1))
ylabel(handles.binning_plot,'Counts'); xlabel(handles.binning_plot,'t(s)');
if numel(channels)==1,
    set(handles.channel_edit, 'enable', 'off')    
end
vGlobs=struct('tMax',tMax,'channels',channels,'fcsData',pat) ;% variables globales
setappdata(handles.figure1,'vGlobs',vGlobs)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_binning wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_binning_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function t0_edit_Callback(hObject, eventdata, handles)
% hObject    handle to t0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tf=str2double(get(handles.tf_edit, 'String'));
t0_ini=str2double(get(hObject,'String'));
t0=compruebayactualizaedit(hObject, 0, tf, t0_ini);

% Hints: get(hObject,'String') returns contents of t0_edit as text
%        str2double(get(hObject,'String')) returns contents of t0_edit as a double


% --- Executes during object creation, after setting all properties.
function t0_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to tf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vGlobs=getappdata(handles.figure1,'vGlobs');
t0=str2double(get(handles.t0_edit, 'String'));
tf_ini=str2double(get(hObject,'String'));
tf=compruebayactualizaedit(hObject, t0, vGlobs.tMax, tf_ini);
% Hints: get(hObject,'String') returns contents of tf_edit as text
%        str2double(get(hObject,'String')) returns contents of tf_edit as a double


% --- Executes during object creation, after setting all properties.
function tf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function binFreq_edit_Callback(hObject, eventdata, handles)
% hObject    handle to binFreq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
binFreq=str2double(get(hObject,'String'));
set (hObject, 'String', num2str(binFreq))
% Hints: get(hObject,'String') returns contents of binFreq_edit as text
%        str2double(get(hObject,'String')) returns contents of binFreq_edit as a double


% --- Executes during object creation, after setting all properties.
function binFreq_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binFreq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channel_edit_Callback(hObject, eventdata, handles)
% hObject    handle to channel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vGlobs=getappdata(handles.figure1,'vGlobs');
channelNr_ini=str2double(get(hObject,'String'));
channelNr=compruebayactualizaedit(hObject, vGlobs.channels(1), vGlobs.channels(end), channelNr_ini);
% Hints: get(hObject,'String') returns contents of channel_edit as text
%        str2double(get(hObject,'String')) returns contents of channel_edit as a double


% --- Executes during object creation, after setting all properties.
function channel_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calculateBinning.
function calculateBinning_Callback(hObject, eventdata, handles)
% hObject    handle to calculateBinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
calculate=get(hObject,'Value');
if calculate==1,
% Carga las variables de las "edit text" de la GUI    
    t0=str2double(get(handles.t0_edit,'String'));
    tf=str2double(get(handles.tf_edit,'String'));
    binFreq=str2double(get(handles.binFreq_edit,'String'));
    channel=str2double(get(handles.channel_edit,'String'))-1;
    vGlobs=getappdata(handles.figure1,'vGlobs');
% Calcula ROI y binning
    fcsData=vGlobs.fcsData;
    data=fcsData.MacroMicroTime(:,1)+fcsData.MacroMicroTime(:,2); 
    indDataROI=and(and(data>=t0,data<=tf),fcsData.channel==channel);
    dataROI=data(indDataROI);
    tPhoton0=dataROI(1); %tiempo del primer fotón de la ROI
    fcsDataROI.MacroMicroTime=fcsData.MacroMicroTime(indDataROI,:); 
    fcsDataROI.channel=fcsData.channel(indDataROI); 
    fcsBin=FCS_binning_FIFO_pixel1(fcsDataROI, binFreq, tPhoton0); %Le pasamos la ROI para evitar hacer el binning de toda la adquisicion
    deltaT=(tf-t0)/numel(fcsBin);
    timeScale=t0+deltaT/2:deltaT:tf-deltaT/2; %numel(fcsBin),numel(timeScale)
    plot(handles.binning_plot,timeScale,fcsBin); axis([t0,tf,0,Inf]); ylabel(handles.binning_plot,'Counts'); xlabel(handles.binning_plot,'t(s)');
    setappdata(handles.figure1,'vGlobs',vGlobs) %Actualiza vGlobs
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
