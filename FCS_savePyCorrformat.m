function g=FCS_savePyCorrformat(Gintervalos, FCSintervalos, binFreq, fileName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
% De https://github.com/paulmueller/PyCorrFit/blob/2373325b90387e54f8227ef6dd0db9e3dacbe069/src/readfiles/read_mat_ries.py

%Las trazas se almacenan como g.ac(numPuntos, numTrazas)
%Los datos temporales en g.act (1xnumPuntos)
%El tiempo debe ser común a todas las trazas g.ac y debe estar en s
%PyCorr lo espera en ms
% g.trace el promedio
% g.dc Cuando hay dos colores (g.dct)
% g.twof Two focus (g.twoft)
% g.dc2f Cuando hay dos colores (g.dc2ft)
% 
% Idealmente fileName es [path fname(1:end-4) '_PyCFit.mat']
%
% jri 20-Jan-2015


numData=size(FCSintervalos, 1);
numIntervalos=size(FCSintervalos, 3);
tdata=1000*(1:numData)*1/binFreq; %En ms!
g.act=squeeze(Gintervalos(:, 1, 1))*1000;
g.ac=squeeze(Gintervalos(:, 2, 1:end));

pos=find(fileName=='\', 1, 'last');
nombreFCSData=fileName(pos+1:end);
disp (['Saving ' nombreFCSData ' for PyCorrFit'])
    save (fileName, 'g', '-v7')
disp ('OK')

%g.trace=zeros(numData, numIntervalos+1);
%g.trace(:,1)=tdata;
%g.trace(:,2:numIntervalos+1)=squeeze(FCSintervalos(:, 1, 1:end));
%g.trace(:,1)=1:3;
% g.trace(2,1)=2;
% g.trace(3,1)=2;
% g.trace(4,1)=4;
% g.trace(1,2)=5;
% g.trace(2,2)=6;
% g.trace(3,2)=7;
% g.trace(4,2)=8;
