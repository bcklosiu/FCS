function [M cpsIntervalos]= FCS_matriz (FCSData, numIntervalos, numSubIntervalosError, binFreq, numSecciones, numPuntosSeccion, base, tauLagMax)

%[M cpsIntervalos]= FCS_matriz (FCSData, numIntervalos, numSubIntervalosError, binFreq, numSecciones, numPuntosSeccion, base, tauLagMax)
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
%   deltaTBin=1/sampfreq
%   numSecciones es el numero de secciones (Parámetros Multi-tau)
%   numPuntosSeccion es el numero de puntos por seccion (Parámetros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Parámetros Multi-tau)
%
% 26-10-10
% jri 22Abr15 - Inicializa Mtotal
% jri 4May15 - Calcula los intervalos de cada vez para no duplicar FCSData


numData=size(FCSData, 1);
numCanales=size(FCSData, 2);
deltaTBin=1/binFreq;
numDataIntervalos =floor(numData/numIntervalos);  %% El floor es necesario para poder analizar el photon mode


%Calculo el número de puntos que tendrá la correlación al final, quitando los que se repiten
[~ , ~ , ~, numPuntosCorrFinal]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaTBin, tauLagMax);

numColumnasM=3; %Autocorrelación: M=[tdata, G, SD]
if numCanales>1
    numColumnasM=7; %Correlación cruzada: M=[tdata, G1, SD1, G2, SD2, Gcc, SDcc]
end

M=zeros(numPuntosCorrFinal, numColumnasM, numIntervalos, 'double');
cpsIntervalos=zeros(numIntervalos, numCanales, 'double');

for intervalo=1:numIntervalos, 
    FCSintervalo=FCSData((intervalo-1)*numDataIntervalos+1:intervalo*numDataIntervalos, :);
    if not(isfloat(FCSintervalo)) %De esta forma lo único que es double es la parte con la que hace el subbinning
        FCSintervalo=double(FCSintervalo);
    end
    M (:, :, intervalo)=FCS_stdev(FCSintervalo, numSubIntervalosError, deltaTBin, numSecciones, numPuntosSeccion, base, tauLagMax);
    
    cpsIntervalos(intervalo, :)=round(squeeze(sum(FCSintervalo, 1, 'double'))/(numDataIntervalos*deltaTBin));

end


% Gtotal=M(:,2:end,:);
% tdatacorr=Mtotal(:,1,1);

