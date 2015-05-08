function [G_AP alfa]=FCS_afterpulsing (G, cps, tau_AP, alfaCoeff, acqChannel)
%
% [G_AP alfa]=FCS_afterpulsing (G, cps, tau_AP, alfaCoeff)
% Corrige el afterpulsing dados G, tau_AP y los coeficientes de alfa y tau_AP 
% alfa(coeff, canal) y tau_AP(coeff, canal) llevan siempre los datos de los dos canales
%
% Utiliza el modelo biexpoencial de ZHAO03
%
% jri - 27Apr15
% jri - 8May15. Modelo de tres exponenciales


%Si acqChannel es 3, entonces lleva los datos del canal 1 y el 2
numCanales=1;
if acqChannel>2
    numCanales=2;
end

G_AP=G;
tauG=G(:,1);
alfa=zeros(numel(tauG), numCanales);

switch numCanales
    case 1
        alfa(:)=alfaCoeff(1, acqChannel).*exp(-tauG/tau_AP(1,acqChannel))+alfaCoeff(2, acqChannel).*exp(-tauG/tau_AP(2,acqChannel));
        G_AP(:,2)=G(:,2)-alfa/squeeze(cps);
    otherwise
        for canal=1:numCanales
            alfa(:,canal)=alfaCoeff(1, canal).*exp(-tauG/tau_AP(1,canal))+alfaCoeff(2, canal).*exp(-tauG/tau_AP(2,canal))+alfaCoeff(3, canal).*exp(-tauG/tau_AP(3,canal));
            G_AP(:,2*canal)=G(:,2*canal)-alfa(:,canal)/(cps(canal));
        end
end
