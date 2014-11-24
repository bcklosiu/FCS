function [Data_bin, sampfreq_bin, deltat_bin]=FCS_binning_FIFO_pixel1(FCSdata, binfreq, t0)

% [Data_bin, sampfreq_bin, deltat_bin]=FCS_binning_FIFO_pixel1(FCSdata, binfreq, t0);
%
% Esta función hace un binning temporal del archivo que le especifiquemos,
% INPUT ARGUMENTS:
%   FCSdata - es la matriz de una o dos columnas que devuelve el programa ISSread
%   binfreq - es la frecuencia que queremos aplicar al binning (en Hz)
%   t0 - es el tiempo de referencia que se le resta a todos los canales
% OUTPUT ARGUMENTS:
%   Data_bin - es la nueva matriz con la traza temporal y el binning aplicado
%   sampfreq_bin - es igual a binfreq
%   deltat_bin - es el deltat para la nueva frecuencia de binning
%
% Modificado jri para incluir el microtime 11abr14
% Modificado por Unai para calcular automáticamente el nº de canales

channels=sort(unique(FCSdata(:,6)),'ascend');
nrChannels=numel(channels);
sampfreq_bin=binfreq;
deltat_bin=1/sampfreq_bin; %en segundos
numFotCh=zeros(nrChannels,1); %Número de fotones de cada canal  
Data=zeros(size(FCSdata,1),nrChannels); %Matriz de tiempos por canal

for cc=1:nrChannels, %Identifica los fotones de cada canal
    indsxCh=FCSdata(:,6)==channels(cc);
    numFotCh(cc)=numel(find(indsxCh==1));
    Data(1:numFotCh(cc),cc)=FCSdata(indsxCh,4)+FCSdata(indsxCh,5)-t0; %MT+mT-tiempo referencia
end %end for (cc)
Data(max(numFotCh)+1:end,:)=[];

MTmax=max(Data(:)); %MT del último fotón válido
numfilData_bin=MTmax/(deltat_bin); %Nro. de filas de Data_bin
if rem(MTmax,deltat_bin)==0,
    dimData_bin=ceil(numfilData_bin)+1;
else
    dimData_bin=ceil(numfilData_bin);
end

Data_bin=zeros(dimData_bin,nrChannels);
for d=1:nrChannels,
    binHasta=numFotCh(d); %límite superior del for anidado
    for dd=1:binHasta,
        indice_bin=floor(Data(dd,d)/deltat_bin);
        Data_bin(indice_bin+1,d)=Data_bin(indice_bin+1,d)+1;
    end %end for (dd)
end %end for (d)

