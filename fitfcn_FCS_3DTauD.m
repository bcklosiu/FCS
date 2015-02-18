function G=fitfcn_FCS_3DTauD (param, tdata)

% G=fitfcn_FCS_3DTauD (param, tdata)
% Función de autocorrelación con un modelo de difusion 3D single photon 
%  G = (1/N)*((1+tdata/tauD).^-1).*((1+tdata/(tauD*SP^2)).^-0.5)
%
% SP es el parámetro estructural: S=z0/w0
% tdata en s!!
% tauD en ms!!
%
% Definición de los parámetros actual: param(n)=Parameter Units
% Definición de los parámetros futura: param(n)=Parameter, Meaning, Units, Value, Lower bound, Upper bound
%
% param(1)=N
% param(2)=tauD [ms]
% param(3)=SP
%
% jri 4Feb15


 G = ((1+tdata/(param(2)*1E-3)).^-1).*((1+tdata/(param(2)*1E-3*param(3)^2)).^-0.5)/param(1);
 
