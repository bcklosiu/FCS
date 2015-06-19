function FCS_saveIntervals2ASCII(fname, Gintervalos, intervalosPromediados, channel, cpsIntervalos)

%
%Guarda los intervalos promediados en archivos ASCII independientes
%
% jri - 4jun15

for n=1:numel(intervalosPromediados)
    intervalo=intervalosPromediados(n);
    figure
    set (gcf, 'Name', num2str(intervalo))
	hold on 
    errorbar (Gintervalos(:,1, intervalo), Gintervalos(:,2, intervalo), Gintervalos(:,3, intervalo), '-o', 'LineWidth', 2, 'Color', 'g')
%    errorbar (Gintervalos(:,1, intervalo), Gintervalos(:,4, intervalo), Gintervalos(:,5, intervalo), '-o', 'LineWidth', 2, 'Color', 'r')
    set (gca, 'xscale', 'log')
    %h_text=text ('Units', 'normalized', 'Position', [0.8, 0.9], 'String', ['CPS: ', num2str(cps)]);
    %set (h_text, 'BackgroundColor', [1 1 1])
    grid on
    s=sprintf('%s_%02d.dat', fname, intervalo);
    FCS_save2ASCII (s, squeeze(Gintervalos(:,:, intervalo)), channel, intervalo, cpsIntervalos(intervalo, :));

end