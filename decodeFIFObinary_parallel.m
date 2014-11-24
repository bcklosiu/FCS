function  [arrivalTimesOUT, twoDIntensity, frameSync, lineSync, pixelSync]= decodeFIFObinary_parallel (fblock, TACrange, TACgain)

% [arrivalTimesOUT, twoDIntensity, frameSync, lineSync, pixelSync]= decodeFIFObinary_parallel (fblock, TACrange, TACgain)
% Lee archivos BH FIFO fblock se carga con loadFIFOtest y el archivo es un .spc. Cada elemento incluye información de la adquisición (32 bits).
% La decodificación está paralelizada: Divide el nº frames entre el nº de procesadores y las analiza de forma independiente.
% 
% TACrange (en s) y TACgain son parámetros de la adquisición. Cambian en función del detector utilizado.
% frameSync tiene el timing de comienzo de cada (frame, arrivalTime)
% lineSync el de cada frame y línea (frame, line, arrivalTime)
% pixelSync el de cada frame y línea (frame, line, pixel, arrivalTime)
% arrivalTimes indica el frame, la línea el pixel, los tiempos (macro y micro, en s) y el canal de cada fotón.


INVALID32=uint32(hex2dec('80000000'));
P_MARK32=uint32(hex2dec ('90001000')); 
L_MARK32=uint32(hex2dec ('90002000'));
F_MARK32=uint32(hex2dec ('90004000'));
PLF_MARK32=uint32(hex2dec ('7000'));

MTOV32=uint32(hex2dec('40000000'));             % Macro timer overflow
INVALID_MTOV32=uint32(hex2dec('c0000000'));     % Invalid + Macro timer overflow
INVALID_MARK32=uint32(hex2dec('90000000'));     % Invalid + Mark 
INV_MTOV_GAP_MARK32=uint32(hex2dec('F0000000'));  % Invalid + MT overflow + Gap + Mark
OVRUN32=uint32(hex2dec('20000000'));            % Fifo overrun, recording gap
ROUT32=uint32(hex2dec('f000'));                 % Routing signals( inverted )
MT32=uint32(hex2dec('fff'));                    % Macro time
MT16=uint16(MT32);  % MT32 must be a 16 bit variable in the adc bitand operation
ADC32=uint32(hex2dec('0fff0000'));              % ADC value
CNT32=uint32(hex2dec('0FFFFFFF'));

% masks for the 1st frame in .spc file
RB_NO32=uint32(hex2dec('78000000'));   %routing bits number used during measurement
MT_CLK32=uint32(hex2dec('00ffffff'));   %macro time clock in 0.1 ns units
M_FILE32=uint32(hex2dec('02000000'));   %file with markers
R_FILE32=uint32(hex2dec('04000000'));   % file with raw data ( diagnostic mode only )

% Byte 3
maskf0 = uint8(hex2dec('f0'));  %4 most significant bits of byte 3 (4)
mask0f = uint8(hex2dec('0f'));  %4 least significant bits of byte 3 (4)
mask90 = uint8(hex2dec('90'));  %Invalid and Mark
maska0 = uint8(hex2dec('a0'));  %Invalid and Gap
mask10 = uint8(hex2dec('10'));  %Gap
maskc0 = uint8(hex2dec('c0'));  %Invalid and MacroTime overflow
maskd0 = uint8(hex2dec('d0'));  %Invalid and Mark and MacroTime overflow
mask00 = uint8(hex2dec('00'));  %Photon
mask40 = uint8(hex2dec('40'));  %MTOV: MacroTime overflow

frameClockPattern = uint8(hex2dec('40'));
lineClockPattern = uint8(hex2dec('20'));
pixelClockPattern = uint8(hex2dec('10'));

% Common variables initialisation
currentFrame= 0;
currentLine = 0;
currentPixel=0;
timeStep = 4096;
macroTcounter=0;
macroTOffset=0;
% photonMacroTime=0;
% photonMicroTime=0;
photonCount=0;
arrivalTimes = zeros(size(fblock,1), 6, 'double');
lineEventcounter=0;
sumaMToffset=0;
numWorkers=feature('NumCores'); %Number of active workers. 
    if numWorkers>=8
        numWorkers=8; %For Matlab 2010b, 8 workers maximum.
    end

% First event
photonFrame1=fblock(1);
MacroTimeClock=double(bitand(photonFrame1,MT_CLK32))/10; % Macro Time clock in 0.1 ns unit;
nr_RoutChannels=bitshift(bitand(fblock(1),RB_NO32),-27)+1; %Nr. of routing channels

foundFrame = find(bitand(fblock,F_MARK32) == F_MARK32);
foundLine = find(bitand(fblock,L_MARK32) == L_MARK32);

if not(and(isempty(foundFrame),isempty(foundLine))); % FIFO Image or FIFO Line
    firstFrame=foundFrame(1);       % First frame event in fblock      
    lastFrame=foundFrame(end);      % Last Frame event in fblock
    numFrames=numel(foundFrame); 
    firstLine=foundLine(1);       % First line event in fblock       
    lastLine=foundLine(end);      % Last line event in fblock   
    numLines=numel(find(bitand(fblock(firstFrame:foundFrame(2)),L_MARK32) == L_MARK32));     % Nr. of lines in 1 frame
    numPixels=numel(find(bitand(fblock(firstLine:foundLine(2)),P_MARK32) == P_MARK32));  % Nr. of pixels in 1 Line

    pixelCount=0;
    frameSync=zeros (numFrames, 2, 'double'); % Los marcadores de Frame, Line y Pixel no llevan registro de microtime
    lineSync=zeros (numel(foundLine), 3, 'double');
        
    if numLines<530, % FIFO Image
        forFrom=firstFrame; % 1st index of the for bucle
        forTo=lastFrame; % 2nd index of the for bucle
        twoDIntensity=zeros(numLines, numPixels-1, nr_RoutChannels, 'double');
    else    % FIFO Line
    
    forFrom=firstLine; % 1st index of the for bucle
    forTo=lastLine; % 2nd index of the for bucle
    numLinesTotal=numel(foundLine);     % Nr. of lines in 1 frame
    twoDIntensity=zeros(numLinesTotal, numPixels-1, nr_RoutChannels, 'double');
    %fblock will be divided into the frames (fblockCutcell)
    coc=double(idivide(numFrames,uint32(numWorkers),'floor'));
    resto=rem(numFrames,numWorkers);
    vFrames=coc*ones(1,numWorkers); %Nr. of frames analysed per lab
    if resto>0
        vFrames(1:resto)=vFrames(1:resto)+1;
    end
    v=zeros(1,numWorkers);
    v(1,1)=foundFrame(vFrames(1))-forFrom+1;
    for fl1=2:numWorkers-1
        v(1,fl1)=foundFrame(sum(vFrames(1:fl1)))-foundFrame(sum(vFrames(1:fl1-1)));
    end
    v(1,end)=forTo-foundFrame(sum(vFrames(1:end-1)));
    fblockCutmat=fblock(forFrom:forTo,1);
    fblockCutcell=mat2cell(fblockCutmat,v,1);

    end     % end if FIFO Image/FIFO Line
    
    numPixelTotal=numel(find(bitand(fblock(forFrom:forTo),P_MARK32) == P_MARK32)); % Nr. of pixels in the whole acquisition
    pixelSync=zeros (numPixelTotal, 4, 'double');
    
else % FIFO 1 point 
    vFrames=zeros(1,numWorkers);
    twoDIntensity=0;
    frameSync=0;
    lineSync=0;
    pixelSync=0;
    forFrom=2; % 1st index of the for bucle
    forTo=size(fblock,1); % 2nd index of the for bucle
    numPixelTotal=(find(bitand(fblock(forFrom:forTo),P_MARK32) == P_MARK32)); % Nr. of pixels in the whole acquisition
    if not(isempty(numPixelTotal)), 
        fblock(numPixelTotal+1)=[];
        forTo=size(fblock,1);
    end
    %fblock will be divided into different parts, according to numWorkers (fblockCutcell)
    coc=double(idivide(forTo-forFrom+1,uint32(numWorkers),'floor'));
    resto=rem(forTo-forFrom+1,numWorkers);
    v=coc*ones(1,numWorkers);
    if resto>0
        v(1:resto)=v(1:resto)+1;
    end
    fblockCutmat=fblock(forFrom:forTo,1);
    fblockCutcell=mat2cell(fblockCutmat,v,1);
end     % end if


%Event cases
invAndGap_event=maska0; % Invalid and Gap
gap_event=mask10; %Gap
invAndMark_event=mask90;
invAndMarkandMacroOverFlow_event=maskd0;
invAndMacroOverFlow_event=maskc0; %Se activa el bit de Inv y el de Macrotime Overflow
timerOverflow_event=mask40; %Macro Timer Overflow en detección de fotón
photon_event=mask00;


spmd (numWorkers)
    parFrame=fblockCutcell{labindex};
    parArrivalTimes=zeros(size(parFrame,1),6);
    parFrameCount=numel(find(bitand(parFrame,F_MARK32) == F_MARK32)); %Nr. of frames per worker
    parLineCount=numel(find(bitand(parFrame,L_MARK32) == L_MARK32)); %Nr. of lines per worker
    parPixelCount=numel(find(bitand(parFrame,P_MARK32) == P_MARK32)); %Nr. of pixels per worker
    parFrameSync=zeros(parFrameCount,2);
    parLineSync=zeros(parLineCount,3);
    parPixelSync=zeros(parPixelCount,4);
    
    for bb = 1:numel(parFrame)
        parEventdata=parFrame(bb);
        bytesinEvent=typecast (parEventdata, 'uint8'); %saca 4 bytes
        adcM=bytesinEvent(4);
        
%         El orden de los cases importa. Primero identifica los invalid. Tengo que ver qué pasa con el gap!!
        event_adcM=bitand(adcM, maskf0);
        switch (event_adcM)
            case {invAndMark_event, invAndMarkandMacroOverFlow_event}
%                 disp('Inv and Mark')
                if event_adcM==invAndMarkandMacroOverFlow_event
                    macroTcounter=macroTcounter+1;
                    macroTOffset=macroTcounter*timeStep;
                end
%                 eventdata=fblock(bb);
                newframe_event=bitand(parEventdata, F_MARK32);  
                newline_event=bitand(parEventdata, L_MARK32);	
                newpixel_event=bitand(parEventdata, P_MARK32);	

                if newframe_event==F_MARK32 % frame clock
                    currentFrame  = currentFrame + 1;
                    currentLine = 0;
                    frameStart=double(bitand (parEventdata, MT32))+macroTOffset; 
                    parFrameSync(currentFrame, :)=[currentFrame frameStart];
                end
                if newline_event==L_MARK32           % line clock
                    if currentLine < (numLines+1);
                        currentLine = currentLine + 1;
                        lineEventcounter=lineEventcounter+1;
                        currentPixel=0;
                        lineStart=double(bitand (parEventdata, MT32))+macroTOffset; 
                        parLineSync(lineEventcounter,:)=[currentFrame currentLine lineStart];
                    end
                end
                    if newpixel_event==P_MARK32           % pixel clock
                        pixelCount=pixelCount+1;    %Hay que llevar cuenta del número de píxeles total porque no todas las líneas tienen el mismo número de píxeles
                        currentPixel=currentPixel+1;
                        pixelStart=double(bitand (parEventdata, MT32))+macroTOffset; 
                        parPixelSync(pixelCount, :)=[currentFrame currentLine currentPixel pixelStart];
                    end

            case invAndMacroOverFlow_event %Inv and MacroTime Overflow
                macroTimerOFCount = double(bitand(parEventdata, CNT32));       % número de veces que ha rebosado el MacroTimer
                macroTcounter=macroTcounter+macroTimerOFCount;
                macroTOffset=macroTcounter*timeStep;

            case {gap_event, invAndGap_event}
                disp('gap - FIFO overflow')

            case timerOverflow_event   %Detección de un fotón con un Macro Timer OverFlow event
                photonCount=photonCount+1; 
                macroTcounter=macroTcounter+1; 
                macroTOffset=macroTcounter*timeStep; 
%                     [photonMacroTime, photonMicroTime, channel] = newphoton(fblock(bb), macroTOffset, MT32, MT16, ROUT32);
                macroT =  double(bitand(parEventdata, MT32));   % 12 significant bits MacroTime
                photonMacroTime = macroT+macroTOffset; % Macro Time clocks
                eventdata16=typecast (parEventdata, 'uint16'); %Split event data in 2 parts (16 and 16 bits)
                adc = double(bitand(eventdata16(2), MT16)); % 12 significant bits ADC
                photonMicroTime = (4095 - adc); % Micro Time unit
                channel=double(bitshift(bitand(parEventdata,ROUT32),-12)); % Routing channel 
                parArrivalTimes(photonCount, :)=[currentFrame, currentLine, currentPixel, photonMacroTime, photonMicroTime, channel];

            case photon_event  % Detección de un fotón
                photonCount=photonCount+1; 
%                     [photonMacroTime, photonMicroTime, channel] = newphoton(fblock(bb), macroTOffset, MT32, MT16, ROUT32);
                macroT =  double(bitand(parEventdata, MT32));   % 12 significant bits MacroTime
                photonMacroTime = macroT+macroTOffset; % Macro Time clocks
                eventdata16=typecast (parEventdata, 'uint16'); %Split event data in 2 parts (16 and 16 bits)
                adc = double(bitand(eventdata16(2), MT16)); % 12 significant bits ADC
                photonMicroTime = (4095 - adc); % Micro Time unit
                channel=double(bitshift(bitand(parEventdata,ROUT32),-12)); % Routing channel 
                parArrivalTimes(photonCount, :)=[currentFrame, currentLine, currentPixel, photonMacroTime, photonMicroTime, channel];
        end     %end switch
    end     % end for (bb)

    parArrivalTimes(photonCount+1:end,:)=[];
          
end     %end spmd
% % matlabpool close
    % Filling arrivalTimes in 
    matPhotonCount=cell2mat(photonCount(:,:)); 
    matMacroTOffset=cell2mat(macroTOffset(:,:));
    % 1st frame
    frame=parArrivalTimes{1}; 
    arrivalTimes(1:matPhotonCount(1),1)=frame(:,1);
    arrivalTimes(1:matPhotonCount(1),2:3)=frame(:,2:3);
    arrivalTimes(1:matPhotonCount(1),4)=frame(:,4);    
    arrivalTimes(1:matPhotonCount(1),5:6)=frame(:,5:6);       
    for aa2=2:numWorkers, % from lab2 to labNumWorkers
        frame=parArrivalTimes{aa2};     
        indSumaAT1=sum(matPhotonCount(1:aa2-1))+1;
        indSumaAT2=sum(matPhotonCount(1:aa2));
        sumaMToffset=sumaMToffset+matMacroTOffset(aa2-1);
        arrivalTimes(indSumaAT1:indSumaAT2,1)=frame(:,1)+sum(vFrames(1:aa2-1));
        arrivalTimes(indSumaAT1:indSumaAT2,2:3)=frame(:,2:3);
        arrivalTimes(indSumaAT1:indSumaAT2,4)=frame(:,4)+sumaMToffset;
        arrivalTimes(indSumaAT1:indSumaAT2,5:6)=frame(:,5:6);        
    end %end for (aa2)
arrivalTimes(sum(matPhotonCount)+1:end,:)=[];


if not(and(isempty(foundFrame),isempty(foundLine))); % FIFO Image or FIFO Line
    indIMG=find(and(and(arrivalTimes(:,2)>0,arrivalTimes(:,2)<numLines+1),and(arrivalTimes(:,3)>0,arrivalTimes(:,3)<numPixels))); % Valid indexes for arrivalTimesOUT
    arrivalTimesOUT=arrivalTimes(indIMG,:);
    % Filling frameSync, lineSync and pixelSync in 
    matFrameSync=cell2mat(parFrameCount(:,:)); 
    matLineSync=cell2mat(parLineCount(:,:)); 
    matPixelSync=cell2mat(parPixelCount(:,:)); 
    frameSync(1:matFrameSync(1),:)=parFrameSync{1};
    lineSync(1:matLineSync(1),:)=parLineSync{1};
    pixelSync(1:matPixelSync(1),:)=parPixelSync{1};
    for aa3=2:numWorkers
        fSync=parFrameSync{aa3};
        lSync=parLineSync{aa3};
        pSync=parPixelSync{aa3};
        indFSync1=sum(matFrameSync(1:aa3-1))+1;
        indFSync2=sum(matFrameSync(1:aa3));
        indLSync1=sum(matLineSync(1:aa3-1))+1;
        indLSync2=sum(matLineSync(1:aa3));
        indPSync1=sum(matPixelSync(1:aa3-1))+1;
        indPSync2=sum(matPixelSync(1:aa3));
        frameSync(indFSync1:indFSync2,1)=fSync(:,1)+sum(matFrameSync(1:aa3-1));
        lineSync(indLSync1:indLSync2,1)=lSync(:,1)+sum(matFrameSync(1:aa3-1));
        pixelSync(indPSync1:indPSync2,1)=pSync(:,1)+sum(matFrameSync(1:aa3-1));
        frameSync(indFSync1:indFSync2,2)=fSync(:,2)+sum(matMacroTOffset(1:aa3-1));
        lineSync(indLSync1:indLSync2,3)=lSync(:,3)+sum(matMacroTOffset(1:aa3-1));
        pixelSync(indPSync1:indPSync2,4)=pSync(:,4)+sum(matMacroTOffset(1:aa3-1));
        lineSync(indLSync1:indLSync2,2)=lSync(:,2);
        pixelSync(indPSync1:indPSync2,2:3)=pSync(:,2:3);
    end
    
    if numLines<530, % FIFO Image
        for c=1:size(indIMG,1) % twoDIntensity for FIFO Image
            twoDIntensity(arrivalTimesOUT(c,2),arrivalTimesOUT(c,3),arrivalTimesOUT(c,6)+1)=twoDIntensity(arrivalTimesOUT(c,2),arrivalTimesOUT(c,3),arrivalTimesOUT(c,6)+1)+1;
        end     % end embedded for nr.1
    else % FIFO Line 
        qSum=zeros(numFrames+2,1); % Quantity to add to arrivalTimesOUT(:,2)
        indrSum=zeros(numFrames+2,1); % Indexes to complete rSum
        rSumFrame1=arrivalTimesOUT(find(arrivalTimesOUT(:,1)==0,1,'last'),2); 
        for d=2:numFrames+2 % Fills in qSum and indrSum
            qSum(d,1)=rSumFrame1+numLines*(d-2);
            indrSum(d,1)=find(arrivalTimesOUT(:,1)==d-2,1,'last');
        end  % end embedded for nr.2

        rSum=zeros(size(arrivalTimesOUT,1),1); % Row matrix, added to arrivalTimesOUT(:,2), to display the whole acquisition in a row  
        for e=1:numFrames+1 %Fills in rSum
            rSum(indrSum(e)+1:indrSum(e+1))=qSum(e);
        end %end embedded for nr.3
        
        for f=1:size(indIMG,1) % twoDIntensity for FIFO Line
            twoDIntensity(rSum(f)+arrivalTimesOUT(f,2),arrivalTimesOUT(f,3),arrivalTimesOUT(f,6)+1)=...
                twoDIntensity(rSum(f)+arrivalTimesOUT(f,2),arrivalTimesOUT(f,3),arrivalTimesOUT(f,6)+1)+1;
        end     % end embedded for nr.4
    end %end embedded if
    
%     for g=1:nr_RoutChannels, % Images representation     
%         figure(g)
%         imagesc(twoDIntensity(:,:,g)); %%axis image
%     end     % end embedded for nr.5

    lineSync(sum(matLineSync)+1:end,:)=[];
    frameSync(:,2)=MacroTimeClock*1E-9*frameSync(:,2); %Convert from clocks to s
    lineSync(:,3)=MacroTimeClock*1E-9*lineSync(:,3); %Convert from clocks to s
    pixelSync(:,4)=MacroTimeClock*1E-9*pixelSync(:,4); %Convert from clocks to s
    indPixelSync=and(and(pixelSync(:,2)>0,pixelSync(:,2)<numLines+1),and(pixelSync(:,3)>0,pixelSync(:,3)<numPixels)); % Valid indexes for arrivalTimesOUT
    pixelSync=pixelSync(indPixelSync,:);
    
    else % FIFO Point
        arrivalTimesOUT=arrivalTimes(1:sum(matPhotonCount),:);
end     % end if

arrivalTimesOUT(:,4)=MacroTimeClock*1E-9*arrivalTimesOUT(:,4); %Macro Time (s)
arrivalTimesOUT(:,5)=arrivalTimesOUT(:,5)*TACrange/(TACgain*4096); %Micro Time (s)
% end decodeFIFOBinary_parallel


