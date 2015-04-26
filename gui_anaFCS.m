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

% Last Modified by GUIDE v2.5 24-Apr-2015 22:38:07

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

cierraFigurasMalCerradas; %Esto lo hace si ha habido un error anterior.

variables.anaFCS_version='20Apr15'; %Esta es la versión del código

variables.path=pwd;
variables.pathSave='';

set(handles.edit_acquisitionTime, 'String', '');
set(handles.edit_t0, 'String', '');
set(handles.edit_tf, 'String', '');
set(handles.edit_intervals, 'String', '');
set(handles.edit_binningFrequency, 'String', '');
set(handles.edit_maximumTauLag, 'String', '10');
set(handles.edit_sections, 'String', '3');
set(handles.edit_base, 'String', '4');
set(handles.edit_pointsPerSection, 'String', '20');
set(handles.edit_binningFrequency, 'Enable', 'on')
set(handles.edit_binningLines, 'Enable', 'off', 'String', '')
set(handles.edit_channel, 'String', '1');
set(handles.radiobutton_auto, 'Value', true)
set(handles.radiobutton_averageSEM, 'Value', true)
set(handles.edit_subIntervalsForUncertainty, 'String', '0', 'Enable', 'off');

variables.numSubIntervalosError_anterior=18; %Por defecto cuando se activa
variables.h_figIntervalos=figure;
variables.h_figPromedio=figure;
variables.allFigures=[variables.h_figIntervalos variables.h_figPromedio];
set (variables.allFigures, 'NumberTitle' , 'off', 'Visible', 'off', 'DockControls', 'off', 'Color', [1 1 1])
set (variables.allFigures, 'CloseRequestFcn', @FigCloseRequestFcn)

%v son variables de la applicación
%S es la estructura que contiene los datos de FCS
%R es la estructura que contiene los datos raw de los fotones (B&H)
S=struct();
R=struct();
S.version=1; %Esta es la versión de los ficheros matlab en los que se guardan las imágenes, etc.
R.version=1;
variables.scannerFreq=1400; %Por ahora en variables, hasta que decida qué hacer con ella
setappdata (handles.figure1, 'v', variables);  %Convierte variablesapl en datos de la aplicación con el nombre v
setappdata (handles.figure1, 'S', S);  %Convierte variablesapl en datos de la aplicación con el nombre v
setappdata (handles.figure1, 'R', R);  %Convierte variablesapl en datos de la aplicación con el nombre v


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
v=getappdata (handles.figure1, 'v'); %Recupera variables

set (v.allFigures, 'CloseRequestFcn', 'closereq')
close (v.allFigures)

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
%S no la tiene que recuperar, porque la carga aquí

[FileName,PathName, FilterIndex] = uigetfile({'*.mat'},'Choose your FCS file', v.path);
if ischar(FileName)
    rmappdata (handles.figure1, 'S'); %Borra S como variable global para que no ocupe RAM mientras carga la siguiente
    if isappdata (handles.figure1, 'R');
        rmappdata (handles.figure1, 'R');
    end
    set (handles.figure1,'Pointer','watch')
    drawnow update
    v.path=PathName;
    S=load ([v.path FileName], 'acqTime', 'numIntervalos', 'binFreq', 'numSubIntervalosError', 'tauLagMax', 'numSecciones', 'base', 'numPuntosSeccion', 'channel', 'tipoCorrelacion',...
        'intervalosPromediados', 'FCSintervalos', 'Gintervalos', 'FCSmean', 'Gmean', 'isScanning');
    v.fname=[v.path FileName];
    if S.isScanning
        macroTimeCol=4;
        microTimeCol=5;
        channelsCol=6;
    else
        macroTimeCol=1;
        microTimeCol=2;
        channelsCol=3;
    end
    if not(isfield(S, 'acqTime'))
        S.acqTime=0;
    end
    if not(isfield(S, 'intervalosPromediados')) %Para archivos viejos. Si no se indican los intervalos promediados, se promedian todos
        S.intervalosPromediados=1:S.numIntervalos;
    end
    
    %acqTime=S.photonArrivalTimes(end, macroTimeCol)+S.photonArrivalTimes(end, microTimeCol)-(S.photonArrivalTimes(1, macroTimeCol)+S.photonArrivalTimes(1, microTimeCol));
    strAcqTime=sprintf('%3.2f', S.acqTime);
    set(handles.edit_acquisitionTime, 'String', strAcqTime);
    set(handles.edit_intervals, 'String', num2str(S.numIntervalos));
    set(handles.edit_binningFrequency, 'String', num2str(S.binFreq/1E3));
    set(handles.edit_subIntervalsForUncertainty, 'String', num2str(S.numSubIntervalosError));
    set(handles.edit_subIntervalsForUncertainty, 'Enable', 'off');
    set(handles.radiobutton_averageSEM, 'Value', true)
    if S.numSubIntervalosError
        set(handles.edit_subIntervalsForUncertainty, 'Enable', 'on');
        set (handles.radiobutton_subIntervalsSEM, 'Value', true)
    end
    set(handles.edit_maximumTauLag, 'String', num2str(S.tauLagMax/1E-3));
    set(handles.edit_sections, 'String', num2str(S.numSecciones));
    set(handles.edit_base, 'String', num2str(S.base));
    set(handles.edit_pointsPerSection, 'String', num2str(S.numPuntosSeccion));
    switch lower(S.tipoCorrelacion)
        case 'auto'
            set (handles.radiobutton_auto, 'Value', 1)
        otherwise
            set (handles.radiobutton_cross, 'Value', 1)
    end
    
    
    for n=1:S.numIntervalos
        FCS_representa (S.FCSintervalos(:,:,n), S.Gintervalos(:, :, n), 1/S.binFreq, S.channel, v.h_figIntervalos); %Las ventana promedio va a ser la 500
    end
    FCS_representa (S.FCSmean, S.Gmean, 1/S.binFreq, S.channel, v.h_figPromedio);
    promedioString='';
    for n=1:numel(S.intervalosPromediados)
        promedioString=[promedioString num2str(S.intervalosPromediados(n)), ', '];
    end
    promedioString=promedioString(1:end-2); %Le quito la última ', '
    set (v.allFigures, 'Visible', 'on')
    set (v.h_figPromedio, 'NumberTitle', 'off', 'Name', ['Average: ' promedioString])
    
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['...' v.fname(pos:end-4)];
    set (handles.figure1, 'Name' , ['anaFCS - ' nombreFCSData])
    set (handles.figure1,'Pointer','arrow')
    setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables
    setappdata(handles.figure1, 'S', S); %Guarda S
end


% --- Executes on button press in pushbutton_plotCorrelationCurves.
function pushbutton_plotCorrelationCurves_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
S=getappdata (handles.figure1, 'S');

set (v.allFigures, 'Visible', 'on')
gui_FCSrepresenta (S.FCSintervalos, S.Gintervalos, 1/S.binFreq, S.tipoCorrelacion, v.h_figIntervalos)
FCS_representa (S.FCSmean, S.Gmean, 1/S.binFreq, S.tipoCorrelacion, v.h_figPromedio);
promedioString='';
for n=1:numel(S.intervalosPromediados)
    promedioString=[promedioString num2str(S.intervalosPromediados(n)), ', '];
end
promedioString=promedioString(1:end-2); %Le quito la última ', '
set (v.h_figPromedio, 'NumberTitle', 'off', 'Name', ['Average: ' promedioString])


setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables



function edit_sections_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S');

if isfield (S, 'numSecciones')
    valorAnterior=S.numSecciones;
else
    valorAnterior=str2double(get(handles.edit_sections, 'String'));
end
S.numSecciones=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'S', S);


% --- Executes during object creation, after setting all properties.
function edit_sections_CreateFcn(hObject, eventdata, handles)



function edit_base_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S');

if isfield (S, 'base')
    valorAnterior=S.base;
else
    valorAnterior=str2double(get(handles.edit_base, 'String'));
end
S.base=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'S', S);


% --- Executes during object creation, after setting all properties.
function edit_base_CreateFcn(hObject, eventdata, handles)



function edit_pointsPerSection_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S');

if isfield (S, 'numPuntosSeccion')
    valorAnterior=S.numPuntosSeccion;
else
    valorAnterior=str2double(get(handles.edit_pointsPerSection, 'String'));
end
S.numPuntosSeccion=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'S', S);

% --- Executes during object creation, after setting all properties.
function edit_pointsPerSection_CreateFcn(hObject, eventdata, handles)


function edit_intervals_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S');

if isfield (S, 'numIntervalos')
    valorAnterior=S.numIntervalos;
else
    valorAnterior=str2double(get(handles.edit_intervals, 'String'));
end
S.numIntervalos=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'S', S);

% --- Executes during object creation, after setting all properties.
function edit_intervals_CreateFcn(hObject, eventdata, handles)



function edit_binningFrequency_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S');

if isfield (S, 'binFreq')
    valorAnterior=S.binFreq/1E-3;
else
    valorAnterior=str2double(get(handles.edit_binningFrequency, 'String'));
end
S.binFreq=1000*compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'S', S);


% --- Executes during object creation, after setting all properties.
function edit_binningFrequency_CreateFcn(hObject, eventdata, handles)


function edit_maximumTauLag_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S');

if isfield (S, 'tauLagMax')
    valorAnterior=S.tauLagMax/1000;
else
    valorAnterior=str2double(get(handles.edit_maximumTauLag, 'String'));
end
S.tauLagMax=compruebayactualizaedit(hObject, 0, Inf, valorAnterior)/1000;
setappdata (handles.figure1, 'S', S);



% --- Executes during object creation, after setting all properties.
function edit_maximumTauLag_CreateFcn(hObject, eventdata, handles)



function edit_subIntervalsForUncertainty_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S');

if isfield (S, 'numSubIntervalosError')
    valorAnterior=S.numSubIntervalosError;
else
    valorAnterior=str2double(get(handles.edit_subIntervalsForUncertainty, 'String'));
end
S.numSubIntervalosError=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
setappdata (handles.figure1, 'S', S);


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
S=getappdata (handles.figure1, 'S');

if isfield (S, 'binLines')
    valorAnterior=S.binLines;
else
    valorAnterior=str2double(get(handles.edit_binningLines, 'String'));
end
S.binLines=compruebayactualizaedit(hObject, 0, Inf, valorAnterior);
S.binFreq=v.scannerFreq/S.binLines;
strBinFreq=sprintf('%3.2f', S.binFreq/1000);
set (handles.edit_binningFrequency, 'String', strBinFreq)
setappdata (handles.figure1, 'S', S);

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


% --- Executes on button press in pushbutton_averageFCSCurves.
function pushbutton_averageFCSCurves_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
S=getappdata (handles.figure1, 'S');

answer=inputdlg('Average FCS curves: ', 'Average', 1);
if not(isempty(answer))
    rangeString=answer{1};
    endPage=size (S.Gintervalos,3); %Esto debe ser igual que numIntervalos
    S.intervalosPromediados=pagerangeparser (rangeString, 1, endPage);
    usaSubIntervalosError=logical(S.numSubIntervalosError);
    [S.FCSmean S.Gmean]=FCS_promedio(S.Gintervalos, S.FCSintervalos, S.intervalosPromediados, usaSubIntervalosError);
    FCS_representa (S.FCSmean, S.Gmean, 1/S.binFreq, S.tipoCorrelacion, v.h_figPromedio);
    promedioString='';
    for n=1:numel(S.intervalosPromediados)
        promedioString=[promedioString num2str(S.intervalosPromediados(n)), ', '];
    end
    promedioString=promedioString(1:end-2); %Le quito la última ', '
    set (v.h_figPromedio, 'NumberTitle', 'off', 'Name', ['Average: ' promedioString])
end
setappdata (handles.figure1, 'S', S);


function cierraFigurasMalCerradas
h=findobj('CloseRequestFcn',@FigCloseRequestFcn);
set (h, 'CloseRequestFcn', 'closereq')
if h
    disp (['Closing previously opened figures ' num2str(h')])
end
close (h)



% --- Executes on button press in pushbutton_fitIndividualCurves.
function pushbutton_fitIndividualCurves_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
S=getappdata (handles.figure1, 'S');

if S.isScanning
    funStr='fitfcn_FCS_scanningTauD';
else
    funStr='fitfcn_FCS_3DTauD';
end

answer=inputdlg('Fit correlation curves: ', 'Choose curves to fit', 1);
rangeString=answer{1};
endPage=size (S.Gintervalos,3); %Esto debe ser igual que numIntervalos
S.fittedCurves=pagerangeparser (rangeString, 1, endPage);
for n=1:numel(S.fittedCurves)
    dataFit(n)=mat2cell(S.Gintervalos(:,:,S.fittedCurves(n)));
end
[allParam chi2 dataSetSelection fittingFunction Gmodel]=gui_FCSfit(dataFit, funStr, [], []);

setappdata (handles.figure1, 'S', S);
setappdata (handles.figure1, 'v', v);


% --- Executes on button press in pushbutton_fitAverage.
function pushbutton_fitAverage_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
S=getappdata (handles.figure1, 'S');

if S.isScanning
    funStr='fitfcn_FCS_scanningTauD';
else
    funStr='fitfcn_FCS_3DTauD';
end
[v.h_corrPromedio, v.h_resPromedio, ~, v.h_figPromedio]=FCS_representa_ajuste (S.FCSmean, S.Gmean, [], 1/S.binFreq, S.tipoCorrelacion, 1, v.h_figPromedio);

[allParam chi2 dataSetSelection fittingFunction Gmodel]=gui_FCSfit({S.Gmean}, funStr, v.h_corrPromedio, v.h_resPromedio);

setappdata (handles.figure1, 'v', v);



function edit_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_channel as a double


% --- Executes during object creation, after setting all properties.
function edit_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FigCloseRequestFcn (hObject, eventdata)
% Esta es la función que se ejecuta cuando alguien quiere cerrar una ventana que contiene imágenes
set (hObject, 'Visible', 'off')



function [S R]=loadrawFCSdata(fname, scannerFreq, handles)
%fname debe llevar el path
%S contiene los datos que guardaremos en el archivo .mat
%R contiene los datos raw con los que opera
S=load (fname, 'isScanning');
if S.isScanning
    disp ('Scanning FCS experiment')
    R=load (fname, 'TACrange', 'TACgain', 'photonArrivalTimes', 'isScanning', 'imgDecode', 'lineSync', 'pixelSync');
    macroTimeCol=4;
    microTimeCol=5;
    channelsCol=6;
    S.numChannelsAcquisition=numel(unique(R.photonArrivalTimes(:, channelsCol)));
    disp(['Number of acquisition channels: ' num2str(S.numChannelsAcquisition)])
    [R.imgBin, R.indLinesLS, R.indMaxCadaLinea, S.sigma2_5, S.timeInterval]=...
        FCS_align(R.photonArrivalTimes, R.imgDecode, R.lineSync, R.pixelSync);
    %imgBin, indLinesLS, indMaxCadaLinea están en R, por tanto no se
    %guardarán al darle a save, aunque están disponibles durante la sesión
    strT0=sprintf('%3.2f', S.timeInterval(1));
    strTf=sprintf('%3.2f', S.timeInterval(2));
    set(handles.edit_t0, 'String', strT0);
    set(handles.edit_tf, 'String', strTf);
    set(handles.edit_binningFrequency, 'Enable', 'off', 'String', '')
    S.binLines=1;
    set(handles.edit_binningLines, 'Enable', 'on', 'String', num2str(S.binLines))
    S.binFreq=scannerFreq/S.binLines;
    strBinFreq=sprintf('%3.2f', S.binFreq/1000);
    set (handles.edit_binningFrequency, 'String', strBinFreq)
    S.tauLagMax=5;
    set(handles.edit_maximumTauLag, 'String', num2str(S.tauLagMax/1E-3));
    S.numSecciones=2;
    set(handles.edit_sections, 'String', num2str(S.numSecciones));
    
else
    disp ('Point FCS experiment')
    R=load (fname, 'TACrange', 'TACgain', 'photonArrivalTimes', 'isScanning');
    macroTimeCol=1;
    microTimeCol=2;
    channelsCol=3;
    S.numChannelsAcquisition=numel(unique(R.photonArrivalTimes(:, channelsCol)));
    disp(['Number of acquisition channels: ' num2str(S.numChannelsAcquisition)])
    set(handles.edit_binningLines, 'Enable', 'off', 'String', '')
    
end
S.acqTime=R.photonArrivalTimes(end, macroTimeCol)+R.photonArrivalTimes(end, microTimeCol)-(R.photonArrivalTimes(1, macroTimeCol)+R.photonArrivalTimes(1, microTimeCol));
strAcqTime=sprintf('%3.2f', S.acqTime);
set(handles.edit_acquisitionTime, 'String', strAcqTime);
%    save ([path FileName(1:end-4) '_tmp.mat'], '-struct', 'S')

function [S FCS_intervalos]=computecorrelation (S_in, R, handles)

S=S_in;
if S.isScanning
    macroTimeCol=4;
    microTimeCol=5;
    channelsCol=6;
    S.binLines=str2double(get(handles.edit_binningLines, 'String'));
else
    macroTimeCol=1;
    microTimeCol=2;
    channelsCol=3;
    S.binFreq=1000*str2double(get(handles.edit_binningFrequency, 'String'));
end

S.numIntervalos=str2double(get(handles.edit_intervals, 'String'));
S.numSubIntervalosError=str2double(get(handles.edit_subIntervalsForUncertainty, 'String'));
S.tauLagMax=str2double(get(handles.edit_maximumTauLag, 'String'))/1000;
S.numSecciones=str2double(get(handles.edit_sections, 'String'));
S.base=str2double(get(handles.edit_base, 'String'));
S.numPuntosSeccion=str2double(get(handles.edit_pointsPerSection, 'String'));
S.tipoCorrelacion='cross';
if get (handles.radiobutton_auto, 'Value')
    S.tipoCorrelacion='auto';
    S.channel=str2double(get(handles.edit_channel, 'String'));
end
if get (handles.radiobutton_cross, 'Value')
    S.tipoCorrelacion='cross';
    S.channel=3;
end

set (handles.figure1,'Pointer','watch')
drawnow update
disp ('Computing correlation')
tic;
if S.isScanning
    [S.FCSintervalos, S.Gintervalos, S.FCSmean, S.Gmean, S.cps, S.tData, S.binFreq]=...
        FCS_computecorrelation (R.photonArrivalTimes, S.numIntervalos, S.binLines, S.tauLagMax, S.numSecciones, S.numPuntosSeccion, S.base, S.numSubIntervalosError, S.tipoCorrelacion, ...
        R.imgBin, R.lineSync, R.indLinesLS, R.indMaxCadaLinea, S.sigma2_5);
    strBinFreq=sprintf('%3.2f', S.binFreq/1000); %Actualiza el binFreq. esto debería hacerlo solo desde el principio.
    set (handles.edit_binningFrequency, 'String', strBinFreq);
else
    [S.FCSintervalos, S.Gintervalos, S.FCSmean, S.Gmean, S.cps, S.tData]=...
        FCS_computecorrelation (R.photonArrivalTimes, S.numIntervalos, S.binFreq, S.tauLagMax, S.numSecciones, S.numPuntosSeccion, S.base, S.numSubIntervalosError, S.channel);
    %Esto para cada intervalo
    %[S.FCSTraza, S.tTraza]=FCS_calculabinstraza(FCSData, deltaT, 0.01);
end
tdecode=toc;
disp (['Correlation time: ' num2str(tdecode) ' s'])
S.intervalosPromediados=1:S.numIntervalos; %Al principio promediamos todos



% --------------------------------------------------------------------
function menu_decodeRawData_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables

[FileName,PathName, FilterIndex] = uigetfile({'*.spc'},'Choose the raw data file', v.path);
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(FileName)
    v.path=PathName;
    R.rawFile=[PathName FileName];
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['...' R.rawFile(pos:end-4)];
    set (handles.figure1, 'Name' , nombreFCSData)
    rmappdata (handles.figure1, 'S'); %Hace espacio para las siguientes
    rmappdata (handles.figure1, 'R');
    [S.isScanning, R.photonArrivalTimes, R.TACrange, R.TACgain, imgDecode, frameSync, lineSync, pixelSync] = FCS_load(R.rawFile);
    if S.isScanning
        R.imgDecode=imgDecode;
        R.frameSync=frameSync;
        R.lineSync=lineSync;
        R.pixelSync=pixelSync;
    end
end

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', R); %Guarda los cambios en variables
setappdata(handles.figure1, 'v', S);
%[isScanning, photonArrivalTimes, TACrange, TACgain, imgDecode, frameSync, lineSync, pixelSync] = FCS_load(fname)
%
% Para point FCS
% [isScanning, photonArrivalTimes, TACrange, TACgain]= FCS_load(fname)




% --------------------------------------------------------------------
function menu_saveFCSAnalysis_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
S=getappdata (handles.figure1, 'S'); %Recupera variables

posName=find(v.fname=='\', 1, 'last')+1;
fname=v.fname(posName:end);
posName=strfind(fname, '_raw');
if posName
    fname=[fname(1:posName-1) '.mat'];
end
[fname, v.path] = uiputfile({'*.mat'},'Save FCS file', [v.path fname]);
set (handles.figure1,'Pointer','watch')
drawnow update

if fname
    disp (['Saving ' v.path fname])
    if exist([v.path fname], 'file')
        save ([v.path fname], '-struct', 'S', '-append')
    else
        save ([v.path fname], '-struct', 'S')
    end
    disp ('OK')
end
set (handles.figure1,'Pointer','arrow')

% --------------------------------------------------------------------
function menu_saveForPyCorrFit_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v');
S=getappdata (handles.figure1, 'S');
set (handles.figure1,'Pointer','watch')
drawnow update
%FCS_savePyCorrformat(S.Gintervalos, S.FCSintervalos, S.binFreq, [v.path S.fname]);
FCS_savePyCorrformat(S.Gmean, S.FCSmean, S.binFreq, [v.path S.fname]);
set (handles.figure1,'Pointer','arrow')


% --------------------------------------------------------------------
function menu_saveAsASCII_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v');
S=getappdata (handles.figure1, 'S');
set (handles.figure1,'Pointer','watch')
drawnow update
FCS_G2ASCII (v.fname, S.channel, S.intervalosPromediados, S.Gmean);
set (handles.figure1,'Pointer','arrow')
drawnow update
disp ('OK')

% --------------------------------------------------------------------
function menu_batchConvertToASCII_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
pathName = uigetdirJava(v.path, 'Choose folder');
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(pathName)
    v.path=[pathName '\'];
    d=dir([v.path '*.mat']);
    numFiles=numel(d);
    disp (['Saving ' num2str(numFiles) ' files as ASCII'])
    for n=1:numFiles;
        disp ([num2str(numFiles+1-n) ' files left'])
        fname=d(n).name;
        disp (['Loading ' v.path fname])
        S=load ([v.path fname], 'channel', 'intervalosPromediados', 'Gmean', 'tipoCorrelacion');
        FCS_G2ASCII ([v.path fname], S.channel, S.intervalosPromediados, S.Gmean, S.tipoCorrelacion);
        disp ('OK')
    end
    disp ('Finished converting to ASCII')
end
set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --------------------------------------------------------------------
function menu_loadRawFCSData_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
[FileName,PathName, FilterIndex] = uigetfile({'*.mat'},'Choose your FCS file', v.path);
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(FileName)
    v.path=PathName;
    disp (['Loading ' FileName])
    v.fname=[v.path FileName];
    rmappdata (handles.figure1, 'S');
    if isappdata (handles.figure1, 'R')
        rmappdata (handles.figure1, 'R');
    end
    [S R]=loadrawFCSdata(v.fname, v.scannerFreq, handles);
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['anaFCS - ...' v.fname(pos:end-4)];
    set (handles.figure1, 'Name' , nombreFCSData)
    disp ('OK')
end

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables
setappdata(handles.figure1, 'R', R);
setappdata(handles.figure1, 'S', S);

% --------------------------------------------------------------------
function menu_computecorrelation_Callback(hObject, eventdata, handles)
S=getappdata (handles.figure1, 'S'); %Recupera variables
R=getappdata (handles.figure1, 'R'); %Recupera variables

set (handles.figure1,'Pointer','watch')
drawnow update
S=computecorrelation (S, R, handles);
disp ('OK')
set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'S', S); %Guarda los cambios en variables


% --------------------------------------------------------------------
function menu_batchCorrelate_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
pathName = uigetdirJava(v.path, 'Choose folder');
if ischar(pathName)
    answer=inputdlg('Enter name tail that will be added to the filename', 'Filename');
    nameTail=['_' answer{1}];
    set (handles.figure1,'Pointer','watch')
    drawnow update
    v.path=[pathName '\'];
    d=dir([v.path '*_raw.mat']);
    numFiles=numel(d);
    disp (['Correlating ' num2str(numFiles) ' files'])
    for n=1:numFiles;
        disp ([num2str(numFiles+1-n) ' files left'])
        fname=d(n).name;
        disp (['Loading ' v.path fname])
        R=struct([]); %Libera memoria antes de cargar matrices inmensas
        S=struct([]);
        [S R]=loadrawFCSdata([v.path fname], v.scannerFreq, handles);
        S=computecorrelation (S, R, handles);
        S=orderfields(S);
        fname=[fname(1:end-8) nameTail '.mat'];
        disp(['Saving ' v.path fname])
        if exist([v.path fname], 'file')
            save ([v.path fname], '-struct', 'S', '-append')
        else
            save ([v.path fname], '-struct', 'S')
        end
        disp ('OK')
    end
    disp ('Finished correlating')
end
set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --------------------------------------------------------------------
function menu_batchDecode_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
S=getappdata (handles.figure1, 'S'); %Recupera variables

pathName = uigetdirJava(v.path, 'Choose folder');
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(pathName)
    v.path=[pathName '\'];
    d=dir([v.path '*.spc']);
    numFiles=numel(d);
    disp (['Decoding ' num2str(numFiles) ' files'])
    for n=1:numFiles;
        disp ([num2str(numFiles+1-n) ' files left'])
        fileName=d(n).name;
        S.rawFile=[v.path fileName];
        pos=find(v.path=='\', 2, 'last');
        nombreFCSData=['...' S.rawFile(pos:end-4)];
        set (handles.figure1, 'Name' , nombreFCSData)
        FCS_load(S.rawFile);
    end
    disp ('Finished decoding')
end

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables
setappdata(handles.figure1, 'S', S);


% --- Executes when selected object is changed in uipanel_uncertainty.
function uipanel_uncertainty_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_uncertainty
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

vv=getappdata (handles.figure1, 'v'); %Recupera variables
S=getappdata (handles.figure1, 'S');

if get(handles.radiobutton_subIntervalsSEM, 'Value')
    S.numSubIntervalosError=v.numSubIntervalosError_anterior;
    set(handles.edit_subIntervalsForUncertainty, 'String', num2str(S.numSubIntervalosError));
    set(handles.edit_subIntervalsForUncertainty, 'Enable', 'on');
end
if get(handles.radiobutton_averageSEM, 'Value')
    v.numSubIntervalosError_anterior=S.numSubIntervalosError;
    S.numSubIntervalosError=0;
    set(handles.edit_subIntervalsForUncertainty, 'String', '0', 'Enable', 'off');
end

setappdata(handles.figure1, 'S', S); %Guarda los cambios en variables
