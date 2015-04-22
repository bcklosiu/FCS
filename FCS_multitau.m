function [G tdata]= FCS_multitau (FCSData, deltaT, numSecciones, numPuntosSeccion, base, tLagMax)
%
% [G  tdata]= FCS_multitau (FCSData, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion);
% Algorimo multitau para el cálculo de la función de autocorrelación/correlacion cruzada

% Sigue el algoritmo de Wohland_2001
%
%   FCSData contiene la traza temporal. FCSData puede ser un vector columna o una matriz de dos columnas, segun se quiera calcular la auto- o la cross-correlacion, respectivamente.
%   deltaT es el inverso de la frecuencia de muestreo,
%   numSecciones es el número de secciones de la función de autocorrelación
%   numPuntos es el número de puntos por sección 
%   base define la resolución temporal de cada sección: res_temporal=deltaT*(base^seccion)
%   tLagMax es el último punto temporal con el que se hace correlación, en s
%
% 26-10-2010
% 27abr11 - Modificado para que llame a los programas que calculan la
% correlacion en C++
%
% jri - 16May14 Ordenado un poco
% jri - 20Apr15 Quito los puntos que repite al calcular la correlación
% jri - 20Apr15 Quito tipoCorrelacio. Si FCSData tiene dos canales hace también la correlación cruzada


numData=size(FCSData, 1);
numSecciones=numSecciones+1; %Le ponemos una sección extra para añadir la cola logarítimca

%Calcula todos los puntos de cada sección en los que hará la correlación
%para evitar los puntos repetidos por sección
[tdataTodos matrizIndices indicesNOrepe]=calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tLagMax);
%Hace la correlación
[G tdata]=correlacionSeccion (FCSData, deltaT, numSecciones, numPuntosSeccion, base, numData, matrizIndices, indicesNOrepe, tdataTodos);


function [tdata matrizIndices indicesNOrepe]=calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tLagMax)
%Devuelve una matriz de índices no repetidos para luego calcular la correlación sólo en esos puntos

%Esto para las primeras numSecciones-1

tdata=zeros (numPuntosSeccion, numSecciones);
matrizIndices=zeros (numPuntosSeccion, numSecciones);
indicesNOrepe=false(size(tdata));

vectorIndices=1:numPuntosSeccion;
for seccion=1:numSecciones-1 %Hace una correlación por cada sección
    multiBase=base^(seccion-1);
    tdata(:, seccion)=calculatdata (vectorIndices, multiBase, deltaT);
    matrizIndices(:, seccion)=vectorIndices;
end

%Última sección:
%Calcula los puntos de la última sección expandiendo logarítmicamente la base de la sección anterior,
%puesto que la última sección la hemos añadido para expandir el final de la correlación logarítmicamente
%multiBase tiene el mismo valor que la última sección del bucle anterior.
numPuntos_ultimaSeccion=floor(tLagMax/(deltaT*multiBase)); %Esto es el numero de puntos que habria que calcular de la ultima seccion para correlacionar hasta tLagMax
vectorIndices=round(logspace (0, log10(numPuntos_ultimaSeccion), numPuntosSeccion));  % logspace genera un vector FILA
matrizIndices(:, seccion+1)=vectorIndices;
tdata(:, numSecciones)=calculatdata (vectorIndices, multiBase, deltaT);

%Ahora localizo los repetidos en tdata
[~, m]=unique(tdata(:), 'last');
indicesNOrepe(m)=true;

%[tdata_ordenado orden_tdata]=sort(tdata(indicesNOrepe));



function [G tdata]=correlacionSeccion (FCSData, deltaT, numSecciones, numPuntosSeccion, base, numData, matrizIndices, indicesNOrepe, tdataTodos)

numCanales=size(FCSData, 2);
numPuntosCorrTotal=numel(find(indicesNOrepe));
G=zeros (numPuntosCorrTotal, 1);
tdata_corr=zeros(numPuntosCorrTotal, 1);

tdata=tdataTodos(indicesNOrepe);

numPuntosCorrAcumula=0;
%Esto para las primeras numSecciones-1
for seccion=1:numSecciones-1 %Hace una correlación por cada sección
    multiBase=base^(seccion-1);
    vectorIndices=matrizIndices(indicesNOrepe(:, seccion), seccion);
    numPuntosCorrSeccion=numel(vectorIndices); %Número de puntos en la sección en los que se calculará la correlación
    numDataSeccion=floor(numData/multiBase); %Número de datos en cada sección que se usarán para calcular la correlacion
    if numDataSeccion <= numPuntosSeccion
        error('No hay puntos suficientes para calcular la correlación: %d', numDataSeccion)
    end
    if numCanales==1 %Autocorrelación
        FCSDataSeccion=zeros (numDataSeccion, 1, 'double');
        C_FCS_binning1(FCSDataSeccion, FCSData, multiBase);
        %{
            for n=1:numDataSeccion     %Hace el binning para cada sección según la base
                FCSDataSeccion(n)=sum(FCSData(((n-1)*multiBase+1:n*multiBase))); % Cuando es una autocorrelación
            end
        %}
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCS_autocorr_Cpp (FCSDataSeccion, multiBase*deltaT, vectorIndices);
    else %Correlación cruzada
        FCSDataSeccion=zeros (numDataSeccion, 2, 'double');
        C_FCS_binning1(FCSDataSeccion(:, 1), FCSData(:, 1), multiBase);
        C_FCS_binning1(FCSDataSeccion(:, 2), FCSData(:, 2), multiBase);
        %{
            for n=1:numDataSeccion     %Hace el binning para cada sección según la base
                FCSDataSeccion(n, 1)=sum(FCSData(((n-1)*multiBase+1:n*multiBase), 1));
                FCSDataSeccion(n, 2)=sum(FCSData(((n-1)*multiBase+1:n*multiBase), 2));
            end
        %}
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 1) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCS_autocorr_Cpp (FCSDataSeccion(:,1), multiBase*deltaT, vectorIndices);
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 2) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCS_autocorr_Cpp (FCSDataSeccion(:,2), multiBase*deltaT, vectorIndices);
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 3) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCCS_crosscorr_Cpp (FCSDataSeccion, multiBase*deltaT, vectorIndices);
        
    end
    %Control:
    %tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)-tdataTodos(indicesNOrepe(:,seccion), seccion) tiene que ser 0
    numPuntosCorrAcumula=numPuntosCorrAcumula+numPuntosCorrSeccion;
    
end

%Calcula la correlacion puntos de la última sección (logarítmica), que comparte binning, datos y multiBase con la anterior
seccion=seccion+1;
vectorIndices=matrizIndices(indicesNOrepe(:, seccion), seccion);
numPuntosCorrSeccion=numel(vectorIndices);
if numCanales==1
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCS_autocorr_Cpp(FCSDataSeccion, multiBase*deltaT, vectorIndices);
else
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 1) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCS_autocorr_Cpp (FCSDataSeccion(:,1), multiBase*deltaT, vectorIndices);
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 2) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCS_autocorr_Cpp (FCSDataSeccion(:,2), multiBase*deltaT, vectorIndices);
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 3) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCCS_crosscorr_Cpp (FCSDataSeccion, multiBase*deltaT, vectorIndices);
end

%Control:
%tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)-tdataTodos(indicesNOrepe(:,seccion), seccion) tiene que ser 0

numPuntosCorrAcumula=numPuntosCorrAcumula+numPuntosCorrSeccion;

%Finalmente ordena
[tdata, IX]=sort (tdata); %Finalmente ordena
G=G(IX, :);


function tdata=calculatdata (vectorIndices, multiBase, deltaT)
%Calcula tdata en cada sección para ver qué puntos se repiten en el cálculo de la correlación según la sección

numPuntos=numel(vectorIndices);
tdata=zeros(numPuntos, 1);
for puntosCorrelacion=1:numPuntos
    tdata(puntosCorrelacion)=vectorIndices(puntosCorrelacion)*multiBase*deltaT;
end