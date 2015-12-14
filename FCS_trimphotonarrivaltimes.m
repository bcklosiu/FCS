function varargout=FCS_trimphotonarrivaltimes(photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync, TACrange, TACgain, fname) 
%
%Scanning FCS:
%[photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync]=FCS_arrivalTimes2photonArrivalTimes (photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync, TACrange, TACgain, fname)
%
%Point FCS:
% photonArrivalTimes=FCS_arrivalTimes2photonArrivalTimes (photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync, TACrange, TACgain, fname)
% Convierte la matriz arrivalTimes según sale de decode en la matriz
% photonArrivalTimes de 6 o 3 columnas según sea scanning o point FCS
% 
% jri - 26Nov14
% Unai - 11ago15: photonArrivalTimes es una struct. En caso de point FCS,
% se elimina 

isScanning=and (numel(imgDecode)>1, and(numel(frameSync)>1, and(numel(lineSync)>1, numel(pixelSync)>1)));

fname=[fname(1:end-4) '.mat'];
if isScanning
    varargout={photonArrivalTimes, imgDecode, frameSync, lineSync, pixelSync, isScanning};
    disp ('Scanning FCS experiment')
%    disp (['Decode time:' numstr(tdecode/60) ' min'])
    disp (['Saving ' fname(1:end-4) '.mat'])
    save (fname, 'photonArrivalTimes', 'imgDecode', 'frameSync', 'lineSync', 'pixelSync', 'TACrange', 'TACgain', 'fname', 'isScanning')
    disp ('OK')
else
%     photonArrivalTimes(:, 1:3)=[];
    photonArrivalTimes=rmfield(photonArrivalTimes, 'frameLinePixel');
    varargout={photonArrivalTimes, isScanning};
    disp ('Point FCS experiment')
%    disp (['Decode time:' numstr(tdecode/60) ' min'])
    disp (['Saving ' fname])
    save (fname, 'photonArrivalTimes', 'TACrange', 'TACgain', 'fname', 'isScanning')
    disp ('OK')
end

