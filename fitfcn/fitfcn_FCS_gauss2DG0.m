function G=FCS_gauss2DG0 (param, tdata)

% G=FCS_gauss2DG0 (param, tdata);
% Función de autocorrelacion con un modelo de difusion 2D single photon y haz gaussiano
%
% G = G0./((1+4*D*tdata/w0^2).*(1+4*D*tdata/z0^2));
%
% Definición de los parámetros actual: param(n)=Parameter Units
% Definición de los parámetros futura: param(n)=Parameter, Meaning, Units, Value, Lower bound, Upper bound
%
% param(1)=omega0 [mum]
% param(2)=z0 [mum]
% param(3)=G0 
% param(4)=D [mum^2/s]
%
% GdlH (01ago14)

 G = param(3)./(sqrt(1+4*param(4)*tdata/(param(1)^2)).*sqrt(1+4*param(4)*tdata/(param(2)^2)));