function varargout=FCS_computecorrelation (varargin)

%
% Scanning FCS:
%[FCSintervalos, Gintervalos, FCSmean, Gmean, tData, binFreq]=...
%    FCS_computecorrelation (photonArrivalTimes, numIntervalos, binLines, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion...
%    imgBin, lineSync, indLinesLS, indMaxCadaLinea, sigma2_5);
%
% Point FCS
%[FCSintervalos, Gintervalos, FCSmean, Gmean]=...
%   FCS_computecorrelation (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion)
%
%
%   FCSintervalos es FCSData de cada intervalo (los datos de FCS en bins temporales de tamaño deltaT=1/binFreq)
%   Gintervalos es la curva experimental de correlación de cada intervalo con su tiempo, su traza y su error en la tercera columna
%   FCSmean es el promedio de todas las trazas
%   Gmean es el promedio de todas las curvas de correlación
%
%   photonArrivalTimes es la matriz de tiempos de llegada (arrivalTimes) de B&H
%   binFreq es la frecuencia del binning, en Hz.
%   en el caso de scanning FCS usamos multiploLineas que es el número de
%   líneas sobre las que se hace binning. En este caso binFreq sería scanning frequency/multiploLineas
%   numIntervalos es el número de numIntervalos en los que dividimos la traza temporal. Generalmente son de 10s cada uno
%Parámetros del algoritmo multitau
%   numSecciones es el número de secciones en las que divide la curva de correlación
%   base define la resolución temporal de cada sección
%   numPuntosSeccion es el número de puntos en los que se calcula la curva de
%   autocorrelación (en cada sección). numPuntosSeccion define, por tanto, la precisión del ajuste
%   tauLagMax es el último punto temporal (tiempo máximo) para el que se calcula la correlación (con todos los fotones adquiridos, incluyendo los de momentos posteriores a tauLagMax)
%Parámetros del cálculo de la incertidumbre
%   numSubIntervalosError es el número de subintercalos para los que calcula la correlación y que utiliza para obtener la incertidumbre (error estándar) de cada punto de la curva de correlación
%
%   tipoCorrelacion puede ser auto, cross o todas 
%
%   TAC range y TACgain dependen del reloj SYNC (ya o hay que introducirlos como argumentos)
%   
%   binLines es el número de líneas con las que se hace binning en el caso de scanning FCS    
%
%   En el caso de scanning FCS hay que llamar antes a FCS_align, que hace
%   el ROI y después la alineación
%
% Basado en FCS_analisis_BH
% ULS Sep2014
% jri 25Nov14


photonArrivalTimes=varargin{1};
numIntervalos=varargin{2};
tauLagMax=varargin{4};
numSecciones=varargin{5};
numPuntosSeccion=varargin{6};
base=varargin{7};
numSubIntervalosError=varargin{8};
tipoCorrelacion=varargin{9};

% Es esto necesario? 
inicializamatlabpool();

isScanning = logical(size(photonArrivalTimes,2)-3); %isScanning es true si se trata de scanning FCS; sino, false
if isScanning
    binLines=varargin{3};
    imgBin=varargin{10};
    lineSync=varargin{11};
    indLinesLS=varargin{12};
    indMaxCadaLinea=varargin{13};
    sigma2_5=varargin{14};
        
    macroTimeCol=4;
    microTimeCol=5;
    channelsCol=6;
    
else
    binFreq=varargin{3};

    macroTimeCol=1;
    microTimeCol=2;
    channelsCol=3;
end

numCanales=numel(unique(photonArrivalTimes(:, channelsCol)));

if isScanning
    [FCSData, deltaTBin]=FCS_binning_FIFO_lines(imgBin, lineSync, indLinesLS, indMaxCadaLinea, sigma2_5, binLines); % Binning temporal de imgBIN, en múltiplos de línea de la imagen (binLines)
    binFreq=1/deltaTBin;
    
else %isSCanningFCS==0 -  Esto es FCS puntual

    switch numCanales
        case 1
            t0=photonArrivalTimes(1, macroTimeCol)+photonArrivalTimes(1, microTimeCol); %pixel de referencia para binning (1er photon)
        case 2 
            t0channels=zeros(numCanales,1);
            for channel=1:numCanales
                indPrimerPhotonCanal=find(photonArrivalTimes(:, channelsCol)==channel-1,1,'first');
                t0channels(channel)=photonArrivalTimes(indPrimerPhotonCanal, macroTimeCol)+photonArrivalTimes(indPrimerPhotonCanal, microTimeCol);
            end
            t0=min(t0channels);
    end
    FCSData=FCS_binning_FIFO_pixel1(photonArrivalTimes, binFreq, t0); %Binning temporal de FCSDataALINcorregido con los datos del Macro+micro times
end %end if isSCanningFCS

FCSintervalos= FCS_troceador(FCSData, numIntervalos);
Gintervalos= FCS_matriz (FCSintervalos, numSubIntervalosError, deltaTBin, numSecciones, numPuntosSeccion, base, tauLagMax, tipoCorrelacion);
[FCSmean Gmean]=FCS_promedio(Gintervalos, FCSintervalos, 1:numIntervalos, deltaTBin, tipoCorrelacion);
tData=(1:size(FCSintervalos, 1))/binFreq;

if isScanning
    varargout={FCSintervalos, Gintervalos, FCSmean, Gmean, tData, binFreq};
else
    varargout={FCSintervalos, Gintervalos, FCSmean, Gmean, tData};
end

