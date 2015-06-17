%  AverageSpectrum(timeSeries, fsamp, numWindows, window) produces a properly
%  normalized power spectrum , P(f), of timeSeries, sampled at fsamp, using the
%  window function given by the user, and averaged over numWindows of windows. 
%  The resulting spectrum is plotted on a loglog axis.  

%  Jeffrey Moffitt
%  November 15, 2004
function [spectrum, f] = AverageSpectrum(timeSeries, fsamp, numWindows, window)

%default parameter values
if nargin < 4 window = @nowindow; end;
if nargin < 3 numWindows = 1; window = @nowindow; end;

sumSpectrum = 0;

%Tom Changed 01 June 2011
NoPointsInSector=floor(length(timeSeries)/numWindows);
for i = 1:numWindows-1
    index1 = NoPointsInSector*(i-1)+1;
    index2 = NoPointsInSector*(i+1);
    [tempSpectrum, f] = OneSidedSpectrum(timeSeries(index1:index2), fsamp, window);
    sumSpectrum = tempSpectrum + sumSpectrum;
end
spectrum = sumSpectrum/numWindows;
%loglog(f, spectrum);

end

%Jeff's original code

% for i = 1:numWindows
%     index1 = floor(length(timeSeries)/numWindows)*(i-1)+1;
%     index2 = floor(length(timeSeries)/numWindows)*i;
%     [tempSpectrum, f] = OneSidedSpectrum(timeSeries(index1:index2), fsamp, window);
%     sumSpectrum = tempSpectrum + sumSpectrum;
% end
% spectrum = sumSpectrum/numWindows;
% %loglog(f, spectrum);
% 
% end
