function getSACv2(outDIR, network, stnm, EQmeta, Twin)
%   Authors: Tolulope Olugboji, Ziqi Zhang
%   GETSAC Summary of this function goes here
%   Detailed explanation goes here

numSAVE = 0;

min_before = Twin(1);
min_after = Twin(2);

nEvnts = length(EQmeta);

for iEv = 1:nEvnts
    
    fprintf('Downloading %6d of %6d traces\n', iEv, nEvnts);
    tt = datetime(EQmeta(iEv).Time,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
    
    try
        Tbeg = tt - minutes(min_before) ;
        Tend = tt + minutes(min_after) ;
        
        traces = irisFetch.Traces(network,stnm,'*','BH?', ...
            Tbeg, Tend);
        
        
        % ------- start event meta data, super important for recfunc
        nTrace = length(traces);
        
        for it = 1: nTrace
            traces(it).BAZ = EQmeta(iEv).evBaz;
            traces(it).GCARC = EQmeta(iEv).evDistDeg;
            traces(it).MAG = EQmeta(iEv).evMg;
            traces(it).EVDP = EQmeta(iEv).evDp;
            traces(it).EVLA = EQmeta(iEv).evLat;
            traces(it).EVLO = EQmeta(iEv).evLon;
            traces(it).T0 = min_before * 60; % arrival time default...
            traces(it).T1 = min_before * 60; % arrival time default...
            traces(it).KT1 = EQmeta(iEv).phsNme; % arrival phase
            traces(it).T2 = EQmeta(iEv).phsArrS + min_before * 60; % S arrival
            traces(it).KT2 = EQmeta(iEv).phsNmeS; % arrival phase S
            traces(it).USER0 = EQmeta(iEv).evPslow; %slowness
            
            traces(it).CMPAZ = traces(it).azimuth; % is this correct??
            
            % simple file name tagged with event meta file ...
            chnl = traces(it).channel;
            loc = traces(it).location;
            traces(it).fName = [network '.' stnm '.' num2str(iEv) '.' loc '.' chnl '.SAC'];
        end
        % ------ end event metadata, now no need to cross reference, yet.
        
        
        irisFetch.Trace2SAC(traces, outDIR);
        
        numSAVE = numSAVE + 1;
 
    catch
       disp('Error while fetching data');
       continue;
    end
    
end

fprintf('\nTotal saved events: %d\n', numSAVE);

end

