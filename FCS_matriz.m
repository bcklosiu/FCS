function [Mtotal]= FCS_matriz (FCS_intervalo, numintervalos, deltat, numsecciones, numpuntos, base, tlagmax, tipocorrelacion)

% [Mtotal]= FCS_matriz (FCS_intervalo, numintervalos, deltat, numsecciones, numpuntos, base, tlagmax, tipocorrelacion);
% Genera las curvas de correlación en forma de matriz bi o tridimensional, dependiendo de los intervalos en que hayamos dividido la traza temporal.

%   Mtotal es una matriz que contiene las trazas de autocorrelación y correlación cruzada de los intervalos. 
%   Mtotal es una matriz numpuntoscorrelacionx7xnumintervalos 
%   Mtotal (:,1, intervalo) contiene tdatacorr, que es la información temporal de la correlación
%   Mtotal (:,2, intervalo) es la autocorrelación del canal 1
%   Mtotal (:,3, intervalo) es el error de la autocorrelación del canal 1
%   Mtotal (:,4, intervalo) es la autocorrelación del canal 2
%   Mtotal (:,5, intervalo) es el error de la autocorrelación del canal 2
%   Mtotal (:,6, intervalo) es la correlación cruzada
%   Mtotal (:,7, intervalo) es el error de la correlación cruzada
% 
%
%   FCS_intervalo son los datos de la traza temporal, que puede ser una matriz bidimensional (si no hay intervalos) o tridimensional (si hemos dividido en intervalos)
%   numintervalos es el número de intervalos en que vamos a dividir cada matriz bidimensional de FCS_intervalo para calcular la desviacion estándar de la correlación (es decir, es S)
%-----  Importante: NO confundir los intervalos de FCS_intervalo (para evitar el drifting de la traza temporal) con numintervalos o S (para calcular la SD) ------
%   deltat=1/sampfreq
%   numsecciones es el numero de secciones (Parámetros Multi-tau)
%   numpuntos es el numero de puntos por seccion (Parámetros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Parámetros Multi-tau)
%   tipocorrelación es una cadena de caracteres que indica que tipo de correlación calculará el programa ('auto', 'cross' o 'todas')
%
% 26-10-10

intervalos=size (FCS_intervalo, 3);

for k=1:intervalos
    Mtotal(:,:,k)= FCS_stdev(FCS_intervalo(:,:,k), numintervalos, deltat, numsecciones, numpuntos, base, tlagmax, tipocorrelacion);
    
end

% Gtotal=Mtotal(:,2:end,:);
% tdatacorr=Mtotal(:,1,1);

