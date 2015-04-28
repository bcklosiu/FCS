function varargout=FCS_computecorrelation (varargin)

%
% Scanning FCS:
%[FCSintervalos, Gintervalos, FCSmean, Gmean, cps, tData, binFreq]=...
%    FCS_computecorrelation (photonArrivalTimes, numIntervalos, binLines, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion, ...
%    imgBin, lineSync, indLinesLS, indMaxCadaLinea, sigma2_5);
%
% Point FCS
%[FCSintervalos, Gintervalos, FCSmean, Gmean, cps, tData]=...
%   FCS_computecorrelation (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion)
%
%   FCSintervalos es FCSData de cada intervalo (los datos de FCS en bins temporales de tamaño deltaT=1/binFreq)
%   Gintervalos es la curva experimental de correlación de cada intervalo con su tiempo, su traza y su error en la tercera columna
%   FCSmean es el promedio de todas las trazas
%   Gmean es el promedio de todas las curvas de correlación
%   cps son las cuentas por segundo en cada canal
%   tData es el tiempo de cada punto en FCSintervalos
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
%   Si es cero calcula la incertidumbre para el promedio de las curvas como SEM de las curvas promediadas
%   tipoCorrelacion puede ser 1 o 2 para autocorrelación de los canales 1 o 2, respectivamente, o 3 para ambas
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
% jri 22Ene15 - Corrijo el deltaTbin, que faltaba para el point-FCS
% jri 24Abr15 - Añado las cuentas por segundo y corrijo tData para que sea el t de los FCSintervalos y no el de FCSData
% jri 28Apr15 - Añado cps por intervalo y ambio FCS promedio para que FCSmean la calcule fuera de FCSpromedio


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
            t0channels=zeros(numCanales, 1);
            for channel=1:numCanales
                indPrimerPhotonCanal=find(photonArrivalTimes(:, channelsCol)==channel-1,1,'first');
                t0channels(channel)=photonArrivalTimes(indPrimerPhotonCanal, macroTimeCol)+photonArrivalTimes(indPrimerPhotonCanal, microTimeCol);
            end
            t0=min(t0channels);
    end
    FCSData=FCS_binning_FIFO_pixel1(photonArrivalTimes, binFreq, t0); %Binning temporal de FCSDataALINcorregido con los datos del Macro+micro times
    deltaTBin=1/binFreq;
end %end if isSCanningFCS

%FCS_binning_FIFO_pixel1 devuelve siempre dos canales si los hay
%Si sólo quiero un canal tengo que deshacerlo. Si tipoCorrelacion=1 ó 2
%indica que ése es el canal que quiero. Si es 3, entonces va todo.
if tipoCorrelacion < 3
    FCSData=FCSData(:, tipoCorrelacion);
end

disp(['Correlating ' num2str(size(FCSData, 2)) ' channels'])

FCSintervalos= FCS_troceador(FCSData, numIntervalos);
Gintervalos= FCS_matriz (FCSintervalos, numSubIntervalosError, deltaTBin, numSecciones, numPuntosSeccion, base, tauLagMax);
usaSubIntervalosError=logical(numSubIntervalosError); %Si numSubIntervalosError>0 entonces usa los subIntervalos para calcular la incertidumbre
Gmean=FCS_promedio(Gintervalos, 1:numIntervalos, usaSubIntervalosError);

numData=size(FCSData,1);
numDataIntervalos=size(FCSintervalos,1);
cps=round(sum(FCSData)/(numData*deltaTBin));
cpsIntervalos=round(squeeze(sum(FCSintervalos, 1))/(numDataIntervalos*deltaTBin));
tData=(1:numData)*deltaTBin;

if isScanning
    varargout={FCSintervalos, Gintervalos, Gmean, cps, cpsIntervalos, tData, binFreq};
else
    varargout={FCSintervalos, Gintervalos, Gmean, cps, cpsIntervalos, tData};
end

