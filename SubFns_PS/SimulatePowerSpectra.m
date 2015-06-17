function SimulatePowerSpectra

MainPath=pwd;
SubFunctions=strcat(MainPath,'\Jeffs Code');
addpath(SubFunctions)

white=randn(100000,1);

fsamp=1;

[WhiteSpectrum, WhiteF] = OneSidedSpectrum(white, fsamp, @nowindow);

[WhiteAv, WhiteAvF] = AverageSpectrum(white, fsamp, 10, @nowindow);

pW=fminsearch(@(p) FitPowerLawSpectrum(WhiteAvF(2:end),WhiteAv(2:end),p),[WhiteAv(end) sqrt(WhiteAv(2)*WhiteAvF(2)^2)])

Brown=cumsum(white);

[BrownSpectrum, BrownF] = OneSidedSpectrum(Brown, fsamp, @nowindow);

[BrownAv, BrownAvF] = AverageSpectrum(Brown, fsamp, 100, @nowindow);

BrownSpectrum(2)*BrownF(2)^2

pB=fminsearch(@(p) FitPowerLawSpectrum(BrownAvF(2:end),BrownAv(2:end),p),[BrownAv(end) sqrt(BrownAv(2)*BrownAvF(2)^2)])

subplot(2,2,1)

loglog(WhiteF,WhiteSpectrum,'b.',WhiteAvF,WhiteAv,'r-',WhiteAvF(2:end),CreatePowerLawSpectrum(WhiteAvF(2:end),pW),'g-')
xlabel('freq (Hz)')
ylabel('unit^2 Hz^{-1}')
title('White noise \propto f^0')
legend('Power Spectrum','100-window Power Spectrum')

subplot(2,2,2)

loglog(BrownF,BrownSpectrum,'b.',BrownAvF,BrownAv,'r-',BrownF(2:end),CreatePowerLawSpectrum(BrownF(2:end),pB),'g-')
xlabel('freq (Hz)')
ylabel('unit^2 Hz^{-1}')
title('Brown noise \propto f^{-2}')
legend('Power Spectrum','100-window Power Spectrum')

SR=500;
StepSize=5;
Noise=5;

[PoisNoNoise PoisTNoNoise XNoNoise StepTimesNoNoise StepLevelsNoNoise]=GeneratePoissonStepper(StepSize,1,0,1,500,100);

[PoisSpectrumNoNoise, PoisFNoNoise] = OneSidedSpectrum(XNoNoise', SR, @nowindow);

[PoisAvNoNoise, PoisAvFNoNoise] = AverageSpectrum(XNoNoise', SR, 100, @nowindow);

pMNoNoise=fminsearch(@(p) FitPowerLawSpectrum(PoisAvFNoNoise(2:end),PoisAvNoNoise(2:end),p),[PoisAvFNoNoise(end) sqrt(PoisAvNoNoise(2)*PoisAvFNoNoise(2)^2)])

dfNoNoise=PoisAvFNoNoise(2)-PoisAvFNoNoise(1);

NoiseStDevNoNoise=sqrt(dfNoNoise*pMNoNoise(1)^2*length(PoisAvFNoNoise))

subplot(2,2,3)

loglog(PoisFNoNoise,PoisSpectrumNoNoise,'b.',PoisAvFNoNoise,PoisAvNoNoise,'r-',PoisAvFNoNoise(2:end),CreatePowerLawSpectrum(PoisAvFNoNoise(2:end),pMNoNoise),'g-')
xlabel('freq (Hz)')
ylabel('unit^2 Hz^{-1}')
title(strcat('Noiseless Poisson stepper'))
legend('Power Spectrum','100-window Power Spectrum')

[Pois PoisT X StepTimes StepLevels]=GeneratePoissonStepper(StepSize,1,Noise,1,500,100);
% GeneratePoissonStepper(StepSize,StepSizeWidth,Noise,MeanDwell,SR,NoSteps)

t=(1:1:length(X))/SR;

% figure;
% plot(t,x,'.')

[PoisSpectrum, PoisF] = OneSidedSpectrum(X', SR, @nowindow);

[PoisAv, PoisAvF] = AverageSpectrum(X', SR, 100, @nowindow);

pM=fminsearch(@(p) FitPowerLawSpectrum(PoisAvF(2:end),PoisAv(2:end),p),[PoisAvF(end) sqrt(PoisAv(2)*PoisAvF(2)^2)])

df=PoisAvF(2)-PoisAvF(1);

NoiseStDev=sqrt(df*pM(1)^2*length(PoisAvF))

subplot(2,2,4)

loglog(PoisF,PoisSpectrum,'b.',PoisAvF,PoisAv,'r-',PoisAvF(2:end),CreatePowerLawSpectrum(PoisAvF(2:end),pM),'g-')
xlabel('freq (Hz)')
ylabel('unit^2 Hz^{-1}')
title(strcat('Noisy Poisson stepper (',num2str(100*NoiseStDev/Noise),'% of noise found)'))
legend('Power Spectrum','100-window Power Spectrum')





%-------------------------
%%

function f=FitPowerLawSpectrum(F,P,p)

y=p(1)^2+p(2)^2./F.^2;

% f=sum((y-P).^2);
f=sum((log(y)-log(P)).^2);


%%
function fit=CreatePowerLawSpectrum(F,p)

fit=p(1)^2+p(2)^2./F.^2;