function M= FCS_matriz (FCSintervalos, numSubIntervalosError, deltaT, numSecciones, numPuntosSeccion, base, tauLagMax)

% M= FCS_matriz (FCSintervalos, numSubIntervalosError, deltaT, numSecciones, numPuntosSeccion, base, tauLagMax);
% Genera las curvas de correlaci�n en forma de matriz bi o tridimensional, dependiendo de los intervalos en que hayamos dividido la traza temporal.

%   M es una matriz que contiene las trazas de autocorrelaci�n y correlaci�n cruzada de los intervalos. 
%   M es una matriz numpuntoscorrelacionx7xnumintervalos 
%   M (:,1, intervalo) contiene tdatacorr, que es la informaci�n temporal de la correlaci�n
%   M (:,2, intervalo) es la autocorrelaci�n del canal 1
%   M (:,3, intervalo) es el error de la autocorrelaci�n del canal 1
%   M (:,4, intervalo) es la autocorrelaci�n del canal 2
%   M (:,5, intervalo) es el error de la autocorrelaci�n del canal 2
%   M (:,6, intervalo) es la correlaci�n cruzada
%   M (:,7, intervalo) es el error de la correlaci�n cruzada
% 
%
%   FCSintervalos son los datos de la traza temporal, que puede ser una matriz bidimensional (si no hay intervalos) o tridimensional (si hemos dividido en intervalos)
%   numSubIntervalosError es el n�mero de intervalos en que se subdivide de FCSintervalos para calcular la desviacion est�ndar de la correlaci�n (es decir, es S)
%-----  Importante: NO confundir los intervalos de FCSintervalos (para evitar el drifting de la traza temporal) con numSubIntervalosError o S (para calcular la SD) ------
%   deltaT=1/sampfreq
%   numSecciones es el numero de secciones (Par�metros Multi-tau)
%   numPuntosSeccion es el numero de puntos por seccion (Par�metros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Par�metros Multi-tau)
%
% 26-10-10
% jri 22Abr15 - Inicializa Mtotal

numCanales=size (FCSintervalos, 2);
numIntervalos=size (FCSintervalos, 3);

%Calculo el n�mero de puntos que tendr� la correlaci�n al final, quitando los que se repiten
[~ , ~ , ~, numPuntosCorrFinal]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tauLagMax);

numColumnasM=3; %Autocorrelaci�n: M=[tdata, G, SD]
if numCanales>1
    numColumnasM=7; %Correlaci�n cruzada: M=[tdata, G1, SD1, G2, SD2, Gcc, SDcc]
end

M=zeros(numPuntosCorrFinal, numColumnasM, numIntervalos);
%Bucle que hay que paralelizar
for intervalo=1:numIntervalos
    M (:, :, intervalo)= FCS_stdev(FCSintervalos(:,:,intervalo), numSubIntervalosError, deltaT, numSecciones, numPuntosSeccion, base, tauLagMax);
end

% Gtotal=M(:,2:end,:);
% tdatacorr=Mtotal(:,1,1);

