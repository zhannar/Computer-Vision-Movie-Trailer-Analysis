function output = getBiconcept( image )
%GETBICONCEPT Summary of this function goes here
%   Detailed explanation goes here

% cd vlfeat-0.9.16\toolbox;
% run vl_setup;
% cd ..;
% cd ..;

    if ~isdeployed
        addpath 'vlfeat-0.9.16\toolbox';
        run vl_setup;
    end


    load('model.mat');


    load('model_2000.mat');


try
    im = imread(image);
catch
    disp('Failed to read image!');
    output = -1;
    return;
end

[w,h,c] = size(im);
if (w<10||h<h)
    disp('Image too small!');
    output = -1;
    return;
end
if (c==1)
    im=gray2rgb(im);
end

k1=getImageDescriptor(model, im);
k3=cat(2,k1);
gBOW= vl_homkermap(k3, 1, 'kchi2', 'gamma', .5) ;
%save([fullfile(outpath,outname) '-BOW.mat'],'gBOW');


%comingFile=image;

%extract gist feature
img = im;
img = rgb2gray(img);
imgsize=size(img);
lengthTemp=imgsize(1);
widthTemp=imgsize(2);


if lengthTemp>widthTemp
    img=img(int32((lengthTemp-widthTemp)/2+1):int32((lengthTemp+widthTemp)/2),:);
else
    img=img(:,int32((widthTemp-lengthTemp)/2+1):int32((lengthTemp+widthTemp)/2));
end
imgsize=size(img);
lengthTemp=imgsize(1);
widthTemp=imgsize(2);
img=img(1:min(lengthTemp,widthTemp),1:min(lengthTemp,widthTemp));

imgsize=size(img);
lengthTemp=imgsize(1);
widthTemp=imgsize(2);


% Parameters:
Nblocks = 4;
imageSize = min(lengthTemp,widthTemp);
orientationsPerScale = [8 8 4];
numberBlocks = 4;

% Precompute filter transfert functions (only need to do this one, unless image size is changes):
createGabor(orientationsPerScale, imageSize); % this shows the filters
G = createGabor(orientationsPerScale, imageSize);

% Computing gist requires 1) prefilter image, 2) filter image and collect
% output energies
output = prefilt(double(img), 4);
gGist = gistGabor(output, numberBlocks, G);
%save([fullfile(outpath,outname) '-Gist.mat'],'gGist');

% extract lbp features
img = im;

mapping=getmapping(8,'u2');
g=lbp(img,1,8,mapping,'h');
gLBP=g';
%save([fullfile(outpath,outname) '-LBP.mat'],'gLBP');

%%extract color hist feature
I = im;
nBins = 256;
rHist = imhist(I(:,:,1), nBins);
gHist = imhist(I(:,:,2), nBins);
bHist = imhist(I(:,:,3), nBins);
gColor=[rHist;gHist;bHist];
%save([fullfile(outpath,outname) '-Color.mat'],'gColor');


gBOW=normc(gBOW);
gGist=normc(gGist);
gLBP=normc(gLBP);
gColor=normc(gColor);
att = att_ext(gBOW', gLBP',  gGist', gColor', model_all);
gAtt = att';
%save([fullfile(outpath,outname) '-Att.mat'],'gAtt');
gAtt=normc(gAtt);
gEarly=[gLBP' gBOW' gGist' gAtt' gColor'];
%save([fullfile(outpath,outname) '-Early.mat'],'gEarly');
output = 1;

load('classes.mat');
classnum = length(classes);
biconceptVector=zeros(classnum,1);
g=gEarly;
targetFile='testEarlyFusion';
label=1;
fileID = fopen(targetFile,'a+');
fprintf(fileID,'%d',label);
fprintf(fileID,' ');
[row,col]=size(g);
for j = 1:col
    fprintf(fileID,'%d',j);
    fprintf(fileID,':');
    if(isnan(g(j)))
        fprintf(fileID,'%f',0);
    else
        fprintf(fileID,'%f',g(j));
    end
    fprintf(fileID,' ');
end
fprintf(fileID,'\n');
fclose(fileID);
[label_descriptortest, inst_descriptortest] = libsvmread('testEarlyFusion');
for tempj=1:classnum
    currentClass=classes{tempj};
    try
        load(['SVM\' currentClass '.mat']);
    catch exception
    end
    [predict_label, accuracy, dec_values] = predict(label_descriptortest, inst_descriptortest, modelfusion,'-b 1');
    biconceptVector(tempj,1)=dec_values(1);
end
%biconceptVector = normc(biconceptVector);
save(['result\' image(1:end-4) '-biconcept.mat'],'biconceptVector');
dlmwrite(['result\' image(1:end-4) '-biconcept.txt'],biconceptVector, ' ');
delete(targetFile)
end



