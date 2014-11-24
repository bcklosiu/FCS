function [Mtotal]= FCS_matriz (FCS_intervalo, numintervalos, deltat, numsecciones, numpuntos, base, tlagmax, tipocorrelacion)

% [Mtotal]= FCS_matriz (FCS_intervalo, numintervalos, deltat, numsecciones, numpuntos, base, tlagmax, tipocorrelacion);
% Genera las curvas de correlaci�n en forma de matriz bi o tridimensional, dependiendo de los intervalos en que hayamos dividido la traza temporal.

%   Mtotal es una matriz que contiene las trazas de autocorrelaci�n y correlaci�n cruzada de los intervalos. 
%   Mtotal es una matriz numpuntoscorrelacionx7xnumintervalos 
%   Mtotal (:,1, intervalo) contiene tdatacorr, que es la informaci�n temporal de la correlaci�n
%   Mtotal (:,2, intervalo) es la autocorrelaci�n del canal 1
%   Mtotal (:,3, intervalo) es el error de la autocorrelaci�n del canal 1
%   Mtotal (:,4, intervalo) es la autocorrelaci�n del canal 2
%   Mtotal (:,5, intervalo) es el error de la autocorrelaci�n del canal 2
%   Mtotal (:,6, intervalo) es la correlaci�n cruzada
%   Mtotal (:,7, intervalo) es el error de la correlaci�n cruzada
% 
%
%   FCS_intervalo son los datos de la traza temporal, que puede ser una matriz bidimensional (si no hay intervalos) o tridimensional (si hemos dividido en intervalos)
%   numintervalos es el n�mero de intervalos en que vamos a dividir cada matriz bidimensional de FCS_intervalo para calcular la desviacion est�ndar de la correlaci�n (es decir, es S)
%-----  Importante: NO confundir los intervalos de FCS_intervalo (para evitar el drifting de la traza temporal) con numintervalos o S (para calcular la SD) ------
%   deltat=1/sampfreq
%   numsecciones es el numero de secciones (Par�metros Multi-tau)
%   numpuntos es el numero de puntos por seccion (Par�metros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Par�metros Multi-tau)
%   tipocorrelaci�n es una cadena de caracteres que indica que tipo de correlaci�n calcular� el programa ('auto', 'cross' o 'todas')
%
% 26-10-10

intervalos=size (FCS_intervalo, 3);

for k=1:intervalos
    Mtotal(:,:,k)= FCS_stdev(FCS_intervalo(:,:,k), numintervalos, deltat, numsecciones, numpuntos, base, tlagmax, tipocorrelacion);
    
end

% Gtotal=Mtotal(:,2:end,:);
% tdatacorr=Mtotal(:,1,1);

