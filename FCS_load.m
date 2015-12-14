function  varargout=FCS_load(fname)

% Carga, decodifica y guarda en un .mat los datos FIFO de B&H para FCS
%
% Para scanning FCS
%[isScanning, photonArrivalTimes, TACrange, TACgain, imgDecode, frameSync, lineSync, pixelSync] = FCS_load(fname)
%
% Para point FCS
%[isScanning, photonArrivalTimes, TACrange, TACgain]= FCS_load(fname)
%
% Al final el programa guarda un fname.mat con las variables relevantes
%
% Para scanning FCS
% frameSync tiene el timing de comienzo de cada (frame, arrivalTime)
% lineSync el de cada frame y línea (frame, line, arrivalTime)
% pixelSync el de cada frame y línea (frame, line, pixel, arrivalTime)
% photonArrivalTimes indica en cada columna el frame, la línea el pixel, los tiempos (macro y micro,
% en s) y el canal de detección de cada fotón
%
% Para point FCS
% photonArrivalTimes indica en cada columna los tiempos (macro y micro, en s) y el canal de detección cada fotón
%
% Los tiempos macro y micro no están sumados para ver si podemos hacer en
% el futuro FCS and lifetime simultáneamente
%
%
% TACrange (en s) y TACgain son parámetros de la adquisición de B&H. Cambian en función del detector utilizado.
%
%
% ULS...
% jri - 26Nov14
% jri - 26Mar15 - Corrijo los errores al cargar datos de scanning FCS
% Unai, 07oct15 - No es necesario borrar photonArrivalTimes.frameLinePixel para el caso Point FCS


inicializamatlabpool()


disp (['Decoding ' fname])
[fblock, TACrange, TACgain]=loadFIFO(fname); %Carga en la RAM (como enteros de 32 bits), cada evento del archivo FIFO. Calcula TAC gain y TAC range.
tic;
[photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync]= decodeFIFObinary_parallel (fblock, TACrange, TACgain); %Decodifica los eventos de BH
tdecode=toc;

photonArrivalTimes_flp=photonArrivalTimes.frameLinePixel;
photonArrivalTimes_c=photonArrivalTimes.channel;
numPixels=numel(unique(photonArrivalTimes_flp(:,3)));
isScanning=logical(numPixels-1); %Comprueba que frameSync, etc tenga elementos. Si no, es pointFCS
numChannelsAcquisition=numel(unique(photonArrivalTimes_c));
disp(['Number of acquisition channels: ' num2str(numChannelsAcquisition)])


fname=[fname(1:end-4) '.mat'];
disp (['Decoding time: ' num2str(tdecode) ' s'])
if isScanning
    varargout={isScanning, photonArrivalTimes, TACrange, TACgain, imgDecode, frameSync, lineSync, pixelSync};

    disp ('Scanning FCS experiment')
    disp (['Saving ' fname(1:end-4) '_raw.mat'])
    save ([fname(1:end-4) '_raw.mat'], 'photonArrivalTimes', 'imgDecode', 'frameSync', 'lineSync', 'pixelSync', 'TACrange', 'TACgain', 'fname', 'isScanning')
else
    
    varargout={isScanning, photonArrivalTimes, TACrange, TACgain};
    if nargout>4
        for n=5:nargout
            varargout{n}=[];
        end
    end
    disp ('Point FCS experiment')
    disp (['Saving ' fname(1:end-4) '_raw.mat'])
    save ([fname(1:end-4) '_raw.mat'], 'photonArrivalTimes', 'TACrange', 'TACgain', 'fname', 'isScanning')
end
disp ('OK')
