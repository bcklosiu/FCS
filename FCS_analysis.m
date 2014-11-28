function varargout=FCS_analysis (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion)
%
% Scanning FCS:
%[FCSDataALINcorregido, imgDecode, imgROI, imgALIN, tPromedioLS, FCSData_bin, FCSintervalos, Gintervalos, FCSmean, Gmean]=...
%    FCS_analysis (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion)
%
%
% Point FCS
%[FCSintervalos, Gintervalos, FCSmean, Gmean]=FCS_analysis (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion)
%
%
%   FCSintervalos es FCSData de cada intervalo (los datos de FCS en bins temporales de tamaño deltaT=1/binFreq)
%   Gintervalos es la curva experimental de correlación de cada intervalo con su tiempo, su traza y su error en la tercera columna
%   FCSmean es el promedio de todas las trazas
%   Gmean es el promedio de todas las curvas de correlación
%
%   photonArrivalTimes es la matriz de tiempos de llegada (arrivalTimes) de B&H
%   binFreq es la frecuencia del binning, en Hz
%   numIntervalos es el número de numIntervalos en los que dividimos la traza temporal. Generalmente son de 10s cada uno
%Parámetros del algoritmo multitau
%   numSecciones es el número de secciones en las que divide la curva de correlación
%   base define la resolución temporal de cada sección
%   numPuntosSeccion es el número de puntos en los que se calcula la curva de
%   autocorrelación (en cada sección). numPuntosSeccion define, por tanto, la precisión del ajuste
%   tauLagMax es el último punto temporal (tiempo máximo) para el que se calcula la correlación (con todos los fotones adquiridos, incluyendo los de momentos posteriores a tauLagMax)
%
%Parámetros del cálculo de la incertidumbre
%numSubIntervalosError es el número de subintercalos para los que calcula la correlación y que utiliza para obtener la incertidumbre (error estándar) de cada punto de la curva de correlación
%
%   tipoCorrelacion puede ser auto, cross o todas 
%
%   TAC range y TACgain dependen del reloj SYNC (ya o hay que introducirlos como argumentos)
%
% Basado en FCS_analisis_BH
% ULS Sep2014
% jri 25Nov14

% Es esto necesario? No parece que lo esté usando
isOpen=matlabpool ('size')>0;
if not(isOpen) %Inicializa matlabpool con el máximo numero de cores
    numWorkers=feature('NumCores'); %Número de workers activos. 
    if numWorkers>=8
        numWorkers=8; %Para Matlab 2010b, 8 cores máximo.
    end
    disp (['Inicializando matlabpool con ' num2str(numWorkers) ' cores'])
matlabpool ('open', numWorkers) 
end


isScanning = logical(size(photonArrivalTimes,2)-3); %isScanning es true si se trata de scanning FCS; sino, false
if isScanning
    macroTimeCol=4;
    microTimeCol=5;
    channelsCol=6;
else
    macroTimeCol=1;
    microTimeCol=2;
    channelsCol=3;
end

numCanales=numel(unique(photonArrivalTimes(:, channelsCol)));
deltaTBin=1/binFreq;

if isScanning
    %Seleccionar ROI de la imagen decodificada   
    [imgROI, indLinesFCS, indLinesLS, indLinesPS, offset] = FCS_ROI(imgDecode, photonArrivalTimes, lineSync, pixelSync); 
    if numCanales>1
        
    cellOption=inputdlg('Selecciona tipo de alineación: 1-Suma de canales. 2-Cada canal independiente.');
    option=str2double(cellOption{1});
    switch option
        case 1
            imgROIsuma=imgROI(:,:,1)+imgROI(:,:,2);
            [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROIsuma); 
%             [FCSDataALINcorregido,tPromedioLS]=FCS_membraneAlignment_time(photonArrivalTimes, lineSync, pixelSync, imgROIsuma, indLinesFCS, indLinesLS, indLinesPS, offset, indMaxCadaLinea, sigma2_5);
        case 2

            [imgALIN1, sigma2_5_1, indMaxCadaLinea1]=FCS_membraneAlignment_space(imgROI(:,:,1)); 
%             [FCSDataALINcorregido1,tPromedioLS1]=FCS_membraneAlignment_time(photonArrivalTimes, lineSync, pixelSync, imgROI(:,:,1), and(indLinesFCS,photonArrivalTimes(:,6)==0), indLinesLS, indLinesPS, offset, indMaxCadaLinea1, sigma2_5_1);
            [imgALIN2, sigma2_5_2, indMaxCadaLinea2]=FCS_membraneAlignment_space(imgROI(:,:,2)); 
%             [FCSDataALINcorregido2,tPromedioLS2]=FCS_membraneAlignment_time(photonArrivalTimes, lineSync, pixelSync, imgROI(:,:,2), and(indLinesFCS,photonArrivalTimes(:,6)==1), indLinesLS, indLinesPS, offset, indMaxCadaLinea2, sigma2_5_2);            
            FCSDataALINcorregido=cat(1,FCSDataALINcorregido1,FCSDataALINcorregido2);
            tPromedioLS=cat(1,tPromedioLS1,tPromedioLS2);
            imgALIN=cat(3,imgALIN1,imgALIN2);
    end
        
    else %numCanales=1;
        [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROI); 
%         [FCSDataALINcorregido,tPromedioLS]=FCS_membraneAlignment_time(photonArrivalTimes, lineSync, pixelSync, imgROI, indLinesFCS, indLinesLS, indLinesPS, offset, indMaxCadaLinea, sigma2_5);
    end
    
    pixelROIdesde=min(pixelSync(indLinesPS,3));
    pixelROIhasta=max(pixelSync(indLinesPS,3));
    imgBin=imgDecode(:,pixelROIdesde:pixelROIhasta,:); %Imagen que se utilizará para el binning temporal
    [FCSData, deltaTBin]=FCS_binning_FIFO_lines(imgBin, lineSync, indLinesLS, indMaxCadaLinea, sigma2_5, multiploLineas); % Binning temporal de imgBIN, en múltiplos de línea de la imagen
    
else %isSCanningFCS==0 -  Esto es FCS puntual
    FCSDataALINcorregido=0;
    imgDecode=0;
    imgROI=0;
    imgALIN=0;
    tPromedioLS=0;
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
    %Comprobar esto
    varargout={FCSDataALINcorregido, imgDecode, imgROI, imgALIN, tPromedioLS, FCSintervalos, Gintervalos, FCSmean, Gmean, tData};
else
    varargout={FCSintervalos, Gintervalos, FCSmean, Gmean, tData};
end

