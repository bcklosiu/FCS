function [FCSdata, imgDecode, imgROI, imgALIN, tPromedioLS, Data_bin, G_intervalos, FCSmean, Gmean, tdecode]=...
    FCS_analisis_BH (fname, binFreq, numIntervalos, numSecciones, numPuntosSeccion, base, tauLagMax, numSubIntervalosError, tipoCorrelacion)

%
% [FCSdata, FCSdataALINcorregido, imgDecode, imgROI, imgALIN, tPromedioLS,Data_bin, G_intervalos, FCSmean, Gmean, tdecode]=
% FCS_analisis_BH (fname, intervalos, numSecciones, numPuntos, base, tauLagMax, numSubIntervalosError, tipoCorrelacion, binFreq)
%
%  fname es el nombre del archivo SPC
%  binFreq es la frecuencia del binning, en Hz
%  intervalos es el número de intervalos en los que dividimos la traza temporal. Generalmente son de 10s cada uno
%Parámetros del algoritmo multitau
%  numSecciones es el número de secciones en las que divide la curva de correlación
%  base define la resolución temporal de cada sección
%  numPuntos es el número de puntos en los que se calcula la curva de
%  autocorrelación (en cada sección). numPuntos define, por tanto, la precisión del ajuste
%  tauLagMax es el último punto temporal (tiempo máximo) para el que se
%  calcula la correlación (con todos los fotones adquiridos, incluyendo los de momentos posteriores a tauLagMax)
%
% Parámetros del cálculo de la incertidumbre
%  numSubIntervalosError es el número de subintercalos para los que calcula la
%  correlación y que utiliza para obtener la incertidumbre (error estándar) de cada punto de
%  la curva de correlación
%
%  tipoCorrelacion puede ser auto, cross o todas 
%
% TAC range y TACgain dependen del reloj SYNC (ya o hay que introducirlos como argumentos)
%
% ULS Sep2014
% jri 25Nov14
% Actualmente esta función no se usa. Se sustituye por FCS_computecorrelation.

%% 
isOpen=matlabpool ('size')>0;
if isOpen==0 %Inicializa matlabpool con el máximo numero de cores
    numWorkers=feature('NumCores'); %Número de workers activos. 
    if numWorkers>=8
        numWorkers=8; %Para Matlab 2010b, 8 cores máximo.
    end
matlabpool ('open', numWorkers) 
end

%%
[fblock,TACrange,TACgain]=loadFIFO(fname); %Carga en la RAM (como enteros de 32 bits), cada evento del archivo FIFO. Calcula TAC gain y TAC range.
tic;[FCSdata, imgDecode, frameSync, lineSync, pixelSync]= decodeFIFObinary_parallel (fblock, TACrange, TACgain);tdecode=toc; %Decodifica los eventos de BH
%Guarda el archivo decoficado antes de empezar con la alineación
save ([fname(1:end-4) '.mat'])

FCSdata_c=FCSdata.channel;
FCSdata_flp=FCSdata.frameLinePixel;
numCanales=numel(unique(FCSdata_c));
numPixels=numel(unique(FCSdata_flp(:,3)));
isScanningFCS = logical(numPixels-1);

if isScanningFCS==1
    %Seleccionar ROI de la imagen decodificada   
    [imgROI, indLinesFCS, indLinesLS, indLinesPS, offset] = FCS_ROI(imgDecode, FCSdata, lineSync, pixelSync); 

    if numCanales>1  
    cellOption=inputdlg('Selecciona tipo de alineación: 1-Suma de canales. 2-Cada canal independiente.');
    option=str2double(cellOption{1});
    switch option
        case 1
            imgROIsuma=imgROI(:,:,1)+imgROI(:,:,2);
            [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROIsuma); 
%             [FCSdataALINcorregido,tPromedioLS]=FCS_membraneAlignment_time(FCSdata, lineSync, pixelSync, imgROIsuma, indLinesFCS, indLinesLS, indLinesPS, offset, indMaxCadaLinea, sigma2_5);
        
        case 2
            [imgALIN1, sigma2_5_1, indMaxCadaLinea1]=FCS_membraneAlignment_space(imgROI(:,:,1)); 
%             [FCSdataALINcorregido1,tPromedioLS1]=FCS_membraneAlignment_time(FCSdata, lineSync, pixelSync, imgROI(:,:,1), and(indLinesFCS,FCSdata(:,6)==0), indLinesLS, indLinesPS, offset, indMaxCadaLinea1, sigma2_5_1);
            [imgALIN2, sigma2_5_2, indMaxCadaLinea2]=FCS_membraneAlignment_space(imgROI(:,:,2)); 
%             [FCSdataALINcorregido2,tPromedioLS2]=FCS_membraneAlignment_time(FCSdata, lineSync, pixelSync, imgROI(:,:,2), and(indLinesFCS,FCSdata(:,6)==1), indLinesLS, indLinesPS, offset, indMaxCadaLinea2, sigma2_5_2);            
%             FCSdataALINcorregido=cat(1,FCSdataALINcorregido1,FCSdataALINcorregido2);
%             tPromedioLS=cat(1,tPromedioLS1,tPromedioLS2);
            imgALIN=cat(3,imgALIN1,imgALIN2);
    end
        
    else %numCanales=1;
        [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROI); 
%         [FCSdataALINcorregido,tPromedioLS]=FCS_membraneAlignment_time(FCSdata, lineSync, pixelSync, imgROI, indLinesFCS, indLinesLS, indLinesPS, offset, indMaxCadaLinea, sigma2_5);
    end
    pixelSync_flp=pixelSync.frameLinePixel;
    pixelROIdesde=min(pixelSync_flp(indLinesPS,3));
    pixelROIhasta=max(pixelSync_flp(indLinesPS,3));
    imgBin=imgDecode(:,pixelROIdesde:pixelROIhasta,:); %Imagen que se utilizará para el binning temporal
    [Data_bin, deltat_bin]=FCS_binning_FIFO_lines(imgBin, lineSync, indLinesLS, indMaxCadaLinea, sigma2_5, multiploLineas); % Binning temporal de imgBIN, en múltiplos de línea de la imagen
    
else %isScanningFCS==0 -  Esto es FCS puntual
    imgDecode=0;
    imgROI=0;
    imgALIN=0;
    tPromedioLS=0;
    switch numCanales
        case 1
            t0=FCSdata(1,4)+FCSdata(1,5); %pixel de referencia para binning (1er photon)
        case 2 
            t0channels=zeros(numCanales,1);
            for channel=1:numCanales
                indPrimerPhotonCanal=find(FCSdata(:,6)==channel-1,1,'first');
                t0channels(channel)=FCSdata(indPrimerPhotonCanal,4)+FCSdata(indPrimerPhotonCanal,5);
            end
            t0=min(t0channels);
    end
    [Data_bin, sampfreq_bin, deltat_bin]=FCS_binning_FIFO_pixel1(FCSdata, binFreq, t0); %Binning temporal de FCSdataALINcorregido con los datos del Macro+micro times
end %end if isScanningFCS

dataIntervalos= FCS_troceador(Data_bin, intervalos);
% G_intervalos= FCS_matriz (dataIntervalos, numSubIntervalosError, deltat_bin, numSecciones, numPuntos, base, tauLagMax, tipoCorrelacion);
G_intervalos= FCS_matriz (dataIntervalos, numIntervalos, numSubIntervalosError, binFreq, numSecciones, numPuntosSeccion, base, tauLagMax);
[FCSmean Gmean]=FCS_promedio(G_intervalos, dataIntervalos, [1:intervalos], deltat_bin, tipoCorrelacion);

save ([fname(1:end-4) '.mat'])

