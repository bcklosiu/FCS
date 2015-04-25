function M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax)

%
%  M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax);
%
%   Este programa devuelve la función de correlación G y la incertidumbre (error estándar) en cada punto de G (calculada por el tercer metodo descrito en el articulo de Wohland
%   et al. de 2001. Asimismo también devuelve los valores de tiempo (tau) en los que se calcula de la curva de correlación.
%   La forma de devolver estos datos es como una matriz M que contiene de 3 a 7 columnas con los datos del tiempo, correlación y error estándar de la media de los subintervalos.
%   Hay una M por cada intervalo, que se construye en FCS_matriz
%   Asumimos G(infinito)=0 
%
%   FCSData es un vector columna o una matriz de dos columnas que contiene datos de la traza temporal de uno o dos canales, respectivamente.
%   numSubIntervalosError es el numero de intervalos en que queremos dividir la traza temporal para calcular la desviación estándar.
%   deltaT=1/sampfreq
%   numSecciones es el numero de secciones (Parámetros Multi-tau)
%   numPuntos es el numero de puntos por seccion (Parámetros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Parámetros Multi-tau)
%   tLagMax es el último punto temporal con el que se hace correlación, en s
%
%   Si FCSData contiene datos de dos canales calcula también la correlación cruzada
%
% jri & GdlH (12nov10)
% Modificado el 26abr11 para hacer G_0 un escalar en lugar de un vector y evitar problemas al indicar tipoCorrelacion='todas'
% jri 20abr15 - Quito tipoCorrelacion y hago la correlación cruzada cuando hay dos canales en FCSData
% jri 24abr15 - No se calcula el error a partir de los subintervalos si numSubIntervalosError son 0 o 1


numData=size(FCSData,1);
numCanales=size(FCSData, 2); %Si hay dos canales calcula también la correlación cruzada
%Si hay dos canales hace la correlación cruzada automáticamente
if numCanales>1
    numCanales=3; %Dos canales más la correlación cruzada
end

[G tdatacorr]= FCS_multitau (FCSData, deltaT, numSecciones, numPuntos, base, tLagMax);
numPuntosCorrelacion=size(G, 1);

SD=zeros(numPuntosCorrelacion, numCanales);
SE=zeros(numPuntosCorrelacion, numCanales);
%Cálculo de SD a partir de la correlación de subintervalos. Si no SD=0 en todas las filas.
if numSubIntervalosError
    G_k=zeros(numSubIntervalosError, numPuntosCorrelacion, numCanales);
    gk_mean= zeros(numPuntosCorrelacion, numCanales); %La G de cada subIntervaloError promediada
    %Ahora divido cada intervalo en numSubIntervalosError trozos y calculo las subcorrelaciones 
    intervalo=floor(numData./numSubIntervalosError);
    for k=1:numSubIntervalosError
        FCS_intervalo=FCSData((k-1)*intervalo+1:k*intervalo, :);
        G_k(k, :, :)= FCS_multitau (FCS_intervalo, deltaT, numSecciones, numPuntos, base, tLagMax);
    end
    %Y calculo la media de las correlaciones
    for m=1:numPuntosCorrelacion
        gk_mean(m,:)= sum(squeeze(G_k(:,m,:)))/numSubIntervalosError; %Este es el promedio de los subIntervalosError
        for canal=1:numCanales
            %Calculo la desviación estándar
            SD(m, canal)=sqrt(sum((squeeze(G_k(1:numSubIntervalosError, m, canal))-gk_mean(m, canal)).^2)/(numSubIntervalosError-1)); %SD en cada punto
        end     
    end
    SE=SD/sqrt(numSubIntervalosError); %Convierte la desviación estándar en error estándar de la media de las curvas de cada subIntervalo
end

if numCanales>1 %Cuando es correlación cruzada o todas
    M=[tdatacorr G(:,1) SE(:,1) G(:,2) SE(:,2) G(:,3) SE(:,3)];
else %cuando es una autocorrelación
    M=[tdatacorr G(:,1) SE(:,1)];
end

