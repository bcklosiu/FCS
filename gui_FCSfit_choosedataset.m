function varargout = gui_FCSfit_choosedataset(varargin)
%[dataSelection, intervaloAjuste, numDataSetsAjuste]=gui_FCSfit_choosedataset(data, rangoAjuste, dataSelection, colores)
%
% Escoge las funciones que serán ajustadas.
% Permite cambiar el intervalo de ajuste
%
%
% jri - 9-Feb-2015

% Edit the above text to modify the response to help gui_FCSfit_choosedataset

% Last Modified by GUIDE v2.5 10-Feb-2015 12:26:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_FCSfit_choosedataset_OpeningFcn, ...
    'gui_OutputFcn',  @gui_FCSfit_choosedataset_OutputFcn, ...
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


% --- Executes just before gui_FCSfit_choosedataset is made visible.
function gui_FCSfit_choosedataset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_FCSfit_choosedataset (see VARARGIN)





numDataSets=numel(varargin{1});
%dataSelection=true(numDataSets,1);
%dataFitColors=linspecer(numDataSets);
v.data=varargin{1};
intervaloAjuste=varargin{2};
dataSelection=varargin{3};
dataFitColors=varargin{4};
preparatablas (handles.uitable_dataSets, handles.uitable_colores)


for n=1:numDataSets
    dataTmp=cell2mat(v.data(n));
    xdata=dataTmp(:,1);
    ydata=dataTmp(:,2);
    yerr=dataTmp(:,3);
    n0=intervaloAjuste(n, 1);
    nf=intervaloAjuste(n, 2);
    dataTabla(n,:)={n, '',  numel(xdata), n0, nf, xdata(n0), xdata(nf), ydata(n0), ydata(nf), dataSelection(n)};
    dataColors(n,:)={' '};
end

set (handles.uitable_dataSets, 'Data', dataTabla);

%Colores de la tabla
fgcols = floor(255 * [1 1 1]);
bgcols = floor(255 * dataFitColors);

numfmt = '%g';
desiredcellwid=1000;

for n=1:numDataSets
 colprestr = sprintf('<HTML><TABLE><TD color="rgb(%d,%d,%d)" bgcolor="rgb(%d,%d,%d)">', fgcols(1,:), bgcols(n,:));
  Tcol=cellstr(' · ');
  Tcol= cellfun(@(s) [blanks(desiredcellwid - length(s)), s], Tcol, 'Uniform', 0);
  Tcol= strcat( colprestr, regexprep(Tcol, ' ', ' ') );
  dataColors(n, :)=Tcol;
end
  
set (handles.uitable_colores, 'Data', dataColors)



setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% Choose default command line output for gui_FCSfit_choosedataset
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_FCSfit_choosedataset wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_FCSfit_choosedataset_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% v=getappdata (handles.figure1, 'v'); %Recupera variables
%

dataTabla=get(handles.uitable_dataSets, 'Data');
intervaloAjuste=zeros(size(dataTabla,1), 2);
intervaloAjuste(:,1)=cell2mat(dataTabla(:, 4));
intervaloAjuste(:,2)=cell2mat(dataTabla(:, 5));
dataFitChoice=cell2mat(dataTabla(:, 10));
varargout{1} = dataFitChoice;
varargout{2} = intervaloAjuste;
varargout{3} = numel(find(dataFitChoice));
varargout{4} = handles.output;

delete(hObject);


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)

uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

uiresume(hObject);


function preparatablas (h_datos, h_colores)

infoColumns={'Dataset', 'Name', 'N', 'n0', 'nf', 'x(n0)', 'x(nf)', 'y(n0)', 'y(nf)', 'Fit'};
columnFormat={'numeric', 'char', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'logical'};
columnEditable= logical([0, 0, 0, 1, 1, 0, 0, 0, 0, 1]);
set  (h_datos, 'ColumnName', infoColumns)
set  (h_datos, 'ColumnFormat', columnFormat)
set  (h_datos, 'ColumnEditable', columnEditable)
set (h_datos, 'Data', {});

infoColumns={'Colour'};
columnFormat={'char'};
columnEditable= logical(0);

set  (h_colores, 'ColumnName', infoColumns)
set  (h_colores, 'ColumnFormat', columnFormat)
set  (h_colores, 'ColumnEditable', columnEditable)

set (h_colores, 'Data', {});


% --- Executes when entered data in editable cell(s) in uitable_dataSets.
function uitable_dataSets_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable_dataSets (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

v=getappdata (handles.figure1, 'v'); %Recupera variables
n=eventdata.Indices(1);
columna=eventdata.Indices(2);
if or(columna==4, columna==5)
    n=eventdata.Indices(1);
    dataTabla=get (handles.uitable_dataSets, 'Data');
    
    dataTmp=cell2mat(v.data(n));
    xdata=dataTmp(:,1);
    ydata=dataTmp(:,2);
    yerr=dataTmp(:,3);
    n0=dataTabla{n, 4};
    nf=dataTabla{n, 5};
    dataSelection=dataTabla{n, 10};
    dataTabla(n,:)={n, '',  numel(xdata), n0, nf, xdata(n0), xdata(nf), ydata(n0), ydata(nf), dataSelection};
set (handles.uitable_dataSets, 'Data', dataTabla);
end
