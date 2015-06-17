function ComparePowerSpectra

MainPath=pwd;
SubFunctions=strcat(MainPath,'\Jeffs Code');
addpath(SubFunctions)

pathname='K:\Trap results\110302\';

filename='110302_163820_SR20000NP200000ANGm1_555_CHtftf_4K_41mW_CALI_40PSDsignals.txt';


DataFilePath=strcat(pathname,filename)

Data=textread(DataFilePath);

[ANG SR ProtNum]=getdetailsfromFilename_PS(filename);

Sy=Data(:,1);
Sx=Data(:,2);
Fx=Data(:,3);
Fy=Data(:,4);



Sx=Sx-mean(Sx);

Sy=Sy-mean(Sy);

Sx=Sx(1:2*(floor(length(Sx)/2)));
Sy=Sy(1:2*(floor(length(Sy)/2)));

StDevX=std(Sx)


t=1/SR:1/SR:length(Sx)/SR;


%-- My Code

[Fx PSx DFx]=createPS2(Sx,SR);
[Fy PSy DFy]=createPS2(Sy,SR);

%-- Jeff's Code

[Spectrumx, fx] = AverageSpectrum(Sx, SR, 10, '@nowindow');
[Spectrumy, fy] = AverageSpectrum(Sy, SR, 10, '@nowindow');

loglog(Fx,PSx,'b*',fx,Spectrumx,'r-')

sqrt(sum(Spectrumx))

