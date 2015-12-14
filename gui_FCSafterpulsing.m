function varargout = gui_FCSafterpulsing(varargin)

% [tau_AP alfaCoeff OKbutton]=gui_FCSafterpulsing(tau_AP, alfaCoeff)

% jri & ULS - 26Oct15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_FCSafterpulsing_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_FCSafterpulsing_OutputFcn, ...
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

% --- Executes just before gui_FCSafterpulsing is made visible.
function gui_FCSafterpulsing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_FCSafterpulsing (see VARARGIN)

% Get default command line output from handles structure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject, 'Name', 'Correct for afterpulsing');


if nargin>3
    v.tau_AP=varargin{1};
    v.alfaCoeff=varargin{2};
else
    v.tau_AP=[];
end
v.tau_AP_old=v.tau_AP;
v.alfaCoeff_old=v.alfaCoeff;

if isempty(v.tau_AP) %Por si llega un argumento vacío
    v.tau_AP=[2.76574e-07, 1.75635e-07; 7.012010e-06, 3.917470e-06; 1E-30, 1.859350e-05];
    v.alfaCoeff=[5143.28,2.879463288e+04; 486.22, 732.09; 0, 459.790];
end


v.OKbutton=false; %Si se le da a OK entonces es true; si se cierra de otra forma es false

tabla_alfaCorr=num2cell([v.tau_AP; v.alfaCoeff]);
set (handles.uitable_alfaCorr, 'Data', tabla_alfaCorr);
setappdata (handles.figure1, 'v', v);  %Convierte variablesapl en datos de la aplicación con el nombre v

% UIWAIT makes gui_FCSafterpulsing wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = gui_FCSafterpulsing_OutputFcn(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); %Recupera variables

if v.OKbutton
    tabla_alfaCorr=get (handles.uitable_alfaCorr, 'Data');
    tau_AP=cell2mat(tabla_alfaCorr(1:3, :));
    alfaCoeff=cell2mat(tabla_alfaCorr(4:6, :));
    varargout{1}=tau_AP;
    varargout{2}=alfaCoeff;
else
    varargout{1}=v.tau_AP_old;
    varargout{2}=v.alfaCoeff_old;
end
varargout{3} = v.OKbutton;

delete(handles.figure1);


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


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    v.OKbutton=false;
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
        v.OKbutton=true;
    guidata(hObject, handles);

    uiresume(handles.figure1);
end    


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 
v.OKbutton=true;
setappdata (handles.figure1, 'v', v); 

uiresume(handles.figure1);

% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
v=getappdata (handles.figure1, 'v'); 
v.OKbutton=false;
setappdata (handles.figure1, 'v', v); 

uiresume(handles.figure1);


% --- Executes on button press in pushbutton_loadAPParamas.
function pushbutton_loadAPParamas_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadAPParamas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
