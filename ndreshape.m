function Y = ndreshape(X,inputsizes,outputorder)
% 
% This function is useful for manipulating ND matrices whose dimensions contains sub-dimensions stacked in each dimension
% In particular it permutes the subdimensions 
%
% Y = ndreshape(X,sizes,order)
% Y = ndreshape(X,sizes)
%
% Inputs:
% X is a N-dimensional matrix
% sizes is the size of every dimension of the matrix as cell array or list (see below) 
% order is the order of the sub-dims inside each output dimension
%
% The variants when order is not specified expands the matrix into a new NDmatrix in which the stacked dimensions are explicit
%
% Cell Syntax: sizes is a cell array in which every element is a list of sizes: {[2,3],[5,2]}
% List Syntax: sizes is a list of sizes of every dimension separated by NaN:  [2,3,NaN,5,2]
%
% As in Matlab the dimensions are ordered from the inner to the outer when transformed in a vector, the same applies for the subdims
%
% Given for example a case in which we have: sizes [a=5 b=3] x [c=4 d=2] => [d b] x [a c]
%
% X = rand(15,8);
% Y = ndreshape(X,{[5,3],[4,2]},{[4,2],[1,3]});
% Y = ndreshape(X,[5,3,NaN,4,2],[4,2,NaN,1,3]);
%
% Initial 2013/06/07
% Emanuee Ruffaldi, Scuola Superiore S.Anna, Pisa, Italy
%
% Modified 2018
% Refactored support for array
% 

if nargin == 2
    order = [];
end

if iscell(inputsizes) == 0
    % split by nan
    isizes = inputsizes;
    parts = find(isnan(isizes));
    if isempty(parts)
        inputsizes = {isizes};
    else
        parts = [0;parts;length(isizes)+1];
        inputsizes = cell(length(parts)-1,1);
        for I=1:length(parts)-1
            inputsizes{I} = isizes(parts(I)+1:parts(I+1)-1);
        end
    end    
end

indims = length(inputsizes);
subdimsize = [];
for I=1:length(inputsizes)
    missing = find(inputsizes{I} == 0);
    assert(length(missing) < 2);
    if length(missing) == 1
        s = inputsizes{I};
        s(missing) = 1;
        inputsizes{I}(missing) = size(X,I)/prod(s);
    end
    subdimsize = [subdimsize,inputsizes{I}(:)'];
end

outdims = length(outputorder);
reorderedsubdims = [];
outdimssizes = zeros(outdims,1);
for I=1:length(outputorder)
    subsI = outputorder{I}(:)';
    if isempty(subsI)
        outdimssizes(I) = 1;            
    else
        reorderedsubdims = [reorderedsubdims,subsI];
        outdimssizes(I) = prod(subdimsize(subsI));
    end
end
    

assert(numel(X) == prod(subdimsize),'Number of elements from description does not match with input matrix');
assert(ndims(X) >= indims,'Number of dimensions from description does not match with input matrix');

if isempty(outputorder) 
    Y = reshape(X,subdimsize);
else
    assert(prod(outdimssizes) == prod(subdimsize),'Number of elements in input should be the same of output');

    if all(diff(reorderedsubdims) == 1) == 0
            X = reshape(X,subdimsize);
        X = permute(X,reorderedsubdims);
    end
    if outdims == 1
        % favour column vectors
        outdimssizes = [outdimssizes;1]; 
    end
    Y = reshape(X,outdimssizes');
end
