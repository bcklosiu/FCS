function cpsIntervalos=FCS_calculacpsintervalos (FCSData, numIntervalos, binFreq)
%
%cpsIntervalos=FCS_calculacpsintervalos (FCSData, numIntervalos, binFreq)
%
% Calcula las cps en cada intervalo sin dividir FCSData en intervalos de
% memoria
%
% jri 4may15

numData=size(FCSData, 1);
numCanales=size(FCSData, 2);
deltaTBin=1/binFreq;
numDataIntervalos =floor(numData/numIntervalos);  %% El floor es necesario para poder analizar el photon mode
cpsIntervalos=zeros(numIntervalos, numCanales, 'double');

for intervalo=1:numIntervalos
    FCSintervalo=FCSData((intervalo-1)*numDataIntervalos+1:intervalo*numDataIntervalos, :);
    cpsIntervalos(intervalo, :)=round(squeeze(sum(FCSintervalo, 1, 'double'))/(numDataIntervalos*deltaTBin));
end

