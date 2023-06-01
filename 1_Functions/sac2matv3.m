function [dataOut, head] = sac2matv3(inwavefile, maindir, network, stnm, ...
    rebuild, skipsave, checknan, beforeP, afterP, fband, isplot, sortby)

% Authors: Tolulope Olugboji, Ziqi Zhang
% -- save data to matlab structure as file infrastructure ..

datacache = maindir;
sta_filename = fullfile([datacache,'EqData_',network,'_',stnm,'.mat']);

if exist(sta_filename,'file') && ~rebuild
    % if EqData matfile already exist and rebuild is not needed, load in
    % the existing file
    disp(['Exist: ',sta_filename,', Skip!']);
    disp('Loading already existing file');
    InDat = load(sta_filename);
    
    dataOut.ZZ = InDat.DATnHEAD.ZZ;
    dataOut.RR = InDat.DATnHEAD.RR;
    dataOut.TT = InDat.DATnHEAD.TT;
    
    head = InDat.DATnHEAD.HEAD;
    isplot = 0;
else
    % otherwise first read inwave.txt into cell array
    fid = fopen(inwavefile, 'r');
    thisline = fgetl(fid);
    fileNames = cell(0, 1);
    while ischar(thisline)
        fileNames{end + 1} = thisline;
        thisline = fgetl(fid);
    end
    
    nwaves = length(fileNames);
    
    epidists = nan(1, nwaves);
    bazs = nan(1, nwaves);
    srates = nan(1, nwaves);
    s2ns = nan(1,nwaves); % future development
    slows = nan(1, nwaves);
    lengths = nan(1, nwaves);
    ptimes = nan(1, nwaves);
    
    % then start preprocessing
    cmp =['Z' 'T' 'R'];
    for iwave = 1:nwaves
        
        fileName = fileNames{iwave}(1:end-1); % sac file name without component

        if iwave == 1
            ll = fprintf(' Processing %6d of %6d traces', iwave, nwaves);
        else
            fprintf([repmat('\b',1, ll-1) 'Processing %6d of %6d traces'], iwave, nwaves);
        end
        if iwave == nwaves
            fprintf('\n All %d traces processed.\n', nwaves);
        end
        
        clear S trace lentrace;
        for ic = 1:length(cmp)
            
            S = readsac([fileName cmp(ic)]);
            
            try
                
                trace = S.DATA1;
                trace = detrend(trace);
                trace = trace-mean(trace);

                %initialize time series
                if iwave == 1
                    Msrate = S.DELTA;
                    Mlentrace = round((beforeP + afterP) / Msrate);
                    ZZ = zeros(Mlentrace, nwaves);
                    RR = zeros(Mlentrace, nwaves);
                    TT = zeros(Mlentrace, nwaves);
                    discard = zeros(1, nwaves);
                end

                % if higher sample rate (lower delta), modify data matrices
                current_srate = S.DELTA;
                if current_srate < Msrate
                    newlentrace = round((beforeP + afterP) / current_srate);
                    Msrate = current_srate;
                    Mlentrace = newlentrace;
                    ZZ = [ZZ; zeros(newlentrace - Mlentrace, nwaves)];
                    RR = [RR; zeros(newlentrace - Mlentrace, nwaves)];
                    TT = [TT; zeros(newlentrace - Mlentrace, nwaves)];
                end

                % cut trace
                current_srate = S.DELTA;
                current_ptime = S.T0;
                current_len   = length(trace);
                cut_begin = round(1 + (current_ptime - beforeP) / current_srate);
                cut_end   = round((current_ptime + afterP)  / current_srate);
                if cut_begin < 1 || cut_end > current_len
                    discard(iwave) = 1;
                    continue;
                end
                trace = trace(cut_begin:cut_end);
                lentrace = length(trace);
                
                switch ic
                    case 1
                        % store length only on z trace ...
                        
                        ZZ(1:lentrace, iwave) = trace;
                        s2ns(iwave)= getsnr(trace, beforeP, S.DELTA, fband); % future development
                        ptimes(iwave) = beforeP; % getEqtime(ZZ); % future development
                        lengths(iwave) = lentrace;
                        epidists(iwave) = S.GCARC;
                        bazs(iwave) = S.BAZ;
                        srates(iwave) = S.DELTA;
                        slows(iwave) = S.USER0 ;
                        
                    case 2
                        TT(1:lentrace, iwave) = trace;
                        if lentrace ~= lengths(iwave)
                            warning('Lengths do not match for Z and T!');
                        end
                    case 3
                        RR(1:lentrace, iwave) = trace;
                        % take min(SNR_Z, SNR_R) as the final SNR value
                        s2ns(iwave)= min(s2ns(iwave), getsnr(trace, beforeP, S.DELTA, fband));
                        if lentrace ~= lengths(iwave)
                            warning('Lengths do not match for Z and R!');
                        end
                end
                
                
            catch
                warning('Error occured when processing %s%s\n', fileName, cmp(ic));
            end
            clear S trace lentrace
            
        end
        
    end
    
    
    % data processing complete; start constructing header information
    if ~checknan
        % if opt not to check nan traces:
        
        head.nrec = nwaves;
        head.srate = srates;
        head.baz = bazs;
        head.dist = epidists;
        head.slow = slows ./  (rad2deg(1) * deg2km(1));
        head.ptimeFromHeader = ptimes;
        head.snr = s2ns;
        head.lentrace = lengths;
        
        dataOut.ZZ = ZZ;
        dataOut.RR = RR;
        dataOut.TT = TT;
        
    else
        % if opt to check nan traces:
        
        discard = discard | isnan(srates) | isnan(bazs) | isnan(epidists); %| isnan(s2ns); % future development
        keep = ~discard;
        
        nwaves  = sum(keep);
        fprintf('%d of %d waveforms kept after initial check.\n', nwaves, length(keep));
        
        ZK = ZZ(:, keep);
        RK = RR(:, keep);
        TK = TT(:, keep);
        
        
        % ---- pack headers
        lengthsk = lengths(keep);
        sratesk = srates(keep);
        bazsk = bazs(keep);
        epidistsk = epidists(keep);
        s2nsk = s2ns(keep);
        slowsk = slows(keep) ./  (rad2deg(1) * deg2km(1));
        ptimesk = ptimes(keep);
 
        % -- pack waveforms -- sorted by distance
        dataOut.ZZ = ZK;
        dataOut.RR = RK;
        dataOut.TT = TK;
        
        % -- pack headers  -- sorted by distance
        head.nrec = nwaves;
        head.srate = sratesk;
        head.baz = bazsk;
        head.dist = epidistsk;
        head.slow = slowsk;
        head.snr = s2nsk; % future development
        head.lentrace = lengthsk;
        head.ptime = ptimesk;
        
    end
    
    % save to matlab structure only once .. else reconstitute.
    
    if ~skipsave
        dataOut.HEAD = head;
        DATnHEAD = dataOut;
        save(sta_filename, 'DATnHEAD');
    end
    
end

if isplot
    srateAll = uniquetol(sratesk, 1e-3);
    srateCnt = length(srateAll);
    for is = 1:srateCnt
        figure(21);
        subplot(srateCnt, 1, is);
        thisZZ = ZK(:, abs(sratesk - srateAll(is)) < 1e-3);
        imagesc(normc(thisZZ));
%         colorbar(seismic);
        caxis([-0.01 0.01]);
        yline(beforeP / srateAll(is), 'r-', 'linewidth', 2);
        title(sprintf('Z, srate = %4.3f', srateAll(is)));
        
        figure(22);
        subplot(srateCnt, 1, is);
        thisRR = RK(:, abs(sratesk - srateAll(is)) < 1e-3);
        imagesc(normc(thisRR));
%         colorbar(seismic);
        caxis([-0.01 0.01]);
        yline(beforeP / srateAll(is), 'r-', 'linewidth', 2);
        title(sprintf('R, srate = %4.3f', srateAll(is)));

        figure(23);
        subplot(srateCnt, 1, is);
        thisTT = TK(:, abs(sratesk - srateAll(is)) < 1e-3);
        imagesc(normc(thisTT));
%         colorbar(seismic);
        caxis([-0.01 0.01]);
        yline(beforeP / srateAll(is), 'r-', 'linewidth', 2);
        title(sprintf('T, srate = %4.3f', srateAll(is)));

    end

    
    figure(11); clf;
    subplot(3,1,1);
    histogram(bazsk, (0:10:360));
    title('Back Azimuth');
    
    subplot(3,1,2);
    histogram(epidistsk, (0:10:180));
    title('Epicentral Distance');

    subplot(3,1,3);
    histogram(s2nsk, (0:1:20));
    title('SNR');
end

end