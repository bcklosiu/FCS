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

% Last Modified by GUIDE v2.5 21-Apr-2015 21:30:29

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
set(handles.edit_binningFrequency, 'Enable', 'on') 
set(handles.edit_binningLines, 'Enable', 'off', 'String', '') 
set(handles.edit_channel, 'String', '1');
set(handles.radiobutton_auto, 'Value', true)

variables.h_figIntervalos=figure;
variables.h_figPromedio=figure;
variables.allFigures=[variables.h_figIntervalos variables.h_figPromedio];
set (variables.allFigures, 'NumberTitle' , 'off', 'Visible', 'off', 'DockControls', 'off', 'Color', [1 1 1])
set (variables.allFigures, 'CloseRequestFcn', @FigCloseRequestFcn)


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
[FileName,PathName, FilterIndex] = uigetfile({'*.mat'},'Choose your FCS file', v.path);
if ischar(FileName)
    set (handles.figure1,'Pointer','watch')
    drawnow update
    v.path=PathName;
    v.S=load ([v.path FileName], 'acqTime', 'numIntervalos', 'binFreq', 'numSubIntervalosError', 'tauLagMax', 'numSecciones', 'base', 'numPuntosSeccion', 'tipoCorrelacion',...
        'intervalosPromediados', 'FCSintervalos', 'Gintervalos', 'FCSmean', 'Gmean', 'isScanning');
    v.fname=[v.path FileName];
    if v.S.isScanning
        macroTimeCol=4;
        microTimeCol=5;
        channelsCol=6;
    else
        macroTimeCol=1;
        microTimeCol=2;
        channelsCol=3;
    end
    if not(isfield(v.S, 'acqTime'))
        v.S.acqTime=0;
    end
    if not(isfield(v.S, 'intervalosPromediados')) %Para archivos viejos. Si no se indican los intervalos promediados, se promedian todos
        v.S.intervalosPromediados=1:v.S.numIntervalos; 
    end
    
    %acqTime=v.S.photonArrivalTimes(end, macroTimeCol)+v.S.photonArrivalTimes(end, microTimeCol)-(v.S.photonArrivalTimes(1, macroTimeCol)+v.S.photonArrivalTimes(1, microTimeCol));
    strAcqTime=sprintf('%3.2f', v.S.acqTime);
    set(handles.edit_acquisitionTime, 'String', strAcqTime);
    set(handles.edit_intervals, 'String', num2str(v.S.numIntervalos));
    set(handles.edit_binningFrequency, 'String', num2str(v.S.binFreq/1E3));
    set(handles.edit_subIntervalsForUncertainty, 'String', num2str(v.S.numSubIntervalosError));
    set(handles.edit_maximumTauLag, 'String', num2str(v.S.tauLagMax/1E-3));
    set(handles.edit_sections, 'String', num2str(v.S.numSecciones));
    set(handles.edit_base, 'String', num2str(v.S.base));
    set(handles.edit_pointsPerSection, 'String', num2str(v.S.numPuntosSeccion));
    switch lower(v.S.tipoCorrelacion)
        case 'auto'
            set (handles.radiobutton_auto, 'Value', 1)
        case 'cross'
            set (handles.radiobutton_cross, 'Value', 1)
        case 'todas'
            set (handles.radiobutton_all, 'Value', 1)
    end
    
    for n=1:v.S.numIntervalos
        [~, ~, v.h_figIntervalos(n)]=FCS_representa (v.S.FCSintervalos(:,1,n), v.S.Gintervalos(:, :, n), 1/v.S.binFreq, v.S.tipoCorrelacion, 1); %Las ventana promedio va a ser la 500
        set (v.h_figIntervalos(n), 'NumberTitle', 'off', 'Name', ['Curve: ' num2str(n)])
    end
    %    set (v.h_figIntervalos, 'CloseRequestFcn', @FigCloseRequestFcn)
    [~, ~, v.h_figPromedio]=FCS_representa (v.S.FCSmean, v.S.Gmean, 1/v.S.binFreq, v.S.tipoCorrelacion, 1);
    promedioString='';
    for n=1:numel(v.S.intervalosPromediados)
        promedioString=[promedioString num2str(v.S.intervalosPromediados(n)), ', '];
    end
    promedioString=promedioString(1:end-2); %Le quito la última ', '
    set (v.h_figPromedio, 'NumberTitle', 'off', 'Name', ['Average: ' promedioString])
    
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['...' v.fname(pos:end-4)];
    set (handles.figure1, 'Name' , ['anaFCS - ' nombreFCSData])
    set (handles.figure1,'Pointer','arrow')
    setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables
end

% --- Executes on button press in pushbutton_computeCorrelation.
function pushbutton_computeCorrelation_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
set (handles.figure1,'Pointer','watch')
drawnow update
v.S=computecorrelation (v.S, v.R, handles);
disp ('OK')
set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables




% --- Executes on button press in pushbutton_plotCorrelationCurves.
function pushbutton_plotCorrelationCurves_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables

set (v.allFigures, 'Visible', 'on')
gui_FCSrepresenta (v.S.FCSintervalos, v.S.Gintervalos, 1/v.S.binFreq, v.S.tipoCorrelacion, v.h_figIntervalos)
FCS_representa (v.S.FCSmean, v.S.Gmean, 1/v.S.binFreq, v.S.tipoCorrelacion, v.h_figPromedio);
promedioString='';
for n=1:numel(v.S.intervalosPromediados)
    promedioString=[promedioString num2str(v.S.intervalosPromediados(n)), ', '];
end
promedioString=promedioString(1:end-2); %Le quito la última ', '
set (v.h_figPromedio, 'NumberTitle', 'off', 'Name', ['Average: ' promedioString])


setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables




% --- Executes on button press in pushbutton_saveFCSData.
function pushbutton_saveFCSData_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables

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
    S=v.S;
    S=orderfields(S);
    if exist([v.path fname], 'file')
        save ([v.path fname], '-struct', 'S', '-append')
    else
        save ([v.path fname], '-struct', 'S')
    end
    disp ('OK')
end
set (handles.figure1,'Pointer','arrow')



% --- Executes on button press in pushbutton_saveForPyCorrFit.
function pushbutton_saveForPyCorrFit_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 
set (handles.figure1,'Pointer','watch')
drawnow update
%FCS_savePyCorrformat(v.S.Gintervalos, v.S.FCSintervalos, v.S.binFreq, [v.path v.S.fname]);
FCS_savePyCorrformat(v.S.Gmean, v.S.FCSmean, v.S.binFreq, [v.path v.S.fname]);
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
    v.fname=[v.path FileName];
    scannerFreq=1400;
    [v.S v.R]=loadrawFCSdata(v.fname, scannerFreq, handles);
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['anaFCS - ...' v.fname(pos:end-4)];
    set (handles.figure1, 'Name' , nombreFCSData)
    disp ('OK')
end

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --- Executes on button press in pushbutton_saveAsASCII.
function pushbutton_saveAsASCII_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 
set (handles.figure1,'Pointer','watch')
drawnow update
fileName=v.fname;
fileName=[fileName(1:end-4) '.dat'];
pos=find(fileName=='\', 1, 'last');
if isempty(pos)
    pos=0;
end
nombreFCSData=fileName(pos+1:end-4);
disp (['Saving ' nombreFCSData ' as ASCII'])
fid=fopen(fileName, 'w'); %Esto lo hice muy bien en genpol
fprintf(fid, '%s', datestr(now));
fprintf(fid, '\n%s', fileName);
fprintf(fid, '\nAveraged curves:\t');
fprintf(fid, '%d, ', v.S.intervalosPromediados);
fprintf(fid, '\n\n%s\t%s\t%s', 'time(ms)', 'G', 'Error');
fprintf(fid, '\n%f\t%f\t%f', [v.S.Gmean(:,1), v.S.Gmean(:,2), v.S.Gmean(:,3)]');
fclose (fid);

set (handles.figure1,'Pointer','arrow')
drawnow update
disp ('OK')

set (handles.figure1,'Pointer','arrow')




% --- Executes on button press in pushbutton_decodeRawData.
function pushbutton_decodeRawData_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
[FileName,PathName, FilterIndex] = uigetfile({'*.spc'},'Choose the raw data file', v.path);
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(FileName)
    v.path=PathName;
    v.S.rawFile=[PathName FileName];
    pos=find(v.path=='\', 2, 'last');
    nombreFCSData=['...' v.S.rawFile(pos:end-4)];
    set (handles.figure1, 'Name' , nombreFCSData)
    [v.S.isScanning, v.S.photonArrivalTimes, v.S.TACrange, v.S.TACgain, imgDecode, frameSync, lineSync, pixelSync] = FCS_load(v.S.rawFile);
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
strBinFreq=sprintf('%3.2f', v.S.binFreq/1000);
set (handles.edit_binningFrequency, 'String', strBinFreq)
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


% --- Executes on button press in pushbutton_averageFCSCurves.
function pushbutton_averageFCSCurves_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_averageFCSCurves (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v=getappdata (handles.figure1, 'v'); %Recupera variables

answer=inputdlg('Average FCS curves: ', 'Average', 1);
rangeString=answer{1};
endPage=size (v.S.Gintervalos,3); %Esto debe ser igual que numIntervalos
v.S.intervalosPromediados=pagerangeparser (rangeString, 1, endPage);

[v.S.FCSmean v.S.Gmean]=FCS_promedio(v.S.Gintervalos, v.S.FCSintervalos, v.S.intervalosPromediados, v.S.tipoCorrelacion);

[~, ~, v.h_figPromedio]=FCS_representa (v.S.FCSmean, v.S.Gmean, 1/v.S.binFreq, v.S.tipoCorrelacion);
promedioString='';
for n=1:numel(v.S.intervalosPromediados)
    promedioString=[promedioString num2str(v.S.intervalosPromediados(n)), ', '];
end
promedioString=promedioString(1:end-2); %Le quito la última ', '
set (v.h_figPromedio, 'NumberTitle', 'off', 'Name', ['Average: ' promedioString])

setappdata (handles.figure1, 'v', v);


function cierraFigurasMalCerradas
h=findobj('CloseRequestFcn',@FigCloseRequestFcn);
set (h, 'CloseRequestFcn', 'closereq')
if h
disp (['Closing previously opened figures ' num2str(h')])
end
close (h)

% function FigCloseRequestFcn (hObject, eventdata)
% % Esta es la función que se ejecuta cuando alguien quiere cerrar una
% % ventana que contiene imágenes
% set (hObject, 'CloseRequestFcn', 'closereq')
% close (hObject)
% v=getappdata (handles.figure1, 'v'); %Recupera variables
% v.S.intervalosPromediados(v.S.intervalosPromediados=1:v.S.numIntervalos;
% setappdata (handles.figure1, 'v', v);


% --- Executes on button press in pushbutton_fitIndividualCurves.
function pushbutton_fitIndividualCurves_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables

if v.S.isScanning
    funStr='fitfcn_FCS_scanningTauD';
else
    funStr='fitfcn_FCS_3DTauD';
end

answer=inputdlg('Fit correlation curves: ', 'Choose curves to fit', 1);
rangeString=answer{1};
endPage=size (v.S.Gintervalos,3); %Esto debe ser igual que numIntervalos
v.S.fittedCurves=pagerangeparser (rangeString, 1, endPage);
for n=1:numel(v.S.fittedCurves)
    dataFit(n)=mat2cell(v.S.Gintervalos(:,:,v.S.fittedCurves(n)));
end
[allParam chi2 dataSetSelection fittingFunction Gmodel]=gui_FCSfit(dataFit, funStr, [], []);


setappdata (handles.figure1, 'v', v);


% --- Executes on button press in pushbutton_fitAverage.
function pushbutton_fitAverage_Callback(hObject, eventdata, handles)

v=getappdata (handles.figure1, 'v'); %Recupera variables

if v.S.isScanning
    funStr='fitfcn_FCS_scanningTauD';
else
    funStr='fitfcn_FCS_3DTauD';
end
[v.h_corrPromedio, v.h_resPromedio, ~, v.h_figPromedio]=FCS_representa_ajuste (v.S.FCSmean, v.S.Gmean, [], 1/v.S.binFreq, v.S.tipoCorrelacion, 1, v.h_figPromedio);

[allParam chi2 dataSetSelection fittingFunction Gmodel]=gui_FCSfit({v.S.Gmean}, funStr, v.h_corrPromedio, v.h_resPromedio);

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
% Esta es la función que se ejecuta cuando alguien quiere cerrar una
% ventana que contiene imágenes
set (hObject, 'Visible', 'off')



% --- Executes on button press in pushbutton_batchDecodeRawData.
function pushbutton_batchDecodeRawData_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables
pathName = uigetdirJava(v.path, 'Choose folder');
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(pathName)
    v.path=[pathName '\'];
    d=dir('*.spc');
    numFiles=numel(d);
    disp (['Decoding ' num2str(numFiles) ' files'])
    for n=1:numFiles;
        disp ([num2str(numFiles+1-n) ' files left'])
        fileName=d(n).name;
        v.S.rawFile=[v.path fileName];
        pos=find(v.path=='\', 2, 'last');
        nombreFCSData=['...' v.S.rawFile(pos:end-4)];
        set (handles.figure1, 'Name' , nombreFCSData)
        FCS_load(v.S.rawFile);
    end
    disp ('Finished decoding')
end

set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables



% --- Executes on button press in pushbutton_batchCorrelate.
function pushbutton_batchCorrelate_Callback(hObject, eventdata, handles)

v=getappdata (handles.figure1, 'v'); %Recupera variables
pathName = uigetdirJava(v.path, 'Choose folder');
set (handles.figure1,'Pointer','watch')
drawnow update
if ischar(pathName)
    answer=inputdlg('Enter name tail that will be added to the filename', 'Filename');
    nameTail=['_' answer{1}];
    v.path=[pathName '\'];
    d=dir([v.path '*_raw.mat']);
    numFiles=numel(d);
    disp (['Correlating ' num2str(numFiles) ' files'])
    for n=1:numFiles;
        disp ([num2str(numFiles+1-n) ' files left'])
        fname=d(n).name;
        disp (['Loading ' v.path fname])
        scannerFreq=1400;
        [S R]=loadrawFCSdata([v.path fname], scannerFreq, handles);
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
    set(handles.edit_binningLines, 'Enable', 'off', 'String', '')
  
end
S.acqTime=R.photonArrivalTimes(end, macroTimeCol)+R.photonArrivalTimes(end, microTimeCol)-(R.photonArrivalTimes(1, macroTimeCol)+R.photonArrivalTimes(1, microTimeCol));
strAcqTime=sprintf('%3.2f', S.acqTime);
set(handles.edit_acquisitionTime, 'String', strAcqTime);
%    save ([path FileName(1:end-4) '_tmp.mat'], '-struct', 'S')

function S=computecorrelation (S_in, R, handles)

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
    [S.FCSintervalos, S.Gintervalos, S.FCSmean, S.Gmean, S.tData, S.binFreq]=...
        FCS_computecorrelation (R.photonArrivalTimes, S.numIntervalos, S.binLines, S.tauLagMax, S.numSecciones, S.numPuntosSeccion, S.base, S.numSubIntervalosError, S.tipoCorrelacion, ...
        R.imgBin, R.lineSync, R.indLinesLS, R.indMaxCadaLinea, S.sigma2_5);
    strBinFreq=sprintf('%3.2f', S.binFreq/1000); %Actualiza el binFreq. esto debería hacerlo solo desde el principio.
    set (handles.edit_binningFrequency, 'String', strBinFreq);
else
    [S.FCSintervalos, S.Gintervalos, S.FCSmean, S.Gmean, S.tData]=...
        FCS_computecorrelation (R.photonArrivalTimes, S.numIntervalos, S.binFreq, S.tauLagMax, S.numSecciones, S.numPuntosSeccion, S.base, S.numSubIntervalosError, S.channel);
end
tdecode=toc;
disp (['Correlation time: ' num2str(tdecode) ' s'])
S.intervalosPromediados=1:S.numIntervalos; %Al principio promediamos todos