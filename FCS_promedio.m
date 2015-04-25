function [FCSmean Gmean]=FCS_promedio(Mtotal, FCSintervalo, combinacion, usaSubIntervalosError)

% [FCSmean Gmean]=FCS_promedio(Mtotal, FCSintervalo, combinacion, usaSubIntervalosError);
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
%
%   Si usaSubIntervalosError=true, el error estándar de cada punto es el SD de las curvas que se promedian entre la raíz del número de curvas
%   Si usaSubIntervalosError=false, el error estándar de cada punto calculado a partir de la suma cudrática de la incertidumbre de los subintervalos
%
% FCSmean (matriz numpuntosx2) es la media de la traza temporal de los intervalos indicados en el vector "combinacion"
% Gmean es la media de las correlaciones y la suma en cuadratura de los errores de las correlaciones de los intervalos
% Gmean (:,1) es la información temporal de la correlacion (tdata)
% Gmean (:,2) es la media de las autocorrelaciones del canal 1
% Gmean (:,3) es la incertidumbre de la media de las autocorrelaciones del canal 1
% etc.
%
%
% jri & GdlH (12nov10)
% jri - 2Feb15 Quito deltat porque no lo usamos. Antes era: [FCSmean Gmean]=FCS_promedio(Mtotal, FCSintervalo, combinacion, deltat, tipocorrelacion);
% jri - 20abr15 Cambio el tipocorrelacion
% jri - 24Abr15 Cálculo del error estándar de la media a partir de las curvas con las que se hace el promedio


indices=zeros(1, size (FCSintervalo,3));
indices(combinacion)=1;
indices=logical(indices);
FCSmean=mean(FCSintervalo (:, : , indices),3);
numPuntosCorrelacion=size(Mtotal, 1);
Gmean=zeros(numPuntosCorrelacion, size(Mtotal, 2));
numCurvasPromediadas=numel(combinacion);

Gmean(:,1)=Mtotal(:,1,1);
Gmean(:,2)=mean (Mtotal(:,2, indices),3);
if usaSubIntervalosError %Usa el SEM de los subintervalos para calcular la SEM de la traza promedio
    Gmean(:,3)=sqrt (sum (Mtotal(:,3, indices).^2,3))/numel(combinacion);   %Suma cuadrática de los errores
else %Si no usa cada uno de los intervalos
    Gmean(:,3)=stderrG(squeeze(Gmean(:,2)), squeeze(Mtotal(:,2, indices)), numCurvasPromediadas);
end
if size(Gmean,2)==7
    Gmean(:,4)=mean (Mtotal(:,4, indices),3);
    Gmean(:,6)=mean (Mtotal(:,6, indices),3);
    if usaSubIntervalosError
        Gmean(:,5)=sqrt (sum (Mtotal(:,5, indices).^2,3))/numCurvasPromediadas;   %Suma cuadrática de los errores
        Gmean(:,7)=sqrt (sum (Mtotal(:,7, indices).^2,3))/numCurvasPromediadas;
    elseif numCurvasPromediadas>1 
        Gmean(:,5)=stderrG(squeeze(Gmean(:,4)), squeeze(Mtotal(:,4, indices)), numCurvasPromediadas);
        Gmean(:,7)=stderrG(squeeze(Gmean(:,6)), squeeze(Mtotal(:,6, indices)), numCurvasPromediadas);
    end
end

function SE=stderrG (Gpromedio, Gintervalos, numCurvasPromediadas)
%Calcula el error estándar de la media de Gintervalos
numPuntosCorrelacion=size(Gpromedio, 1);
SD=zeros(numPuntosCorrelacion, 1);
for tau=1:numPuntosCorrelacion
    SD(tau)=sqrt(sum((Gintervalos(tau, :)-Gpromedio(tau)).^2)/(numCurvasPromediadas-1));
end
SE=SD/sqrt(numCurvasPromediadas);
