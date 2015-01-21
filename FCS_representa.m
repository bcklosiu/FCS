function varargout=FCS_representa (FCSdata, matrizG, deltaT, tipoCorrelacion, canal)

%
% hinf=FCS_representa (FCSdata, matrizG, deltaT, tipoCorrelacion, canal);
% Representa el resultado de la correlación
%   FCSdata es un vector columna o una matriz de dos columnas que contiene datos de la traza temporal de uno o dos canales, respectivamente.
%   matrizG es una matriz que contiene los datos de la correlación (matrizFCS): la 1ª columna es el tiempo, la 2ª la ACF del canal 1, la 3ª su error, etc.
%   deltaT=1/sampfreq (en s)
%   tipoCorrelacion es una cadena de caracteres que indica que tipo de correlación calculará el programa ('auto', 'cross' o 'todas')
%   canal es una variable opcional para distinguir entre el canal 1 y el canal 2
%   Si no hay argumentos de salida no devuelve nada
%
% jri & GdlH - 12nov10
% jri & GdlH - 01jun11
% jri 19may14 - Evito el argumento de salida con vargout si no se pone nada
% jri 1ago14 - Cambio el tamaño de la figura para que no se salga de la pantalla.
% jri 1ago14 - Comentarios en inglés y fondo blanco
% jri 1ago14 - Cambio la escala a ms (no sólo la leyenda)
% jri 27Nov14 - Hago una función para calcular la traza y no tener que hacerlo de cada vez. 
% jri 21Jan15 - Incluye que no sea necesario poner el canal en 'auto'

tdata_k=matrizG(:,1)*1000; %Para poner la escala en ms
G(:,1)=matrizG(:,2);
SD (:,1)=matrizG(:,3);
if size(matrizG, 2)>3
    G(:,2)=matrizG(:,4);
    SD (:,2)=matrizG(:,5);
    G(:,3)=matrizG(:,6);
    SD (:,3)=matrizG(:,7);
end


verde =[1 131 95]/255;
rojo = [197 22 56]/255;
azul = [0 102 204]/255;
negro = [50 50 50]/255;


hfig=figure;
hsup=subplot (2,1,1); %Representa las trazas
hinf=subplot (2,1,2); % Representa la autocorrelacion

[FCSTraza, tTraza, cpscanal]=FCS_calculabinstraza(FCSdata, deltaT, 0.02);
switch (tipoCorrelacion)
    case 'auto'
        if nargin<5 %No se ha indicado el canal que se quiere representar
            canal =1;
        end
          set(hfig, 'CurrentAxes', hsup)
        if canal==1
            htemp=plot (tTraza, FCSTraza(:,1), 'Color', verde, 'Linewidth', 1.5);
            hLegend(1)=legend (['Ch 1: ', num2str(cpscanal(1))]);
            v=axis (hsup);
            line ([v(1) v(2)], [1 1], 'Color', [0 0 0], 'LineStyle', ':')
            axis (hsup, [v(1) v(2) min(min(FCSTraza))*0.99 max(max(FCSTraza))*1.01])
            
            hold off
            set(hfig, 'CurrentAxes', hinf)
            hcorr=errorbar (tdata_k, G, SD, 'o-', 'Color', verde, 'Linewidth', 1.5);
        else
            htemp=plot (tTraza, FCSTraza(:,2), 'Color', rojo, 'Linewidth', 1.5);
            hLegend(1)=legend (['Ch 2: ', num2str(cpscanal(2))]);
            v=axis (hsup);
            line ([v(1) v(2)], [1 1], 'Color', [0 0 0], 'LineStyle', ':')
            axis (hsup, [v(1) v(2) min(min(FCSTraza))*0.99 max(max(FCSTraza))*1.01])
            
            hold off
            set(hfig, 'CurrentAxes', hinf)
            hcorr=errorbar (tdata_k, G, SD, 'o-', 'Color', rojo, 'Linewidth', 1.5);
        end
        
    otherwise % cuando es correlación cruzada o todas
        set(hfig, 'CurrentAxes', hsup)
        htemp1=plot (tTraza, FCSTraza(:,1), 'Color', verde, 'Linewidth', 1.5);
        hold on
        htemp2=plot (tTraza, FCSTraza(:,2), 'Color', rojo, 'Linewidth', 1.5);
        hLegend(1)=legend (['Ch 1: ', num2str(cpscanal(1))], ['Ch 2: ', num2str(cpscanal(2))]);
        
        v=axis (hsup);
        line ([v(1) v(2)], [1 1], 'Color', [0 0 0], 'LineStyle', ':') %Pinta una línea que pasa por 1
        %     line ([v(1) v(2)], [meangkmean(1)+sqrt(meangkmean(1)) meangkmean(1)+sqrt(meangkmean(1))]/meangkmean(1), 'Color', verde, 'LineStyle', ':') %Pinta una línea que indica la desv. est. poissoniana
        %     line ([v(1) v(2)], [meangkmean(1)-sqrt(meangkmean(1)) meangkmean(1)-sqrt(meangkmean(1))]/meangkmean(1), 'Color', verde, 'LineStyle', ':') %Pinta una línea que indica la desv. est. poissoniana
        %     line ([v(1) v(2)], [meangkmean(2)+sqrt(meangkmean(2)) meangkmean(2)+sqrt(meangkmean(2))]/meangkmean(2), 'Color', rojo, 'LineStyle', ':') %Pinta una línea que indica la desv. est. poissoniana
        %     line ([v(1) v(2)], [meangkmean(2)-sqrt(meangkmean(2)) meangkmean(2)-sqrt(meangkmean(2))]/meangkmean(2), 'Color', rojo, 'LineStyle', ':') %Pinta una línea que indica la desv. est. poissoniana
        axis (hsup, [v(1) v(2) min(min(FCSTraza))*0.99 max(max(FCSTraza))*1.01]) %Cambia los límites de los ejes
        
        set(hfig, 'CurrentAxes', hinf)
        if strcmpi (tipoCorrelacion, 'todas')
            hold on
            hcorr1=errorbar (tdata_k, G(:,1), SD(:,1), 'o-', 'Color', verde, 'Linewidth', 1.5);
            hcorr2=errorbar (tdata_k, G(:,2), SD(:,2), 'o-', 'Color', rojo, 'Linewidth', 1.5);
            hcorr12=errorbar (tdata_k, G(:,3), SD(:,3), 'o-', 'Color', azul, 'Linewidth', 1.5);
            hLegend(2)=legend ('Ch1', 'Ch2', 'Cross');
            hold off
        else
            hcorr12=errorbar (tdata_k, G, SD, 'o-', 'Color', azul, 'Linewidth', 1.5); %Si es correlación cruzada
        end
        
end


rect=get (hfig, 'OuterPosition');
screenSize=get(0, 'Screensize');
set (hfig, 'OuterPosition', [rect(1) 50 screenSize(4)-50 screenSize(4)-50])
rect_sup=get (hsup, 'OuterPosition');
set (hsup, 'OuterPosition', [rect_sup(1) 0.75 rect_sup(3) rect_sup(3)*0.2])
subplot (2,1,2)
rect_inf=get (hinf, 'OuterPosition');
set (hinf, 'OuterPosition', [rect_inf(1) 0.01 rect_sup(3) rect_sup(3)*0.7])
set (hinf, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
v=axis (hinf);
axis (hinf, [tdata_k(1)-0.25*tdata_k(1) tdata_k(end)+0.5*tdata_k(end) v(3) v(4)])
% axes (hsup)
%{
     a=get(hinf,'XTickLabel');
     b=str2num(a)+3; %%% Para pasar los segundos a milisegundos en escala logarítmica
     set(hinf,'XTickLabel',10.^b)
     xlabel ('\tau (ms)')
%}

set (hfig, 'Color', [1 1 1])
set ([hsup hinf], 'Color', 'none', 'FontName', 'Calibri', 'FontSize', 11)

hLabel(1,1)=xlabel (hsup, 'Time (s)');
hLabel(1,2)=ylabel (hsup, {'Channel-averaged'; 'normalised counts'});

set (hinf, 'XScale', 'log')
hLabel(2,1)=xlabel (hinf, '\tau (ms)');
hLabel(2,2)=ylabel (hinf, 'G (\tau)');
set (hLabel, 'FontName', 'Calibri', 'FontSize', 11)
set (hLegend, 'FontName', 'Calibri', 'FontSize', 11)


if nargout==1
    varargout(1)={hinf};
end




