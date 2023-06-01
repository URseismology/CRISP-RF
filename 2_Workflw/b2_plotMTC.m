MTCfile = [RFDIR netname '_' staname '_RF.mat'];

RFmat = load(MTCfile, 'time','radRF','bin');

R = RFmat.radRF';
t = RFmat.time;
rayP = RFmat.bin(:, 2);
epiDist = RFmat.bin(:, 1);
tPhase = [];
tWin = [1 30];
tWin = tWin - timeshft;
scale = 0.5;
singlePlot = 1;
pws = 0;

RFWigglePlot(R, t, rayP, epiDist, tPhase, tWin, scale, singlePlot, pws);
sgtitle(sprintf('%s.%s MTC-RF', netname, staname));

if timeshft ~= 0
    xticklabels(cellstr(num2str(str2double(xticklabels) + timeshft)));
    xlabel('Time (s)', 'FontSize', 20);
end