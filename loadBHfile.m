function [imData tdata acqDate]=loadBHfile (filename)


% [imData tdata aqcDate]=loadBHFile (filename)
%
%   Reads a ".sdt" files as recorded with B&H
%   assuming that the images are 256x256
%   and they have 256 time-bins
%   imData is a 3dmatrix where the first index is the time-bin, 
%   the second is the y coordinate and the third the x coordinate
%   tdata are in ns.
%
%  Added automatic detection of number of pixels, time bins and time range
%  También le pongo que me haga la traspuesta para que coincida con los tif
%  de Leica
%
%  He añadido la fecha como un argumento más de salida
% (se puede convertir a formato OMERO con datestr(acqDate, 'yyyy-mm-ddTHH:MM:SS'))
%
% jri 29ene13



fid=fopen(filename);

    fread(fid,1, 'uint16');

    %Reads the header
    
    fileinfopos=fread(fid,1, 'uint32');
    fileinfocount=fread(fid,1, 'uint16');
    setuppos=fread(fid,1, 'uint32');
    setupcount=fread(fid,1, 'uint16');
    blockheaderpos=fread(fid,1, 'uint32');
    fread(fid,1, 'uint16');
    fread(fid,1, 'uint32');
    fread(fid,1, 'uint32');
    fread(fid,1, 'uint16');
    fread(fid,1, 'uint16');
    fread(fid,1, 'uint16');
    fread(fid,1, 'uint32');
    fread(fid,1, 'uint16');
    fread(fid,1, 'uint16');
    
    fseek (fid, fileinfopos, 'bof');
    fileinfo=fread (fid, fileinfocount, 'uint8=>char');
    fileinfo=fileinfo';
    C=textscan(fileinfo, '%s', 'Delimiter', sprintf('\n'));
    str=C{1}; %Cada celda de str es una línea de fileinfo
    for n=2:numel(str)-2
        fprintf('%s \n', str{n});
    end
    k=strfind(fileinfo, 'Date');
    fecha=fileinfo(k+12:k+21);
    k=strfind(fileinfo, 'Time');
    hora=fileinfo(k+12:k+19);
    acqDate=datestr([fecha ' ' hora]); 
        
    fseek (fid, setuppos, 'bof');
    setup=fread (fid, setupcount, 'uint8=>char');
    setup=setup'; %setup contiene todos los campos del setup
    C=textscan(setup, '%s', 'Delimiter', sprintf('\n'));
    str=C{1};
    k= strfind(setup, 'TAC_R'); %TAC time/div
    if not(isempty(k))
        str2=strtok(setup(k+8:end), ']');     
        TAC_range=str2double (str2); %Lo mide en s
    end
    k= strfind(setup, 'TAC_G'); %TAC time/div
    if not(isempty(k))
        str2=strtok(setup(k+8:end), ']');          
        TAC_gain=str2double (str2); %Lo mide en s
    end
    k= strfind(setup, 'ADC_RE'); %ADC Resolution
    if not(isempty(k))
        str2=strtok(setup(k+9:end), ']');     
        ADC_resolution=str2double (str2); %en número de canales
    end
    k= strfind(setup, 'SP_SCAN_X'); %Número de pixeles X
    if not(isempty(k))
        str2=strtok(setup(k+12:end), ']');     
        numpixX=str2double (str2); 
            
    end
    k= strfind(setup, 'SP_SCAN_Y'); %Número de pixeles Y
    if not(isempty(k))
        str2=strtok(setup(k+12:end), ']');          
        numpixY=str2double (str2); 
    end

    fseek (fid, blockheaderpos, 'bof');
    fread(fid,1, 'uint16');
    datapos=fread(fid,1, 'uint32');
    datacount=fread(fid,1, 'uint32');
    fread(fid,1, 'uint16');
    fread(fid,1, 'uint16');
    fread(fid,1, 'uint32');
    dataelements=fread(fid,1, 'uint32')/2;
    
    % Reads the data
    
    fseek (fid, datapos, 'bof');
    a=fread(fid, datacount, 'uint16');

fclose(fid);

%Reshape the data array to Imdata (t, y, x)

imData=reshape (a, ADC_resolution, numpixX, numpixY);
for t=1:ADC_resolution
    imData(t,:,:)=squeeze(imData(t,:,:))';
end

timerange=1E9*TAC_range/TAC_gain;
tdata=0:timerange/ADC_resolution:timerange-timerange/ADC_resolution;
tdata=tdata(:);
fprintf('Timerange: %f ns\n', timerange);
fprintf('ADC resolution: %f channels\n', ADC_resolution);
fprintf('X dimension: %f pixels\n', numpixX);
fprintf('Y dimension: %f pixels\n', numpixY);

