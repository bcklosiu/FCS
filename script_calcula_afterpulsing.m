function script_calcula_afterpulsing
d=dir('*.mat');
for m=1:numel(d)
    fname=d(m).name;
    load (fname)
    load ('D:\jri\UBf\!Experimental\2015\Afterpulsing\afterpulsing_5000', 'tau_AP', 'alfaCoeff');
    
    %     Esto es para los viejos. Ahora los no corregidos son _noAP y los
    %     corregidos no llevan nada
    %     correctAP=true;
    %       Gmean_noAP=Gmean(:,1:end,1);
    %        Gmean=zeros(size(Gmean_noAP));
    %        deltaTBin=1/binFreq;
    %        [FCSTraza, tTraza]=FCS_calculabinstraza(FCSmean, numIntervalos, binFreq, 0.01);
    %        cpsIntervalos=round(squeeze(sum(FCSintervalos, 1)/(size(FCSintervalos, 1)*deltaTBin)));
    %        if size(FCSintervalos, 2)>1
    %            cpsIntervalos=cpsIntervalos'; %Primero los intervalos, luego los canales
    %        end
    %       cps=round(mean(cpsIntervalos));
    %      Gintervalos_noAP=Gintervalos;
    
    for n=1:numIntervalos
        [Gintervalos(:,:,n) alfa]=FCS_afterpulsing (Gintervalos_noAP(:, :, n), cpsIntervalos(n,:), tau_AP, alfaCoeff, channel);
    end
    
    Gmean=FCS_promedio(Gintervalos, intervalosPromediados, false);
    
    save (fname, 'Gmean', 'Gintervalos', 'tau_AP', 'alfaCoeff', 'alfa', '-append')
    %    FCS_save2ASCII ([fname(1:end-4) '_noAP.mat'], Gmean_noAP, 1, intervalosPromediados, cps);
    FCS_save2ASCII (fname(1:end-4), Gmean, channel, intervalosPromediados, cps);
    hfig=figure;
    set (hfig, 'Name', fname(1:end-4), 'Color', [1 1 1])
    errorbar(Gmean_noAP(:,1), Gmean_noAP(:,2), Gmean_noAP(:,3), 'b', 'LineWidth', 2)
    hold on
    errorbar(Gmean(:,1), Gmean(:,2), Gmean(:,3), 'r', 'LineWidth', 2)
    set (gca, 'xscale', 'log')
    h_text=text ('Units', 'normalized', 'Position', [0.8, 0.9], 'String', ['CPS: ', num2str(cps(1))]);
    set (h_text, 'BackgroundColor', [1 1 1])
    
    % También de los viejos
    %    errorbar(G_AP(:,1), G_AP(:,2), G_AP(:,3), 'g', 'LineWidth', 2)
    
    hold off
    h_legend=legend ('Uncorrected', 'Corrected');
    set (h_legend, 'Location', 'SouthWest', 'Box', 'off');
    grid on
    
    if channel==3
        hfig=figure;
        set (hfig, 'Name', [fname(1:end-4) ' -  Ch: 2'], 'Color', [1 1 1])
        errorbar(Gmean_noAP(:,1), Gmean_noAP(:,4), Gmean_noAP(:,5), 'b', 'LineWidth', 2)
        hold on
        errorbar(Gmean(:,1), Gmean(:,4), Gmean(:,5), 'r', 'LineWidth', 2)
        set (gca, 'xscale', 'log')
        h_text=text ('Units', 'normalized', 'Position', [0.8, 0.9], 'String', ['CPS: ', num2str(cps(2))]);
        set (h_text, 'BackgroundColor', [1 1 1])
        hold off
        h_legend=legend ('Uncorrected - Ch: 2', 'Corrected - Ch: 2');
        set (h_legend, 'Location', 'SouthWest', 'Box', 'off');
        grid on
    end
    
end

%{
for m=1:numel(d)
        fname=d(m).name;
    load (fname)
figure (m)
set (m, 'Name', fname)
errorbar(G_AP(:,1), G_AP(:,2), G_AP(:,3), 'b', 'LineWidth', 2)
hold on
errorbar(Gmean(:,1), Gmean(:,2), Gmean(:,3), 'r', 'LineWidth', 2)
set (gca, 'xscale', 'log')
hold off
title(fname)
end
%}
%{
for n=1:numel(intervalosPromediados)
    [~, ~, cpsIntervalos(n, :)]=FCS_calculabinstraza(FCSintervalos(:,:,n), 1/binFreq, 0.01);
end
G_APintervalos=zeros(size(Gintervalos));
for n=1:numel(intervalosPromediados)
    [G_APintervalos(:,:,n) alfa]=FCS_afterpulsing (Gintervalos(:, :, n), cpsIntervalos(n,:), tau_AP(:,1), alfaCoeff(:,1));
end

[~, G_AP]=FCS_promedio(G_APintervalos, FCSintervalos, 1:18, false);
%}