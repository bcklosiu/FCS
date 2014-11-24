function [Data_bin, deltat_bin]=FCS_binning_FIFO_lines(imgNOalineada, lineSync, indLineasLS, indMaxCadaLinea, sigma2_5, multiploLineas)

% [Data_bin]=FCS_binning_FIFO_lines(imgNOalineada, indLineasLS, indMaxCadaLinea, sigma2_5, multiploLineas)
%
% BINNING TEMPORAL DE imgNOalineada, en múltiplos de línea de la imagen
% imgNOalineada - imagen decodificada, sin alinear.
% indLineasLS - Matriz booleana que indica el nº de líneas que se analizarán
% indMaxCadaLinea - índice máximo de cada línea de la imagen, obtenida con la función FCS_membraneAlignment_space (alineación espacial de la membrana).
% sigma2_5 - Nº de píxeles que se cogerén a la izquierda y derecha del centro de cada línea
% multiploLineas - Nº de líneas de la imagen que sumará el binning.

imgCut=imgNOalineada(indLineasLS,:,:);
numChannels=size(imgCut,3);
limitesImg5sigma=[indMaxCadaLinea-sigma2_5,indMaxCadaLinea+sigma2_5];
numLineas=(size(imgCut,1));
numPixeles=(size(imgCut,2));
limitesImg5sigma(limitesImg5sigma(:,1)<1,1)=1; %Busca los límites de la imagen menores que 1
limitesImg5sigma(limitesImg5sigma(:,2)>numPixeles,2)=numPixeles; %Busca los límites de la imagen mayores que 1
lineSynccut=lineSync(indLineasLS,:);

% Cálculo de la frecuencia de binning (binfreq)
primerFrame=lineSynccut(1,1);
indPrincipioFrame=find(lineSynccut(:,1)==primerFrame+3,1,'first');
indFinalFrame=find(lineSynccut(:,1)==primerFrame+3,1,'last');
tLineas=zeros(indFinalFrame-(indPrincipioFrame+1)-1,1); %Tiempo de escaneo de cada línea del frame
for lineaLS=1:numel(tLineas)
    tLineas(lineaLS)=lineSynccut(lineaLS+1,3)-lineSynccut(lineaLS,3);
end
media=mean2(tLineas);
desv=std(tLineas);
lineasValidas=and(tLineas<media+3*desv,tLineas>media-3*desv);
tPromedioLinea=mean2(tLineas(lineasValidas));
deltat_bin=multiploLineas*tPromedioLinea;
binfreq=1/deltat_bin;

% Paralelización (SPMD)
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
parLimitesImg5sigma=[limitesImg5sigma;ones(restoLineas,2)];
parImgCut=[imgCut;zeros(restoLineas,size(imgCut,2),numChannels)];
parNumLineas=size(parIndLineasIMG,1);
Data_bin=zeros(parNumLineas*numWorkers,numChannels);

spmd (numWorkers)
    parData_bin=zeros(parNumLineas,numChannels);
    for channel=1:numChannels
        parImgCutTemp=parImgCut(:,:,channel); %Matriz temporal, solo un canal
        for parLine=1:parNumLineas
            indDesde=parIndLineasIMG(parLine,labindex);
            indHasta=indDesde+multiploLineas-1;
            cuentaPhots=0;
                for line=indDesde:indHasta,
                    numPhotsTemp=sum(parImgCutTemp(line,parLimitesImg5sigma(line,1):parLimitesImg5sigma(line,2)));
                    cuentaPhots=cuentaPhots+numPhotsTemp;
                end %end for line
            parData_bin(parLine,channel)=cuentaPhots;
        end %end for parLine
    end  %end for channel
end %end spmd

% Reorganizar datos del binning en Data_bin
for core=1:numWorkers
    binningWorker=cell2mat(parData_bin(core));
    Data_bin((core-1)*parNumLineas+1:core*parNumLineas,:)=binningWorker;
end
restoLineasBinning=ceil(restoLineas/multiploLineas);
Data_bin(end-(restoLineasBinning-1):end,:)=[];
