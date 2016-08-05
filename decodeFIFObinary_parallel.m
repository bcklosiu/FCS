function  [photonArrivalTimes, twoDIntensity, frameSync, lineSync, pixelSync]= decodeFIFObinary_parallel (fblock, TACrange, TACgain)

% [photonArrivalTimes, twoDIntensity, frameSync, lineSync, pixelSync]= decodeFIFObinary_parallel (fblock, TACrange, TACgain)
% 
% decodeFIFObinary_parallel decodes the B&H spc files. The decoding is parallelised for 8 workes (maximum allowed number of workers for Matlab2010). 
% 
% Input arguments:
% fblock - Coded individual events.
% TACrange (en s) y TACgain - B&H acquisition. TAC parameters.
% 
% Output arguments (struct dataOut):
% photonArrivalTimes.frameLinePixel -uint32- Corresponding frame, line and pixel of each photon.
% photonArrivalTimes.MacroMicroTime -double-  Macrotime (from the beginning of the experiment, in seconds) and microtime (from the last laser pulse, in seconds) of each photon.
% photonArrivalTimes.channel -uint8- Corresponding channel to each photon.
% twoDIntensity -uint16- Decoded image.
% frameSync.frame -uint32- Acquired frames. 
% frameSync.time -double- Start time of the acquired frames (in seconds).
% lineSync.frameLine -uint32- Acquired lines and their corresponding frames: [frame, line].
% lineSync.time -double- Start time of the acquired lines (in seconds).
% pixelSync.frameLinePixel -uint32- Acquired pixels and their corresponding frames and lines:[frame, line, pixel].
% pixelSync.time -double- Start time of the acquired frames, lines and pixels (in seconds).
% 
% Unai, 28may2015. Based on decodeFIFObinary_parallel 08may2014
% Unai - 6Ago15. Output arguments changed.
% Unai - 25Sep15. Distinction in the initialisation of photonArrivalTimes.frameLinePixel for scanning FCS and point FCS. 

%% B&H marks
INVALID32=uint32(hex2dec('80000000')); %Invalid photon 
P_MARK32=uint32(hex2dec ('90001000')); %New pixel 
L_MARK32=uint32(hex2dec ('90002000')); %New line 
F_MARK32=uint32(hex2dec ('90004000')); %New frame 
PLF_MARK32=uint32(hex2dec ('7000')); %New pixel, line and frame 

MTOV32=uint32(hex2dec('40000000'));             %Macro timer overflow
INVALID_MTOV32=uint32(hex2dec('c0000000'));     %Invalid + Macro timer overflow
INVALID_MARK32=uint32(hex2dec('90000000'));     %Invalid + Mark 
INV_MTOV_GAP_MARK32=uint32(hex2dec('F0000000'));  %Invalid + MT overflow + Gap + Mark
OVRUN32=uint32(hex2dec('20000000'));            %Fifo overrun, recording gap
ROUT32=uint32(hex2dec('f000'));                 %Routing signals(inverted)
MT32=uint32(hex2dec('fff'));                    %Macro time
MT16=uint16(MT32);  %MT32 must be a 16 bit variable in the adc bitand operation
ADC32=uint32(hex2dec('0fff0000'));              %ADC value
CNT32=uint32(hex2dec('0FFFFFFF'));

% Masks for the 1st event in .spc file
RB_NO32=uint32(hex2dec('78000000'));   %routing bits number used during measurement
MT_CLK32=uint32(hex2dec('00ffffff'));   %macro time clock (in 0.1 ns units)
M_FILE32=uint32(hex2dec('02000000'));   %file with markers
R_FILE32=uint32(hex2dec('04000000'));   %file with raw data (diagnostic mode only)

% Byte 3
maskf0 = uint8(hex2dec('f0'));  %4 most significant bits of byte 3 (4)
mask0f = uint8(hex2dec('0f'));  %4 least significant bits of byte 3 (4)
mask90 = uint8(hex2dec('90'));  %Invalid and Mark
maska0 = uint8(hex2dec('a0'));  %Invalid and Gap
mask20 = uint8(hex2dec('20'));  %Gap
maskc0 = uint8(hex2dec('c0'));  %Invalid and MacroTime overflow
maskd0 = uint8(hex2dec('d0'));  %Invalid and Mark and MacroTime overflow
mask00 = uint8(hex2dec('00'));  %Photon
mask40 = uint8(hex2dec('40'));  %MTOV: MacroTime overflow

frameClockPattern = uint8(hex2dec('40'));
lineClockPattern = uint8(hex2dec('20'));
pixelClockPattern = uint8(hex2dec('10'));

invAndGap_event=maska0; % Invalid and Gap
gap_event=mask20; %Gap
invAndMark_event=mask90;
invAndMarkandMacroOverFlow_event=maskd0;
invAndMacroOverFlow_event=maskc0; %Invalid and Macrotime Overflow bits are activated
timerOverflow_event=mask40; %Macro Timer Overflow with photon detection
photon_event=mask00;

%% Common variables initialisation
currentFrame= 0;
currentLine = 0;
currentPixel=0;
timeStep = 4096;
macroTcounter=0;
macroTOffset=0;
photonCount=0;
numValidEvents=numel(find(bitand(fblock,INVALID32)==0)); %Number of valid events 
data_MacroMicroTime=zeros(numValidEvents, 2, 'double');
data_channel=zeros(numValidEvents,1,'uint8');
lineEventcounter=0;
numWorkers=feature('NumCores'); %Number of active workers. 
if numWorkers>=8
    numWorkers=8; %For Matlab 2010b, 8 workers maximum.
end %end if (numWorkers)

%% First event
event1=fblock(1);
MacroTimeClock=double(bitand(event1,MT_CLK32))/10; %Macro Time clock (in 0.1 ns unit);
foundFrame = find(bitand(fblock,F_MARK32) == F_MARK32); %Frame events in fblock
foundLine = find(bitand(fblock,L_MARK32) == L_MARK32); %Line events in fblock

%% Identify the acquisition type
if not(and(isempty(foundFrame),isempty(foundLine))); %FIFO Image or Scanning FCS
    firstFrame=foundFrame(1);       %First frame mark in fblock
    numLines=numel(find(bitand(fblock(firstFrame:foundFrame(2)),L_MARK32) == L_MARK32));     %Nr. of lines in 1 frame
    if numLines<530, %FIFO Image
        acqType=1;
    else    %Scanning FCS
        acqType=2;
    end
else %FIFO Point
    acqType=3;
end


switch acqType
    case {1,2} %FIFO Image or Scanning FCS
        data_frameLinePixel=zeros(numValidEvents, 3, 'uint32');
        lastFrame=foundFrame(end);      %Last Frame mark in fblock
        numFrames=numel(foundFrame); 
        firstLine=foundLine(1);       %First line event in fblock       
        lastLine=foundLine(end);      %Last line event in fblock   
        numPixels=numel(find(bitand(fblock(firstLine:foundLine(2)),P_MARK32) == P_MARK32));  %Nr. of pixels in 1 Line
        pixelCount=0;
        
        if acqType==1 %FIFO Image (fblock will be decoded from the first frame event to the last frame event)
            forFrom=firstFrame; %1st index of the for bucle
            forTo=lastFrame; %2nd index of the for bucle
            numLinesTotal=numLines;
            numPixelTotal=numel(find(bitand(fblock(forFrom:forTo),P_MARK32) == P_MARK32));

        else    %Scanning FCS (fblock will be decoded from the first line event to the last line event)
            forFrom=firstLine; %1st index of the for bucle
            forTo=lastLine; %2nd index of the for bucle
            numLinesTotal=numel(find(bitand(fblock(forFrom:forTo),L_MARK32) == L_MARK32));
            numPixelTotal=numel(find(bitand(fblock(forFrom:forTo),P_MARK32) == P_MARK32));
        end     %end if (FIFO Image/Scanning FCS)
    
        %The total number of frames will be divided by numWorkers
        coc=double(idivide(numFrames,uint32(numWorkers),'floor')); %quotient
        resto=rem(numFrames,numWorkers); %remainder
        vFrames=coc*ones(1,numWorkers); %Nr. of frames analysed per worker
        if resto>0
            vFrames(1:resto)=vFrames(1:resto)+1;
        end %end if(resto)
        v=zeros(1,numWorkers); %Number of fblock events analysed per worker
        v(1,1)=foundFrame(vFrames(1))-forFrom+1;
        for fl1=2:numWorkers-1
            v(1,fl1)=foundFrame(sum(vFrames(1:fl1)))-foundFrame(sum(vFrames(1:fl1-1)));
        end %end for(fl1)
        v(1,end)=forTo-foundFrame(sum(vFrames(1:end-1)));
        fblockCutmat=fblock(forFrom:forTo,1); 
        fblockCutcell=mat2cell(fblockCutmat,v,1); %Sorted fblock. Each column will be analysed by one worker
  
    case 3 % FIFO Point (fblock will be completely decoded) 
        data_frameLinePixel=zeros(1, 3, 'uint32');
        vFrames=zeros(1,numWorkers);
        forFrom=2; % 1st index of the for bucle
        forTo=size(fblock,1); % 2nd index of the for bucle
        numPixelPoint=(find(bitand(fblock(forFrom:forTo),P_MARK32) == P_MARK32)); % Nr. of pixels in the whole acquisition
        numFrames=1;
        numLinesTotal=1;
        numPixels=2;
        numPixelTotal=1;
        if not(isempty(numPixelPoint)), %Remove the extra pixels (in case of coded scanner movement at the end of acquisition) 
            fblock(numPixelPoint+1)=[];
            forTo=size(fblock,1);
        end %end if(not(isempty(numPixelPoint)))

        %fblock will be divided into different parts, according to numWorkers. All the events are photons.
        coc=double(idivide(forTo-forFrom+1,uint32(numWorkers),'floor')); %quotient
        resto=rem(forTo-forFrom+1,numWorkers); %remainder
        v=coc*ones(1,numWorkers); %Number of photon events analysed per worker
        if resto>0
            v(1:resto)=v(1:resto)+1;
        end %end if(resto)
        fblockCutmat=fblock(forFrom:forTo,1);
        fblockCutcell=mat2cell(fblockCutmat,v,1); %Sorted fblock. Each column will be analysed by one worker
end     %end switch(acqType)1


frameSync_f=zeros (numFrames,1,'uint32'); %frameSync_frame
frameSync_t=zeros (numFrames,1,'double'); %frameSync_time
lineSync_fl=zeros (numLinesTotal,2,'uint32'); %lineSync_frameLine
lineSync_t=zeros(numLinesTotal,1,'double'); %lineSync_time
pixelSync_flp=zeros (numPixelTotal, 3, 'uint32'); %pixelSync_frameLinePixel
pixelSync_t=zeros (numPixelTotal, 1, 'double'); %pixelSync_time

%% Parallelised code: every event will be decoded and stored in its corresponding worker. The created variables are composites.
spmd (numWorkers)
    parFrame=fblockCutcell{labindex}; 
    parNumValidEvents=numel(find(bitand(parFrame,INVALID32)==0));
    %Nr. of photons per worker
    if acqType<3, %not FIFO Point
        parData_frameLinePixel=zeros(parNumValidEvents,3,'uint32');
    end
    parData_MacroMicroTime=zeros(parNumValidEvents,2,'double');
    parData_channel=zeros(parNumValidEvents,1,'uint8');        
    parFrameCount=numel(find(bitand(parFrame,F_MARK32) == F_MARK32)); %Nr. of frames per worker
    parFrameSync_f=zeros(parFrameCount,1,'uint32');
    parFrameSync_t=zeros(parFrameCount,1,'double');
    parLineCount=numel(find(bitand(parFrame,L_MARK32) == L_MARK32)); %Nr. of lines per worker
    parLineSync_fl=zeros(parLineCount,2,'uint32');
    parLineSync_t=zeros(parLineCount,1,'double');
    parPixelCount=numel(find(bitand(parFrame,P_MARK32) == P_MARK32)); %Nr. of pixels per worker
    parPixelSync_flp=zeros(parPixelCount,3,'uint32');
    parPixelSync_t=zeros(parPixelCount,1,'double');
    
    for bb = 1:numel(parFrame)
        parEventdata=parFrame(bb);
        bytesinEvent=typecast (parEventdata, 'uint8'); %Split event in 4 parts (8 bits each)
        adcM=bytesinEvent(4);
        
        event_adcM=bitand(adcM, maskf0);
        switch (event_adcM) %Frame, Line and Pixel markers don't have microtime bits
            
            case {invAndMark_event, invAndMarkandMacroOverFlow_event}
                if event_adcM==invAndMarkandMacroOverFlow_event
                    macroTcounter=macroTcounter+1;
                    macroTOffset=macroTcounter*timeStep;
                end %end if (event_adcM)
                newframe_event=bitand(parEventdata, F_MARK32);  
                newline_event=bitand(parEventdata, L_MARK32);	
                newpixel_event=bitand(parEventdata, P_MARK32);	
                if newframe_event==F_MARK32 %frame clock
                    currentFrame  = currentFrame + 1;
                    currentLine = 0;
                    frameStart=double(bitand (parEventdata, MT32))+macroTOffset; 
                    parFrameSync_f(currentFrame)=currentFrame;
                    parFrameSync_t(currentFrame)=frameStart;
                end %end if (newframe_event)
                if newline_event==L_MARK32 %line clock
                    if currentLine < (numLines+1);
                        currentLine = currentLine + 1;
                        lineEventcounter=lineEventcounter+1;
                        currentPixel=0;
                        lineStart=double(bitand (parEventdata, MT32))+macroTOffset; 
                        parLineSync_fl(lineEventcounter,:)=[currentFrame,currentLine];
                        parLineSync_t(lineEventcounter)=lineStart;
                    end %end if (currentLine)
                end %end if (newline_event)
                    if newpixel_event==P_MARK32 %pixel clock
                        pixelCount=pixelCount+1;   
                        currentPixel=currentPixel+1;
                        pixelStart=double(bitand (parEventdata, MT32))+macroTOffset; 
                        parPixelSync_flp(pixelCount, :)=[currentFrame,currentLine,currentPixel];
                        parPixelSync_t(pixelCount)=pixelStart;
                    end %end if (newpixel_event)

            case invAndMacroOverFlow_event %Inv and MacroTime Overflow
                macroTimerOFCount = double(bitand(parEventdata, CNT32));       %Nr. of MT overflows between two detected photons
                macroTcounter=macroTcounter+macroTimerOFCount;
                macroTOffset=macroTcounter*timeStep;

            case {gap_event, invAndGap_event}
                disp('gap - FIFO overflow')

            case timerOverflow_event   %Photon detected with a Macro Timer OverFlow
                photonCount=photonCount+1; 
                macroTcounter=macroTcounter+1; 
                macroTOffset=macroTcounter*timeStep; 
                macroT =  double(bitand(parEventdata, MT32));   %12 significant bits MacroTime
                photonMacroTime = macroT+macroTOffset; %Macro Time clocks
                eventdata16=typecast (parEventdata, 'uint16'); %Split event in 2 parts (16 and 16 bits)
                adc = double(bitand(eventdata16(2), MT16)); % 12 significant bits ADC
                photonMicroTime = (4095 - adc); % Micro Time unit
                channel=uint8(bitshift(bitand(parEventdata,ROUT32),-12)); % Routing channel 
                parData_MacroMicroTime(photonCount,:)=[photonMacroTime, photonMicroTime];
                parData_channel(photonCount)=channel;
                if acqType<3,
                parData_frameLinePixel(photonCount,:)=[currentFrame, currentLine, currentPixel]; 
                end
                
            case photon_event  %Photon detected
                photonCount=photonCount+1; 
                macroT =  double(bitand(parEventdata, MT32));   % 12 significant bits MacroTime
                photonMacroTime = macroT+macroTOffset; % Macro Time clocks
                eventdata16=typecast (parEventdata, 'uint16'); %Split event in 2 parts (16 and 16 bits)
                adc = double(bitand(eventdata16(2), MT16)); %12 significant bits ADC
                photonMicroTime = (4095 - adc); %Micro Time unit
                channel=double(bitshift(bitand(parEventdata,ROUT32),-12)); %Routing channel 
                parData_MacroMicroTime(photonCount,:)=[photonMacroTime, photonMicroTime];
                parData_channel(photonCount,:)=channel;
                if acqType<3,
                parData_frameLinePixel(photonCount,:)=[currentFrame, currentLine, currentPixel];
                end
                
        end     %end switch(event_adcM)
    end     % end for(bb)
    
    parData_frameLinePixel(photonCount+1:end,:)=[]; %Remove empty rows in parData_frameLinePixel (if any)
    parData_MacroMicroTime(photonCount+1:end,:)=[]; %Remove empty rows in parData_MacroMicroTime (if any)
    parData_channel(photonCount+1:end,:)=[]; %Remove empty rows in parData_channel(if any)
    
end     %end spmd (Parallelised code)

%% Copy and sort the parallelised data (from composites to arrays)
matPhotonCount=cell2mat(photonCount(:,:));
matMacroTOffset=cell2mat(macroTOffset(:,:));
indPhotTo=0;
sumaMToffset=0;
sumaFrameCores=0;

for aa2=1:numWorkers
    dataLab_MacroMicroTime=parData_MacroMicroTime{aa2}; 
    dataLab_channel=parData_channel{aa2};
    indPhotFrom=indPhotTo+1; %Initial index to copy the photons in data_frameLinePixel, data_MacroMicroTime, data_channel  
    indPhotTo=sum(matPhotonCount(1:aa2)); %Final index to copy the photons in data_frameLinePixel, data_MacroMicroTime, data_channel 
    data_MacroMicroTime(indPhotFrom:indPhotTo,1)=dataLab_MacroMicroTime(:,1)+sumaMToffset;
    data_MacroMicroTime(indPhotFrom:indPhotTo,2)=dataLab_MacroMicroTime(:,2);
    data_channel(indPhotFrom:indPhotTo,:)=dataLab_channel;
    if acqType<3, %not FIFO Point
        dataLab_frameLinePixel=parData_frameLinePixel{aa2};
        data_frameLinePixel(indPhotFrom:indPhotTo,1)=dataLab_frameLinePixel(:,1)+sumaFrameCores;
        data_frameLinePixel(indPhotFrom:indPhotTo,2:3)=dataLab_frameLinePixel(:,2:3);
    end
    sumaMToffset=sumaMToffset+matMacroTOffset(aa2);
    sumaFrameCores=sumaFrameCores+vFrames(aa2);
end %end for(aa2)

numPhots=sum(matPhotonCount); % Total number of decoded photons  
data_MacroMicroTime(numPhots+1:end,:)=[]; 
data_channel(numPhots+1:end,:)=[]; 

acqChannels=unique(data_channel);
nr_RoutChannels=numel(acqChannels); %Nr. of acquired channels
dif_channels=(acqChannels-uint8(0:1:nr_RoutChannels-1)'); %Difference between the acquistion channels and consecutive channels
%The acquisition channels may not be consecutive. The following if loop affects the initialisation of twoDIntensity. To avoid more Z planes than expected.
if(not(isempty(find(dif_channels~=0, 1)))) 
    data_channel_sort=zeros(size(data_channel),'uint8');
    for ch=1:nr_RoutChannels,
        indChannel=data_channel==acqChannels(ch);
        data_channel_sort(indChannel)=ch-1;
    end %end for(ch)
else
    data_channel_sort=data_channel;
end %end if(isempty)

twoDIntensity=zeros(numLinesTotal, numPixels-1, nr_RoutChannels, 'uint16'); %Decoded image initialisation

switch acqType
    case {1,2}
        data_frameLinePixel(numPhots+1:end,:)=[];
        indIMG=and(and(data_frameLinePixel(:,2)>0,data_frameLinePixel(:,2)<numLines+1),and(data_frameLinePixel(:,3)>0,data_frameLinePixel(:,3)<numPixels)); % Valid indexes for FCSdata
        data_frameLinePixel(not(indIMG),:)=[];
        data_MacroMicroTime(not(indIMG),:)=[]; 
        data_channel(not(indIMG),:)=[];
        data_channel_sort(not(indIMG),:)=[];
        numPhotFin= size(data_MacroMicroTime,1);% Number of photons for the whole acquisition

        % Filling frameSync, lineSync and pixelSync in 
        matFrameSync=cell2mat(parFrameCount(:,:)); 
        matLineSync=cell2mat(parLineCount(:,:)); 
        matPixelSync=cell2mat(parPixelCount(:,:)); 
        indFSyncTo=0; %Final index to copy the data in frameSync_f, frameSync_t
        indLSyncTo=0; %Final index to copy the data in lineSync_fl, lineSync_t
        indPSyncTo=0; %Final index to copy the data in pixelSync_flp, pixelSync_t
        sumMToffset=0;
        for aa3=1:numWorkers
            fSyncTemp_f=parFrameSync_f{aa3};
            fSyncTemp_t=parFrameSync_t{aa3};
            lSyncTemp_fl=parLineSync_fl{aa3};
            lSyncTemp_t=parLineSync_t{aa3};
            pSyncTemp_flp=parPixelSync_flp{aa3};
            pSyncTemp_t=parPixelSync_t{aa3};
            indFSyncFrom=indFSyncTo+1; %Initial index to copy the data in frameSync_f, frameSync_t
            sumFrameFS=indFSyncTo;
            indFSyncTo=indFSyncTo+matFrameSync(aa3);
            indLSyncFrom=indLSyncTo+1; %Initial index to copy the data in lineSync_fl, lineSync_t
            indLSyncTo=indLSyncTo+matLineSync(aa3);
            indPSyncFrom=indPSyncTo+1; %Initial index to copy the data in pixelSync_flp, pixelSync_t
            indPSyncTo=indPSyncTo+matPixelSync(aa3);
            frameSync_f(indFSyncFrom:indFSyncTo)=fSyncTemp_f+sumFrameFS; %frameSync Frame
            frameSync_t(indFSyncFrom:indFSyncTo)=fSyncTemp_t+sumMToffset; %frameSync Time
            lineSync_fl(indLSyncFrom:indLSyncTo,1)=lSyncTemp_fl(:,1)+sumFrameFS; %lineSync Frame
            lineSync_fl(indLSyncFrom:indLSyncTo,2)=lSyncTemp_fl(:,2); %lineSync Line
            lineSync_t(indLSyncFrom:indLSyncTo)=lSyncTemp_t+sumMToffset; %lineSync Time
            pixelSync_flp(indPSyncFrom:indPSyncTo,1)=pSyncTemp_flp(:,1)+sumFrameFS; %pixelSync Frame
            pixelSync_flp(indPSyncFrom:indPSyncTo,2:3)=pSyncTemp_flp(:,2:3); %pixelSync Line & Pixel 
            pixelSync_t(indPSyncFrom:indPSyncTo)=pSyncTemp_t+sumMToffset; %pixelSync Time
            sumMToffset=sumMToffset+matMacroTOffset(aa3);
        end %end for(aa3)
    
        if acqType==1 %FIFO Image
            for c=1:numPhotFin %Image recontruction (FIFO Image)
                twoDIntensity(data_frameLinePixel(c,2),data_frameLinePixel(c,3),data_channel_sort(c,1)+1)=...
                    twoDIntensity(data_frameLinePixel(c,2),data_frameLinePixel(c,3),data_channel_sort(c,1)+1)+1;
            end     %end for(c)
        
        else % Scanning FCS 
            qSum=zeros(numFrames+2,1); %Quantity to add to data_frameLinePixel(:,2)
            indrSum=zeros(numFrames+2,1); %Indexes to complete rSum
            rSumFrame1=data_frameLinePixel(find(data_frameLinePixel(:,1)==0,1,'last'),2); %Nr. of lines in Frame0
            for d=2:numFrames+2 
                qSum(d,1)=rSumFrame1+numLines*(d-2);
                indrSum(d,1)=find(data_frameLinePixel(:,1)==d-2,1,'last'); %Nr. of lines in the corresponding frame
            end  % end for(d)

            rSum=zeros(size(data_frameLinePixel,1),1); % Row matrix, added to data_frameLinePixel(:,2), to display the whole acquisition in a row  
            for e=1:numFrames+1 %Fills in rSum
                rSum(indrSum(e)+1:indrSum(e+1))=qSum(e);
            end %end for(e)

            for f=1:numPhotFin % Image recontruction (Scanning FCS)
                twoDIntensity(rSum(f)+data_frameLinePixel(f,2),data_frameLinePixel(f,3),data_channel_sort(f,1)+1)=...
                    twoDIntensity(rSum(f)+data_frameLinePixel(f,2),data_frameLinePixel(f,3),data_channel_sort(f,1)+1)+1;
            end     % end for(f)
        end %end if (FIFO Image/Scanning FCS)

        frameSync_t=MacroTimeClock*1E-9*frameSync_t; %Convert from clocks to s
        lineSync_t=MacroTimeClock*1E-9*lineSync_t; %Convert from clocks to s
        pixelSync_t=MacroTimeClock*1E-9*pixelSync_t; %Convert from clocks to s
        indPixelSync=and(and(pixelSync_flp(:,2)>0,pixelSync_flp(:,2)<numLines+1),and(pixelSync_flp(:,3)>0,pixelSync_flp(:,3)<numPixels)); % Valid indexes for pixelSync
        pixelSync_flp=pixelSync_flp(indPixelSync,:);
        pixelSync_t=pixelSync_t(indPixelSync,:);
    
    case 3 % FIFO Point
        data_MacroMicroTime(numPhots+1:end,:)=[]; 
        data_channel(numPhots+1:end,:)=[]; 
end     % end switch(acqType)2

data_MacroMicroTime(:,1)=MacroTimeClock*1E-9*data_MacroMicroTime(:,1); %Macro Time (s)
data_MacroMicroTime(:,2)=data_MacroMicroTime(:,2)*TACrange/(TACgain*4096); %Micro Time (s)

%%  Output variable
photonArrivalTimes=struct('frameLinePixel',data_frameLinePixel,'MacroMicroTime',data_MacroMicroTime,'channel',data_channel);
frameSync=struct('frame',frameSync_f,'time',frameSync_t);
lineSync=struct('frameLine',lineSync_fl,'time',lineSync_t);    
pixelSync=struct('frameLinePixel',pixelSync_flp,'time',pixelSync_t);

% end decodeFIFOBinary_parallel
