function [Chi2 deltaParam ymodel] = ajusta_computeuncertainties (FUN, xdata, ydata, yerr, allparam, indparamvariables, jacob_mat)

% [Chi2 deltaParam ymodel] = ajusta_computeuncertainties (FUN, xdata, ydata, yerr, allparam, indparamvariables, jacob_mat);
% Calcula el Chi2 y las incertidumbres de los parámetros ajustados por ajusta_lsqnonlin

%   FUN es un handle a la función de ajuste
%   paramfit son los resultados del ajuste
%   jacob_mat es una matriz que contiene el jacobiano calculado por Matlab (corresponde a las derivadas de G respecto de los parámetros ajustados)
%
%  chi2 es chi2
%  deltaParam son las incertidumbres del ajusta
%  ymodel es el modelo (sólo los datos y)
%
% jri 3Feb2015



jacob_mat=full(jacob_mat);

numParamVariables=numel(indparamvariables);
alfa=zeros(numParamVariables);
numData=numel(ydata); 

for n=1:numParamVariables
    for m=1:numParamVariables
        alfa(n, m)=sum(jacob_mat(:,n).*jacob_mat(:,m));
    end
end

C=sqrt(inv(alfa));
for n=1:numParamVariables
    deltaParam(n)=C(n,n);
end

ymodel =FUN(allparam, xdata);

Chi2=sum(((ydata-ymodel)./yerr).^2)/(numData-numParamVariables); % El chi2 reducido se calcula dividiendo por el # de grados de libertad (calculado como la diferencia entre el # total de puntos de la correlación y el # de parámetros que queremos calcular)





