function [imgOUT, indLinesFCS, indLinesLS, indLinesPS, timeInterval] = FCS_ROI(imgIN, FCSdata, lineSync, pixelSync)

% [imgOUT, indLinesFCS, indLinesLS, indLinesPS, timeInterval] = FCS_ROI(imgIN, FCSdata, lineSync, pixelSync)
% Crea una ROI rectangular para la imagen de entrada, y calcula los índices de FCSdata, lineSync y pixelSync que están dentro de ella.
% 
% Unai, 01/07/2014
% Unai, 10/08/2015. Cambio variables de entrada: imgIN(uint16) - FCSdata: struct - lineSync(uint32) - pixelSync:pixelSync(uint32)

imgIN_double=cast(imgIN,'double'); %Se utiliza para normalizar imgRGB. Si utilizaramos imgIN, imgRGB sería uint16
data_frameLinePixel=FCSdata.frameLinePixel;
data_channel=FCSdata.channel;
lineSync_fl=lineSync.frameLine;
pixelSync_flp=pixelSync.frameLinePixel;
numFilasIMG=size(imgIN,1);
numColsIMG=size(imgIN,2);
scanningFreq=1400; %cuidado!! Esto depende de la frecuencia de barrido!!

% tFinal=FCSdata(end,4)+FCSdata(end,5);
%binfreq=1/((FCSdata(end,4)+FCSdata(end,5))/100);
%[Data_bin, sampfreq_bin, deltat_bin]=FCS_binning_FIFO(FCSdata, binfreq);

imgRGB=zeros(numFilasIMG,numColsIMG,3,'double'); %La ROI se seleccionará sobre una imagen RGB
coords=[0.5,0.5,numFilasIMG,numColsIMG];
numFrames=max(data_frameLinePixel(:,1)+1);
nrChannels=numel(unique(data_channel)); %Nº de canales
switch(nrChannels)
    case 1 
        channel=data_channel(1);
        switch (channel)
            case 0 
                plano=2;
            case 1 
                plano=1;
        end
        imgRGB(:,:,plano)=imgIN_double./max(max(imgIN_double)); %Normalización del canal correspondiente
    case 2
        imgRGB(:,:,1)=imgIN_double(:,:,2)/max(max(imgIN_double(:,:,2))); %Normalización del canal 1
        imgRGB(:,:,2)=imgIN_double(:,:,1)/max(max(imgIN_double(:,:,1))); %Normalización del canal 2
end

imgRGBtrasp=permute(imgRGB,[2,1,3]); %imagen RGB transpuesta

% Matrices reducidas a 1 columna con la información de frame+linea
FCSdataRedux=zeros(size(data_frameLinePixel,1),1);
lineSyncRedux=zeros(size(lineSync_fl,1),1);
pixelSyncRedux=zeros(size(pixelSync_flp,1),1);
sumaLineas=0; %Acumula líneas de frame a frame
ind1FCS=1;
ind1LS=1;
ind1PS=1;
for r1=1:numFrames %Completa FCSdataRedux,lineSyncRedux,pixelSyncRedux
    indCambioFrameFCS=find(data_frameLinePixel(:,1)==r1-1,1,'last');
    indCambioFrameLS=find(lineSync_fl(:,1)==r1-1,1,'last');
    indCambioFramePS=find(pixelSync_flp(:,1)==r1-1,1,'last');
    FCSdataRedux(ind1FCS:indCambioFrameFCS)=data_frameLinePixel(ind1FCS:indCambioFrameFCS,2)+sumaLineas;
    lineSyncRedux(ind1LS:indCambioFrameLS)=lineSync_fl(ind1LS:indCambioFrameLS,2)+sumaLineas;
    pixelSyncRedux(ind1PS:indCambioFramePS)=pixelSync_flp(ind1PS:indCambioFramePS,2)+sumaLineas;
    sumaLineas=sumaLineas+lineSync_fl(indCambioFrameLS,2);
    ind1FCS=indCambioFrameFCS+1;
    ind1LS=indCambioFrameLS+1;
    ind1PS=indCambioFramePS+1;
end

h_fig=figure; 

h_axesRGB=axes; %Handle de los ejes de la figura con el tiempo reducido

imagesc(imgRGBtrasp); axis off
%a=zeros(numColsIMG, 100); a(10:20, 40:60)=1;
%imagesc (a); axis off

h_axesROI=axes;
set (h_axesROI, 'XLim', [0.5 numFilasIMG+0.5], 'YLim', [0.5 numColsIMG+0.5], 'YDir', 'reverse', 'Color', 'none')
timeLabels=get (h_axesROI, 'XTick')/scanningFreq;
set (h_axesROI, 'XTickLabel', {num2str(round(timeLabels'))});
xlabel ('t (s)')


hroi=imrect(h_axesROI, coords); %Crea un rectángulo, y el handle de la ROI.
fcn = makeConstrainToRectFcn('imrect',  [0.5 numFilasIMG+0.5], [0.5 numColsIMG+0.5]); %Encuentra los límites de la imagen
setPositionConstraintFcn(hroi, fcn); %Fija esos límites para la ROI 
coords=wait(hroi); %Coordenadas de la ROI = [x0,y0,deltaX,deltaY], x= coord. temporal, y=coord. espacial 
close(h_fig) 

coordsAbs=[coords(1),coords(2),coords(1)+coords(3),coords(2)+coords(4)]; % Coordenadas absolutas de la imagen: [x0,y0,xfinal,yfinal]
imgOUT=imgIN(ceil(coordsAbs(1)):floor(coordsAbs(3)),ceil(coordsAbs(2)):floor(coordsAbs(4)),:);
timeInterval=[ceil(coordsAbs(1)) floor(coordsAbs(3))]/scanningFreq;

indLinesFCS=and(and(FCSdataRedux>coordsAbs(1),FCSdataRedux<coordsAbs(3)), and(data_frameLinePixel(:,3)>coordsAbs(2),data_frameLinePixel(:,3)<coordsAbs(4)));
indLinesLS=and(lineSyncRedux>coordsAbs(1),lineSyncRedux<coordsAbs(3));
indLinesPS=and(and(pixelSyncRedux>coordsAbs(1),pixelSyncRedux<coordsAbs(3)), and(pixelSync_flp(:,3)>coordsAbs(2),pixelSync_flp(:,3)<coordsAbs(4)));
