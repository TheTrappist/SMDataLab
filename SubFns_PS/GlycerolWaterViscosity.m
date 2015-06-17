function dynamicViscosity = GlycerolWaterViscosity(tempCelsius, ...
    percentGlycerol)
% Calculates the dynamic viscosity of a glycerol-water mixture according to
% the paper: Cheng, Nian-sheng. (2008). Formula for the Viscosity of a
% Glycerol-Water Mixture. Industrial and Engineering Chemistry Research,
% 47(9), 3285-3288.

% Written by Vladislav Belyy
% Last modified on 12/15/2011

%% Calculate dynamic viscosity of water, in cP:
T = tempCelsius;
muW = 1.790*exp((-1230-T)*T / (36100 + 360*T));

%% Calculate dynamic viscosity of glycerol, in cP:

muG = 12100*exp((-1233+T)*T / (9900 + 70*T));


%% Calculate coefficients a, b, and alpha

a = 0.705 -0.0017*T;
b = (4.9 + 0.036*T)*a^2.5;

Cm = percentGlycerol / 100;

alpha = 1 - Cm + (a*b*Cm*(1-Cm))/(a*Cm + b*(1-Cm));


%% Calculate viscosity of the mixture, in cP:

dynamicViscosity = (muW^alpha)*(muG^(1-alpha));

