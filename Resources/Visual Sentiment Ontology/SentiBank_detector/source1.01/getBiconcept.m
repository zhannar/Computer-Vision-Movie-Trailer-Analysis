function getBiconcept( image )
%GETBICONCEPT Summary of this function goes here
%   Detailed explanation goes here

% cd vlfeat-0.9.16\toolbox;
% run vl_setup;
% cd ..;
% cd ..;
comingFile=image;

%extract gist feature
try
    img = imread(comingFile);
catch exception
end
imgsize=size(img);
lengthTemp=imgsize(1);
widthTemp=imgsize(2);


if lengthTemp>widthTemp
    img=img(((lengthTemp-widthTemp)/2+1):(lengthTemp+widthTemp)/2,:);
else
    img=img(:,((widthTemp-lengthTemp)/2+1):(lengthTemp+widthTemp)/2);
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


% extract lbp features
try
    img = imread(comingFile);
catch exception
    comingFile=['dup' comingFile];
end

mapping=getmapping(8,'u2');
g=lbp(img,1,8,mapping,'h');
gLBP=g';


%%extract color hist feature
if i==1;
    I = imread(comingFile);
end
try
    Itemp = imread(comingFile);
catch exception
end
if (size(Itemp, 3) == 3)
    I=Itemp;
end
nBins = 256;
rHist = imhist(I(:,:,1), nBins);
gHist = imhist(I(:,:,2), nBins);
bHist = imhist(I(:,:,3), nBins);
gColor=[rHist;gHist;bHist];

load([image '-BOW.mat']);
delete([image '-BOW.mat'])

gBOW=normc(gBOW);
gGist=normc(gGist);
gLBP=normc(gLBP);
gColor=normc(gColor);
load('model_2000.mat')
att = att_ext(gBOW', gColor', gGist', gLBP', model_all);
gAtt=normc(att');
gEarly=[gLBP' gBOW' gGist' gAtt' gColor'];

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
    cellCurrentClass=classes(tempj);
    currentClass=char(cellCurrentClass);
    currentClass=currentClass(2:end-1);
    try
        load(['SVM\' currentClass '-BOW.mat']);
    catch exception
    end
    [predict_label, accuracy, dec_values] = predict(label_descriptortest, inst_descriptortest, modelfusion,'-b 1');
    biconceptVector(tempj,1)=dec_values(1);
end
save(['result\' image(1:end-4) '-biconcept.mat'],'biconceptVector');
delete(targetFile)
end

