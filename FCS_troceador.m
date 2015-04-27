function FCS_intervalo = FCS_troceador(FCSData, numIntervalos)

%
% FCS_intervalo = FCS_troceador(FCSData, intervalos);
%
% Este programa fracciona las trazas temporales de FCCS según lo que se especifique en la variable numintervalos.
%   
%   FCSData es la matriz de datos (autocorrelaciones y crosscorrelacion) generada por el programa ISSread
%   intervalos es el numero de intervalos en que queremos dividir la traza temporal
%
% gdh & jri - 22-7-2010
% gdh - 10may11 (Introducir la función class para determinar la precisión de FCSData)
% jri - 27Apr15 - Cambio de nombres de las variables

numData=size(FCSData, 1);
numCanales=size(FCSData, 2);

%Ahora lo hago en trozos
numDatosPorIntervalo =floor(numData/numIntervalos);  %% El floor es necesario para poder analizar el photon mode
FCS_intervalo=zeros (numDatosPorIntervalo , numCanales, numIntervalos, class(FCSData));  %% class es para determinar la precision con que viene calculada FCSData
for k=1:numIntervalos
    FCS_intervalo(:, :, k)=(FCSData((k-1)*numDatosPorIntervalo+1:k*numDatosPorIntervalo, :));
end