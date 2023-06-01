function [dataO, headersO] = dataselect(data, headers, bazrnge, distrnge, snrrnge)
% Authors: Tolulope Olugboji, Ziqi Zhang
 
ddist = headers.dist;
bbaz = headers.baz;
ssnr = headers.snr;

ifnd = (bbaz>= bazrnge(1)) & (bbaz<= bazrnge(2)) ...
    & (ddist>= distrnge(1)) & (ddist<= distrnge(2)) ...
    & (ssnr>= snrrnge(1)) & (ssnr<= snrrnge(2)) ;

fprintf('%d of %d waveforms kept after QC.\n', sum(ifnd), length(ddist));

dataF.ZZ = data.ZZ(:, ifnd); 
dataF.RR = data.RR(:, ifnd); 
dataF.TT = data.TT(:, ifnd); 


headersF.nrec = sum(ifnd);
headersF.baz = headers.baz(ifnd);
headersF.dist = headers.dist(ifnd);
headersF.slow = headers.slow(ifnd);
headersF.snrs = headers.snr(ifnd);
headersF.ptimes = headers.ptime(ifnd);

% --- sort by slowness to improve stacking  ... looks like bug here
distF = headersF.dist;
[distO, dist_order] = sort(distF);

dataO.ZZ = dataF.ZZ(:, dist_order); 
dataO.RR = dataF.RR(:, dist_order); 
dataO.TT = dataF.TT(:, dist_order); 


headersO.nrec = sum(ifnd);
headersO.baz = headersF.baz(dist_order);
headersO.dist = distO;
headersO.slow = headersF.slow(dist_order);
headersO.snrs = headersF.snrs(dist_order);
headersO.ptimes = headersF.ptimes(dist_order);

end
