% T Test Window
% Jeff Moffitt
% August 11, 2005
% Updated by Yann Chemla

function [t, sgn, sD] = TTestWindow(Data, N, option)

if nargin < 3
    option = 'CalSign';
end

L = length(Data);

sgn = zeros(length(Data),1);
t = zeros(length(Data), 1);
sD = zeros(length(Data), 1);

Data = [Data(1)*ones(1,N-1) Data Data(end)*ones(1,N-1)]; 

[M1,M2] = meshgrid(0:N-1,1:L);
M = M1+M2; 
leftSamp = Data(M);
rightSamp = Data(M+N-1);
leftMean = mean(leftSamp,2);
rightMean = mean(rightSamp,2);

sD = sqrt((sum((leftSamp - meshgrid(leftMean',1:N)').^2,2) + sum((rightSamp - meshgrid(rightMean',1:N)').^2,2))/(N*(N-1)));
t = (leftMean - rightMean)./sD;

if strcmp(option, 'CalSign')
    %display('Calculating significance');
    sgn = betainc(2*(N-1)./(2*(N-1) + t.^2), N-1, 1/2);
end