function [centF centPS]=centralFregion(lowF,highF,F,PS,DF)

centF=F(floor(lowF/DF):floor(highF/DF));
centPS=PS(floor(lowF/DF):floor(highF/DF));