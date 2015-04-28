function varargout=FCS_representa (Gdata, tipoCorrelacion, hfig)

%
% [hCorr hsup hfig]=FCS_representa (FCSData, Gdata, tipoCorrelacion, hfig);
% Representa el resultado de la correlación
%   FCSData es un vector columna o una matriz de dos columnas que contiene datos de la traza temporal de uno o dos canales, respectivamente.
%   Gdata es una matriz que contiene los datos de la correlación (matrizFCS): la 1ª columna es el tiempo, la 2ª la ACF del canal 1, la 3ª su error, etc.
%   deltaT=1/sampfreq (en s)
%   tipoCorrelacion es 3 para correlacón cruzada o 1 ó 2 para autocorrelación
%   Puede estar vacío: []. Si no hay handle, tampoco es necesario ponerlo
%   hfig es el handle a la figura en la que lo representará. Si no se indica crea una figura nueva
%   Si no hay argumentos de salida no devuelve nada
%
%  hCorr es el handle a los ejes de la gráfica de la correlación (inferior)
%  hsup es el handle a los ejes de la gráfica de la traza temporal (superior)
%  hfig es el handle a la figura
%
% jri & GdlH - 12nov10
% jri & GdlH - 01jun11
% jri 19may14 - Evito el argumento de salida con vargout si no se pone nada
% jri 1ago14 - Cambio el tamaño de la figura para que no se salga de la pantalla.
% jri 1ago14 - Comentarios en inglés y fondo blanco
% jri 1ago14 - Cambio la escala a ms (no sólo la leyenda)
% jri 27Nov14 - Hago una función para calcular la traza y no tener que hacerlo de cada vez.
% jri 21Jan15 - Incluye que no sea necesario poner el canal en 'auto'
% jri 2Feb15 - Incluye el número de figura
% jri 26Mar15 - Dibuja CPS en 10^2 CPS (bins de 0.01s). Cambia la línea para que pase por el promedio, en vez de por 1
% jri 20Abr15

tdata_k=Gdata(:,1)*1000; %Para poner la escala en ms
G(:,1)=Gdata(:,2);
SD (:,1)=Gdata(:,3);
if size(Gdata, 2)>3
    G(:,2)=Gdata(:,4);
    SD (:,2)=Gdata(:,5);
    G(:,3)=Gdata(:,6);
    SD (:,3)=Gdata(:,7);
end


verde =[1 131 95]/255;
rojo = [197 22 56]/255;
azul = [0 102 204]/255;
negro = [50 50 50]/255;

if nargin<3 %No hay handle a la figura, por tanto crea una nueva
    hfig=figure;
else
    %set (0, 'CurrentFigure', hfig);
    figure (hfig)
end
set (0, 'CurrentFigure', hfig);
hCorr=axes;
%[FCSTraza, tTraza, cpscanal]=FCS_calculabinstraza(FCSData, deltaT, 0.01);
if tipoCorrelacion==3 % cuando es correlación cruzada
    set(hfig, 'CurrentAxes', hCorr)
    hold on
    hcorr1=errorbar (tdata_k, G(:,1), SD(:,1), 'o-', 'Color', verde, 'Linewidth', 1.5);
    hcorr2=errorbar (tdata_k, G(:,2), SD(:,2), 'o-', 'Color', rojo, 'Linewidth', 1.5);
    hcorr12=errorbar (tdata_k, G(:,3), SD(:,3), 'o-', 'Color', azul, 'Linewidth', 1.5);
    hLegend=legend ('Ch1', 'Ch2', 'Cross');
    hold off
else
    canal=1;
    set(hfig, 'CurrentAxes', hCorr)
    hCorrPlot=errorbar (tdata_k, G(:, canal), SD(:, canal), 'o-', 'Color', verde, 'Linewidth', 1.5);
    hLegend=legend (['Ch' num2str(canal)]);
end


rect=get (hfig, 'OuterPosition');
screenSize=get(0, 'Screensize');
%set (hfig, 'OuterPosition', [rect(1) 50 screenSize(4)-50 (screenSize(4)-50])
set (hCorr, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
v=axis (hCorr);
axis (hCorr, [tdata_k(1)-0.25*tdata_k(1) tdata_k(end)+0.5*tdata_k(end) v(3) v(4)])

set (hfig, 'Color', [1 1 1])
set (hCorr, 'Color', 'none', 'FontName', 'Calibri', 'FontSize', 11)

set (hCorr, 'XScale', 'log')
hLabel(1)=xlabel (hCorr, '\tau (ms)');
hLabel(2)=ylabel (hCorr, 'G (\tau)');
set (hLabel, 'FontName', 'Calibri', 'FontSize', 11)
set (hLegend, 'FontName', 'Calibri', 'FontSize', 11)


if nargout>0
    varargout(1)={hCorr};
end
if nargout>1
    varargout(2)={hfig};
end




