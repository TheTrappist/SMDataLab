function MonomerAnalysis

% Code written 16 June 2011 - Tom Bilyard
% 
% Fits single transitions to dissociation data obtained from 
% optical trap experiment.
% 
% Inputs
% pathname - name of folder containing data
% filename - name of ...PSD_signals.txt file
% ax/ay - PSD to nm conversion parameters for x and y axes
% 
% ShortTime (s) - Transitions less than this time ignored in output file
% 
% (NumFreqShiftPoints - fudge factor to correct slight temporal
% misalignment)
% 
% Outputs
% i)Creates a new folder of same name as filename
% ii)Creates a .txt file containing 5 columns
%     1)Start Time
%     2)Transition Time
%     3)End Time
%     4) Start Level
%     5) End Level
% iii) Saves .jpg images of each transition



close all

%Inputs to change-----------------------

pathname='E:\Work\Coding\Matlab\TrapDataViewer\Analysis scripts\';
filename='130201_120350_SR20000NP4000000ANG1_011_CHtftf_K349DNA-apo-Apyrase_22PSDsignals.txt';
ax=[6.105883402E-4 0 -2.192598470E-9];
ay=[6.407936377E-4 0 -1.882712420E-9];

ShortTime=.0025;

NumFreqShiftPoints=2;%do not change unless required
%----------------------------------

%rest of file
DataFilePath=strcat(pathname,filename)

ChannelLogic=WhichChannels(filename);

Data=textread(DataFilePath);

Sy=[0];
Sx=[0];
Fx=[0];
Fy=[0];
BF=[0];

if ChannelLogic(1)==1

    Sy=Data(:,1);
    Sx=Data(:,2);

end

Fchannel=2*ChannelLogic(1)+2*ChannelLogic(2)+1;

BFChannel=2*ChannelLogic(1)+2*ChannelLogic(2)+2*ChannelLogic(3)+1;

if ChannelLogic(3)==1

    Fx=Data(:,Fchannel);
    Fy=Data(:,Fchannel+1);

end

if ChannelLogic(4)==1

    BF=Data(:,BFChannel);

end



X=convertPSD2position(Sx,ax);
Y=convertPSD2position(Sy,ay);

[ANG SR ProtNum]=getdetailsfromFilename(filename);

M=[cos(ANG) sin(ANG);-sin(ANG) cos(ANG)];

S=[X';Y'];

D=M*S;

X=D(1,:);
Y=D(2,:);

M=[cos(ANG) sin(ANG); -sin(ANG) cos(ANG)];
FF=[Fx'; Fy'];
DF=M*FF;

ConvertPara=812.1;

Flong=-DF(1,:)*ConvertPara;
Fshort=-DF(2,:)*ConvertPara;

Flong=Flong(1:end-NumFreqShiftPoints);
Fshort=Fshort(1:end-NumFreqShiftPoints);

X=X(1+NumFreqShiftPoints:end);
Y=Y(1+NumFreqShiftPoints:end);

X=X+Flong;
Y=Y+Fshort;

t=1/SR:1/SR:length(X)/SR;

NShort=ShortTime*SR;


Fplus=Flong(2:end);
Fminus=Flong(1:end-1);

Fdiff=Fplus-Fminus;

TransInd=find(Fdiff)+1;

plot(t,X,'b-',t,Y,'r-',t,Flong,'g.')

hold on

plot(t(TransInd),Flong(TransInd),'go')

legend('X','Y','trap')
xlabel('time (s)')
ylabel('position (nm)')
title('Bead_{XY} and Trap_X position')

StartInd=TransInd(1:end-1);
EndInd=TransInd(2:end)-1;

NoSections=length(StartInd);

ALLFIG=figure(9);

for i=1:NoSections
    
    Str=strcat('Processing section number ', num2str(i),' of ', num2str(NoSections));
    
    disp(Str)
    
   T=t(StartInd(i):EndInd(i));
   x=X(StartInd(i):EndInd(i));
   f=Flong(StartInd(i):EndInd(i));
   
   plot(T,x,'b-',T,f,'g-')
   
   [TP FirstLevel SecondLevel fit]=FitStepTransition2(T,x);
%    [TP FirstLevel SecondLevel]=FitStepTransition(T,x);
%    fit=zeros(1,length(x));
% 
%    fit(1:TP)=FirstLevel;
%    fit(TP+1:length(x))=SecondLevel;
   
   hold on
      
   plot(T,fit,'r-')
   
   Delta(i)=SecondLevel-FirstLevel;
   Time(i)=TP/SR;
   
   t1(i)=T(1);
   t2(i)=t1(i)+Time(i)-1/SR;
   t3(i)=T(end);
   x1(i)=real(FirstLevel);
   x2(i)=real(SecondLevel);
   
   flag(i)=(Time(i)>ShortTime);

end

legend('bead','trap','step fit')
xlabel('time (s)')
ylabel('position (nm)')
title('Bead_X,Trap_X and Single Step Fit')

figure;

plot(Delta,Time,'*')
xlabel('transition size (nm)')
ylabel('step time (s)')
title('Transition Size vs Dwell Length')

LongLocs=find(flag);

Data=[t1(LongLocs)' t2(LongLocs)' t3(LongLocs)' x1(LongLocs)' x2(LongLocs)'];

% figure
% 
% plot(Data(:,2)-Data(:,1),Data(:,4)-Data(:,3))


FileNameStart=filename(1:(strfind(filename,'.txt')-1));

NewPathName=strcat(pathname,FileNameStart,'\');

mkdir(pathname,FileNameStart)

NewFileNameText=strcat(FileNameStart,'_Transitions.txt');

NewFileNameFig=strcat(FileNameStart,'_Transitions.txt');

save(strcat(NewPathName,NewFileNameText),'Data','-ASCII','-TABS')

NewFileNameFigAll=strcat(FileNameStart,'_ALL.fig')

saveas(ALLFIG,strcat(NewPathName,NewFileNameFigAll),'fig')

NumGoodTrans=size(Data,1);

for im=1:NumGoodTrans
    
    NewFileNameFig=strcat(FileNameStart,'_',num2str(im),'.jpg');
    
    h=figure(10);
    
    t1_ind=Data(im,1)*SR;
    t2_ind=Data(im,2)*SR;
    t3_ind=Data(im,3)*SR;
    
    FirstLev=median(X(t1_ind:t2_ind))*ones(1,t2_ind-t1_ind+1);
    
    SecondLev=median(X(t2_ind+1:t3_ind))*ones(1,t3_ind-t2_ind);
    
    Trans=[FirstLev SecondLev];

    TempT=t(t1_ind:t1_ind+length(Trans)-1);

    plot(t(t1_ind:t3_ind),X(t1_ind:t3_ind),'-b')
    hold on
    plot(t((t1_ind-1):t2_ind),X((t1_ind-1):t2_ind),'-ob','MarkerFaceColor','g','MarkerSize',2)
    hold on
    plot (TempT,[FirstLev SecondLev],'r-','linewidth',1)
    hold off
    xlabel('time (s)')
    ylabel('position (nm)')
    title(strcat('Transition ',num2str(im),' of ',num2str(NumGoodTrans)))
    
    saveas(h,strcat(NewPathName,NewFileNameFig),'jpg')
    
end
hold off
%sub functions
%%

function ChannelLogic=WhichChannels(filename)

ChLoc=strfind(filename,'_CH');

ChannelLogicStr=filename(ChLoc+3:ChLoc+6);

for i=1:4;
    
    if strcmp(ChannelLogicStr(i),'t')
        
        ChannelLogic(i)=1;
        
    else
        
        ChannelLogic(i)=0;
        
    end
    
end


%%
function X=convertPSD2position(S,A)

% solves A(3)x^3+A(2)x^2+A(1)x+S=0

a=A(3);
b=A(2);
c=A(1);
d=S;

f=(3*c/a-b^2/a^2)/3;
g=(2*b^3/a^3-9*b*c/a^2+27*d/a)/27;
h=g.^2/4+f^3/27;

i=(g.^2/4-h).^.5;
j=i.^(1/3);
L=-j;
K=acos(-g/2./i);
M=cos(K/3);
N=sqrt(3)*sin(K/3);
P=-b/3/a;

% X(1)=2.*j.*M+P
% X(2)=L.*(M+N)+P
X=L.*(M-N)+P;
%%
function [ANG SR ProtNum]=getdetailsfromFilename(filename)


firstANG=strfind(filename,'ANG')+3;
lastANG=strfind(filename,'_CH');
ANGlength=lastANG-firstANG;

negIND=1;

if ANGlength==6
    
    firstANG=firstANG+1;
    negIND=-1;
    
end

bigANG=str2num(filename(firstANG));
littleANG=str2num(filename(firstANG+2:firstANG+4));

angle=bigANG+littleANG/1000;

ANG=angle*negIND;

lastProtNum=strfind(filename,'PSDsignals')-1;
firstProtNum=strfind(fliplr(filename(1:lastProtNum)),'_');

ProtNum=str2num(filename(lastProtNum-firstProtNum+2:lastProtNum));

firstSR=strfind(filename,'_SR');
lastSR=strfind(filename,'NP');
SR=str2num(filename(firstSR+3:lastSR-1));

%%
function [TP FirstLevel SecondLevel fit]=FitStepTransition2(t,x)

LSum_of_xsquared=sum(x.*x);
LSum_of_x=sum(x);
USum_of_xsquared=0;
USum_of_x=0;

% xsquared=x.*x
% cumxsquared=xsquared%(cumsum(xsquared))
% cumxsquared=cumxsquared(2:end)
% cumx=x%(cumsum(x))
% cumx=cumx(2:end)
Num=fliplr(1:1:length(x));
Num2=[1 1:1:length(x)-1];

LSumXSq=fliplr(cumsum(fliplr(x.*x)));
LSqSumX=fliplr(cumsum(fliplr(x)));

USumXSq=cumsum((x.*x));
USqSumX=cumsum((x));

LSumXSq=LSumXSq;
LSqSumX=LSqSumX;
USumXSq=[0 USumXSq(1:length(x)-1)];
USqSumX=[0 USqSumX(1:length(x)-1)];

% Chi2(1)=LSum_of_xsquared-LSum_of_x*LSum_of_x/length(x)
% NLowerTemp(1)=Chi2(1)
% NUpperTemp(1)=0
NLowerTemp=LSumXSq-LSqSumX.*LSqSumX./Num;
NUpperTemp=USumXSq-USqSumX.*USqSumX./Num2;

ChiSq=NLowerTemp+NUpperTemp;

[minChi minChiInd]=min(ChiSq);

TP=minChiInd;

FirstLevel=median(x(1:minChiInd-1));
SecondLevel=median(x(minChiInd:end));

fit=[ones(1,TP-1)*FirstLevel ones(1,length(x)-TP+1)*SecondLevel];



