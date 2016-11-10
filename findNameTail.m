function [nameTail]=findNameTail(matStruct,rawStruct)
% [nameTail]=findNameTail(matStruct,rawStruct)
% 
% Encuentra automáticamente el 'name tail' introducido por el usuario para los archivos de correlación.
% Busca, en matStruct y rawStruct, y distingue los archivos de correlación y los raw.
% 
% Inputs: 
% matStruct - Listado de archivos mat de la carpeta
% rawStruct - Listado de archivos raw de la carpeta
% Unai, 02 Noviembre 2016


numMat=numel(matStruct);
numRaw=numel(rawStruct);
mat_bin=false(numMat,1);
raw_bin=false(numRaw,1);
ind_raw=(1:1:numRaw)';
ind_raw_temp=ind_raw(not(raw_bin));
m=0; %inicializar contador mat
allRaw=false; %indicador de que todos los archivos raw están identificados

while and(m<numMat,not(allRaw))
    m=m+1;
    fname_mat=matStruct(m).name;
    numRaw_temp=numel(ind_raw_temp);
    r=0; %inicializar contador raw
    israw=false;
    while and (r<numRaw_temp,not(israw))
        r=r+1;
        fname_raw=rawStruct(ind_raw_temp(r)).name;
        israw=isequal(fname_mat,fname_raw); %si el archivo mat es raw
    end
    raw_bin(ind_raw_temp(r))=israw;
    mat_bin(m)=israw;
    allRaw=numel(find(raw_bin)==1)==numRaw;
end

mat_nonRaw_bin=not(mat_bin); %archivos de correlación 
corrStruct=matStruct(mat_nonRaw_bin);
corrFile1name=corrStruct(1).name;
offset_=max(strfind(corrFile1name, '_')); %Puede que haya mas de un '_'. Nos interesa el mas cercano al '.mat'
offsetMat=strfind(corrFile1name, '.mat');
nameTail=corrFile1name(offset_:offsetMat-1);