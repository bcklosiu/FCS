function [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgIN)

% [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgIN);
%
% ALINEACI�N ESPACIAL DE imgIN
% 1- Alinea la m�ximos de la membrana (matriz imgALIN). 2- Suma cada fila de la imagen
% alineada. 3- Ajusta la suma a una gaussiana. 4- Selecciona 5sigma de la
% matriz alineada. 5- Suma cada columa de la matriz 5sigma y crea imgALIN_5sigmaSum.
% 6- Crea FCSdataALIN: Selecciona los datos v�lidos (5sigma) de FCSdataIN. 
% 
% imgALIN - imgIN con los m�ximos alineados
% sigma2_5 - 
% indMaxCadaLinea - Contiene los m�ximos de cada l�nea

numLines=size(imgIN,1);
indMaxCadaLinea=zeros(numLines,1); %Contiene los m�ximos de cada l�nea
imgInSum1=sum(imgIN,1); %Suma las filas de imgIN SIN ordenar
indMaximgInSum1=find(imgInSum1==max(imgInSum1)); %Indice del m�ximo de la suma total
indMaxLine1=find(imgIN(1,:)==max(imgIN(1,:))); % Indice del m�ximo de la linea 1
if size(indMaxLine1,2)>1 %Si hay m�s de un m�ximo en la l�nea, cogemos el que m�s cerca est� del m�ximo total
    [difMinLine1,indMaxLine1_2]=min(abs(indMaxLine1-indMaximgInSum1));
    indMaxLine1=indMaxLine1(indMaxLine1_2);
end
indMaxCadaLinea(1,1)=indMaxLine1;

for m1=2:numLines %Busca el m�ximo de cada l�nea
    indMaxLinem1=find(imgIN(m1,:)==max(imgIN(m1,:))); % Indice del m�ximo de cada l�nea
    if size(indMaxLinem1,2)>1 %Si hay m�s de un m�ximo en la l�nea, cogemos el que m�s cerca est� del m�ximo total
        [difMinLinem1,indMaxLinem1_2]=min(abs(indMaxLinem1-indMaximgInSum1)); 
        indMaxLinem1=indMaxLinem1(indMaxLinem1_2);
    end
    indMaxCadaLinea(m1,1)=indMaxLinem1;
end

imgALIN=zeros(size(imgIN)); %Imagen con m�ximos alineados
for m2=1:numLines % Alinea la imagen
    difMaxLine1=indMaxCadaLinea(m2,1)-indMaxCadaLinea(1,1);
    if difMaxLine1<=0
        imgALIN(m2,1-difMaxLine1:end)=imgIN(m2,1:end+difMaxLine1);
    else
        imgALIN(m2,1:end-difMaxLine1)=imgIN(m2,1+difMaxLine1:end);
    end
end

imgALINsum=sum(imgALIN,1);
options=optimset (optimset('lsqnonlin'), 'Display','final-detailed'); %Opciones de ajuste
guess=[min(imgALINsum),max(imgALINsum)-min(imgALINsum),find(imgALINsum==max(imgALINsum)),1]; %Par�metros iniciales para el ajuste
paramfit = lsqnonlin(@err_gauss, guess, [], [], options, 1:numel(imgALINsum), imgALINsum); %Ajuste por m�nimos cuadrados de imgALINsum
sigma2_5=round(2.5*paramfit(4));
imgALIN_5sigma=imgALIN(:,find(imgALINsum==max(imgALINsum))-sigma2_5:find(imgALINsum==max(imgALINsum))+sigma2_5);
imgALIN_5sigmaSum=sum(imgALIN_5sigma,2);
G = ULS_gauss(paramfit, 1:numel(imgALINsum)); %Curva ajustada
figure;plot(imgALINsum); hold on; plot(G,'r'); legend('Perfil imagen alineada', 'Curva ajustada');