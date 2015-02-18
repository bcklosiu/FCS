function [paramName, paramUnits, numParam, fittingFunction]=parsefittingfunctionfile (fname)


% param(n)=Parameter, Meaning, Units, Value, Lower bound, Upper bound <-
% Esto no está implementado. Sólo pilla el nombre y las unidades

if not(strcmpi(fname(end-2:end), '.m'))
    fname=[fname '.m'];
end
fid=fopen(fname, 'r');

idxParam=0;
strbegin='parameters description begins here';
while not(feof(fid))
    linea=fgets(fid);
    if strcmp(linea(1), '%')
        linea=linea(2:end);
        parampos=strfind(linea, 'param');
        if parampos
            linea=linea (parampos+5:end);
            [startParentesis, endparentesis, tokenindex,  matchStr, tokenstr, exprnames, splitstr]=regexp(linea,'\((.*?)\)');
            if startParentesis
                [startIndex, endIndex, tokenindex,  matchStr, tokenstr, exprnames, splitstr]=regexp(matchStr{1},'\d*'); %sólo comprueba el primer paréntesis
                if startIndex
                    linea=linea(endparentesis(1)+1:end);
                    idxParam=idxParam+1;
                    igualpos=strfind(linea, '=');
                    if igualpos
                        %Comprueba el nombre del parámetro
                        [startIndex, endIndex, tokenindex,  matchStr, tokenstr, exprnames, splitstr]=regexp(linea(igualpos+1:end),'\S*'); %sólo comprueba el primer paréntesis
                        paramName{idxParam}=matchStr{1};
                        semiColon=strfind(paramName{idxParam}, ';');
                         if semiColon
                             paramName{idxParam}=paramName{idxParam}(1:semiColon-1);
                         end
                        %Y las unidades (si las tiene)
                        [startIndex, endIndex, tokenindex,  matchStr, tokenstr, exprnames, splitstr]=regexp(linea,'\[(.*?)\]');
                        if startIndex
                            paramUnits{idxParam}=matchStr{1}(2:end-1);
                        else
                            paramUnits{idxParam}='';
                        end
                    end
                end
                
            end
        end
    end
end
numParam=idxParam;
fittingFunction=str2func(fname(1:end-2)); %Luego tendré que hacer para quitarle el path