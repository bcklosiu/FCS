d=dir('*.mat');
numFiles=numel(d);
for n=1:numFiles
    fname=d(n).name;
    load (fname, 'cpsIntervalos', 'Gmean', 'intervalosPromediados');
    cps=round(mean(cpsIntervalos(intervalosPromediados, :)));
    figure
    set (gcf, 'Name', fname(1:end-4))
    subplot (2, 1, 1)
    plot (cpsIntervalos(intervalosPromediados, :), 'o', 'LineWidth', 2)
    subplot (2, 1, 2)
    errorbar (Gmean(:,1), Gmean(:,2), Gmean(:,3), '-o', 'LineWidth', 2)
    set (gca, 'xscale', 'log')
    h_text=text ('Units', 'normalized', 'Position', [0.8, 0.9], 'String', ['CPS: ', num2str(cps)]);
    set (h_text, 'BackgroundColor', [1 1 1])
    grid on
end