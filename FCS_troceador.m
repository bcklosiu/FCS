function FCS_intervalo = FCS_troceador(FCSdata, intervalos)

%
% FCS_intervalo = FCS_troceador(FCSdata, intervalos);
%
% Este programa fracciona las trazas temporales de FCCS según lo que se especifique en la variable numintervalos.
%   
%   FCSdata es la matriz de datos (autocorrelaciones y crosscorrelacion) generada por el programa ISSread
%   intervalos es el numero de intervalos en que queremos dividir la traza temporal
%
% gdh & jri - 22-7-2010
% gdh - 10may11 (Introducir la función class para determinar la precisión de FCSdata)

numdatos=size(FCSdata, 1);
numcanales=size(FCSdata, 2);

%Ahora lo hago en trozos
intervalo =floor(numdatos/intervalos);  %% El floor es necesario para poder analizar el photon mode
FCS_intervalo=zeros (intervalo, numcanales, intervalos, class(FCSdata));  %% class es para determinar la precision con que viene calculada FCSdata
for k=1:intervalos
    FCS_intervalo(:, :, k)=(FCSdata((k-1)*intervalo+1:k*intervalo,:));

end