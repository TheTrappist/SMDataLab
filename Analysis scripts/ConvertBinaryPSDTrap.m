function [PSD_signal, trapPos, tVector] = ConvertBinaryPSDTrap(fileName, SR, length)
% Written by Vladislav Belyy
% Last updated on 9/28/2012

data = ReadBinaryFile(fileName, 6, SR, length);

numPoints = size(data,1);

PSD_signal = zeros(numPoints, 2);

PSD_signal(:,1) = data(:,1)./data(:,3);
PSD_signal(:,2) = data(:,2)./data(:,4);

trapPos = data(:,5:6);

tVector = 0:(1/SR):(length-1/SR);
