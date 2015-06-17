function f=FitNewLorentzian(F,PSX,PSY,p)

%p(1)=beta,p(2)=KsX,p(3)=KsY

X=4.11/pi/pi./(p(2)^2/p(1)/4/pi/pi+p(1)*F.^2);

Y=4.11/pi/pi./(p(3)^2/p(1)/4/pi/pi+p(1)*F.^2);

f=sum((X-PSX).^2)+sum((Y-PSY).^2);