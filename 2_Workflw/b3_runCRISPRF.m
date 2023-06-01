
% % load data for test (temporary)
% inDat = load([localBaseDir 'Prj7_RadonT/Prj2_SEUS_RF/0_startHere/Radon_codes/radon_transforms/ULM_doQC.mat'], 'datimg', 'outy');
% tx = inDat.datimg.d;
% taus = inDat.datimg.taus;
% rayP = inDat.outy(2:end,2)';
% dist = inDat.outy(2:end,1)';
% dts = diff(taus); dt =  dts(1); 

% load synthetic data
inDat = load('../../SynRadonRF.mat');
tx = inDat.txn;
taus = inDat.t;
dt = taus(2) - taus(1);
rayP = inDat.rayP;
dist = inDat.epiDist;

% % load data based on network and station
% MTCfile = [RFDIR netname '_' staname '_RF.mat'];
% inDat = load(MTCfile, 'time', 'radRF', 'bin');
% tx = inDat.radRF';
% taus = inDat.time;
% dt = taus(2) - taus(1);
% rayP = inDat.bin(:, 2)';
% dist = inDat.bin(:, 1)';

% cut data
tBegin = find(taus > twin(1), 1);
tEnd   = find(taus > twin(2), 1);
taus = taus(tBegin:tEnd);
tx = tx(:, tBegin:tEnd);

% demean and detrend
for i = 1:size(tx, 1)
    tx(i,:) = detrend(tx(i,:));
    tx(i,:) = tx(i,:) - mean(tx(i,:));
end

dq = (qmax-qmin)/(nq-1);  %value increament of qs
qs = qmin+dq*(0:1:nq-1);  % generate all q values from qmin to qmax

mk1 = sparse_inverse_radon_data(tx', dt, rayP, dist, 0, qs, fmin, fmax, ...
    mu, alpha, tstep, maxiter, kstop, vmodel, migration, twin, qwin);
