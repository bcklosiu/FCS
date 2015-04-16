function [imgBin, indLinesLS, indMaxCadaLinea, sigma2_5, timeInterval]=FCS_align(photonArrivalTimes, imgDecode, lineSync, pixelSync)

%[imgBin, indLinesLS, indMaxCadaLinea, sigma2_5, timeInterval]=FCS_align(photonArrivalTimes, imgDecode, lineSync, pixelSync)
%
%Escoge la ROI y la alinea a uno o dos canales
%
%
% jri 3Dic14 (de FCS_analisis_BH de Unai)
% jri 27Mar15 - Corrijo para cuando tenemos dos canales que analiza por separado


inicializamatlabpool();


numCanales=numel(unique(photonArrivalTimes(:, 6)));
%Seleccionar ROI de la imagen decodificada
[imgROI, ~, indLinesLS, indLinesPS, timeInterval] = FCS_ROI(imgDecode, photonArrivalTimes, lineSync, pixelSync);
if numCanales>1
    cellOption=inputdlg('Selecciona tipo de alineación: 1-Sólo canal 1. 2- Sólo canal 2. 3-La suma de canales');
    option=str2double(cellOption{1});
    switch option
        case 3 %Suma de canales. 
            imgROIsuma=imgROI(:,:,1)+imgROI(:,:,2);
            [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROIsuma);
        otherwise
            [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROI(:,:,option));
    end
    
else %numCanales=1;
    [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROI);
end

%Necesito convertir estos píxeles a tiempo y devolverlos!!
pixelROIdesde=min(pixelSync(indLinesPS,3));
pixelROIhasta=max(pixelSync(indLinesPS,3));

switch option
    case 3%Suma de canales
    imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, :); %Imagen que se utilizará para el binning temporal
    case 4 %Para que alinee los dos canales a un único canal
        imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, :); 
    case 5 
        imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, :); 
    otherwise %Para que sólo alinee un canal
    imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, option); %Imagen que se utilizará para el binning temporal
end
