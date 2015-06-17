function[F_dec PS_dec]=decimate_sig(F,PS,deci_factor,method)

% Decimate the Power Spectrum by factor=deci_factor

% The decimation method can be either 'average', 'median' or simply the
% central value

NP=length(F);

for i=1:floor(NP/deci_factor)
    
        switch lower(method)
            
            case 'average'
    
                F_dec(i)=mean(F((i-1)*deci_factor+1:i*deci_factor));
                PS_dec(i)=mean(PS((i-1)*deci_factor+1:i*deci_factor));
    
            case 'median'
            
                F_dec(i)=median(F((i-1)*deci_factor+1:i*deci_factor));
                PS_dec(i)=median(PS((i-1)*deci_factor+1:i*deci_factor));
    
            otherwise
            
                F_dec(i)=F(floor(mean([(i-1)*deci_factor+1 i*deci_factor])));
                PS_dec(i)=PS(floor(mean([(i-1)*deci_factor+1 i*deci_factor])));
            
       end
    
    
end