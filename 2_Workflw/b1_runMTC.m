% load in data from mat structure
if ~exist('dataAllComp', 'var') || from_b1
    try
        maindir = [SACDIR netname '/' staname '/'];
        load([maindir netname '_' staname '_allComp.mat']);
    catch
        disp([netname '_' staname '_allComp.mat does not exist!']);
        disp('Run a1_preprocess first!')
        return;
    end
end

R = dataAllComp.R;
T = dataAllComp.T;
Z = dataAllComp.Z;
N = dataAllComp.N;
tt = dataAllComp.tt;
delT = tt(2) - tt(1);
header = dataAllComp.header;
dist = header.dist;
rayp = header.slow;

disp('Running MTCRF for R and T ...');
[outtime, outy, radRF, transRF, varR, varT] = ...
    MTCRF(R, T, Z, N, delT, Fcut, binparams, dist, rayp, 0);

time = outtime;
bin = outy;

MTCfile = [RFDIR netname '_' staname '_RF.mat'];
save(MTCfile, 'time', 'bin', 'radRF', 'transRF', 'varR', 'varT');

if rotation == 1 || rotation == 3
    L = dataAllComp.L;
    Q = dataAllComp.Q;
    disp('Running MTCRF for Q and T ...');
    [~, outy, qRF, ~, varQ, ~] = ...
        MTCRF(Q, T, L, N, delT, Fcut, binparams, dist, rayp, 0 );
    save(MTCfile, 'time', 'bin', 'radRF', 'transRF', 'varR', 'varT', 'qRF', 'varQ');
end

if rotation == 2 || rotation == 3
    P = dataAllComp.P;
    S = dataAllComp.S;
    H = dataAllComp.H;
    disp('Running MTCRF for SV and SH ...');
    [~, outy, svRF, shRF, varSV, varSH] = ...
        MTCRF(S, H, P, N, delT, Fcut, binparams, dist, rayp, 0 );
    save(MTCfile, 'time', 'bin', 'radRF', 'transRF', 'varR', 'varT', 'qRF', 'varQ',...
        'svRF', 'shRF', 'varSV', 'varSH');
end



fprintf('Finished. MTCRF saved to:\n %s.\n', MTCfile);
