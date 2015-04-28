load ('D:\jri\UBf\!Experimental\2015\Afterpulsing\afterpulsing_jri', 'tau_AP', 'alfaCoeff');
d=dir('*.mat');
canal=1;
for m=1:numel(d)
    fname=d(m).name;
    load (fname)
    Gmean=Gmean(:,1:end,1);
    [~, ~, cps]=FCS_calculabinstraza(FCSmean, 1/binFreq, 0.01);
    %    [G_AP alfa]=FCS_afterpulsing (Gmean, cps, tau_AP(:,canal), alfaCoeff(:,canal));
    

    G_APintervalos=zeros(size(Gintervalos));
    for n=1:numel(intervalosPromediados)
        [~, ~, cpsIntervalos(n, :)]=FCS_calculabinstraza(FCSintervalos(:,:,n), 1/binFreq, 0.01);
        [G_APintervalos(:,:,n) alfa]=FCS_afterpulsing (Gintervalos(:, :, n), cpsIntervalos(n,:), tau_AP(:,canal), alfaCoeff(:,canal));
    end
    
    G_AP=FCS_promedio(G_APintervalos, intervalosPromediados, false);
  
    save (fname, 'Gmean', 'G_AP', 'cpsIntervalos', 'cps', 'G_APintervalos', 'tau_AP', 'alfaCoeff', '-append')
    FCS_save2ASCII ([fname(1:end-4) '_noAP.mat'], Gmean, 1, intervalosPromediados, cps);
    FCS_save2ASCII ([fname(1:end-4) '_AP.mat'], G_AP, 1, intervalosPromediados, cps);
    figure (m)
    set (m, 'Name', fname, 'Color', [1 1 1])
    errorbar(G_AP(:,1), G_AP(:,2), G_AP(:,3), 'b', 'LineWidth', 2)
    hold on
    errorbar(Gmean(:,1), Gmean(:,2), Gmean(:,3), 'r', 'LineWidth', 2)
    set (gca, 'xscale', 'log')
    h_text=text ('Units', 'normalized', 'Position', [0.8, 0.9], 'String', ['CPS: ', num2str(cps)]);
    set (h_text, 'BackgroundColor', [1 1 1])
    hold off
    h_legend=legend ('Corrected', 'Uncorrected');
    set (h_legend, 'Location', 'SouthWest', 'Box', 'off');
    grid on
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