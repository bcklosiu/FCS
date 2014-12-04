function inicializamatlabpool()



isOpen=matlabpool ('size')>0;
if not(isOpen) %Inicializa matlabpool con el máximo numero de cores
    numWorkers=feature('NumCores'); %Número de workers activos. 
    if numWorkers>=8
        numWorkers=8; %Para Matlab 2010b, 8 cores máximo.
    end
    disp (['Inicializando matlabpool con ' num2str(numWorkers) ' cores'])
matlabpool ('open', numWorkers) 
end

