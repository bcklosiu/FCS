function dataBin=FCS_binning_FIFO_pixel1(arrivalTimes, binFreq, t0)

% [dataBin, deltaTBin]=FCS_binning_FIFO_pixel1(arrivalTimes, binFreq, t0);
%
% Esta funci�n hace un binning temporal del archivo que le especifiquemos,
% INPUT ARGUMENTS:
%   arrivalTimes - es la matriz de los arrival times de los fotones de B&H
%   binFreq - es la frecuencia que queremos aplicar al binning (en Hz)
%   t0 - es el tiempo de referencia que se le resta a todos los canales
% OUTPUT ARGUMENTS:
%   dataBin(Fotones en el bin, canal) - es la nueva matriz con la traza temporal y el binning aplicado
%   Con frecuencia se llama FCSData
%
% Modificado jri para incluir el microtime 11abr14
% Modificado por Unai para calcular autom�ticamente el n� de canales
%
% jri - 26Nov14 - Considera que arrivalTimes de FCS puntual s�lo tiene 3 columnas en vez de 6
% jri 4May15 - Reduzco el tama�o de la matriz temporal de fotones al n�mero m�ximo de fotones por canal X 2 canales
% jri 4May15 - Convierto FCSData en uint8
% jri 21Jul15 - Comentarios
% jri 22Jul15 - Advertencia si databin es mayor que 255




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
deltaTBin=1/binFreq; %Per�odo de binning
numFotCh=zeros(nrChannels, 1); %N�mero de fotones de cada canal

%Necesito primero calcular cu�ntos fotones hay por canal. �Esto se puede
%simplificar para no tener que repetir el find y la comparaci�n?
for cc=1:nrChannels, %Identifica los fotones de cada canal
    indsxCh=arrivalTimes(:, channelsCol)==channels(cc);
    numFotCh(cc)=numel(find(indsxCh==1));
end 

numFotonesMaximoCanal=max(numFotCh(:))+1;
data=zeros(numFotonesMaximoCanal, nrChannels); %Matriz de tiempos por canal
for cc=1:nrChannels, %Identifica los fotones de cada canal
    indsxCh=arrivalTimes(:, channelsCol)==channels(cc);
    numFotCh(cc)=numel(find(indsxCh==1));
    data(1:numFotCh(cc), cc)=arrivalTimes(indsxCh, macroTimeCol)+arrivalTimes(indsxCh, microTimeCol)-t0; %MT+mT-tiempo referencia
end %end for (cc)


MTmax=max(data(:)); %MT del �ltimo fot�n v�lido
numfildataBin=MTmax/(deltaTBin); %Nro. de filas de dataBin
if rem(MTmax,deltaTBin)==0,
    dimDataBin=ceil(numfildataBin)+1;
else
    dimDataBin=ceil(numfildataBin);
end

dataBin=zeros(dimDataBin, nrChannels, 'uint8');
for d=1:nrChannels
    binHasta=numFotCh(d); %l�mite superior del for anidado
    for dd=1:binHasta
        indice_bin=floor(data(dd,d)/deltaTBin);
        dataBin(indice_bin+1,d)=dataBin(indice_bin+1,d)+1;
    end %end for (dd)
end %end for (d)

if max(dataBin(:))==255
    disp('Error: FCSData es uint8, pero cada bin tiene m�s de 255 cuentas')
end
