
%% check if inwave.txt exist; if not, create for this station
maindir = [SACDIR netname '/' staname '/'];
inwavefile = [maindir netname '_' staname '_inwave.txt'];

if (~isfile(inwavefile) || rebuild) && ~strcmp(netname, 'CCP') && ~strcmp(netname, 'STACK')
    fileNames = dir([maindir '*Z']);
    fid = fopen(inwavefile, 'w');
    for ifile = 1:length(fileNames)
        fprintf(fid, '%s\n', [fileNames(ifile).folder '/' fileNames(ifile).name]);
    end
    fclose(fid);
end

%% read in sac files according to inwave.txt
% [data, headers] = sac2mat(maindir, fileNames, isplot, rebuild, skipsave);
[dataOut, headers] = sac2matv3(inwavefile, maindir, netname, staname, rebuild, ...
    skipsave, checknan, beforeP, afterP, fband, isplot, sortby);
% add p arrival (from STA/LTA) and snr info to the header: maybe implement
% in the future ...
% [headers, ~] = getEqstats(data.ZZ, headers, fband);

%% resample, QC, rotation, and save

[dts, lentraces, ~] = getsrate(headers); % dts in milisecond

if length(dts) > 1 % non-consistent dt/srate, resample
    dt_old = max(dts); len_old = min(lentraces);  % sampling slower
    dt_new = min(dts); len_new = max(lentraces);  % sampling faster
    [dataN, headers] = dataresample(dataOut, headers, dt_old, dt_new, len_old, len_new, isplot);
else % consistent dt/srate, no processing needed
    dataN = dataOut;
    dt_new = dts;
    headers.srate = dt_new;
    headers.lentrace = lentraces;
end

%% QC selection based on baz, dist, and snr ranges
[dataQC, headersQC] = dataselect(dataN, headers, bazrnge, distrnge, snrrnge);

% resort data by slowness
% no need to do this because it is already sorted before QC

% cut data and rotate to LQT and PSH
rayp = headersQC.slow;
delT = dt_new / 1e3; % milisecond to second
allPtime = headers.ptime;

% after previous steps all saved data has the length from beforeP to
% afterP; the following step uses [beforeP - Pwindow] as the starting point
% for P arrival to account for the taper effect in MTC Calculation
[R, T, Z, N, tt] = shftwndo(dataQC, delT, nsewin, beforeP, Pwindow, timedur, timeshft);
headers.ptimes = beforeP - Pwindow;

dataAllComp.R = R;
dataAllComp.T = T;
dataAllComp.Z = Z;
dataAllComp.N = N;
dataAllComp.tt = tt;

if rotation == 1 || rotation == 3
    [L, Q, T] = lqtrotate(Z, R, T, rayp, pvel);
    dataAllComp.L = L;
    dataAllComp.Q = Q;
end
if rotation == 2 || rotation == 3
    [P, S, H] = psvrotate(Z, R, T, rayp, pvel, svel); %%%%%%%%%% H == T?
    dataAllComp.P = P;
    dataAllComp.S = S;
    dataAllComp.H = H;
end

% write all components into a mat structure and save
dataAllComp.header = headersQC;

%% final save
outmatfile = [maindir netname '_' staname '_allComp.mat'];
% save(outmatfile, 'dataAllComp', '-v7.3'); % -v7.3 to save large matfiles
fprintf('All kept and rotated waveforms saved to %s.\n', outmatfile);