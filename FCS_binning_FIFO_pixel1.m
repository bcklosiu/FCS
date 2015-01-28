function dataBin=FCS_binning_FIFO_pixel1(arrivalTimes, binFreq, t0)

% [dataBin, deltaTBin]=FCS_binning_FIFO_pixel1(arrivalTimes, binFreq, t0);
%
% Esta función hace un binning temporal del archivo que le especifiquemos,
% INPUT ARGUMENTS:
%   arrivalTimes - es la matriz de los arrival times de los fotones de B&H
%   binFreq - es la frecuencia que queremos aplicar al binning (en Hz)
%   t0 - es el tiempo de referencia que se le resta a todos los canales
% OUTPUT ARGUMENTS:
%   dataBin(Fotones en el bin, canal) - es la nueva matriz con la traza temporal y el binning aplicado
%
% Modificado jri para incluir el microtime 11abr14
% Modificado por Unai para calcular automáticamente el nº de canales
%
% jri - 26Nov14 - Considera que arrivalTimes de FCS puntual sólo tiene 3 columnas en vez de 6




isScanning = logical(size(arrivalTimes,2)-3);
if isScanning
    macroTimeCol=4;
    microTimeCol=5;
    channelsCol=6;
else
    macroTimeCol=1;
    microTimeCol=2;
    channelsCol=3;
end

channels=sort(unique(arrivalTimes(:, channelsCol)),'ascend');
nrChannels=numel(channels);
deltaTBin=1/binFreq; %Período de binning
numFotCh=zeros(nrChannels,1); %Número de fotones de cada canal
data=zeros(size(arrivalTimes,1),nrChannels); %Matriz de tiempos por canal

for cc=1:nrChannels, %Identifica los fotones de cada canal
    indsxCh=arrivalTimes(:, channelsCol)==channels(cc);
    numFotCh(cc)=numel(find(indsxCh==1));
    data(1:numFotCh(cc),cc)=arrivalTimes(indsxCh, macroTimeCol)+arrivalTimes(indsxCh, microTimeCol)-t0; %MT+mT-tiempo referencia
end %end for (cc)
data(max(numFotCh)+1:end,:)=[];

MTmax=max(data(:)); %MT del último fotón válido
numfildataBin=MTmax/(deltaTBin); %Nro. de filas de dataBin
if rem(MTmax,deltaTBin)==0,
    dimDataBin=ceil(numfildataBin)+1;
else
    dimDataBin=ceil(numfildataBin);
end

dataBin=zeros(dimDataBin, nrChannels);
for d=1:nrChannels
    binHasta=numFotCh(d); %límite superior del for anidado
    for dd=1:binHasta
        indice_bin=floor(data(dd,d)/deltaTBin);
        dataBin(indice_bin+1,d)=dataBin(indice_bin+1,d)+1;
    end %end for (dd)
end %end for (d)

