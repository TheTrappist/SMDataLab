function [NoPWD PWD NoWindow]=GetWindowedPWD(Data,NPinWindow,DeltaTOffset,DeltaTStep)

NPinData=length(Data);

NoWindow=floor(NPinData/NPinWindow);

PWDcurrent=0;

for WindowNo=1:NoWindow
    
    WindowData=Data((WindowNo-1)*NPinWindow+1:WindowNo*NPinWindow);

    [NoPWD PWD]=GetPWD(WindowData,100,10);
    
    NoPWD;
    
    PWDarray(PWDcurrent+1:PWDcurrent+NoPWD)=PWD;
    
    PWDcurrent=PWDcurrent+NoPWD;
    
end

NoPWD=PWDcurrent;

if NoPWD>0
    
PWD=PWDarray;

else
    
    PWD=[0];
    
end