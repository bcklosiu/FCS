function [FCSTraza, tTraza, cps, FCSTrazaNorm, meanFCStraza]=FCS_calculabinstraza(FCSData, deltaT, binTime)
%
%[FCSTraza, tTraza, cpscanal, meanFCStraza]=FCS_calculabinstraza(FCSData, deltaT, binTime)
%   FCS_calculabinstraza es un rebinning de la traza para representarla
%   FCSData son los datos estilo ISS
%   deltaT es el periodo de muestreo de FCSData: deltaT=1/binFreq
%   binTime es el nuevo binning del tiempo
%
% Es una función que es llamada por FCS_representa y FCS_ajusta
%
% jri 27Nov14


numData=size(FCSData,1);
numCanales=size(FCSData,2);
tdatatemporal=linspace (deltaT, numData*deltaT, numData); %Tiempo de FCSData
tdatatemporal=tdatatemporal(:);
tplot=numData*deltaT; % Tiempo que dura la traza en segundos multiplicando el número de puntos por su intervalo temporal. Es como max (tdatatemporal)
binning=floor(binTime/deltaT); % Número de bins de FCSData en un bin temporal (binTime)
numPuntosTraza=floor(tplot/binTime); %Divide la traza en bins de duración binTime (en s) y calcula la media para cada uno de ellos

FCSTraza=zeros(numPuntosTraza, numCanales);
FCSTrazaNorm=zeros(numPuntosTraza, numCanales);
tTraza=zeros(numPuntosTraza, 1);

C_FCS_binning1(FCSTraza, FCSData, binning); %Este es el binning de Matlab que hizo Unai. Es equivalente a las tres líneas que siguen
% for nn=1:numPuntosTraza 
%         FCSTraza(nn, :)=sum(FCSData((nn-1)*binning+1:nn*binning, :));
% end

tTraza=(1:numPuntosTraza)*binTime;
tTraza=tTraza(:);
cps=round(sum(FCSData, 1)/max(tdatatemporal));
meanFCStraza=mean(FCSTraza);
for canal=1:numCanales
    FCSTrazaNorm(:,canal)=FCSTraza(:,canal)/meanFCStraza(canal);
end

