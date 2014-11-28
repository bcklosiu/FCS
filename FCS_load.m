function  varargout=FCS_load(fname)

% Carga y decodifica los datos FIFO de B&H para FCS
%
% Para scanning FCS
%[photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync,  TACrange, TACgain, isScanning] = FCS_load(fname)
%
% Para point FCS
% [photonArrivalTimes, TACrange, TACgain, isScanning]= FCS_load(fname)
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

isOpen=matlabpool ('size')>0;
if isOpen==0 %Inicializa matlabpool con el máximo numero de cores
    numWorkers=feature('NumCores'); %Número de workers activos.
    if numWorkers>=8
        numWorkers=8; %Para Matlab 2010b, 8 cores máximo.
    end
    disp (['Inicializando matlabpool con ' num2str(numWorkers) ' cores'])
    matlabpool ('open', numWorkers)
end


[fblock, TACrange, TACgain]=loadFIFO(fname); %Carga en la RAM (como enteros de 32 bits), cada evento del archivo FIFO. Calcula TAC gain y TAC range.
tic;
[photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync]= decodeFIFObinary_parallel (fblock, TACrange, TACgain); %Decodifica los eventos de BH
tdecode=toc;

isScanning=and (numel(imgDecode)>1, and(numel(frameSync)>1, and(numel(lineSync)>1, numel(pixelSync)>1)));


fname=[fname(1:end-4) '.mat'];
disp (['Decode time: ' num2str(tdecode) ' s'])
if isScanning
    varargout={photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync, TACrange, TACgain, isScanning};

    disp ('Scanning FCS experiment')
    disp (['Saving ' fname(1:end-4) '.mat'])
    save (fname, 'photonArrivalTimes', 'imgDecode', 'frameSync', 'lineSync', 'pixelSync', 'TACrange', 'TACgain', 'fname', 'isScanning')
    disp ('OK')
else
    photonArrivalTimes(:, 1:3)=[];
    varargout={photonArrivalTimes, TACrange, TACgain, isScanning};
    disp ('Point FCS experiment')
    disp (['Saving ' fname])
    save (fname, 'photonArrivalTimes', 'TACrange', 'TACgain', 'fname', 'isScanning')
end
disp ('OK')
