function X=ConvertPSD2position(S,A)
% solves A(3)x^3+A(2)x^2+A(1)x+S=0
% converts raw psd signal to position

% Written by Thomas Bilyard
% Last modified by Vladislav Belyy on 11/20/2013

a=A(3);
b=A(2);
c=A(1);
d=S;

if (a==0) && (b==0) %linear conversion
    X = (c.^(-1)).*(-d);

else %cubic conversion
    
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
X=real(L.*(M-N)+P);

end