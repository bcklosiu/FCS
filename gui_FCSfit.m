function varargout = gui_FCSfit(varargin)
% [allParam chi2 dataSetSelection fittingFunction Gmodel]=gui_FCSfit(expData, fittingFunction, FCSdata, h_fitAxes, h_resAxes)
% expData es una celda con los datos experimales:
%   expData{1}={xdata1, ydata1, errdata1}
%   expData{N}={xdataN, ydataN, errdataN}
% FCSTraza es FCSData con un bin de 0.001 o 0.005 para poder representarla con facilidad
%fittingFunction es la función (por ahora sólo string)
%h_fig son los ejes de la gráfica en la que representa (puede estar vacío)
%
%
% jri - 12-Feb-2015

% Last Modified by GUIDE v2.5 10-Feb-2015 15:08:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_FCSfit_OpeningFcn, ...
    'gui_OutputFcn',  @gui_FCSfit_OutputFcn, ...
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


% --- Executes just before gui_FCSfit is made visible.
function gui_FCSfit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_FCSfit (see VARARGIN)



% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
ScreenUnits=get(0,'Units');
set(0,'Units','pixels');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',ScreenUnits);
if isempty(gcbf)
    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
        GCBFPos(2) - FigHeight];
end

set (handles.radiobutton_globalFit, 'Enable', 'off')
%set (handles.pushbutton_done, 'Enable', 'off')

v.globalFit=false;
v.numDataSets=numel(varargin{1});
v.data=varargin{1};
v.fittingFunctionName=varargin{2};
v.h_fitAxes=varargin{3}; %Handle a los ejes del ajuste
v.h_resAxes=varargin{4}; %Handle a los ejes de los residuos

v.dataSetSelection=true(v.numDataSets,1);
v.int_ajuste=zeros(v.numDataSets, 2);
for n=1:v.numDataSets
    v.int_ajuste(n, 1)=1;
    v.int_ajuste(n, 2)=size(v.data{n}, 1);
end




set (handles.edit_numDataSets, 'String', num2str(v.numDataSets))
set (handles.edit_chi2, 'String', '')

[v.paramName, v.paramUnits, v.numParam, v.fittingFunction]=parsefittingfunctionfile(v.fittingFunctionName);
set (handles.edit_fittingFunction, 'String', v.fittingFunctionName)
preparaParamTableVisible(v.globalFit, handles.table_fitParameters);
v.paramTable_allDataSets=inicializaParamTable(v.paramName, v.paramUnits, v.numParam, v.globalFit, v.numDataSets);
actualizaParamTableVisible(v.paramTable_allDataSets, v.paramName, v.paramUnits, v.numParam, v.globalFit, v.dataSetSelection, handles.table_fitParameters);

v.allParam=cell(v.numDataSets, 1);
v.Gmodel=cell(v.numDataSets, 1);
v.chi2=zeros(v.numDataSets, 1);


v.colores=linspecer(v.numDataSets);
%Inicializa plots
v.h_fitPlot=zeros(v.numDataSets, 1);
v.h_resPlot=zeros(v.numDataSets, 1);
v.h_dataPlot=zeros(v.numDataSets, 1);
[v.h_fig, v.h_fitAxes, v.h_resAxes, v.h_dataPlot, v.h_fitPlot, v.h_resPlot]=inicializaPlots (v.data, v.dataSetSelection, v.colores, v.h_fitAxes, v.h_resAxes, v.h_dataPlot, v.h_fitPlot, v.h_resPlot);

% v.colores(1,:)=[1 131 95]/255; %Verde
% v.colores(2,:)= [197 22 56]/255; %Rojo
% v.colores(3,:)= [0 102 204]/255; %Azul
% v.colores(4,:)= [50 50 50]/255; %Negro



setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables

% Choose default command line output for gui_FCSfit
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_FCSfit wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_FCSfit_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
v=getappdata (handles.figure1, 'v'); %Recupera variables

varargout{1} = v.allParam;
varargout{2} = v.chi2;
varargout{3} = v.dataSetSelection;
varargout{4} = v.fittingFunction;
varargout{5} = v.Gmodel;
varargout{6} = handles.output;
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables
delete(hObject);



function edit_numDataSets_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numDataSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_numDataSets as text
%        str2double(get(hObject,'String')) returns contents of edit_numDataSets as a double


% --- Executes during object creation, after setting all properties.
function edit_numDataSets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numDataSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fittingFunction_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fittingFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fittingFunction as text
%        str2double(get(hObject,'String')) returns contents of edit_fittingFunction as a double


% --- Executes during object creation, after setting all properties.
function edit_fittingFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fittingFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_fit.
function pushbutton_fit_Callback(hObject, eventdata, handles)
% handles    structure with handles and user data (see GUIDATA)
v=getappdata (handles.figure1, 'v'); %Recupera variables

set (handles.pushbutton_done, 'Enable', 'on')
set (handles.figure1,'Pointer','watch')
drawnow update

%FUN está definida en parsefittingfunctionfile(v.fittingFunctionName);

idxdatasets=find(v.dataSetSelection);
numDataSetsAjuste=numel(idxdatasets);
paramTable=get (handles.table_fitParameters, 'Data');

for dataAjuste=1:numDataSetsAjuste
    
    Gdata=cell2mat(v.data(idxdatasets(dataAjuste)));
    xdata=Gdata(:,1);
    ydata=Gdata(:,2);
    yerr=Gdata(:,3);
    filasAllParam=1+(idxdatasets(dataAjuste)-1)*v.numparam:idxdatasets(dataAjuste)*v.numParam; %Las filas que contienen los parámetros del ajuste en allParam (y en paramTableAllDataSets)
    filasParamTable=1+(dataAjuste-1)*v.numParam:(dataAjuste*v.numParam); 
    %Estos parámetros los coge directamente de la tabla, por si han cambiado
    paramFijo=cell2mat(paramTable(filasParamTable, 5));
    paramLibre=not(paramFijo); %Esto son logical, recuerda
    valorparametro=cell2mat(paramTable(filasParamTable, 6));
    valorLB=cell2mat(paramTable(filasParamTable, 8));
    valorUB=cell2mat(paramTable(filasParamTable, 9));
    
    [fitParam, allParam, chi2, deltaAllParam, ymodel]=...
        fitcore (v.fittingFunction, v.numParam, xdata, ydata, yerr, paramLibre, valorparametro, valorLB, valorUB);
   
    %Mete los datos en la tabla que contiene todos los valores (paramTable_allDataSets)
    for n=1:v.numParam
        v.paramTable_allDataSets(filasAllParam(n), :)={paramTable{filasParamTable(n), 1}, v.paramName{n}, '', v.paramUnits{n},...
            paramFijo(n), allParam(n), deltaAllParam(n), valorLB(n), valorUB(n)};
    end
   
    v.allParam(idxdatasets(dataAjuste))={allParam};
    v.chi2(idxdatasets(dataAjuste))=chi2;
    v.Gmodel(idxdatasets(dataAjuste))={[xdata ymodel yerr]};
 
    % Esto tiene que salir de aquí más tarde. Cuidado con ydata!!
    set (0, 'CurrentFigure', v.h_fig)

    if v.h_fitPlot(idxdatasets(dataAjuste))
        delete(v.h_fitPlot(idxdatasets(dataAjuste)));
        delete(v.h_resPlot(idxdatasets(dataAjuste)));
        v.h_fitPlot(idxdatasets(dataAjuste))=0;
        v.h_resPlot(idxdatasets(dataAjuste))=0;
    end
    v.h_fitPlot(idxdatasets(dataAjuste))=plot (v.h_fitAxes, xdata*1000, ymodel, 'Color', v.colores(idxdatasets(dataAjuste), :), 'Linewidth', 2);
    v.h_resPlot(idxdatasets(dataAjuste))=plot (v.h_resAxes, xdata*1000, ymodel-ydata, 'Color', v.colores(idxdatasets(dataAjuste), :), 'Linewidth', 2);
    ylim(v.h_resAxes, 'auto')
   
end



%Actualiza la tabla de parámetros visible
actualizaParamTableVisible(v.paramTable_allDataSets, v.paramName, v.paramUnits, v.numParam, v.globalFit, v.dataSetSelection, handles.table_fitParameters)

%set (handles.edit_chi2, 'String', num2str(v.chi2));

    set (handles.figure1,'Pointer','arrow')
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


function edit_chi2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_chi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_chi2 as text
%        str2double(get(hObject,'String')) returns contents of edit_chi2 as a double


% --- Executes during object creation, after setting all properties.
function edit_chi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_chi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

%checkDoneState=get (handles.pushbutton_done, 'Enable');
%if strcmpi (checkDoneState, 'on')
uiresume(hObject);
%end


% --- Executes on button press in pushbutton_fittingFunction.
function pushbutton_fittingFunction_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fittingFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v=getappdata (handles.figure1, 'v'); %Recupera variables

v.fittingFunctionName=get (handles.edit_fittingFunction, 'String');
[v.paramName, v.paramUnits, v.numParam, v.fittingFunction]=parsefittingfunctionfile(v.fittingFunctionName);
set (handles.edit_fittingFunction, 'String', v.fittingFunctionName)

preparaParamTableVisible(v.globalFit, handles.table_fitParameters);
v.paramTable_allDataSets=inicializaParamTable(v.paramName, v.paramUnits, v.numParam, v.globalFit, v.numDataSets);
actualizaParamTableVisible(v.paramTable_allDataSets, v.paramName, v.paramUnits, v.numParam, v.globalFit, v.dataSetSelection, handles.table_fitParameters);
v.allParam=cell(v.numDataSets, 1);
v.Gmodel=cell(v.numDataSets, 1);

setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables

function infoColumns=preparaParamTableVisible(globalFit, h_tabla)
%Prepara la tabla con títulos y la limpia antes de empezar a rellenarla
%infoColumns=get (h_organelleTableGUI.uitable_organelleAnalysis, 'ColumnName'); %La primera fila contiene los nombres de las columnas. En el futuro la segunda podrá contener las unidades, comentarios, etc

if globalFit
    infoColumns={'Dataset', 'Parameter', 'Meaning', 'Units',...
        'Share', 'Fix', 'Value', 'Error', ...
        'Lower bound', 'Upper bound'};
    columnFormat={'numeric', 'char', 'char', 'char',...
        'logical', 'logical', 'numeric', 'numeric', ...
        'numeric', 'numeric'};
    columnEditable= logical([0, 0, 0, 0, 1, 1, 1, 0, 1, 1]);
    
else
    infoColumns={'Dataset', 'Parameter', 'Meaning', 'Units',...
        'Fix', 'Value', 'Error', ...
        'Lower bound', 'Upper bound'};
    columnFormat={'numeric', 'char', 'char', 'char',...
        'logical', 'numeric', 'numeric', ...
        'numeric', 'numeric'};
    columnEditable= logical([0, 0, 0, 0, 1, 1, 0, 1, 1]);
end
set  (h_tabla, 'ColumnName', infoColumns)
set  (h_tabla, 'ColumnFormat', columnFormat)
set  (h_tabla, 'ColumnEditable', columnEditable)
set (h_tabla, 'Data', [])


% --- Executes when selected object is changed in uipanel_fit.
function uipanel_fit_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_fit
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

v=getappdata (handles.figure1, 'v'); %Recupera variables
if eventdata.NewValue==handles.radiobutton_globalFit
    v.globalFit=true;
else
    v.globalFit=false;
end
preparaParamTableVisible(v.globalFit, handles.table_fitParameters);
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables


% --- Executes on button press in pushbutton_dataSets.
function pushbutton_dataSets_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dataSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v=getappdata (handles.figure1, 'v'); %Recupera variables
[v.dataSetSelection, v.int_ajuste, v.numDataSets]=gui_FCSfit_choosedataset(v.data, v.int_ajuste, v.dataSetSelection, v.colores);
set (handles.edit_numDataSets, 'String', num2str(v.numDataSets));
actualizaParamTableVisible(v.paramTable_allDataSets, v.paramName, v.paramUnits, v.numParam, v.globalFit, v.dataSetSelection, handles.table_fitParameters);
[v.h_fig, v.h_fitAxes, v.h_resAxes, v.h_dataPlot, v.h_fitPlot, v.h_resPlot]=inicializaPlots (v.data, v.dataSetSelection, v.colores, v.h_fitAxes, v.h_resAxes, v.h_dataPlot, v.h_fitPlot, v.h_resPlot);
setappdata(handles.figure1, 'v', v); %Guarda los cambios en variables

function [fitparam, allParam, chi2, deltaAllParam, ymodel]=fitcore (FUN, numParam, xdata, ydata, yerr, paramlibre, valorparametro, valorLB, valorUB)

indparamvariables=[];
indparamfijos=[];
valorparamfijos=[];
numparamfijos=0;
numparamvariables=0;
guess=[];
LB=[];
UB=[];

%Falta definir el intervalo de ajuste v.int_ajuste

for n=1:numParam
    [guess LB UB numparamvariables numparamfijos indparamvariables indparamfijos valorparamfijos]=...
        check_fijoovariable (paramlibre(n), valorparametro(n), n, guess, LB, UB, valorLB(n), valorUB(n), numparamvariables, numparamfijos, indparamvariables, indparamfijos, valorparamfijos);
end


[fitparam, allParam, resnorm, resfun, EXITFLAG, OUTPUT, LAMBDA, jacob_mat]...
    = ajusta_lsqnonlin(FUN, guess, LB ,UB ,[], xdata, ydata, yerr, indparamvariables, indparamfijos, valorparamfijos);

[chi2 deltaParamFit ymodel] = ajusta_computeuncertainties (FUN, xdata, ydata, yerr, allParam, indparamvariables, jacob_mat); %Simplemente calcula el modelo y las incertidumbres del ajuste

deltaAllParam=zeros(1, numParam);
deltaAllParam(paramlibre)=deltaParamFit;

function paramTable_allDataSets=inicializaParamTable(paramName, paramUnits, numParam, globalFit, numTotalDataSets)

paramTable_allDataSets=cell(numTotalDataSets, 9); %Si no hay globalFit, creo que son sólo 10.
for dataAjuste=1:numTotalDataSets
    filasParam=1+(dataAjuste-1)*numParam:(dataAjuste*numParam);
    paramFijo=false(numParam ,1);
    valorParametro=zeros (numParam, 1);
    deltaParametro=zeros (numParam, 1);
    valorLB = -Inf*ones(numParam, 1);
    valorUB = Inf*ones(numParam, 1);
    for n=1:numParam
        paramTable_allDataSets(filasParam(n), :)={dataAjuste, paramName{n}, '', paramUnits{n}, paramFijo(n), valorParametro(n), deltaParametro(n), valorLB(n), valorUB(n)};
    end
end



function actualizaParamTableVisible(paramTable_allDataSets, paramName, paramUnits, numParam, globalFit, dataSetSelection, h_tabla)
%Rellena la tabla con las filas de los parámetros de los datasets que
%mostrará


idxdatasets=find(dataSetSelection);
numDataSetsAjuste=numel(idxdatasets);
paramTable=cell(numDataSetsAjuste, 9); %Si no hay globalFit, creo que son sólo 9


for dataAjuste=1:numDataSetsAjuste
    filasParam=1+(idxdatasets(dataAjuste)-1)*numParam:idxdatasets(dataAjuste)*numParam; %Las filas que contienen los parámetros del ajuste
    
    paramFijo=cell2mat(paramTable_allDataSets(filasParam, 5));
    valorParam=cell2mat(paramTable_allDataSets(filasParam, 6));
    deltaParam=cell2mat(paramTable_allDataSets(filasParam, 7));
    valorLB=cell2mat(paramTable_allDataSets(filasParam, 8));
    valorUB=cell2mat(paramTable_allDataSets(filasParam, 9));
    chi2=cell2mat(paramTable_allDataSets(filasParam, 6));
    filasParam_new=1+(dataAjuste-1)*numParam:(dataAjuste*(numParam)); %Las filas que contienen los parámetros del ajuste
    for n=1:numParam
        paramTable(filasParam_new(n), :)={paramTable_allDataSets{filasParam(n), 1}, paramName{n}, '', paramUnits{n},...
            paramFijo(n), valorParam(n), deltaParam(n), valorLB(n), valorUB(n)};
    end

end

set (h_tabla, 'Data', paramTable)


function [h_fig, h_fitAxes, h_resAxes, h_dataPlot, h_fitPlot, h_resPlot]=inicializaPlots (dataSet, dataSetSelection, colores, h_fitAxes_in, h_resAxes_in, h_dataPlot_in, h_fitPlot_in, h_resPlot_in)
% Borra o dibuja los puntos y las líneas de los datasets que están activados en cada momento
h_fitAxes=h_fitAxes_in;
h_resAxes=h_resAxes_in;
h_dataPlot=h_dataPlot_in;
h_fitPlot=h_fitPlot_in;
h_resPlot=h_resPlot_in;

idxdatasets=find(dataSetSelection);
numDataSetsAjuste=numel(idxdatasets);
numTotalDataSets=numel(dataSet);

if isempty(h_fitAxes)
    h_fig=figure;
    h_fitAxes=subplot (2, 1, 1);
    h_resAxes=subplot (2, 1, 2);
else
    h_fig=get (h_fitAxes, 'Parent');
%    cla (h_fitAxes)
%    cla (h_resAxes)
end

hold (h_fitAxes, 'on')
hold (h_resAxes, 'on')

for n=1:numTotalDataSets
    if h_dataPlot(n)
        delete(h_dataPlot(n));
    end
    if and(h_fitPlot(n), not(dataSetSelection(n)))
        delete(h_fitPlot(n));
        delete(h_resPlot(n));
        h_fitPlot(n)=0;
        h_resPlot(n)=0;
    end
end



h_dataPlot=zeros(numTotalDataSets, 1); 
for dataAjuste=1:numDataSetsAjuste
    Gdata=cell2mat(dataSet(idxdatasets(dataAjuste)));
    xdata=Gdata(:,1);
    ydata=Gdata(:,2);
    yerr=Gdata(:,3);
    set(0, 'CurrentFigure', h_fig)
    set(h_fig, 'CurrentAxes', h_fitAxes)
    h_dataPlot(idxdatasets(dataAjuste))=errorbar(xdata*1000, ydata, yerr, 'o', 'Color', colores(idxdatasets(dataAjuste), :), 'Linewidth', 2);
end

set ([h_fitAxes, h_resAxes], 'Xscale', 'log')



