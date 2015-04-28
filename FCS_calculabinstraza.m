function [FCSTraza, tTraza]=FCS_calculabinstraza(FCSData, deltaT, binTime)
%
%[FCSTraza, tTraza]=FCS_calculabinstraza(FCSData, deltaT, binTime)
%   FCS_calculabinstraza es un rebinning de la traza para representarla
%   FCSData son los datos estilo ISS
%   deltaT es el periodo de muestreo de FCSData: deltaT=1/binFreq
%   binTime es el nuevo binning del tiempo
%
%
% jri 27Nov14
% jri 268Apr15

if not(isfloat(FCSData)) %De esta forma lo único que es double es la parte con la que hace el subbinning
    FCSData=double(FCSData);
end

numData=size(FCSData,1);
numCanales=size(FCSData,2);
tdatatemporal=linspace (deltaT, numData*deltaT, numData); %Tiempo de FCSData
tdatatemporal=tdatatemporal(:);
tplot=numData*deltaT; % Tiempo que dura la traza en segundos multiplicando el número de puntos por su intervalo temporal. Es como max (tdatatemporal)
binning=floor(binTime/deltaT); % Número de bins de FCSData en un bin temporal (binTime)
numPuntosTraza=floor(tplot/binTime); %Divide la traza en bins de duración binTime (en s) y calcula la media para cada uno de ellos

FCSTraza=zeros(numPuntosTraza, numCanales);

C_FCS_binning1(FCSTraza, FCSData, binning); %Este es el binning de Matlab que hizo Unai. Es equivalente a las tres líneas que siguen
% for nn=1:numPuntosTraza 
%         FCSTraza(nn, :)=sum(FCSData((nn-1)*binning+1:nn*binning, :));
% end

tTraza=(1:numPuntosTraza)*binTime;
tTraza=tTraza(:);
FCSTraza=uint16(FCSTraza);
