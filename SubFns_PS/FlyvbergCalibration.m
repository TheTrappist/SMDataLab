function FlyvbergCalibration

textX=textread('\\ANALYSIS-PC\Users\Public\Documents\Trap Results\110222\110222_123630_SR20000NP100000ANG0_000_CHtftf_rapidscan_16_XResponse.txt','%s');
textY=textread('\\ANALYSIS-PC\Users\Public\Documents\Trap Results\110222\110222_123646_SR20000NP100000ANG0_000_CHtftf_rapidscan_17_YResponse.txt','%s');

pathname='\\ANALYSIS-PC\Users\Public\Documents\Trap Results\110223\';
% filename='110222_124856_SR20000NP200000ANG0_000_CHtftf_2000_200nm_2PSDsignals.txt';
filename='110223_173301_SR20000NP1000000ANG0_000_CHtftf_0_50nm_74mW_X_1PSDsignals.txt';

DataFilePath=strcat(pathname,filename);
% DataFilePath='\\ANALYSIS-PC\Users\Public\Documents\Trap Results\110218\110218_171411_SR20000NP400000ANGm1_508_CHtftf_6K_42mWCALI_56PSDsignals.txt';
    size(textX,1);
    
    if size(textX,1)==5
        
        paras(1)=0;%ax0
    paras(2)=str2double(textX(4,:));%ax1
    paras(3)=0;%ax2
    paras(4)=str2double(textX(5,:));%ax3
    
    else
    
    paras(1)=str2double(textX(4,:));%ax0
    paras(2)=str2double(textX(5,:));%ax1
    paras(3)=str2double(textX(6,:));%ax2
    paras(4)=str2double(textX(7,:));%ax3
    
    end
    
    if size(textY,1)==5
        
        paras(5)=0;%ax0
    paras(6)=str2double(textY(4,:));%ax1
    paras(7)=0;%ax2
    paras(8)=str2double(textY(5,:));%ax3
    
    else
    
    paras(5)=str2double(textY(4,:));%ax0
    paras(6)=str2double(textY(5,:));%ax1
    paras(7)=str2double(textY(6,:));%ax2
    paras(8)=str2double(textY(7,:));%ax3
    
    ax=paras(2:4);
    ay=paras(6:8);
    
    end
    
    Data=textread(DataFilePath);
[ANG SR ProtNum]=getdetailsfromFilename_PS(filename);

    OscFreq=32; %32Hz
    Amp=250;    % amplitude in nm
    Tmsr=1/32
    
    NP=size(Data,1)
    
    NPinScan=round(Tmsr*SR)
    
    NoScans=floor(NP/NPinScan)
    
    data=Data(1:NPinScan,:);


Sy=Data(:,1);
Sx=Data(:,2);
Fx=Data(:,3);
Fy=Data(:,4);

length(Sy)

X=convertPSD2position_PS(Sx,ax);
Y=convertPSD2position_PS(Sy,ay);



t=1/SR:1/SR:length(X)/SR;

WindowTime=1;

WindowLength=Tmsr*floor(WindowTime/Tmsr)
lowF=50;
highF=3000;

%     [Fx PSx DFx]=createPS2(Sx,SR);
%     
%     [Fy PSy DFy]=createPS2(Sy,SR);

[F, PSx, PSy]=GetWindowedPowerSpectrum(Sx,Sy,SR,WindowLength);

loglog(F,PSy,'r.',F, PSx,'b.')
% figure

df=F(2)-F(1)




F(1)

ind=round(OscFreq/df)

F(ind+1)
[PoweratScan chan]=max([PSx(ind+1) PSy(ind+1)])

    
    PSx(ind+1)=mean([PSx(ind) PSx(ind+2)]);
  
    
    PSy(ind+1)=mean([PSy(ind) PSy(ind+2)]);
    
    if chan==1
        
        offset=PSx(ind+1);
        
    else
        
        offset=PSy(ind+1);
        
    end
    
    Wex=(PoweratScan-offset)*df
    
    
    [centF centPSx]=centralFregion(lowF,highF,F,PSx,df);
    [centF centPSy]=centralFregion(lowF,highF,F,PSy,df);

% loglog(centF,centPSy,'r.',centF, centPSx,'b.')

px=fminsearch(@(px) FitFlyvbergLorentzian(centF,centPSx,px),[PSx(1)*pi^2*500^2 500])
py=fminsearch(@(py) FitFlyvbergLorentzian(centF,centPSy,py),[PSy(1)*pi^2*500^2 500])

fitx=CreateFlyvbergLorentzian(F,px);
fity=CreateFlyvbergLorentzian(F,py);

hold on

loglog(F,fitx,'b-',F, fity,'r-')

Dvolt=px(1)
FcX=px(2)

Wth=.5*Amp^2/(1+px(2)^2/OscFreq^2);

beta=sqrt(Wth/Wex)

D=beta^2*Dvolt

KT=4.11

KsX=2*pi*FcX*KT/D

gamma=KT/D
