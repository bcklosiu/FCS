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
%   Con frecuencia se llama FCSData
%
% Modificado jri para incluir el microtime 11abr14
% Modificado por Unai para calcular automáticamente el nº de canales
%
% jri - 26Nov14 - Considera que arrivalTimes de FCS puntual sólo tiene 3 columnas en vez de 6
% jri 4May15 - Reduzco el tamaño de la matriz temporal de fotones al número máximo de fotones por canal X 2 canales
% jri 4May15 - Convierto FCSData en uint8
% jri 21Jul15 - Comentarios
% jri 22Jul15 - Advertencia si databin es mayor que 255
% Unai: 13ago2015 - arrivalTimes es de tipo struct

arrivalTimes_MTmT=arrivalTimes.MacroMicroTime;
arrivalTimes_c=arrivalTimes.channel;
channels=sort(unique(arrivalTimes_c),'ascend');
nrChannels=numel(channels);
deltaTBin=1/binFreq; %Período de binning
numFotCh=zeros(nrChannels, 1); %Número de fotones de cada canal

%Necesito primero calcular cuántos fotones hay por canal. ¿Esto se puede
%simplificar para no tener que repetir el find y la comparación?
for cc=1:nrChannels, %Identifica los fotones de cada canal
    indsxCh=arrivalTimes_c==channels(cc);
    numFotCh(cc)=numel(find(indsxCh==1));
end 

numFotonesMaximoCanal=max(numFotCh(:));
data=zeros(numFotonesMaximoCanal, nrChannels); %Matriz de tiempos por canal
for cc=1:nrChannels, %Identifica los fotones de cada canal
    indsxCh=arrivalTimes_c==channels(cc);
    numFotCh(cc)=numel(find(indsxCh==1));
    data(1:numFotCh(cc), cc)=arrivalTimes_MTmT(indsxCh,1)+arrivalTimes_MTmT(indsxCh,2)-t0; %MT+mT-tiempo referencia
end %end for (cc)
   
MTmax=max(data(:)); %MT del último fotón válido
numfildataBin=MTmax/(deltaTBin); %Nro. de filas de dataBin
if rem(MTmax,deltaTBin)==0,
    dimDataBin=ceil(numfildataBin)+1;
else 
    dimDataBin=ceil(numfildataBin);
end
    
dataBin=zeros(dimDataBin, nrChannels, 'uint16');
for d=1:nrChannels
    binHasta=numFotCh(d); %límite superior del for anidado
    for dd=1:binHasta
        indice_bin=floor(data(dd,d)/deltaTBin);
        dataBin(indice_bin+1,d)=dataBin(indice_bin+1,d)+1;
    end %end for (dd)
end %end for (d)

% if max(dataBin(:))==255, 2^16????
%     disp('Error: FCSData es uint8, pero cada bin tiene más de 255 cuentas')
% end
