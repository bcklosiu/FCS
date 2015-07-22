function varargout = gui_FCSrepresenta(varargin)
%gui_FCSrepresenta (FCSIntervalos, tTraza, Gintervalos, intervalosPromediados, cps, tipoCorrelacion, hfig)
%
%   FCSIntervalos es la traza de adquisición en intervalos. Tiene todos los intervalos que queramos representar
%   tTraza es el tiempo de los FCSIntervalos. En general corresponde a 0.01s
%   GIntervalos es la función de correlacion en intervalos

% jri 21Jul15

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

set (hObject, 'CloseRequestFcn', @figure1_CloseRequestFcn)


variables.FCSIntervalos=varargin{1};
variables.tTraza=varargin{2};
variables.GIntervalos=varargin{3};
variables.intervalosPromediados=varargin{4};
variables.cps=varargin{5};
variables.tipoCorrelacion=varargin{6};
variables.hfig=varargin{7};

variables.showing=variables.intervalosPromediados(1); %Este es el intervalo que está mostrando
set (handles.edit_showingCurve, 'String', num2str(variables.showing))


[variables.hinf variables.hsup variables.hfig]=...
    FCS_representa (variables.FCSIntervalos(:, :,variables.showing), variables.tTraza, variables.GIntervalos(:, :, variables.showing), variables.cps, variables.tipoCorrelacion, variables.hfig);
set (variables.hfig, 'Visible', 'on', 'NumberTitle', 'off', 'Name', ['Curve: ' num2str(variables.showing)])
setappdata (handles.figure1, 'v', variables);  %Convierte v en datos de la aplicación con el nombre v

% Choose default command line output for gui_FCSrepresenta
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_FCSrepresenta wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_FCSrepresenta_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
v=getappdata (handles.figure1, 'v'); %Recupera variables

set (v.hfig, 'Visible', 'off')
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on button press in pushbutton_retrocedeImagen.
function pushbutton_retrocedeImagen_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_retrocedeImagen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v=getappdata (handles.figure1, 'v'); %Recupera variables

v.showing=v.showing-1;
if v.showing>v.intervalosPromediados(1)-1
    set (handles.edit_showingCurve, 'String', num2str(v.showing))
    [v.hinf v.hsup v.hfig]=...
        FCS_representa (v.FCSIntervalos(:, :,v.showing), v.tTraza, v.GIntervalos(:, :, v.showing), v.cps, v.tipoCorrelacion, v.hfig);
    set (v.hfig, 'NumberTitle', 'off', 'Name', ['Curve: ' num2str(v.showing)])
else
    v.showing=v.intervalosPromediados(1);
end
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --- Executes on button press in pushbutton_avanzaImagen.
function pushbutton_avanzaImagen_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_avanzaImagen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v=getappdata (handles.figure1, 'v'); %Recupera variables

v.showing=v.showing+1;
if v.showing<v.intervalosPromediados(end)+1
    set (handles.edit_showingCurve, 'String', num2str(v.showing))
    [v.hinf v.hsup v.hfig]=...
        FCS_representa (v.FCSIntervalos(:, :,v.showing), v.tTraza, v.GIntervalos(:, :, v.showing), v.cps, v.tipoCorrelacion, v.hfig);
    set (v.hfig, 'NumberTitle', 'off', 'Name', ['Curve: ' num2str(v.showing)])
else
    v.showing=v.intervalosPromediados(end);
end

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


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume (handles.figure1)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
