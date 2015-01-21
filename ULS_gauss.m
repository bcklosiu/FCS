function G = ULS_gauss (param, coorX)
% G = ULS_gauss (param, coorX)
% offset=param(1);
% A=param(2);
% x0=param(3);
% sigma=param(4);
% ULS y GdH jul12

offset=param(1);
A=param(2);
x0=param(3);
sigma=param(4);

G = offset+A*exp(-((coorX-x0).^2)./(2*sigma^2));

