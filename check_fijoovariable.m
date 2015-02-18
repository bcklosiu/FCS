function [guess LB UB numparamvariables numparamfijos indparamvariables indparamfijos valorparamfijos]=...
    check_fijoovariable (paramlibre, valorparametro, indice, guess, LB, UB, valorLB, valorUB, numparamvariables, numparamfijos, indparamvariables, indparamfijos, valorparamfijos)
%Necesario para los ajustes

%Comprueba si los parámetros son fijos o variables para (1) añadirle los
%límites inferior y superior y (2) hacer un índice de parámetros variables
%para pasárselo a la función de ajuste

if paramlibre
    numparamvariables=numparamvariables+1;
    indparamvariables(numparamvariables)=indice;
    guess(numparamvariables)=valorparametro; %Si el parametro está libre usa el valor introducido como guess
    LB(numparamvariables)=valorLB; 
    UB(numparamvariables)=valorUB; 
else
    numparamfijos=numparamfijos+1;
    indparamfijos(numparamfijos)=indice;
    valorparamfijos(numparamfijos)=valorparametro;
    %Si el parámetro está fijo no se añade lower o upper bounds
end