function NewPSFit

textX=textread('\\ANALYSIS-PC\Users\Public\Documents\Trap Results\110223\110223_175451_SR20000NP100000ANG0_000_CHtftf_rapidscan_9_XResponse.txt','%s');
textY=textread('\\ANALYSIS-PC\Users\Public\Documents\Trap Results\110223\110223_175506_SR20000NP100000ANG0_000_CHtftf_rapidscan_10_YResponse.txt','%s');
pathname='\\ANALYSIS-PC\Users\Public\Documents\Trap Results\110223\';
filename='110223_180242_SR20000NP2000000ANG0_000_CHtftf_94mW_15PSDsignals.txt';
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


Sy=Data(:,1);
Sx=Data(:,2);
Fx=Data(:,3);
Fy=Data(:,4);

X=convertPSD2position_PS(Sx,ax);
Y=convertPSD2position_PS(Sy,ay);

[ANG SR ProtNum]=getdetailsfromFilename_PS(filename);

t=1/SR:1/SR:length(X)/SR;

% plot(t,Y,'r-',t,X,'b-')

WindowLength=.1;
lowF=50;
highF=3000;

[FXall, PSXall, PSYall]=GetWindowedPowerSpectrum(X,Y,SR,WindowLength);
    
    df = FXall(2)-FXall(1);
    
    [FX PSX]=centralFregion(lowF,highF,FXall,PSXall,df);
    [FY PSY]=centralFregion(lowF,highF,FXall,PSYall,df);
    
    loglog(FY ,PSY,'r.',FX, PSX,'b.')
    
    p=fminsearch(@(p) FitNewLorentzian(FX,PSX,PSY,p),[2e-5 0.05 0.05]);
    
    X=4.11/pi/pi./(p(2)^2/p(1)/4/pi/pi+p(1)*FX.^2);

Y=4.11/pi/pi./(p(3)^2/p(1)/4/pi/pi+p(1)*FX.^2);

hold on

loglog(FY,Y,'r-',FX,X,'b-')

beta=p(1)

KsX=p(2)
KsY=p(3)