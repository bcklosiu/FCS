function varargout=varargouttest


    varargout={1 2};
if nargout>2
    for n=3:nargout
         varargout{n}=[];
    end
end
