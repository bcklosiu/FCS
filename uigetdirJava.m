function pathName = uigetdirJava (start_path, dialog_title)
% uigetdirJava
%PICKDIRUSINGJFILECHOOSER Pick a dir with Java widgets instead of uigetdir
%
% De http://stackoverflow.com/questions/6349410/using-uigetfile-instead-of-uigetdir-to-get-directories-in-matlab
%
% Si la selección es un archivo, devuelve el path a la carpeta que contiene el archivo. 
% Si la selección es una carpeta, devuelve el path a la carpeta escogida
%
% jri 21Abr15


if nargin == 0 || isempty(start_path) % Allow a null argument.
    start_path = pwd;
end

import javax.swing.JFileChooser;
jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);
if nargin > 1
    jchooser.setDialogTitle(dialog_title);
end

%jchooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
jchooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
status = jchooser.showOpenDialog([]);

if status == JFileChooser.APPROVE_OPTION
    jFile = jchooser.getSelectedFile();
    file = char(jFile.getPath());
    if exist(file, 'dir')
        pathName=file;
    else
        pos = find(file=='\', 1, 'last');
        pathName=file(1:pos-1);
        
    end
elseif status == JFileChooser.CANCEL_OPTION
    pathName = [];
else
    error('Error occurred while picking file');
end