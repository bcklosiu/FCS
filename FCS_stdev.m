function M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax)

%
%  M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax);
%
%   Este programa devuelve la función de correlación G y su desviacion estándar SD calculada por el tercer metodo descrito en el articulo de Wohland
%   et al. de 2001. Asimismo también devuelve los valores del tiempo de la curva de correlación, tdatacorr.
%   La forma de devolver estos datos es como una matriz M que contiene de 3 a 7 columnas con los datos del tiempo, correlación y desviación estándar.
%   Para la normalización no se tiene en cuenta el término Ginfinito (descrito en Wohl01) ya que nos introduce un error sistemático en el cálculo de la G
%
%   FCSData es un vector columna o una matriz de dos columnas que contiene
%   datos de la traza temporal de uno o dos canales, respectivamente.
%   tdatatraza es un vector columna con los datos temporales correspondientes
%   a FCSData.
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

numColumnasG=3; %Autocorrelación: G=[tdata, G, SD]
if numCanales>1
    numColumnasG=7; %Correlación cruzada: G=[tdata, G_ch1, SD_ch1, G_ch2, SD_ch2, Gcc, SDcc]
end

if numSubIntervalosError<2
    numSubIntervalosError=1;
end

[G tdatacorr]= FCS_multitau  (FCSData, deltaT, numSecciones, numPuntos, base, tLagMax);
numPuntosCorrelacion=size(G, 1);

SD=zeros(numPuntosCorrelacion, numColumnasG);
%Cálculo de SD a partir de la correlación de subintervalos. Si no SD=0 en
%todas las filas.
if numSubIntervalosError>1
    G_k=zeros(numSubIntervalosError, numPuntosCorrelacion, numColumnasG);
    g_norm= zeros(numPuntosCorrelacion, numColumnasG);
    SD_norm_p= zeros(numPuntosCorrelacion, numColumnasG);
    
    %Cálculo de G(0) y G(inf) como promedio de los primeros y últimos 5 puntos
    %respectimamente para la normalización de G y su error
    %Gt_inf=sum(G(end-4:end,:))/5;
    %Gt_0=sum(G(1:5,:))/5;
    
    %Ahora lo hago en trozos y calculo las correlaciones
    intervalo=floor(numData./numSubIntervalosError);
    
    %G_inf=zeros(size(G,3), numSubIntervalosError,1);
    %G_0=zeros(size(G,3), numSubIntervalosError);
    
    for k=1:numSubIntervalosError
        FCS_intervalos=FCSData((k-1)*intervalo+1:k*intervalo,:);
        %cpscanal_k(:,k)=round(sum(FCS_intervalos,1)/max(tdatatemporal_k));
        G_k(k,:,:)= FCS_multitau (FCS_intervalos, deltaT, numSecciones, numPuntos, base, tLagMax);
        %G_inf(:,k)=squeeze(sum(G_k(k, end-4:end, :))/5);
        %    G_0(:,k)=squeeze(sum(G_k(k, 1:5, :))/5);
        G_0=1; %Cambiado el 17 de Enero para evitar la normalización
        %     G_0(:,k)=Gt_0;
    end
     
    %Y calculo la media de las correlaciones
   
    G_0=G_0';
    %G_inf=G_inf';
    for m=1:numPuntosCorrelacion
        %g_norm(m,:)= sum((squeeze(G_k(:,m,:))-G_inf)./(G_0-G_inf))/numSubIntervalosError;
        g_norm(m,:)= sum(squeeze(G_k(:,m,:))./G_0)/numSubIntervalosError;  %Prescindimos de incluir Ginfinito porque en nuestro modelo de ajuste suponemos que es igual a cero
        for ll=1:size(G_k,3)
            %SD_norm_p(m,ll)=sqrt(sum(((squeeze(G_k(1:numSubIntervalosError,m,ll))-G_inf(:,ll))./(G_0(:,ll)-G_inf(:,ll))-g_norm(m,ll)).^2)/(numSubIntervalosError-1));
            SD_norm_p(m,ll)=sqrt(sum((squeeze(G_k(1:numSubIntervalosError, m,ll))./G_0-g_norm(m,ll)).^2)/(numSubIntervalosError-1));
        end
        
    end
    SD_norm=SD_norm_p/sqrt(numSubIntervalosError);
    
    for m=1:size(G_k, 3)
        %SD(:,ll)=SD_norm(:,ll)*(Gt_0(ll)-Gt_inf(ll));
        %SD(:, m)=SD_norm(:, m)*Gt_0;
        SD(:, m)=SD_norm(:, m);
    end
end

if numCanales>1 %Cuando es correlación cruzada o todas
    M=[tdatacorr G(:,1) SD(:,1) G(:,2) SD(:,2) G(:,3) SD(:,3)];
else %cuando es una autocorrelación
    M=[tdatacorr G(:,1) SD(:,1)];
end

