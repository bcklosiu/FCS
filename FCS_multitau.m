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

%Calcula todos los puntos de cada sección en los que hará la correlación
%para evitar los puntos repetidos por sección
[tdataTodos matrizIndices indicesNOrepe numPuntosCorrFinal]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tLagMax);
%Hace la correlación

numCanales=size(FCSData, 2);
G=zeros (numPuntosCorrFinal, 1);
tdata_corr=zeros(numPuntosCorrFinal, 1);

tdata=tdataTodos(indicesNOrepe);

numPuntosCorrAcumula=0;

%Esto para las primeras numSecciones (menos la logarítmica)
for seccion=1:numSecciones %Hace una correlación por cada sección
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


