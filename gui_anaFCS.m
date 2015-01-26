function varargout = gui_anaFCS(varargin)
% GUI_ANAFCS MATLAB code for gui_anaFCS.fig
%      GUI_ANAFCS, by itself, creates a new GUI_ANAFCS or raises the existing
%      singleton*.
%
%      H = GUI_ANAFCS returns the handle to a new GUI_ANAFCS or the handle to
%      the existing singleton*.
%
%      GUI_ANAFCS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ANAFCS.M with the given input arguments.
%
%      GUI_ANAFCS('Property','Value',...) creates a new GUI_ANAFCS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_anaFCS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_anaFCS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_anaFCS

% Last Modified by GUIDE v2.5 04-Dec-2014 15:02:26

% Begin initialization code - DO NOT EDIT

% jri 20Jan2015


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_anaFCS_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_anaFCS_OutputFcn, ...
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


% --- Executes just before gui_anaFCS is made visible.
function gui_anaFCS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_anaFCS (see VARARGIN)


variables.anaFCS_version='21Jan15'; %Esta es la versión del código
variables.version=1; %Esta es la versión de los ficheros matlab en los que se guardan las imágenes, etc.

variables.path=pwd;
variables.pathSave='';
variables.S=[];

set(handles.edit_acquisitionTime, 'String', '');
set(handles.edit_t0, 'String', '');
set(handles.edit_tf, 'String', '');
set(handles.edit_intervals, 'String', '');
set(handles.edit_binningFrequency, 'String', '');
set(handles.edit_subIntervalsForUncertainty, 'String', '18');
set(handles.edit_maximumTauLag, 'String', '10');
set(handles.edit_sections, 'String', '3');
set(handles.edit_base, 'String', '4');
set(handles.edit_pointsPerSection, 'String', '20');
set(handles.edit_binningFrequency, 'Enable', 'off') 
set(handles.edit_binningLines, 'Enable', 'off', 'String', '') 
set (handles.radiobutton_all, 'Value', true)


setappdata (handles.figure1, 'v', variables);  %Convierte variablesapl en datos de la aplicación con el nombre v

% Choose default command line output for gui_anaFCS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_anaFCS wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_anaFCS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure

varargout{1} = handles.output;
delete (hObject);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%Para que esto funcione tiene que estar definido en las properties del GUI.
%Sólo hay que hacer click en el botón de CloseRequestFcn
uiresume (handles.figure1) %Permite que se ejecute vargout


% --- Executes on button press in pushbutton_loadCorrelationCurves.
function pushbutton_loadCorrelationCurves_Callback(hObject, eventdata, handles)

v=getappdata (handles.figure1, 'v'); %Recupera variables
[FileName,PathName, FilterIndex] = uigetfile({'*.mat'},'Choose your FCS file', v.path);
if ischar(FileName)
    set (handles.figure1,'Pointer','watch')
    drawnow update
    v.path=PathName;
    %v.S=load ([v.path FileName], 'Gintervalos', 'Gmean', 'numIntervalos', 'binFreq', ); 
    v.S=load ([v.path FileName]);
    if v.S.isScanning
        macroTimeCol=4;
        microTimeCol=5;
        channelsCol=6;
    else
        macroTimeCol=1;
        microTimeCol=2;
        channelsCol=3;
    end
    %acqTime=v.S.photonArrivalTimes(end, macroTimeCol)+v.S.photonArrivalTimes(end, microTimeCol)-(v.S.photonArrivalTimes(1, macroTimeCol)+v.S.photonArrivalTimes(1, microTimeCol));
    %strAcqTime=sprintf('%3.2f', v.S.acqTime);
    set(handles.edit_acquisitionTime, 'String', strAcqTime);
    set(handles.edit_intervals, 'String', num2str(v.S.numIntervalos));
    set(handles.edit_binningFrequency, 'String', num2str(v.S.binFreq/1E3));
    set(handles.edit_subIntervalsForUncertainty, 'String', num2str(v.S.numSubIntervalosError));
    set(handles.edit_maximumTauLag, 'String', num2str(v.S.tauLagMax/1E-3));
    set(handles.edit_sections, 'String', num2str(v.S.numSecciones));
    set(handles.edit_base, 'String', num2str(v.S.base));
    set(handles.edit_pointsPerSection, 'String', num2str(v.S.numPuntosSeccion));
    for n=1:v.S.numIntervalos
        hinf(n)=FCS_representa (v.S.FCSintervalos(:,1,n), v.S.Gintervalos(:, :, n), 1/v.S.binFreq, 'auto', 1);
    end
    hinf(n+1)=FCS_representa (v.S.FCSmean, v.S.Gmean, 1/v.S.binFreq, 'auto', 1);
    
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['...' v.path(pos:end) v.S.fname(1:end-4)];
    set (handles.figure1, 'Name' , ['anaFCS - ' nombreFCSData])
    set (handles.figure1,'Pointer','arrow')
    setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables
end

% --- Executes on button press in pushbutton_computeCorrelation.
function pushbutton_computeCorrelation_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables

if v.S.isScanning
    macroTimeCol=4;
    microTimeCol=5;
    channelsCol=6;
    v.S.binLines=str2double(get(handles.edit_binningLines, 'String'));

else
    macroTimeCol=1;
    microTimeCol=2;
    channelsCol=3;
    v.S.binFreq=1000*str2double(get(handles.edit_binningFrequency, 'String'));
    
end
    v.S.numIntervalos=str2double(get(handles.edit_intervals, 'String'));
    v.S.numSubIntervalosError=str2double(get(handles.edit_subIntervalsForUncertainty, 'String'));
    v.S.tauLagMax=str2double(get(handles.edit_maximumTauLag, 'String'))/1000;
    v.S.numSecciones=str2double(get(handles.edit_sections, 'String'));
    v.S.base=str2double(get(handles.edit_base, 'String'));
    v.S.numPuntosSeccion=str2double(get(handles.edit_pointsPerSection, 'String'));
    v.S.tipoCorrelacion='todas';
    if get (handles.radiobutton_auto, 'Value')
        v.S.tipoCorrelacion='auto';
    end
    if get (handles.radiobutton_cross, 'Value')
        v.S.tipoCorrelacion='auto';
    end

    
    set (handles.figure1,'Pointer','watch')
    drawnow update
    disp ('Computing correlation')
    tic;
    if v.S.isScanning
        [v.S.FCSintervalos, v.S.Gintervalos, v.S.FCSmean, v.S.Gmean, v.S.tData, v.S.binFreq]=...
            FCS_computecorrelation (v.S.photonArrivalTimes, v.S.numIntervalos, v.S.binLines, v.S.tauLagMax, v.S.numSecciones, v.S.numPuntosSeccion, v.S.base, v.S.numSubIntervalosError, v.S.tipoCorrelacion, ...
            v.S.imgBin, v.S.lineSync, v.S.indLinesLS, v.S.indMaxCadaLinea, v.S.sigma2_5);
        s=sprintf('%3.2f', v.S.binFreq/1000); %Actualiza el binFreq. esto debería hacerlo solo desde el principio.
        set (handles.edit_binningFrequency, 'String', s);
    else
        [v.S.FCSintervalos, v.S.Gintervalos, v.S.FCSmean, v.S.Gmean, v.S.tData]=...
            FCS_computecorrelation (v.S.photonArrivalTimes, v.S.numIntervalos, v.S.binFreq, v.S.tauLagMax, v.S.numSecciones, v.S.numPuntosSeccion, v.S.base, v.S.numSubIntervalosError, v.S.tipoCorrelacion);
    end
    tdecode=toc;
    disp (['Correlation time: ' num2str(tdecode) ' s'])
    for n=1:v.S.numIntervalos
        %Cuidado si queremos representar sólo un canal
        hinf(n)=FCS_representa (v.S.FCSintervalos(:,:,n), v.S.Gintervalos(:, :, n), 1/v.S.binFreq, v.S.tipoCorrelacion);
    end
    hinf(n+1)=FCS_representa (v.S.FCSmean, v.S.Gmean, 1/v.S.binFreq, v.S.tipoCorrelacion);

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables
% --- Executes on button press in pushbutton_plotCorrelationCurves.
function pushbutton_plotCorrelationCurves_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
for n=1:v.S.numIntervalos
    hinf(n)=FCS_representa (v.S.FCSintervalos(:,1,n), v.S.Gintervalos(:, :, n), 1/v.S.binFreq, 'auto', 1);
end
hinf(n+1)=FCS_representa (v.S.FCSmean, v.S.Gmean, 1/v.S.binFreq, 'auto', 1);



% --- Executes on button press in pushbutton_saveFCSData.
function pushbutton_saveFCSData_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables

S=v.S;
set (handles.figure1,'Pointer','watch')
drawnow update
disp (['Saving FCS analysis of ' v.S.fname])
    save ([v.path v.S.fname], '-struct', 'S', '-append')
disp ('OK')
set (handles.figure1,'Pointer','arrow')



% --- Executes on button press in pushbutton_saveForPyCorrFit.
function pushbutton_saveForPyCorrFit_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 
set (handles.figure1,'Pointer','watch')
drawnow update
FCS_savePyCorrformat(v.S.Gintervalos, v.S.FCSintervalos, v.S.binFreq, [v.path v.S.fname]);
set (handles.figure1,'Pointer','arrow')



function edit_sections_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'numSecciones')
    valorAnterior=v.S.numSecciones;
else
    valorAnterior=str2double(get(handles.edit_sections, 'String'));
end
v.S.numSecciones=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'v', v);


% --- Executes during object creation, after setting all properties.
function edit_sections_CreateFcn(hObject, eventdata, handles)



function edit_base_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'base')
    valorAnterior=v.S.base;
else
    valorAnterior=str2double(get(handles.edit_base, 'String'));
end
v.S.base=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'v', v);


% --- Executes during object creation, after setting all properties.
function edit_base_CreateFcn(hObject, eventdata, handles)



function edit_pointsPerSection_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'numPuntosSeccion')
    valorAnterior=v.S.numPuntosSeccion;
else
    valorAnterior=str2double(get(handles.edit_pointsPerSection, 'String'));
end
v.S.numPuntosSeccion=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'v', v);

% --- Executes during object creation, after setting all properties.
function edit_pointsPerSection_CreateFcn(hObject, eventdata, handles)




function edit_intervals_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'numIntervalos')
    valorAnterior=v.S.numIntervalos;
else
    valorAnterior=str2double(get(handles.edit_intervals, 'String'));
end
v.S.numIntervalos=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'v', v);

% --- Executes during object creation, after setting all properties.
function edit_intervals_CreateFcn(hObject, eventdata, handles)



function edit_binningFrequency_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'binFreq')
    valorAnterior=v.S.binFreq/1E-3;
else
    valorAnterior=str2double(get(handles.edit_binningFrequency, 'String'));
end
v.S.binFreq=1000*compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'v', v);


% --- Executes during object creation, after setting all properties.
function edit_binningFrequency_CreateFcn(hObject, eventdata, handles)


function edit_maximumTauLag_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'tauLagMax')
    valorAnterior=v.S.tauLagMax/1000;
else
    valorAnterior=str2double(get(handles.edit_maximumTauLag, 'String'));
end
v.S.tauLagMax=compruebayactualizaedit(hObject, 0, Inf, valorAnterior)/1000;
setappdata (handles.figure1, 'v', v);



% --- Executes during object creation, after setting all properties.
function edit_maximumTauLag_CreateFcn(hObject, eventdata, handles)



function edit_subIntervalsForUncertainty_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'numSubIntervalosError')
    valorAnterior=v.S.numSubIntervalosError;
else
    valorAnterior=str2double(get(handles.edit_subIntervalsForUncertainty, 'String'));
end
v.S.numSubIntervalosError=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'v', v);


% --- Executes during object creation, after setting all properties.
function edit_subIntervalsForUncertainty_CreateFcn(hObject, eventdata, handles)



function edit_acquisitionTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_acquisitionTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_acquisitionTime as text
%        str2double(get(hObject,'String')) returns contents of edit_acquisitionTime as a double


% --- Executes during object creation, after setting all properties.
function edit_acquisitionTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_acquisitionTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_loadRawFCSData.
function pushbutton_loadRawFCSData_Callback(hObject, eventdata, handles)

v=getappdata (handles.figure1, 'v'); %Recupera variables
[FileName,PathName, FilterIndex] = uigetfile({'*.mat'},'Choose your FCS file', v.path);
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(FileName)
    v.path=PathName;
    disp (['Loading ' FileName])
    v.S=load ([v.path FileName], 'TACrange', 'TACgain', 'photonArrivalTimes', 'isScanning');
    if v.S.isScanning
        disp ('Scanning FCS experiment')
        macroTimeCol=4;
        microTimeCol=5;
        channelsCol=6;

        [v.S.imgBin, v.S.indLinesLS, v.S.indMaxCadaLinea, v.S.sigma2_5, v.S.timeInterval]=FCS_align(v.S.photonArrivalTimes, v.S.imgDecode, v.S.lineSync, v.S.pixelSync);
        strT0=sprintf('%3.2f', v.S.timeInterval(1));
        strTf=sprintf('%3.2f', v.S.timeInterval(2));
        
        set(handles.edit_t0, 'String', strT0);
        set(handles.edit_tf, 'String', strTf);
        set(handles.edit_binningFrequency, 'Enable', 'off', 'String', '') 
        v.S.binLines=2;
        set(handles.edit_binningLines, 'Enable', 'on', 'String', num2str(v.S.binLines)) 
        v.S.binFreq=1400/v.S.binLines;
        s=sprintf('%3.2f', v.S.binFreq/1000);
        set (handles.edit_binningFrequency, 'String', s)
    else
        disp ('Point FCS experiment')
        macroTimeCol=1;
        microTimeCol=2;
        channelsCol=3;
        
        set(handles.edit_binningFrequency, 'Enable', 'on', 'String', '100') 
        set(handles.edit_binningLines, 'Enable', 'off', 'String', '') 

    end
    v.S.acqTime=v.S.photonArrivalTimes(end, macroTimeCol)+v.S.photonArrivalTimes(end, microTimeCol)-(v.S.photonArrivalTimes(1, macroTimeCol)+v.S.photonArrivalTimes(1, microTimeCol));
    strAcqTime=sprintf('%3.2f', v.S.acqTime);
    set(handles.edit_acquisitionTime, 'String', strAcqTime);
%    S=v.S;
%    save ([v.path FileName(1:end-4) '_tmp.mat'], '-struct', 'S')
end
pos=find(v.path=='\', 2, 'last');
nombreFCSData=['anaFCS - ...' v.path(pos:end) v.S.fname(1:end-4)];
set (handles.figure1, 'Name' , nombreFCSData)

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --- Executes on button press in pushbutton_saveAsASCII.
function pushbutton_saveAsASCII_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveAsASCII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_decodeRawData.
function pushbutton_decodeRawData_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
[FileName,PathName, FilterIndex] = uigetfile({'*.spc'},'Choose the raw data file', v.path);
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(FileName)
    v.path=PathName;
    v.S.fname=FileName;
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['...' v.path(pos:end) v.S.fname(1:end-4)];
    set (handles.figure1, 'Name' , nombreFCSData)
    
    [v.S.isScanning, v.S.photonArrivalTimes, v.S.TACrange, v.S.TACgain, imgDecode, frameSync, lineSync, pixelSync] = FCS_load(v.S.fname);
     if v.S.isScanning
        v.S.imgDecode=imgDecode;
        v.S.frameSync=frameSync;
        v.S.lineSync=lineSync;
        v.S.pixelSync=pixelSync;
    end
end

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables

%[isScanning, photonArrivalTimes, TACrange, TACgain, imgDecode, frameSync, lineSync, pixelSync] = FCS_load(fname)
%
% Para point FCS
% [isScanning, photonArrivalTimes, TACrange, TACgain]= FCS_load(fname)




function edit_t0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_t0 as text
%        str2double(get(hObject,'String')) returns contents of edit_t0 as a double


% --- Executes during object creation, after setting all properties.
function edit_t0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_tf_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tf as text
%        str2double(get(hObject,'String')) returns contents of edit_tf as a double


% --- Executes during object creation, after setting all properties.
function edit_tf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_binningLines_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 

if isfield (v.S, 'binLines')
    valorAnterior=v.S.binLines;
else
    valorAnterior=str2double(get(handles.edit_binningLines, 'String'));
end
v.S.binLines=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
v.S.binFreq=1400/v.S.binLines;
s=sprintf('%3.2f', v.S.binFreq/1000);
set (handles.edit_binningFrequency, 'String', s)
setappdata (handles.figure1, 'v', v);

% --- Executes during object creation, after setting all properties.
function edit_binningLines_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_binningLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
