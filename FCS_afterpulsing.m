function [G_AP alfa]=FCS_afterpulsing (G, cps, tau_AP, alfaCoeff)
%
% [G_AP alfa]=FCS_afterpulsing (G, cps, tau_AP, alfaCoeff)
% Corrige el afterpulsing dados G, tau_AP y los coeficientes de alfa
%
% Utiliza el modelo biexpoencial de ZHAO03
%
% jri - 27Apr15


numCanales=1;
if size(G,2)>3
    numCanales=2;
end

G_AP=G;
tauG=G(:,1);
alfa=zeros(numel(tauG), numCanales);

for canal=1:numCanales
    alfa(:,canal)=alfaCoeff(1, canal).*exp(-tauG/tau_AP(1,canal))+alfaCoeff(2, canal).*exp(-tauG/tau_AP(2,canal));
    G_AP(:,2*canal)=G(:,2*canal)-alfa(:,canal)/(cps(canal));
end