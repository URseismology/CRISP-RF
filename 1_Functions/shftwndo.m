function [R, T, Z, N, timecut] = shftwndo(data, Dt, nsewin, Ptime, includeNoise, timedur, timeshft)
% Authors: Tolulope Olugboji, Ziqi Zhang

% unpack data ...
ZKs = data.ZZ ;
RKs = data.RR ; 
TKs = data.TT ;

% unpack headers  ...
[~, nwaves] = size(ZKs);

%-- target deeper mantle phases
tshft = timeshft;

% -- generalize MTC-RF for  table instead of vector --
Ptime = Ptime - includeNoise;
PWin = timedur;
NseWin = nsewin;

for iwave = 1:nwaves

    ZKs(:, iwave) = highpass(ZKs(:, iwave), 0.03, 1/Dt);
    RKs(:, iwave) = highpass(RKs(:, iwave), 0.03, 1/Dt);
    TKs(:, iwave) = highpass(TKs(:, iwave), 0.03, 1/Dt);
    
    Nb = round((Ptime-NseWin)/Dt); Ne = round(Ptime/Dt)-1;
    Pb = round((Ptime+tshft)/Dt); Pe = round((Ptime+tshft+PWin)/Dt)-1; % on horizontals
    Zb = round(Ptime/Dt); Ze = round((Ptime+PWin)/Dt)-1; % on vertical

    Ndat = Pe - Pb + 1;
    Nnoi = Ne - Nb + 1;

    rnoi = ZKs(Nb:Ne, iwave); % noise
    rsig = ZKs(Pb:Pe, iwave); % signal

    if iwave == 1
        dnoi = padpow2(rnoi, 1); lennoi = length(dnoi);
        dsig = padpow2(rsig, 1); lensig = length(dsig);
        lenpad = max(lensig, lennoi);

        Z = zeros(lenpad, nwaves);
        R = zeros(lenpad, nwaves);
        T = zeros(lenpad, nwaves);
        N = zeros(lenpad, nwaves);

        timecut = Dt*[0:lenpad-1]';

    end

    N(1:Nnoi, iwave) = rnoi;

    for ic = 1: 3
        switch ic
            case 1
                rsig = ZKs(Zb:Ze, iwave); % signal
                Z(1:Ndat, iwave) = rsig;
            case 2
                rsig = RKs(Pb:Pe, iwave); % signal
                R(1:Ndat, iwave) = rsig;
            case 3
                rsig = TKs(Pb:Pe, iwave); % signal
                T(1:Ndat, iwave) = rsig;
        end
    end
end


end
