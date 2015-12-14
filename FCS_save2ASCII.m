function fid=FCS_save2ASCII (fileName, Gmean, canal, intervalosPromediados, cps)
%
% fid=FCS_save2ASCII (fileName, Gmean, canal, intervalosPromediados, cps)
%
% Si canal es 3 guarda la correlación cruzada; si no guarda sólo la autocorrelación del canal que se le indica
% Guarda la correlación promedio en formato ASCII
% fileName incluye el path
% jri 23Abr15

if strcmpi(fileName(end-3:end), '.mat')
    fileName=[fileName(1:end-4) '.dat'];
elseif not(strcmpi(fileName(end-3:end), '.dat'))
    fileName=[fileName '.dat'];
end

%Por si G tiene información de varios canales pero sólo queremos guardar uno
columnaCanalG=2;
if and (canal==2, size(Gmean)>3)
    columnaCanalG=4;
end


pos=find(fileName=='\', 1, 'last');
if isempty(pos)
    pos=0;
end
nombreFCSData=fileName(pos+1:end-4);
disp (['Saving ' nombreFCSData ' as ASCII'])
fid=fopen(fileName, 'wt'); %Esto lo hice muy bien en genpol
fprintf(fid, '%s', datestr(now));
fprintf(fid, '\n%s', fileName);
fprintf(fid, '\nChannel:\t');
fprintf(fid, '%d', canal);
fprintf(fid, '\nAveraged curves:\t');
fprintf(fid, '%d, ', intervalosPromediados);
if canal<3
    fprintf(fid, '\nCPS:\t');
    fprintf(fid, '%g', cps(columnaCanalG-1));
    fprintf(fid, '\n\n%s\t%s\t%s', 'Time(s)', 'G', 'SD');
    fprintf(fid, '\n%g\t%g\t%g', [Gmean(:,1), Gmean(:,columnaCanalG), Gmean(:,columnaCanalG+1)]');
else
    fprintf(fid, '\nCPS:\t');
    fprintf(fid, '%g, %g', cps(1), cps(2));
    fprintf(fid, '\n\n%s\t%s\t%s\t%s\t%s\t%s\t%s', 'Time(s)', 'G(1)', 'SD(1)', 'G(2)', 'SD(2)', 'Gcc', 'SDcc');
    fprintf(fid, '\n%g\t%g\t%g\t%g\t%g\t%g\t%g', [Gmean(:,1), Gmean(:,2), Gmean(:,3), Gmean(:,4), Gmean(:,5), Gmean(:,6), Gmean(:,7)]');
end

fclose (fid);