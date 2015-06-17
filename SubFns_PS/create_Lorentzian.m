function f=create_Lorentzian(F,p)

f=p(1)/p(2)^2./(1+(F/p(2)).^2);