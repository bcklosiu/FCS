function SE=FCS_stderrG (Gpromedio, Gintervalos)
%
%SE=FCS_stderrG (Gpromedio, Gintervalos, numCurvasPromediadas)
%Calcula el error estándar de la media de Gintervalos
% Gpromedio sólo contiene los datos de la correlación (no contiene el tiempo
% Gintervalos es una matriz con numPuntosCorrelacion X numCurvasPromediadas
% o numPuntosCorrelacionXcanalesX 1 X numCurvasPromediadas para poder pasársela sin squeeza
%
% jri - 26Apr15


%Atención a lo mejor tengo que hacer squueze de Gpromedio o Gpromedio(:)?
Gintervalos=squeeze(Gintervalos); %Porque a veces llega con los datos del canal en la dimensión intermedia

numCurvasPromediadas=size(Gintervalos, 2);
numPuntosCorrelacion=size(Gpromedio, 1);
SD=zeros(numPuntosCorrelacion, 1);

for tau=1:numPuntosCorrelacion
    SD(tau)=sqrt(sum((Gintervalos(tau, :)-Gpromedio(tau)).^2)/(numCurvasPromediadas-1));
end
SE=SD/sqrt(numCurvasPromediadas);