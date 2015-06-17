function linfit = CalcPSDvsTrap (trapPosRaw, PSDsignalRaw, range)

% Code written 12/13/2013 Vladislav Belyy
% 
% Used to quantify the (approximately) linear change in PSD signal as a
% single trapped bead is scanned across the range of the trap. Accepting
% raw trap position (either in MHz for an AOD trap or in volts for a piezo
% mirror-driven trap) and dimensionless PSD signal, the function returns
% the linear fit parameters (m and b from y=mx+b) taken from the desired
% range and displays the fit in a new figure. Both trapPosRaw and
% PSDsignalRaw should be column vectors.


data = [trapPosRaw, PSDsignalRaw];

% remove points outside of the specified range
data((data(:,1)>max(range)), :) = '';
data((data(:,1)<min(range)), :) = '';

% fit select region to line
linfit = polyfit(data(:,1), data(:,2), 1);

% plot result
figure;
hold on
linePlot = data(:,1)*linfit(1) + linfit(2);
plot(trapPosRaw, PSDsignalRaw, 'Color', [0.6 0.6 0.6]);
plot(data(:,1), linePlot, 'Color', 'red', 'linewidth', 2);
title('PSD response vs. trap position')
xlabel('Raw trap position')
ylabel('PSD response')

h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',12);
h_ylabel = get(gca,'YLabel');
set(h_ylabel,'FontSize',12);
h_title = get(gca,'Title');
set(h_title,'FontSize',14);
set(gca, 'FontSize', 12);

fitResult = ['y = ', num2str(linfit(1), 4), '*x + ', ...
    num2str(linfit(2), 4)];

text(mean(trapPosRaw), max(PSDsignalRaw), fitResult)

hold off










