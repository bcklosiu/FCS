function pages=pagerangeparser (rangeString, startPage, endPage)

% pages=pagerangeparser (rangeString, startPage, endPage)
% 
% Divide un string (rangeString) en el número de páginas separadas por "," y "-"
% startPage y endPage son la primera y última página del documento
%
% Si en un rango no se pone la primera, entiende que va desde la primera
% página: por ej. -10 son las 10 primeras páginas
% Si no se pone la última, el rango son todas las páginas menos la última
% Si no se pone la primera, tiene que ir al principio; si no se pone la
% última tiene que ir al final
%
% Por ejemplo: rangeString puede ser '-3, 6, 15, 9-12, 23-'
%
% jri - 2Feb15

[startIndex, endIndex, tokenIndex,  matchStr, tokenStr, exprNames, splitStr]=regexp(rangeString, '\d+');

commas=strfind(rangeString, ',');
pageRange=strfind(splitStr, '-');

numStr=numel(matchStr);

n=0;
strIndex=0;

pages=[];
flagError=false;
for strIndex=1:numStr
    
    if n<0
        flagError=true;
        break;
    end
    n=n+1;
    pages(n)=str2double(matchStr{strIndex});
    
    if pages(n)>endPage
        flagError=true;
        break;
    end
   
    if pageRange{strIndex}
        if strIndex==1
            insertNumPages=pages(n)-startPage;
            pages(n:n+insertNumPages)=startPage:str2double(matchStr{strIndex});
            n=n+insertNumPages;
        end
    elseif pageRange{strIndex+1}
        if strIndex==numStr
            insertNumPages=endPage-pages(n);
            pages(n+1:n+insertNumPages)=pages(n)+1:endPage;
        else
            pageFinalTmp=str2double(matchStr{strIndex+1})-1;
            insertNumPages=pageFinalTmp-pages(n);
            %            pages(n)+1:pageFinalTmp-1;
            pages(n+1:n+insertNumPages)=pages(n)+1:pageFinalTmp;
        end
        n=n+insertNumPages;
    end
end
pages=sort(pages);
if flagError
    pages=[];
end


%{
for strIndex=1:numStr
    endPageTmp=pages(n);
    if pageRange{strIndex+1}
        startPageTmp=pages(n)+1;
        if strIndex+1==numStr
            endPageTmp=endPage;
        end
    end
    if pageRange{strIndex}
        startPageTmp
        endPageTmp
        insertNumPages=pages(n)-startPageTmp;
        pages(n:n+insertNumPages)=startPageTmp:endPageTmp;
        n=n+insertNumPages;
        
    end
end

%}