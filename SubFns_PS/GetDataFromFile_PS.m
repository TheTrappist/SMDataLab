function [X Y Fx Fy filename]=GetDataFromFile_PS

[filename, pathname, filterindex] =uigetfile('*.txt','Select File to Display (_PSDsignals.txt)');

DataFilePath=strcat(pathname,filename)

Data=textread(DataFilePath);

Sy=Data(:,1);
Sx=Data(:,2);
Fx=Data(:,3);
Fy=Data(:,4);


ConvParas=GetConversionParameters;

ax=[ConvParas(1) 0 ConvParas(2)];
ay=[ConvParas(3) 0 ConvParas(4)];

X=convertPSD2position_PS(Sx,ax);
Y=convertPSD2position_PS(Sy,ay);

