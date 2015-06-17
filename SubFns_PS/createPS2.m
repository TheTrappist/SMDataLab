function [F PS DF]=createPS2(x,SR)

% dt=.001;
% 
% SR=1/dt;
% 
% t=0:dt:10-dt;
% 
% a1=5*sqrt(2);
% a2=7*sqrt(2);
% f1=12;
% f2=43;
% Vd=2;
% 
% x=a1*sin(f1*2*pi*t)+a2*sin(f2*2*pi*t)+Vd;

N=length(x);

if rem(N,2)==1
    
    X=x(1:N-1);
%     T=t(1:N-1);
    
    N=N-1;
    
else
    
    X=x;
%     T=t;
    
end

FFx=fft(X);

Sx=FFx.*conj(FFx)/N^2;

DF=SR/(N-1);

% Sx=Sx/DF;

f=0:DF:SR;

PS(1)=Sx(1);
PS(2:N/2)=Sx(2:N/2)*2;

PS=PS/DF;   %ensures that numerical integral = variance

F=f(1:N/2);

% plot(f1d,S1d)


