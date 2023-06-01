function [outRad, outTrans] = stackwithovlpRFs(rRF, tRF, varR, varT, sparams)
% Author: Tolulope Olugboji

[N, nwaves] = size(rRF);


% stacking parameterts
nbins = sparams.nbins;
binedge = sparams.binedge;
distvals = sparams.distvals;

deltabin = 0.5 * sparams.deltabin;

%stackparams.bincnt = hdist.Values;
%stackparams.binlims = hdist.BinLimits;


outRad = zeros(N, nbins);
outTrans = zeros(N, nbins);

stckTble = zeros(nwaves, nbins);

wts = zeros(N, nwaves);
wRF = zeros(N, nwaves);

for ibin = 1:nbins
    ifnd = (distvals>= (binedge(ibin+1) - deltabin)) & (distvals <= (binedge(ibin+1) + deltabin));
    stckTble(:, ibin) = ifnd;
    
    %weighted RF stacking see Zhang & Olugboji, 2022
    % radial receiver functions
    weigths = 1 ./ varR(:, ifnd);  % weights
    rRFwts = rRF(:, ifnd) .* weigths;

    % == debug stacking traces
    
    medianFreq = nanmedian(abs(rRFwts), 1); traceind = 1:sum(ifnd);
    discardbin = medianFreq > 500*median(medianFreq) | ...
                        medianFreq > 1e6; % xline(medianFreq(discardbin));
    if 0    
        clf; plot(medianFreq); hold on;
        plot(traceind(discardbin), medianFreq(discardbin), 'ro');
        title([num2str(ibin) ' of ', num2str(nbins)])
        pause(1)
    end
    % == end debug

    if 0
        keep = ~discardbin;

        wk = weigths(:, keep);
        rfk = rRFwts(:, keep);

        sumw = nansum(wk, 2);
        sumrRF = nansum(rfk, 2); 
    else

        sumw = nansum(weigths, 2);
        sumrRF = nansum(rRFwts, 2); 
    end
    

    wts(:, ifnd) = weigths;
    wRF(:, ifnd) = rRFwts;

    outRad(:, ibin) =  sumrRF ./ sumw;

    % transverse receiver functions
    weigths = 1 ./ varT(:, ifnd);  % weights
    tRFwts = tRF(:, ifnd) .* weigths;

    sumw = nansum(weigths, 2);
    sumtRF = nansum(tRFwts, 2); 

    outTrans(:, ibin) =  sumtRF ./ sumw;

    
end

% imagesc(wts);
end