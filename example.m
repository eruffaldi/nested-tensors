

X = rand(15,8);
Y = stackedpermute(X,{[5,3],[4,2]},{[4,2],[1,3]});
Y = stackedpermute(X,[5,3,NaN,4,2],[4,2,NaN,1,3]);

