function [tdata matrizIndices indicesNOrepe numPuntosNOrepe]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tLagMax)

% [tdata matrizIndices indicesNOrepe numPuntosNOrepe]=FCS_calculaPuntosCorrelacionRepe(numSecciones, base, numPuntosSeccion, deltaT, tLagMax);
% 
% Los puntos temporales de tdata no están ordenados para poder trabajar con ellos en FCS_multitau
%
% Devuelve una matriz de índices no repetidos para luego calcular la correlación sólo en esos puntos
% jri 22Abr15

numSecciones=numSecciones+1;

tdata=zeros (numPuntosSeccion, numSecciones);
matrizIndices=zeros (numPuntosSeccion, numSecciones);
indicesNOrepe=false(size(tdata));

%Esto para las primeras numSecciones-1
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

numPuntosNOrepe=numel(find(indicesNOrepe));


function tdata=calculatdata (vectorIndices, multiBase, deltaT)
%Calcula tdata en cada sección para ver qué puntos se repiten en el cálculo de la correlación según la sección

numPuntos=numel(vectorIndices);
tdata=zeros(numPuntos, 1);
for puntosCorrelacion=1:numPuntos
    tdata(puntosCorrelacion)=vectorIndices(puntosCorrelacion)*multiBase*deltaT;
end
