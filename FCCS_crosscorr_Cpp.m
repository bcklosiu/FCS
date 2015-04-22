function [G tdata]=FCCS_crosscorr_2(FCSdata, deltat, vectorindices)
%
% [G tdata]=FCCS_crosscorr(FCSdata, deltat, vectorindices);
%
% Calcula la correlacion cruzada siguiendo el artículo de WOHL01.
% La normalizacion se hace siguiendo el metodo simetrico. Por tanto, no calcula el sigmaIT
%
%   FCSdata tiene que ser una matriz de dos columnas: tiene datos de los 2 canales de la traza temporal
%   deltat es el inverso de la frecuencia de muestreo, es decir, la resolución del canal temporal
%   vectorindices es un vector que contiene los puntos en los que queremos que se calcule G
%
% Sólo hace el número de numpuntos que se le pida, aunque calcula la correlación con todos ellos
%
% GdlH, jri 12jul2010


FCSdata=double(FCSdata);
%numdata=size(FCSdata,1);
numpuntos=numel(vectorindices);
%Gtemp=zeros (numdata, 1, 'double');
%Gtempcuadrados=zeros (numdata, 1, 'double');
G=zeros(numpuntos,1,'double');
tdata=zeros (numpuntos, 1);
vectorindices=vectorindices(:)';
C_FCCS_crosscorr(G, tdata, FCSdata, deltat, vectorindices);

% k=0;
% for n=1:numpuntos
%     k=k+1;
%     for m=vectorindices(n)
%     Gtemp(1:numdata-m)=(FCSdata(1:numdata-m,1).*FCSdata(1+m:numdata,2)+FCSdata(1:numdata-m,2).*FCSdata(1+m:numdata,1))/2;
%     sumGtemp=sum(Gtemp(1:numdata-m));
%     % M1=sqrt(sum(FCSdata(1:numdata-m,1)).*sum(FCSdata(m:numdata,1)));
%     % M2=sqrt(sum(FCSdata(1:numdata-m,2)).*sum(FCSdata(m:numdata,2)));
%     %M12=M1*M2;
%     M1=sum(FCSdata(1:numdata-m,1)).*sum(FCSdata(m:numdata,2));
%     M2=sum(FCSdata(1:numdata-m,2)).*sum(FCSdata(m:numdata,1));
%     %  M12=(sum(FCSdata(:,1)).*sum(FCSdata(:,2)));
%     
%     M12=(M1+M2)/2;
%     Mmenosm=numdata-m;
%     G(k)=Mmenosm*sumGtemp/M12;
%     tdata(k)=m*deltat;
%     end
% end
G=G-1; %Estamos calculando la función de covarianza cruzada (que no es estrictamente la misma que la correlación cruzada)

%    G(m, 1)=(numdata-m)*sum(Gtemp(1:numdata-m))/(sum(FCSdata(m:numdata,1))*sum(FCSdata(1:numdata-m,1)));
