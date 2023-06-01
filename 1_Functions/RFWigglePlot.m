function RFWigglePlot(R, t, rayP, epiDist, tPhase, tWin, scale, singlePlot, pws)
% function RFWigglePlot(R, t, rayP, epiDist, tPhase, tWin, scale, singlePlot)
% Author: Ziqi Zhang
%
% This function plots the receiver function (RF) matrix and arrival time
% curves (if provided).
% 
% Input:
% R - RF matrix (each row is one trace)
% t - time vector, should have length of size(R, 2)
% rayP - ray parameter vector, should have length of size(R, 1)
% epiDist - epicentral distance vector, should have length of size(R, 1)
% tPhase - arrival times matrix (each column is one phase), can be empty
% tWin - time window (w.r.t. the time vector itself) for plot, e.g., [1 25]
% scale - scaling/normalization factor for individual RF traces
% singlePlot - if this is a single plot or inside a subplot (only plotting
%              stack when this is set to 1)
% pws - to use phase weighted stack or not

%% Prepping values to be plotted from RF

% Epicental distance should be increasing
[rayP, y_order] = sort(rayP, 'ascend');
R = R(y_order, :);
epiDist = epiDist(y_order);

nY = length(rayP);

tStart = tWin(1); tEnd = tWin(2);

it = find(t>tStart, 1);
endt = find(t>=tEnd, 1);

RR = R(:,it:endt);
% for iY = 1:nY
%     RR(iY,:) = detrend(RR(iY,:));
%     RR(iY,:) = RR(iY,:) - mean(RR(iY,:));
% end

if pws
    RR_forStack = RR;
    RR_forStack(any(isnan(RR_forStack), 2), :) = [];
    [stackR, ~] = f_pws(RR_forStack', 3); stackR = stackR'; % phase weighted stack
else
    stackR = sum(RR,  1, 'omitnan'); % linear stack
end

%% Plot pure RF traces with out weighting

if singlePlot
    figure(2);
    clf;
    set(gcf,'position',[50,50,800,800]);

    subplot(6,3,1:15);
    hold on;
end

for iY = 1:nY % plot from top to bottom
    
    meach = max(abs(RR(iY, :)));
    if meach == 0
        meach = 1;
    end
    Rn = RR(iY,:) ./ meach;
    Rn = Rn - mean(Rn);
    if sum(isnan(Rn)) > 0
        Rn = zeros(1, length(Rn));
    end
    Tn = t(it:endt); sizeT = length(Tn);
    
    yLev = (nY-iY) * scale;
    yVec = repmat(yLev, 1, sizeT);
    
    if iY == 1
        ymax = yLev + max(Rn);
    elseif iY == nY
        ymin = yLev + min(Rn);
    end
    
    jbfill(Tn, max(Rn+yLev, yLev), yVec, [0 0 1],'k', 1, 1.0);
    jbfill(Tn, min(Rn+yLev, yLev), yVec, [1 0 0],'k', 1, 1.0);
    
end

yl = 0 * scale;
yh = (nY+1) * scale ;

% Plotting optimized arrival times
if ~isempty(tPhase)
    yPhase = linspace(yl,yh, nY);
    hold on;
    for iphase = 1:size(tPhase, 2)
        plot(tPhase(:, iphase), yPhase, 'k-', 'linewidth', 2);
    end   
end

% Plotting axis
yticks((0:round(nY/10):(nY-1)) * scale);
set(gca, 'yticklabel', round(epiDist(end:-round(nY/10):1)));
xlim([tStart tEnd]);
ylim([ymin ymax]);
ylabel('Epicentral distance (deg)','FontSize', 20);

grid on;

if singlePlot
    set(gca,'xticklabel', '');
    subplot(6,3,16:18);
    hold on;
    Rn = stackR / max(abs(stackR));
    Rn = Rn - mean(Rn);
    yVec = zeros(1, sizeT);
    jbfill(Tn, max(Rn, 0), yVec, [0 0 1],'k', 1, 1.0);
    jbfill(Tn, min(Rn, 0), yVec, [1 0 0],'k', 1, 1.0);

    xlim([tStart tEnd]);
    ylim([-1 1]);
end

end
