function [FCSDataBin, deltaTBin]=FCS_binning_FIFO_lines(imgROI, lineSync, indLineasLS, indMaxCadaLinea, sigma2_5, multiploLineas)

%[FCSDataBin, deltaTBin]=FCS_binning_FIFO_lines(imgNOalineada, lineSync, indLineasLS, indMaxCadaLinea, sigma2_5, multiploLineas)
%
% BINNING TEMPORAL DE imgNOalineada, en múltiplos de línea de la imagen
% imgNOalineada - imagen decodificada, sin alinear.
% indLineasLS - Matriz booleana que indica el nº de líneas que se analizarán
% indMaxCadaLinea - índice máximo de cada línea de la imagen, obtenida con la función FCS_membraneAlignment_space (alineación espacial de la membrana).
% sigma2_5 - Nº de píxeles que se cogerán a la izquierda y derecha del centro de cada línea
% multiploLineas - Nº de líneas de la imagen que sumará el binning.
%
% ULS Ago14
% jri 4Dec14
% jri 4May15 - Convierto FCSData en uint8 pero hay que estar a loro porque me parece que está duplicando el uso de memoria con los cores.
% Unai 13ago15 - Cambios Unai: lineSync es de tipo struct.
% Unai 19may15 - Al programa se le pasa imgROI en lugar de imgDecode y las coordenadas que lo delimitan (indLineasPS)

%%
% figure;imagesc(imgROI)
numChannels=size(imgROI,3);
limitesImg5sigma= [indMaxCadaLinea-sigma2_5, indMaxCadaLinea+sigma2_5];
numLineas=(size(imgROI,1));
numPixeles=(size(imgROI,2));
limitesImg5sigma(limitesImg5sigma(:,1)<1, 1)=1; %Busca los límites de la imagen menores que 1
limitesImg5sigma(limitesImg5sigma(:,2)>numPixeles, 2)=numPixeles; %Busca los límites de la imagen mayores que numPixeles
lineSync_fl=lineSync.frameLine;
lineSync_t=lineSync.time;
lineSyncROI_fl=lineSync_fl(indLineasLS,:);
lineSyncROI_t=lineSync_t(indLineasLS,:);

%% Cálculo de la frecuencia de binning (binFreq)
primerFrame=lineSyncROI_fl(1,1);
indPrincipioFrame=find(lineSyncROI_fl(:,1)==primerFrame+3,1,'first');
indFinalFrame=find(lineSyncROI_fl(:,1)==primerFrame+3,1,'last');
tLineas=zeros(indFinalFrame-(indPrincipioFrame+1)-1,1); %Tiempo de escaneo de cada línea del frame
for lineaLS=1:numel(tLineas)
    tLineas(lineaLS)=lineSyncROI_t(lineaLS+1,1)-lineSyncROI_t(lineaLS,1);
end
media=mean2(tLineas);
desv=std(tLineas);
lineasValidas=and(tLineas<media+3*desv,tLineas>media-3*desv);
tPromedioLinea=mean2(tLineas(lineasValidas));
deltaTBin=multiploLineas*tPromedioLinea;
binFreq=1/deltaTBin;

%% Paralelización (SPMD)
numWorkers=feature('NumCores'); %Nº de cores 
if numWorkers>=8
    numWorkers=8; %Para Matlab 2010b, 8 cores máximo.
end
indLineasIMG=1:multiploLineas:numLineas; %Indices iniciales línea binning
restoWorkers=rem(numel(indLineasIMG),numWorkers);
if not(restoWorkers==0) %el nº de líneas debe ser divisible por el nº de cores para paralelizar
    restoDivWorkers=indLineasIMG(end)+multiploLineas:multiploLineas:indLineasIMG(end)+(numWorkers-restoWorkers)*multiploLineas;
    indLineasIMG=[indLineasIMG,restoDivWorkers];
end
parIndLineasIMG=reshape(indLineasIMG,[],numWorkers);
restoLineas=parIndLineasIMG(end)+multiploLineas-1-numLineas; %Nº de lineas restantes para poder paralelizar
parLimitesImg5sigma=[limitesImg5sigma; ones(restoLineas,2)];
parImgROI=[imgROI;zeros(restoLineas,size(imgROI,2),numChannels)];
parNumLineas=size(parIndLineasIMG,1);
FCSDataBin=zeros(parNumLineas*numWorkers, numChannels, 'uint8'); %Atención estás duplicando la memoria
%%
spmd (numWorkers)
    parFCSDataBin=zeros(parNumLineas, numChannels, 'uint8'); %Atención estás duplicando la memoria?
    for channel=1:numChannels
        parImgROItemp=parImgROI(:,:,channel); %Matriz temporal, solo un canal
        for parLine=1:parNumLineas
            indDesde=parIndLineasIMG(parLine,labindex);
            indHasta=indDesde+multiploLineas-1;
            cuentaPhots=0;
                for line=indDesde:indHasta,
                    numPhotsTemp=sum(parImgROItemp(line,parLimitesImg5sigma(line,1):parLimitesImg5sigma(line,2)));
                    cuentaPhots=cuentaPhots+numPhotsTemp;
                end %end for line
            parFCSDataBin(parLine,channel)=cuentaPhots;
        end %end for parLine
    end  %end for channel
end %end spmd

%% Reorganizar datos del binning en FCSDataBin
for core=1:numWorkers
    binningWorker=cell2mat(parFCSDataBin(core));
    FCSDataBin((core-1)*parNumLineas+1:core*parNumLineas,:)=binningWorker;
end
restoLineasBinning=ceil(restoLineas/multiploLineas);
FCSDataBin(end-(restoLineasBinning-1):end,:)=[];
