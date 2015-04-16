function [G tdata]= FCS_multitau (FCSdata, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion)
%
% [G  tdata]= FCS_multitau (FCSdata, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion);
% Algorimo multitau para el cálculo de la función de autocorrelación/correlacion cruzada

% Sigue el algoritmo de Wohland_2001
%
%   FCSdata contiene la traza temporal. FCSdata puede ser un vector columna o una matriz de dos columnas, segun se quiera calcular la auto- o la cross-correlacion, respectivamente.
%   deltaT es el inverso de la frecuencia de muestreo,
%   numSecciones es el número de secciones de la función de autocorrelación
%   numPuntos es el número de puntos por sección 
%   base define la resolución temporal de cada sección: res_temporal=deltaT*(base^seccion)
%   tLagMax es el último punto temporal con el que se hace correlación, en s
%   tipoCorrelacion puede ser 'cross' o 'auto' o 'todas'
%
% 26-10-2010
% 27abr11 - Modificado para que llame a los programas que calculan la
% correlacion en C++
%
% jri - 16May14 Ordenado un poco

numdata=size(FCSdata, 1);

tdata=zeros (numPuntos, numSecciones, 1);
numSecciones=numSecciones+1;

G=zeros (numPuntos, numSecciones, 1);
Gtemp=zeros (numPuntos, numSecciones, 1);

switch (tipoCorrelacion)
    case 'cross'
        [Gtemp tdata]=multitau_cross (FCSdata, deltaT, numSecciones, numPuntos, base, numdata, tLagMax);
    case 'auto'
        [Gtemp tdata]=multitau_auto (FCSdata, deltaT, numSecciones, numPuntos, base, numdata, tLagMax);
    case 'todas'
        [Gtemp tdata]=multitau_todas (FCSdata, deltaT, numSecciones, numPuntos, base, numdata, tLagMax);
end

[G tdata]=ordena(Gtemp, tdata); %Se deshace de los datos repetidos en Gtemp y ordena Gtemp


function [G tdata]=multitau_auto (FCSdata, deltaT, numSecciones, numPuntos, base, numdata, tLagMax)
G=zeros (numPuntos, numSecciones, 1);
tdata=zeros (numPuntos, numSecciones, 1);

%Esto para las primeras numSecciones-1
vectorindices=1:numPuntos;
for m=1:numSecciones-1 %Hace una correlación por cada sección
    multibase=base^(m-1);
    secpuntos=floor(numdata/multibase); %Número de puntos en cada sección
    if secpuntos <= numPuntos
        error('No hay puntos suficientes para calcular la correlación: %d', secpuntos)
    end    
    Secdata=zeros (secpuntos, 1, 'double');
    for n=1:secpuntos
        Secdata(n)=sum(FCSdata(((n-1)*multibase+1:n*multibase))); % Cuando es una autocorrelación
    end
    [G(:, m) tdata(:,m)]= FCS_autocorr_Cpp (Secdata, multibase*deltaT, vectorindices);
end
%Calcula los puntos de la última sección
numPuntos_ultimaseccion=floor(tLagMax/(deltaT*base^(numSecciones-2))); %Esto es el numero de puntos que habria que calcular de la ultima seccion para correlacionar hasta tLagMax
vectorindices=round(logspace (0, log10(numPuntos_ultimaseccion), numPuntos));  % logspace genera un vector FILA
[G(:, numSecciones) tdata(:,numSecciones)]= FCS_autocorr_Cpp(Secdata, base^(numSecciones-2)*deltaT, vectorindices);



function [G tdata]=multitau_cross (FCSdata, deltaT, numSecciones, numPuntos, base, numdata, tLagMax)
G=zeros (numPuntos, numSecciones, 1);
tdata=zeros (numPuntos, numSecciones, 1);

%Esto para las primeras numSecciones-1
vectorindices=1:numPuntos;
for m=1:numSecciones-1
    multibase=base^(m-1);
    secpuntos=floor(numdata/multibase);
    if secpuntos <= numPuntos
        error('No hay puntos suficientes para calcular la correlación: %d', secpuntos)
    end    
    Secdata=zeros (secpuntos, 1, 'double');
    for n=1:secpuntos
        Secdata(n, 1)=sum(FCSdata(((n-1)*multibase+1:n*multibase), 1)); % Cuando es una correlación cruzada
        Secdata(n, 2)=sum(FCSdata(((n-1)*multibase+1:n*multibase), 2));
    end
    [G(:, m) tdata(:,m)]= FCCS_crosscorr_Cpp(Secdata, multibase*deltaT, vectorindices);
end
%Calcula los puntos de la última sección
numPuntos_ultimaseccion=floor(tLagMax/(deltaT*base^(numSecciones-2))); %Esto es el numero de puntos que habria que calcular de la ultima seccion para correlacionar hasta tLagMax
vectorindices=round(logspace (0, log10(numPuntos_ultimaseccion), numPuntos));
[G(:, numSecciones) tdata(:,numSecciones)]= FCCS_crosscorr_Cpp(Secdata, base^(numSecciones-2)*deltaT, vectorindices);


function [G tdata]=multitau_todas (FCSdata, deltaT, numSecciones, numPuntos, base, numdata, tLagMax)
G=zeros (numPuntos, numSecciones, 3);
tdata=zeros (numPuntos, numSecciones, 1);
%Esto para las primeras numSecciones-1
vectorindices=1:numPuntos;
for m=1:numSecciones-1
    multibase=base^(m-1);
    secpuntos=floor(numdata/multibase);
    if secpuntos <= numPuntos
        fprintf ('Sección: %d\nNúmero de puntos: %d\n', m, secpuntos)
        error('No hay puntos suficientes para calcular la correlación: %d', secpuntos)
    end    
    Secdata=zeros (secpuntos, 1, 'double');
    for n=1:secpuntos
        Secdata(n, 1)=sum(FCSdata(((n-1)*multibase+1:n*multibase), 1)); % Cuando es una correlación cruzada
        Secdata(n, 2)=sum(FCSdata(((n-1)*multibase+1:n*multibase), 2));
    end
    [G(:, m, 1) tdata(:,m)]= FCS_autocorr_Cpp(Secdata(:,1), multibase*deltaT, vectorindices);
    [G(:, m, 2) tdata(:,m)]= FCS_autocorr_Cpp(Secdata(:,2), multibase*deltaT, vectorindices);
    [G(:, m, 3) tdata(:,m)]= FCCS_crosscorr_Cpp(Secdata, multibase*deltaT, vectorindices);
end

%Calcula los puntos de la última sección
numPuntos_ultimaseccion=floor(tLagMax/(deltaT*base^(numSecciones-2))); %Esto es el numero de puntos que habria que calcular de la ultima seccion para correlacionar hasta tLagMax en s
vectorindices=round(logspace (0, log10(numPuntos_ultimaseccion), numPuntos));
[G(:, numSecciones, 1) tdata(:,numSecciones)]= FCS_autocorr_Cpp(Secdata(:,1), base^(numSecciones-2)*deltaT, vectorindices);
[G(:, numSecciones, 2) tdata(:,numSecciones)]= FCS_autocorr_Cpp(Secdata(:,2), base^(numSecciones-2)*deltaT, vectorindices);
[G(:, numSecciones, 3) tdata(:,numSecciones)]= FCCS_crosscorr_Cpp(Secdata, base^(numSecciones-2)*deltaT, vectorindices);


function [G tdata IX indicesrepe]=ordena(Gtemp, tdata)
%Ordena Gtemp (que tiene los puntos de cada sección) para deshacerse de los
%puntos temporales repetidos. Por eso la curva final no es
%numSeccionesXnumPuntos, porque hay puntos que se repiten en cada sección.
G=reshape(Gtemp, size(Gtemp,1)*size(Gtemp,2), size(Gtemp,3));
tdata=tdata(:);

indicesrepe=zeros (numel(tdata)); % Encuentra los valores repetidos del tiempo
for k=1:numel (tdata)
    ck=find(tdata==tdata(k));
    if size(ck,1)>1
        indicesrepe(ck(2:end))=1;
    end
end
indicesrepe=logical(indicesrepe); %Y los borra en t y G 
tdata(indicesrepe)=[];
[tdata, IX]=sort (tdata); %Finalmente ordena
G(indicesrepe,:)=[];
G=G(IX,:);


