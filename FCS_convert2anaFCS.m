function FCS_convert2anaFCS (fname)
%Convierte los archivos decodificados de Gloria en archivos anaFCS
%
% jri 21-Jan-2015

S=load (fname, 'isSCanningFCS', 'TACrange', 'TACgain', 'imgDecode', 'frameSync', 'lineSync', 'pixelSync', 'FCSdata');
S.isScanning=S.isSCanningFCS;
S.photonArrivalTimes=S.FCSdata;
S=rmfield(S, {'isSCanningFCS', 'FCSdata'});
S.fname=fname;
S=orderfields(S);
movefile (fname, [fname '_old'])
save (fname, '-struct', 'S')
