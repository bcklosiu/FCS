function [M]= FCS_stdev (FCSdata, numIntervalos, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion)

%
%  [M]= FCS_stdev (FCSdata, numIntervalos, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion);
%
%   Este programa devuelve la funci�n de correlaci�n G y su desviacion est�ndar SD calculada por el tercer metodo descrito en el articulo de Wohland
%   et al. de 2001. Asimismo tambi�n devuelve los valores del tiempo de la curva de correlaci�n, tdatacorr.
%   La forma de devolver estos datos es como una matriz M que contiene de 3 a 7 columnas con los datos del tiempo, correlaci�n y desviaci�n est�ndar.
%   Para la normalizaci�n no se tiene en cuenta el t�rmino Ginfinito (descrito en Wohl01) ya que nos introduce un error sistem�tico en el c�lculo de la G
%   
%   FCSdata es un vector columna o una matriz de dos columnas que contiene
%   datos de la traza temporal de uno o dos canales, respectivamente.
%   tdatatraza es un vector columna con los datos temporales correspondientes
%   a FCSdata.
%   numIntervalos es el numero de intervalos en que queremos dividir la traza temporal para calcular la desviaci�n est�ndar.
%   deltaT=1/sampfreq
%   numSecciones es el numero de secciones (Par�metros Multi-tau)
%   numPuntos es el numero de puntos por seccion (Par�metros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Par�metros Multi-tau)
%   tLagMax es el �ltimo punto temporal con el que se hace correlaci�n, en s
%   tipocorrelaci�n es una cadena de caracteres que indica que tipo de correlaci�n calcular� el programa ('auto', 'cross' o 'todas')
%
% jri & GdlH (12nov10)
% Modificado el 26abr11 para hacer G_0 un escalar en lugar de un vector y evitar problemas al indicar tipoCorrelacion='todas'

numdatos=size(FCSdata,1);
switch (tipoCorrelacion)
    case 'auto'
        z=1;
    otherwise
        z=2;
end


tdatatemporal=linspace (deltaT, numdatos*deltaT, numdatos)';
cpscanal=round(sum(FCSdata,1)/max(tdatatemporal));
[G tdatacorr]= FCS_multitau  (FCSdata, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion);
%Gt_inf=sum(G(end-4:end,:))/5;
% Gt_0=sum(G(1:5,:))/5;
Gt_0=1; %Cambiado el 17 de Enero para evitar la normalizaci�n


%Ahora lo hago en trozos y calculo las correlaciones
intervalo=floor(numdatos./numIntervalos);
FCS_intervalos=zeros (intervalo, z);
tdatatemporal_k=linspace (deltaT, intervalo*deltaT, intervalo)';
%G_inf=zeros(size(G,3), numIntervalos,1);
%G_0=zeros(size(G,3), numIntervalos);
for k=1:numIntervalos
    FCS_intervalos=FCSdata((k-1)*intervalo+1:k*intervalo,:);
        cpscanal_k(:,k)=round(sum(FCS_intervalos,1)/max(tdatatemporal_k));
    [G_k(k,:,:) tdata_k(:,1)]= FCS_multitau (FCS_intervalos, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion);
    %G_inf(:,k)=squeeze(sum(G_k(k, end-4:end, :))/5);
%    G_0(:,k)=squeeze(sum(G_k(k, 1:5, :))/5);
    G_0=1; %Cambiado el 17 de Enero para evitar la normalizaci�n
%     G_0(:,k)=Gt_0;
end


corr_size=size(G_k,2);
%Y calculo la media de las correlaciones
g_norm= zeros(corr_size,size(G_k,3));
SD_norm_p= zeros(corr_size,size(G_k,3));
G_0=G_0';
%G_inf=G_inf';



for m=1:corr_size
    %g_norm(m,:)= sum((squeeze(G_k(:,m,:))-G_inf)./(G_0-G_inf))/numIntervalos;
    g_norm(m,:)= sum(squeeze(G_k(:,m,:))./G_0)/numIntervalos;  %Prescindimos de incluir Ginfinito porque en nuestro modelo de ajuste suponemos que es igual a cero
    
    for ll=1:size(G_k,3)
        %SD_norm_p(m,ll)=sqrt(sum(((squeeze(G_k(1:numIntervalos,m,ll))-G_inf(:,ll))./(G_0(:,ll)-G_inf(:,ll))-g_norm(m,ll)).^2)/(numIntervalos-1));
        SD_norm_p(m,ll)=sqrt(sum((squeeze(G_k(1:numIntervalos, m,ll))./G_0-g_norm(m,ll)).^2)/(numIntervalos-1));
    end
        
end

SD_norm=SD_norm_p/sqrt(numIntervalos);
for ll=1:size(G_k,3)
    %SD(:,ll)=SD_norm(:,ll)*(Gt_0(ll)-Gt_inf(ll));
    SD(:,ll)=SD_norm(:,ll)*Gt_0;
end



tplot=size(FCSdata,1)*deltaT; % Mide el tiempo que dura la traza en segundos multiplicando el numero de puntos por su intervalo temporal
%dataplot=round(tplot/deltaT);
%plot (tdata(1:tplot/timebase), FCSData (1:tplot/timebase,1))

tiempodetrocitos=0.250; % en s
        deltaTp=round(tiempodetrocitos/deltaT);

if z==2 %z=2 cuando es correlaci�n cruzada o todas 
       if tipoCorrelacion=='todas'
         M=[tdatacorr G(:,1) SD(:,1) G(:,2) SD(:,2) G(:,3) SD(:,3)];
       else
         M=[tdatacorr G(:,1) SD(:,1)];
    end

    
else %cuando es una autocorrelaci�n 
    M=[tdatacorr G(:,1) SD(:,1)];
end
%FCS_representa (FCSdata, M, deltaT, tipoCorrelacion)
    

% figure %Representa la razon entre las trazas de ambos canales
% plot (tmean, gkmean(:,1)./gkmean(:,2))
% xlabel ('Tiempo (s)')
% ylabel ('Raz�n C1/C2')






    
