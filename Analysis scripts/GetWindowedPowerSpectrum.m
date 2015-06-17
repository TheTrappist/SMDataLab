function [F, PSx, PSy]=GetWindowedPowerSpectrum(X,Y,SR,WindowLength)

NP=length(X);

PointsInWindow=SR*WindowLength;

NoWindows=floor(NP/PointsInWindow);

PSxSum=zeros(1,PointsInWindow/2);
PSySum=zeros(1,PointsInWindow/2);

size(PSySum);

for i=1:NoWindows
    
%     i
    
%     T=t((i-1)*PointsInWindow+1:i*PointsInWindow);
    
    Xps=X((i-1)*PointsInWindow+1:i*PointsInWindow);
    
    Yps=Y((i-1)*PointsInWindow+1:i*PointsInWindow);
    
    [Fx PSx DFx]=createPS2(Xps,SR);
    
    [Fy PSy DFy]=createPS2(Yps,SR);
    
    size(PSy);
    
%     loglog(Fx,PSx,'b-',Fy,PSy,'r-')
    
    PSxSum=PSxSum+PSx;
    
    PSySum=PSySum+PSy;
    
end

PSx=PSxSum/NoWindows;
PSy=PSySum/NoWindows;

F=Fx;