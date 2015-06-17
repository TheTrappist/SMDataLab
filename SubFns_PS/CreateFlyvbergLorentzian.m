function fit=CreateFlyvbergLorentzian(F,p)

fit=p(1)/pi/pi./(F.*F+p(2)*p(2));