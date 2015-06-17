function S_dec=decimate_1sig(S,deci_factor,method)

% Decimate the Power Spectrum by factor=deci_factor

% The decimation method can be either 'average', 'median' or simply the
% central value

NP=length(S);

for i=1:floor(NP/deci_factor)
    
        switch lower(method)
            
            case 'average'
    
                S_dec(i)=mean(S((i-1)*deci_factor+1:i*deci_factor));
                
    
            case 'median'
            
                S_dec(i)=median(S((i-1)*deci_factor+1:i*deci_factor));
                
    
            otherwise
            
                S_dec(i)=S(floor(mean([(i-1)*deci_factor+1 i*deci_factor])));
                
            
       end
    
    
end