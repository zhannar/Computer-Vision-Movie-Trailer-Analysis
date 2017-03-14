function temp( image )
%TEMP] Summary of this function goes here
%   Detailed explanation goes here

load('model.mat');
im = imread(image);
k1=getImageDescriptor(model, im);
k3=cat(2,k1);
gBOW= vl_homkermap(k3, 1, 'kchi2', 'gamma', .5) ;


end

