function [G tdata]=FCS_autocorr_2(FCSdata, deltat, vectorindices)
% 
% [G tdata]=FCS_autocorr(FCSdata, deltat, vectorindices);
% Calcula la autocorrelación siguiendo el artículo de WOHL01
%
%   FCSdata tiene la traza temporal. FCSdata tiene que ser un vector columna: sólo tiene datos de un canal de la traza temporal
%   deltat es el inverso de la frecuencia de muestreo, es decir, la resolución del canal temporal
%   vectorindices es un vector que contiene los puntos en los que queremos que se calcule G
%
%
% Sólo hace el número de numpuntos que se le pida, aunque calcula la correlación con todos ellos
%
% GdlH, jri 12jul2010


FCSdata=double(FCSdata);
%numdata=numel(FCSdata);
%Gtemp=zeros (numdata, 1, 'double');
%Gtempcuadrados=zeros (numdata, 1, 'double');
numpuntos=numel(vectorindices);
G=zeros(numpuntos,1,'double');
%sigmaG=zeros(numpuntos,1,'double');
tdata=zeros (numpuntos, 1); 
%k=0;
% for n=1:numpuntos
%     k=k+1;
%     for m=vectorindices(n)
%         Gtemp(1:numdata-m)=FCSdata(1:numdata-m).*FCSdata(1+m:numdata);
%         %size(Gtemp)
%         sumGtemp=sum(Gtemp(1:numdata-m));
%         Mdir=sum(FCSdata(1:numdata-m));
%         Mdel=sum(FCSdata(m:numdata));
%         %    disp ('aquí')
%         %    disp(numdata)
%         Mmenosm=numdata-m;
%         %    disp(k)
%         %    disp (m)
%         %size (Mmenosm*sumGtemp/(Mdel*Mdir))
%         G(k)=Mmenosm*sumGtemp/(Mdel*Mdir);
%         
%         %------------Normalizacion asimetrica----------------------
%         %    Gtemp(1:numdata-m)=FCSdata(1:numdata-m).*FCSdata(1+m:numdata);
%         %    sumGtemp=sum(Gtemp(1:numdata-m));
%         %    Mmenosm=numdata-m;
%         %    denom_asim=((sum(FCSdata(1:numdata)))./numdata).^2;
%         %    G(m)=(sumGtemp./Mmenosm)./denom_asim;
%         %------------Normalizacion asimetrica----------------------
%         
%         %Gtempcuadrados(1:numdata-m)=Gtemp(1:numdata-m).^2;
%         %sumGtempcuadrados=sum(Gtempcuadrados(1:numdata-m));  %Esto era para el
%         %calcular el sigmaIT
%         %sigmaG(m)=Mmenosm*sqrt(sumGtempcuadrados-(sumGtemp^2)/Mmenosm)/(Mdel*Mdir);
%         tdata(k)=m*deltat;
%     end
% end

C_FCS_autocorr(G, tdata, FCSdata, deltat, vectorindices);

G=G-1; %Estamos calculando la función de autocovarianza (que no es estrictamente la misma que la autocorrelación)

% Esta es la expresión para la G con normalización estándar
%    G(m, 1)=(numdata-m)*sum(Gtemp(1:numdata-m))/(sum(FCSdata(m:numdata,1))*sum(FCSdata(1:numdata-m,1))); 


