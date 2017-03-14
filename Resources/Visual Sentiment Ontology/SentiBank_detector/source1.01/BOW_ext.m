function BOW_ext( image )

if ~isdeployed 
addpath 'vlfeat-0.9.16\toolbox';
run vl_setup;
end


load('model.mat');
im = imread(image);
k1=getImageDescriptor(model, im);
k3=cat(2,k1);
gBOW= vl_homkermap(k3, 1, 'kchi2', 'gamma', .5) ;
save([image '-BOW.mat'],'gBOW');
end

