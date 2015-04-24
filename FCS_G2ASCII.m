function fid=FCS_G2ASCII (fileName, channel, intervalosPromediados, Gmean, tipoCorrelacion)
%
% Guarda la correlación promedio en formato ASCII
% fileName incluye el path
% jri 23Abr15

fileName=[fileName(1:end-4) '.dat'];
pos=find(fileName=='\', 1, 'last');
if isempty(pos)
    pos=0;
end
nombreFCSData=fileName(pos+1:end-4);
disp (['Saving ' nombreFCSData ' as ASCII'])
fid=fopen(fileName, 'w'); %Esto lo hice muy bien en genpol
fprintf(fid, '%s', datestr(now));
fprintf(fid, '\n%s', fileName);
fprintf(fid, '\nChannel:\t');
fprintf(fid, '%d, ', channel);
fprintf(fid, '\nAveraged curves:\t');
fprintf(fid, '%d, ', intervalosPromediados);
switch tipoCorrelacion
    case 'auto'
        fprintf(fid, '\n\n%s\t%s\t%s', 'Time(s)', 'G', 'SD');
        fprintf(fid, '\n%f\t%f\t%f', [Gmean(:,1), Gmean(:,2), Gmean(:,3)]');
    otherwise
        fprintf(fid, '\n\n%s\t%s\t%s\t%s\t%s\t%s\t%s', 'Time(s)', 'G(1)', 'SD(1)', 'G(2)', 'SD(2)', 'Gcc', 'SDcc');
        fprintf(fid, '\n%f\t%f\t%f\t%f\t%f\t%f\t%f', [Gmean(:,1), Gmean(:,2), Gmean(:,3), Gmean(:,4), Gmean(:,5), Gmean(:,6), Gmean(:,7)]');
end
   
fclose (fid);