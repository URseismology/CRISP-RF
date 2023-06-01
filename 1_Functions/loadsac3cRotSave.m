%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Tolulope Olugboji
% loadsac3c.
% upload waveforms into station-event table and do the following
function [wave3C, lenWv, delta, baz, mag, loc] = loadsac3cRotSave(fDir, useROTSAVE)

Zname = 'BHZ.SAC';
Nname = 'BHN.SAC';
Ename = 'BHE.SAC';

%wave3C = [];
cmpazne = [0 0];

for iCmp = 1:3
    switch iCmp
        case 1
            zwv = readsac([fDir Zname]);
            zlen = zwv.NPTS;
            zdelta = zwv.DELTA;
            zdat = detrend(zwv.DATA1); zlen = length(zdat);
            
            baz = zwv.BAZ;
            mag = zwv.MAG;
            
            loc = [zwv.STLA, zwv.STLO];
            
        case 2
            if isfile([fDir Nname])
                NFile = [fDir Nname];
            else
                NFile = [fDir 'BH1.SAC'];
            end
            
            nwv = readsac(NFile);
            nlen = nwv.NPTS;
            ndelta = nwv.DELTA;
            ndat = detrend(nwv.DATA1); nlen = length(ndat);
            
            cmpazne(1) = nwv.CMPAZ;
        case 3
            
            if isfile([fDir Ename])
                EFile = [fDir Ename];
            else
                EFile = [fDir 'BH2.SAC'];
            end
            
            ewv = readsac(EFile);
            elen = ewv.NPTS;
            edelta = ewv.DELTA;
            edat = detrend(ewv.DATA1); elen = length(edat);
            
            cmpazne(2) = ewv.CMPAZ;
    end
    
    
end

isEqLen = (zlen == nlen) && (nlen == elen) && (elen == zlen);

if isEqLen
    wave3C = [zdat - mean(zdat), ndat - mean(ndat), edat - mean(edat)];
    lenWv = nlen;
    delta = ndelta;
else
    %[nlen, elen, zlen]
    mlen = min([nlen, elen, zlen]);
    
    wave3C = [zdat(1:mlen) - mean(zdat(1:mlen)), ...
        ndat(1:mlen) - mean(ndat(1:mlen)), ...
        edat(1:mlen) - mean(ndat(1:mlen))];
    lenWv = mlen;
    delta = ndelta;
    
    % update with correct data length
    zdat = zdat(1:mlen); ndat = ndat(1:mlen); edat = edat(1:mlen);
    zwv.NPTS = mlen; nwv.NPTS = mlen; ewv.NPTS = mlen;
    
end
%assert(isEqLen, 'Not same length %d %d %d', zlen, nlen, elen);

%useROTSAVE = 1;
if useROTSAVE
    
    outZname = [fDir  'Z'];
    outRname = [fDir  'R'];
    outTname = [fDir  'T'];
    
    %[length(ndat) length(edat) nlen elen]
    [rdat, tdat] = rotateWaveforms(ndat', edat', cmpazne,baz);
    
    % update rotated waveforms
    zwv.DATA1 = zdat;
    nwv.DATA1 = rdat;
    ewv.DATA1 = tdat;
    
    
    % give them new filenames
    zwv.FILENAME = outZname;
    nwv.FILENAME = outRname;
    ewv.FILENAME = outTname;
    
    %write to directory ...
    writesac(zwv); writesac(nwv); writesac(ewv);
    %disp('Complete rotate and save');
    
end



end
