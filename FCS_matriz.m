function M= FCS_matriz (FCSintervalos, numSubIntervalosError, deltaT, numSecciones, numPuntosSeccion, base, tauLagMax)

% M= FCS_matriz (FCSintervalos, numSubIntervalosError, deltaT, numSecciones, numPuntosSeccion, base, tauLagMax);
% Genera las curvas de correlación en forma de matriz bi o tridimensional, dependiendo de los intervalos en que hayamos dividido la traza temporal.

%   M es una matriz que contiene las trazas de autocorrelación y correlación cruzada de los intervalos. 
%   M es una matriz numpuntoscorrelacionx7xnumintervalos 
%   M (:,1, intervalo) contiene tdatacorr, que es la información temporal de la correlación
%   M (:,2, intervalo) es la autocorrelación del canal 1
%   M (:,3, intervalo) es el error de la autocorrelación del canal 1
%   M (:,4, intervalo) es la autocorrelación del canal 2
%   M (:,5, intervalo) es el error de la autocorrelación del canal 2
%   M (:,6, intervalo) es la correlación cruzada
%   M (:,7, intervalo) es el error de la correlación cruzada
% 
%
%   FCSintervalos son los datos de la traza temporal, que puede ser una matriz bidimensional (si no hay intervalos) o tridimensional (si hemos dividido en intervalos)
%   numSubIntervalosError es el número de intervalos en que se subdivide de FCSintervalos para calcular la desviacion estándar de la correlación (es decir, es S)
%-----  Importante: NO confundir los intervalos de FCSintervalos (para evitar el drifting de la traza temporal) con numSubIntervalosError o S (para calcular la SD) ------
%   deltaT=1/sampfreq
%   numSecciones es el numero de secciones (Parámetros Multi-tau)
%   numPuntosSeccion es el numero de puntos por seccion (Parámetros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Parámetros Multi-tau)
%
% 26-10-10
% jri 22Abr15 - Inicializa Mtotal

numCanales=size (FCSintervalos, 2);
numIntervalos=size (FCSintervalos, 3);

%Calculo el número de puntos que tendrá la correlación al final, quitando los que se repiten
[~ , ~ , ~, numPuntosCorrFinal]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tauLagMax);

numColumnasM=3; %Autocorrelación: M=[tdata, G, SD]
if numCanales>1
    numColumnasM=7; %Correlación cruzada: M=[tdata, G1, SD1, G2, SD2, Gcc, SDcc]
end

M=zeros(numPuntosCorrFinal, numColumnasM, numIntervalos);
%Bucle que hay que paralelizar
for intervalo=1:numIntervalos
    M (:, :, intervalo)= FCS_stdev(FCSintervalos(:,:,intervalo), numSubIntervalosError, deltaT, numSecciones, numPuntosSeccion, base, tauLagMax);
end

% Gtotal=M(:,2:end,:);
% tdatacorr=Mtotal(:,1,1);

