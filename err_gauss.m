function err = err_gauss (param, coorX, data_exp)
% err_gauss (param, data_abs, data_exp)
% coorX: coordenadas X
%  data_exp: datos experimentales
% oldoptions=optimset('lsqnonlin');
% options=optimset(oldoptions, 'Display','final', 'TolFun', 1E-9, 'TolX', 1E-9, 'MaxFunEval', 100000, 'MaxIter', 50000, 'Simplex', 'on');
% [paramfit] = lsqnonlin(@err_gauss, guess, [], [], options, X, Y);
% offset=param(1);
% A=param(2);
% x0=param(3);
% sigma=param(4);

% ULS y GdH jul12


G = ULS_gauss(param, coorX); %Modelo
err = G - data_exp; 
