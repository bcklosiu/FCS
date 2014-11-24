function [FCSmean Gmean]=FCS_promedio(Mtotal, FCSintervalo, combinacion, deltat, tipocorrelacion)
% [FCSmean Gmean]=FCS_promedio(Mtotal, FCSintervalo, combinacion, deltat, tipocorrelacion);
% 
% Devuelve el promedio de las trazas temporales y de autocorrelación indicadas en combinacion
%   Mtotal es una matriz que contiene las trazas de autocorrelación y correlación cruzada de los intervalos. 
%   Mtotal es una matriz numpuntoscorrelacionx7xnumintervalos 
%       Mtotal (:,1, intervalo) contiene tdatacorr, que es la información temporal de la correlación
%       Mtotal (:,2, intervalo) es la autocorrelación del canal 1
%       Mtotal (:,3, intervalo) es el error de la autocorrelación del canal 1
%       Mtotal (:,4, intervalo) es la autocorrelación del canal 2
%       Mtotal (:,5, intervalo) es el error de la autocorrelación del canal 2
%       Mtotal (:,6, intervalo) es la correlación cruzada
%       Mtotal (:,7, intervalo) es el error de la correlación cruzada
%   FCSintervalo es una matriz que contiene las trazas temporales de los intervalos de xx s (en general 10 s). FCSintervalo es una matriz numpuntostemporalesx2xnumintervalos - el 2 es porque hay dos canales
%   combinacion es un vector que contiene elos índices de los intervalos que nos interesa promediar
%   deltat=1/sampfreq
%   tipocorrelación es una cadena de caracteres que indica que tipo de correlación calculará el programa ('auto', 'cross' o 'todas')
% 
% FCSmean (matriz numpuntosx2) es la media de la traza temporal de los intervalos indicados en el vector "combinacion" 
% Gmean es la media de las correlaciones y la suma en cuadratura de los errores de las correlaciones de los intervalos
% Gmean (:,1) es la información temporal de la correlacion (tdata)
% Gmean (:,2) es la media de las autocorrelaciones del canal 1
% Gmean (:,3) es la incertidumbre de la media de las autocorrelaciones del canal 1
% etc.
%
% jri & GdlH (12nov10)


Mtotal=double(Mtotal);
% FCSintervalo=double(FCSintervalo);
indices=zeros(1, size (FCSintervalo,3));
indices(combinacion)=1;
indices=logical(indices);
FCSmean=mean (FCSintervalo (:, : , indices),3); 
%numintervalos=size(FCSintervalo,3);
switch (tipocorrelacion)
    case 'todas'
        Gmean=zeros(size(Mtotal,1),7);
    otherwise
        Gmean=zeros(size(Mtotal,1),3);
end

Gmean(:,1)=Mtotal(:,1,1);
Gmean(:,2)=mean (Mtotal(:,2, indices),3);
Gmean(:,3)=sqrt (sum (Mtotal(:,3, indices).^2,3))/numel(combinacion);
if size(Gmean,2)==7
    Gmean(:,4)=mean (Mtotal(:,4, indices),3);
    Gmean(:,6)=mean (Mtotal(:,6, indices),3);
    Gmean(:,5)=sqrt (sum (Mtotal(:,5, indices).^2,3))/numel(combinacion);
    Gmean(:,7)=sqrt (sum (Mtotal(:,7, indices).^2,3))/numel(combinacion);
end
%FCS_representa (FCSmean, Gmean, deltat, tipocorrelacion)

