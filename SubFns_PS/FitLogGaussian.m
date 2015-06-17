function f=FitLogGaussian(X,lnY,p)

fit=p(2)-X.*X/2/p(1)^2;

f=sum((lnY-fit).*(lnY-fit));