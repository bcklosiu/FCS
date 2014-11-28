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
% lineSync el de cada frame y l�nea (frame, line, arrivalTime)
% pixelSync el de cada frame y l�nea (frame, line, pixel, arrivalTime)
% photonArrivalTimes indica en cada columna el frame, la l�nea el pixel, los tiempos (macro y micro,
% en s) y el canal de detecci�n de cada fot�n
%
% Para point FCS
% photonArrivalTimes indica en cada columna los tiempos (macro y micro, en s) y el canal de detecci�n cada fot�n
%
% Los tiempos macro y micro no est�n sumados para ver si podemos hacer en
% el futuro FCS and lifetime simult�neamente
%
%
% TACrange (en s) y TACgain son par�metros de la adquisici�n de B&H. Cambian en funci�n del detector utilizado.
%
%
% ULS...
% jri - 26Nov14

isOpen=matlabpool ('size')>0;
if isOpen==0 %Inicializa matlabpool con el m�ximo numero de cores
    numWorkers=feature('NumCores'); %N�mero de workers activos.
    if numWorkers>=8
        numWorkers=8; %Para Matlab 2010b, 8 cores m�ximo.
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
