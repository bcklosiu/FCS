function [imgBin, indLinesLS, indMaxCadaLinea, sigma2_5, timeInterval]=FCS_align(photonArrivalTimes, imgDecode, lineSync, pixelSync)

%[imgBin, indLinesLS, indMaxCadaLinea, sigma2_5, timeInterval]=FCS_align(photonArrivalTimes, imgDecode, lineSync, pixelSync)
%
%Escoge la ROI y la alinea a uno o dos canales
%
%
% jri 3Dic12 (de FCS_analisis_BH de Unai)


inicializamatlabpool();


numCanales=numel(unique(photonArrivalTimes(:, 6)));
%Seleccionar ROI de la imagen decodificada
[imgROI, ~, indLinesLS, indLinesPS, timeInterval] = FCS_ROI(imgDecode, photonArrivalTimes, lineSync, pixelSync);
if numCanales>1
    cellOption=inputdlg('Selecciona tipo de alineación: 1-Suma de canales. 2-Cada canal independiente.');
    option=str2double(cellOption{1});
    switch option
        case 1
            imgROIsuma=imgROI(:,:,1)+imgROI(:,:,2);
            [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROIsuma);
        case 2
            
            [imgALIN1, sigma2_5_1, indMaxCadaLinea1]=FCS_membraneAlignment_space(imgROI(:,:,1));
            [imgALIN2, sigma2_5_2, indMaxCadaLinea2]=FCS_membraneAlignment_space(imgROI(:,:,2));
            imgALIN=cat(3, imgALIN1, imgALIN2);
    end
    
else %numCanales=1;
    [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROI);
end

%Necesito convertir estos píxeles a tiempo y devolverlos!!
pixelROIdesde=min(pixelSync(indLinesPS,3));
pixelROIhasta=max(pixelSync(indLinesPS,3));

imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, :); %Imagen que se utilizará para el binning temporal
