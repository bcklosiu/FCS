function varargout=FCS_representa_ajuste (FCSdata, Gdata, Gmodel, deltaT, tipoCorrelacion,  canal, hfig)
%[hcorr hres htrace hfig]=FCS_representa_ajuste (FCSdata, Gdata, Gmodel, deltaT, tipoCorrelacion, canal, hfig)

%
% hcorr=FCS_representa (FCSdata, Gdata, deltaT, tipoCorrelacion, Gmodel);
% Representa el resultado de la correlación
%   FCSTraza es un vector columna o una matriz de dos columnas que contiene los datos de la traza temporal de uno o dos canales, respectivamente.
%   Generalmente FCSTraza es un binning de FCSdata a 0.001 s ó 0.005s (usando FCS_calculabinstraza)
%   tTraza es el tiempo de la traza temporal
%   cpscanal son las cuentas por segundo del canal
%   Gdata es una matriz que contiene los datos de la correlación: la 1ª columna es el tiempo, la 2ª la ACF del canal 1, la 3ª su error, etc.
%   tipoCorrelación es una cadena de caracteres que indica que tipo de correlación calculará el programa ('auto', 'cross' o 'todas')
%   Gmodel es la curva de correlacion calculada con los parámetros ajustados
%   canal es una variable opcional para distinguir entre el canal 1 y el canal 2
%   hcorr, htrace, hres son los handles correspondientes a la gráfica de la
%   correlación, la traza temporal y los residuos

% jri & GdlH (12nov10)
% jri & GdlH (01jun11)
% jri 1ago14 - Evito el argumento de salida con vargout si no se pone nada
% jri 1ago14 - Cambio el tamaño de la figura para que no se salga de la
% pantalla.
% jri 1ago14 - Comentarios en inglés y fondo blanco
% jri 1ago14 - Cambio la escala a ms (no sólo la leyenda)
% jri 15Mar26 - La traza ya no está normalizada, sino en 10^2 CPS

%También podría ser varargout=FCS_representa_ajuste (FCSTraza, tTraza, cpscanal, Gdata, tipoCorrelacion, Gmodel, canal, hfig)

if nargin<7 %No hay handle a la figura, por tanto crea una nueva
    hfig=figure;
else
    %set (0, 'CurrentFigure', hfig);
    figure (hfig)
    clf (hfig)
end

verde =[1 131 95]/255;
rojo = [197 22 56]/255;
azul = [0 102 204]/255;
negro = [50 50 50]/255;


tdata_k=Gdata(:,1)*1000; %Para que la escala esté en ms
G(:,1)=Gdata(:,2);
SD (:,1)=Gdata(:,3);
if size(Gdata,2)>3
    G(:,2)=Gdata(:,4);
    SD (:,2)=Gdata(:,5);
    G(:,3)=Gdata(:,6);
    SD (:,3)=Gdata(:,7);
end

[FCSTraza, tTraza, cpscanal, FCSTrazaNorm]=FCS_calculabinstraza(FCSdata, deltaT, 0.01);
linePos=mean(FCSTraza);


htrace=subplot (3,1,1); %Representa las trazas
hcorr=subplot (3,1,2); % Representa la autocorrelacion
hres=subplot (3,1,3); % Representa los residuos


switch (tipoCorrelacion)
    case 'auto'
        set(hfig, 'CurrentAxes', htrace)
        if canal==1
            htemp1=plot (tTraza, FCSTraza(:,1), 'Color', verde, 'Linewidth', 2);
            hLegend(1)=legend (['Ch 1(CPS): ', num2str(cpscanal(1))]);
            axis (htrace, [min(tTraza)*0.95 max(tTraza)*1.025 min(FCSTraza(:))*0.99 max(FCSTraza(:))*1.01]) %Cambia los límites de los ejes
            v=axis (htrace);
            line ([v(1) v(2)], [linePos linePos], 'Color', [0 0 0], 'LineStyle', ':') %Pinta una línea que pasa por 0
            
        else
            htemp=plot (tTraza, FCSTraza(:,1), 'Color', rojo, 'Linewidth', 2);
            hLegend(1)=legend (['Ch 2: ', num2str(cpscanal(1))]);
            axis (htrace, [min(tTraza)*0.75 max(tTraza)*1.25 min(FCSTraza(:))*0.99 max(FCSTraza(:))*1.01]) %Cambia los límites de los ejes
            v=axis (htrace);
            line ([v(1) v(2)], [linePos linePos], 'Color', [0 0 0], 'LineStyle', ':') %Pinta una línea que pasa por 1
            
        end
        
        set(hfig, 'CurrentAxes', hcorr)
        if canal==1
            hcorr1=errorbar (tdata_k, G, SD, 'o', 'Color', verde, 'Linewidth', 2);
            if not(isempty(Gmodel))
                hold on
                hmodel1=plot(tdata_k, Gmodel, 'Color', verde, 'Linewidth', 2);
            end
            hLegend(2)=legend ('Ch 1','Fit');
        else
            hcorr1=errorbar (tdata_k, G, SD, 'o', 'Color', rojo, 'Linewidth', 2);
            if not(isempty(Gmodel))
                hold on
                hmodel1=plot(tdata_k, Gmodel, 'Color', rojo , 'Linewidth', 2);
            end
            hLegend(2)=legend ('Ch 2','Fit');
            
        end
        hold off
        if not(isempty(Gmodel))
            hres=subplot (3,1,3); % Representa los residuos
            if canal==1
                hres1=plot(tdata_k, Gmodel-G, 'Color', verde, 'Linewidth', 2);
            else
                hres1=plot(tdata_k, Gmodel-G, 'Color', rojo, 'Linewidth', 2);
            end
        end
        
    otherwise % cuando es correlación cruzada o todas
        set (hfig, 'CurrentAxes', htrace)
        htemp1=plot (tTraza, FCSTraza(:,1), 'Color', verde, 'Linewidth', 1.5);
        hold on
        htemp2=plot (tTraza, FCSTraza(:,2), 'Color', rojo, 'Linewidth', 2);
        hLegend(1)=legend (['Ch 1: ', num2str(cpscanal(1))], ['Ch 2: ', num2str(cpscanal(2))]);
        axis (htrace, [min(tTraza)*0.75 max(tTraza)*1.25 min(FCSTraza(:))*0.99 max(FCSTraza(:))*1.01]) %Cambia los límites de los ejes
        v=axis (htrace);
        line ([v(1) v(2)], [linePos linePos], 'Color', [0 0 0], 'LineStyle', ':') %Pinta una línea que pasa por 1
        set(hfig, 'CurrentAxes', hcorr)
        if strcmpi (tipoCorrelacion, 'todas')
            hold on
            hcorr1=errorbar (tdata_k, G(:,1), SD(:,1), 'o', 'Color', verde, 'Linewidth', 2);
            hcorr2=errorbar (tdata_k, G(:,2), SD(:,2), 'o', 'Color', rojo, 'Linewidth', 2);
            hcorr12=errorbar (tdata_k, G(:,3), SD(:,3), 'o', 'Color', azul, 'Linewidth', 2);
            
            if not(isempty(Gmodel))
                hmodel1=plot (Gmodel(:,1), Gmodel(:,2), 'Color', verde, 'Linewidth', 2);
                hmodel2=plot (Gmodel(:,1), Gmodel(:,3), 'Color', rojo, 'Linewidth', 2);
                hmodel12=plot (Gmodel(:,1), Gmodel(:,4), 'Color', azul, 'Linewidth', 2);
            end
            hold off
            hLegend(2)=legend ('Ch 1', 'Ch 2', 'Cross');
            
        else
            hcorr12=errorbar (tdata_k, G, SD, 'o', 'Color', azul, 'Linewidth', 2); %Si es correlación cruzada
            hold on
            if not(isempty(Gmodel))
                hmodel12=plot (tdata_k, Gmodel, 'Color', azul, 'Linewidth', 2);
            end
        end
        
        if not(isempty(Gmodel))
            set(hfig, 'CurrentAxes', hres)
            if strcmpi (tipoCorrelacion, 'todas')
                hold on
                hres1=plot(tdata_k, (Gmodel(:,1)-G(:,1)), 'Color', verde, 'Linewidth', 2);
                hres2=plot(tdata_k, (Gmodel(:,2)-G(:,2)), 'Color', rojo, 'Linewidth', 2);
                hres3=plot(tdata_k, (Gmodel(:,3)-G(:,3)), 'Color', azul, 'Linewidth', 2);
                hold off
            else
                hres1=plot(tdata_k, (Gmodel-G), 'Color', azul, 'Linewidth', 2); %Si es correlación cruzada
            end
        end
end

rect=get (hfig, 'OuterPosition');
screenSize=get(0, 'Screensize');
set (hfig, 'OuterPosition', [rect(1) 50 0.9*(screenSize(4)-50) screenSize(4)-50])
rect_sup=get (htrace, 'OuterPosition');
set (htrace, 'OuterPosition', [rect_sup(1) 0.8 rect_sup(3) rect_sup(3)*0.17])
%subplot (3,1,2)
rect_inf=get (hcorr, 'OuterPosition');
set (hcorr, 'OuterPosition', [rect_inf(1) 0.15 rect_sup(3) rect_sup(3)*0.6])
v=axis (hcorr);
axis (hcorr, [tdata_k(1)-0.25*tdata_k(1) tdata_k(end)+0.5*tdata_k(end) v(3) v(4)]) %Cambia los límites de los ejes
%subplot (3,1,3)
rect_res=get (hres, 'OuterPosition');
set (hres, 'OuterPosition', [rect_res(1) 0.01 rect_sup(3) rect_sup(3)*0.15])
set (hres, 'Box', 'on')
v=axis (hres);
axis (hres, [tdata_k(1)-0.25*tdata_k(1) tdata_k(end)+0.5*tdata_k(end) v(3) v(4)]) %Cambia los límites de los ejes
set (hfig, 'Color', [1 1 1])
set ([htrace hcorr hres], 'Color', 'none', 'FontName', 'Calibri', 'FontSize', 11, 'XColor', negro, 'YColor', negro, 'LineWidth', 1.5)
hLabel(1,1)=xlabel (htrace, 'Time (s)');
%hLabel(1,2)=ylabel (htrace, {'Channel-averaged'; 'normalised counts'});
hLabel(1,2)=ylabel (htrace, 'Counts (10^2 CPS)');
set ([hcorr hres], 'Box', 'on', 'XScale', 'log', 'XGrid', 'on', 'YGrid', 'on')
hLabel(2,1)=xlabel (hcorr, '\tau (ms)');
hLabel(2,2)=ylabel (hcorr, 'G (\tau)');
hLabel(3,1)=xlabel (hres, '\tau (ms)');
hLabel(3,2)=ylabel (hres, 'Residuals');


set (hLabel, 'FontName', 'Calibri', 'FontSize', 11, 'FontWeight', 'Bold', 'Color', negro)
set (hLegend, 'FontName', 'Calibri', 'FontSize', 11, 'FontWeight', 'Bold')


if nargout>1
    varargout{1}=hcorr;
    varargout{2}=hres;
    varargout{3}=htrace;
    varargout{4}=hfig;
end






