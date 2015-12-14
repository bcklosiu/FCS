function [FCSdataALINcorregido,tPromedioLS]=FCS_membraneAlignment_time(FCSdataIN, lineSync, pixelSync, imgIN, indLineasFCS, indLineasLS, indLineasPS, offset, indMaxCadaLinea, sigma2_5)

% [FCSdataALINcorregido,imgALIN,tPromedioLS,t0]=FCS_membraneAlignment_time(FCSdataIN, lineSync, pixelSync, imgIN, indLineasFCS, indLineasLS, indLineasPS, offset, indMaxCadaLinea, sigma2_5);
%
% ALINEACIÓN TEMPORAL DE imgIN y FCSdataIN
% offset indica el nº de píxeles que hay que sumarle a la imagen (para imágenes recortadas)
% indLineasFCS indica las líneas de FCSdataIN que han de ser analizadas.
% indLineasPS indica las líneas de pixelSync que han de ser analizadas.
% FCSdataALINcorregido es la matriz de fotones alineados (5sigma) y corregidos temporalmente: corrige el tiempo que se pierde en cada cambio de frame 
% y el tiempo con respecto al pixel de referencia (alineado).
% tPromedioLS es el tiempo de escaneo de una línea.
% 
% 12ago15: Cambios Unai. FCSdata IN, lineSync y pixelSync son variables de entrada de tipo struct. FCSdataALINcorregido es una variable de salida de tipo struct.

%%
FCSdata_flp=FCSdataIN.frameLinePixel;
FCSdata_MTmT=FCSdataIN.MacroMicroTime;
FCSdata_c=FCSdataIN.channel;
FCSdataINcut=FCSdata_flp(indLineasFCS,:);
FCSdataINcut_MTmT=FCSdata_MTmT(indLineasFCS,:);
FCSdataINcut_c=FCSdata_c(indLineasFCS);
offsetFramesFCS=FCSdataINcut(1,1);
FCSdataINcut(:,1)=FCSdataINcut(:,1)-offsetFramesFCS; % Para poner el primer frame a 0 por si indLinesFCS no tiene datos para el primer frame
lineSync_fl=lineSync.frameLine;
lineSync_t=lineSync.time;
lineSynccut_fl=lineSync_fl(indLineasLS,:);
lineSynccut_t=lineSync_t(indLineasLS,:);
lineSynccut_fl(:,1)=lineSynccut_fl(:,1)-lineSynccut_fl(1,1); % Para poner el primer frame a 0 por si indLinesLS no tiene datos para el primer frame
pixelSync_flp=pixelSync.frameLinePixel;
pixelSync_t=pixelSync.time;
pixelSynccut_flp=pixelSync_flp(indLineasPS,:);
pixelSynccut_t=pixelSync_t(indLineasPS,:);
pixelSynccut_flp(:,1)=pixelSynccut_flp(:,1)-pixelSynccut_flp(1,1); % Para poner el primer frame a 0 por si indLinesPS no tiene datos para el primer frame
numPhots=size(FCSdataINcut,1);
numPixels=size(pixelSynccut_flp,1);

offsetLineasIMG=1; %Nº de línea de imgIN en el que se encuentra el primer fotón
numPhotLine=numel(find(imgIN(offsetLineasIMG,:)));
while numPhotLine==0
    offsetLineasIMG=offsetLineasIMG+1;
    numPhotLine=numel(find(imgIN(offsetLineasIMG,:)));
end

numFrames=max(FCSdataINcut(:,1)+1);
indCambioFrameLS=zeros(numFrames,1);
FCSdataINcut2=zeros(numPhots,2);
pixelSynccut2=zeros(numPixels,2);
sumaLineas=0; %Acumula líneas de frame a frame
ind1FCS=1;
ind1PS=1;
for m3=1:numFrames %Encuentra el índice en el que cambia de frame FCSdataINcut, lineSynccut y pixelSynccut
    indCambioFrameFCS=find(FCSdataINcut(:,1)==m3-1,1,'last');
    indCambioFramePS=find(pixelSynccut_flp(:,1)==m3-1,1,'last');
    indCambioFrameLS(m3)=find(lineSynccut_fl(:,1)==m3-1,1,'last');
    FCSdataINcut2(ind1FCS:indCambioFrameFCS,1)=FCSdataINcut(ind1FCS:indCambioFrameFCS,2)+sumaLineas;
    pixelSynccut2(ind1PS:indCambioFramePS,1)=pixelSynccut_flp(ind1PS:indCambioFramePS,2)+sumaLineas;
    sumaLineas=sumaLineas+lineSynccut_fl(indCambioFrameLS(m3),2);
    ind1FCS=indCambioFrameFCS+1;
    ind1PS=indCambioFramePS+1;
end
FCSdataINcut2(:,1)=FCSdataINcut2(:,1)-(FCSdataINcut2(1,1)-offsetLineasIMG); % Para que el valor de las líneas se inicie en el valor correspondiente
FCSdataINcut2(:,2)=FCSdataINcut(:,3);
pixelSynccut2(:,1)=pixelSynccut2(:,1)-(pixelSynccut2(1,1)-1); % Para que el valor de las líneas se inicie en 1
pixelSynccut2(:,2)=pixelSynccut_flp(:,3);
indMaxCadaLineaLimiteDerecha=indMaxCadaLinea+sigma2_5+offset+1; 
indMaxCadaLineaLimiteIzquierda=indMaxCadaLinea-sigma2_5+offset-1; 
filasConPhots=unique(FCSdataINcut2(:,1)); %Filas de FCSdataINcut2 que contienen fotones
numFilasConPhots=numel(filasConPhots);

%% Cálcula la líneas que se pierden al final de cada frame, y el tiempo promedio de escaneo de una línea
difLineSync=zeros(size(lineSynccut_fl,1)-1,1); %Diferencia de tiempos en líneas consecutivas
for m3_1=1:size(difLineSync,1)
    difLineSync(m3_1)=lineSynccut_t(m3_1+1,1)-lineSynccut_t(m3_1,1);
end
difLineSynccut=difLineSync;
difLineSynccut(indCambioFrameLS(1:end-1),:)=[]; %Todas las líneas menos las últimas de cada frame
tPromedioLS=mean(difLineSynccut); %Tiempo promedio de escaneo de una línea
lineasPerdidasCadaFrame=round(difLineSync(indCambioFrameLS(1:end-1))/tPromedioLS)-1; %Líneas que se pierden al final de cada frame


%% Paralelización (SPMD)
numWorkers=feature('NumCores'); %Nº de cores
    if numWorkers>=8
        numWorkers=8; %Para Matlab 2010b, 8 cores máximo.
    end
resto=rem(numFilasConPhots,numWorkers);
if not(resto==0) %el nº de fotones debe ser divisible por numWorkers para paralelizar
    restoDivNumlabs=ones(numWorkers-resto,1);
    filasConPhots=[filasConPhots;restoDivNumlabs];
end
indMaxLinea1=indMaxCadaLinea(offsetLineasIMG); % Posición del máximo de la 1ª fila de FCSdataINcut

spmd (numWorkers)
    parindFCSdata=zeros(round(numPhots/numWorkers),1);
    parindPixelSync=zeros(round(numPhots/numWorkers),2); 
    cuentaPhot=0;  
    for m5=1:numel(filasConPhots)/numWorkers %Selecciona los datos 5sigma de FCSdataINcut2 y pixelSynccut2
        parFila=filasConPhots((m5-1)*numWorkers+labindex); %Recorre las líneas de FCSdataINcut2 que contengan algún fotón
        indLinem5FCS=find(FCSdataINcut2(:,1)==parFila); %Indices de la línea en FCSdataINcut2
        indPixelm5FCS=find(and(FCSdataINcut2(indLinem5FCS,2)>indMaxCadaLineaLimiteIzquierda(parFila), FCSdataINcut2(indLinem5FCS,2)<indMaxCadaLineaLimiteDerecha(parFila))); %Indices del pixel en FCSdataINcut2
        numPhottemp=numel(indPixelm5FCS); %Nº de fotones válidos por linea  
        indFCStemp=indLinem5FCS(indPixelm5FCS);
        parindFCSdata(cuentaPhot+1:cuentaPhot+numPhottemp,1)=indFCStemp;
        indLinem5PS=find(pixelSynccut2(:,1)==parFila); %Indices de la línea en pixelSynccut2
        difMaximoFila1=indMaxLinea1-indMaxCadaLinea(parFila); %Diferencia de cada pixel con respecto al máximo de referencia (fila 1)
        for m6=1:numPhottemp
           pixelFind=FCSdataINcut2(indFCStemp(m6),2); 
           indPixelm5PS= pixelSynccut2(indLinem5PS,2)==pixelFind; %Indice del pixel en pixelSynccut2
           parindPixelSync(cuentaPhot+m6,2)=indLinem5PS(indPixelm5PS);          
        end
        parindPixelSync(cuentaPhot+1:cuentaPhot+numPhottemp,1)=parindPixelSync(cuentaPhot+1:cuentaPhot+numPhottemp,2)+difMaximoFila1;
        cuentaPhot=cuentaPhot+numPhottemp;     
    end
    if and(labindex>resto, resto>0) %Los últimos fotones encontrados han sido los rellenados para que fueran divisbles por el nº de cores. Hay que eliminarlos.
        cuentaPhot=cuentaPhot-numPhottemp;
    end
    parindFCSdata(cuentaPhot+1:end,:)=[];
    parindPixelSync(cuentaPhot+1:end,:)=[];
end %end spmd

%%
matCuentaPhot=cell2mat(cuentaPhot(:,:));
indFCSdata=zeros(sum(matCuentaPhot),1); % Indices de FCSdataINcut
indPixelSync=zeros(sum(matCuentaPhot),2); %Indices de pixelSynccut
indFCSdata(1:matCuentaPhot(1),1)=parindFCSdata{1};
indPixelSync(1:matCuentaPhot(1),:)=parindPixelSync{1};
for m7=2:numWorkers
    sumatorio1=sum(matCuentaPhot(1:m7-1))+1;
    sumatorio2=sum(matCuentaPhot(1:m7));
    indFCSdata(sumatorio1:sumatorio2,1)=parindFCSdata{m7};
    indPixelSync(sumatorio1:sumatorio2,:)=parindPixelSync{m7};
end
[indFCSdata,orden]=(sort(indFCSdata,'ascend'));
indPixelSync=indPixelSync(orden,:);
FCSdataALIN_flp=FCSdataINcut(indFCSdata,:);
FCSdataALIN_MTmT=FCSdataINcut_MTmT(indFCSdata,:);
FCSdataALIN_c=FCSdataINcut_c(indFCSdata);
tCorregidoLineas=zeros(size(FCSdataALIN_flp,1),1);
indCambioFrameFCSalin=find(FCSdataALIN_flp(:,1)==0,1,'last');
tCorregidoLineas(1:indCambioFrameFCSalin)=0;
indCambioFrameDesde=indCambioFrameFCSalin+1;
for m8=2:numFrames %Encuentra el indice en el que cambia de frame FCSdataALIN
   indCambioFrameFCSalin=find(FCSdataALIN_flp(:,1)==m8-1,1,'last');
   indCambioFrameHasta=indCambioFrameFCSalin;
   tCorregidoLineas(indCambioFrameDesde:indCambioFrameHasta)=sum(lineasPerdidasCadaFrame(1:m8-1))*tPromedioLS;
   indCambioFrameDesde=indCambioFrameFCSalin+1;
end
tCorregidoLineas(indCambioFrameDesde:end)=sum(lineasPerdidasCadaFrame)*tPromedioLS;
tCorregidoFCSalin=FCSdataALIN_MTmT(:,1)+pixelSynccut_t(indPixelSync(:,1),1)-pixelSynccut_t(indPixelSync(:,2),1)-tCorregidoLineas;
FCSdataALINcorregido=struct('frameLinePixel',[FCSdataALIN_flp(:,1)+offsetFramesFCS,FCSdataALIN_flp(:,2:3)],'MacroMicroTime',[tCorregidoFCSalin,FCSdataALIN_MTmT(:,2)],...
    'channel',FCSdataALIN_c);