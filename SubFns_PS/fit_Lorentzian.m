function f=fit_Lorentzian(F,PS,p)

fit=p(1)/p(2)^2./(1+(F/p(2)).^2);

f=sum((fit-PS).^2);