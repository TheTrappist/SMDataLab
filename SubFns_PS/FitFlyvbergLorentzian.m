function f=FitFlyvbergLorentzian(F,PSX,p)

%   p(1)=D, p(2)=fc

fit=p(1)/pi/pi./(F.*F+p(2)*p(2));

f=sum((fit-PSX).*(fit-PSX));

