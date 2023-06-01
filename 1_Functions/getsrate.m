function [repsrates, replentraces, numwaves] =  getsrate(headers)
% Author: Tolulope Olugboji
%-- code to scan for all legitimate sample rates...

% convert to the nearest milisecond
allsrates = floor( headers.srate .* 1e3 );
alldatalen = headers.lentrace;

mins = min(allsrates); maxs = max(allsrates);
sedge = mins:1:maxs+1;

[cnts, hedge] = histcounts(allsrates, sedge);
[cntss, ic ] = sort(cnts, 'descend');

indsrates = hedge(ic);


if length(indsrates) > 1
    repsrates = indsrates(1:2);  % top two samplre rates
    numwaves = cntss(1:2);       % number of waves with sample rates
    
    [ifnd1] = find(allsrates == repsrates(1));
    [ifnd2] = find(allsrates == repsrates(2));
    
    israte1 = allsrates == repsrates(1);
    israte2 = allsrates == repsrates(2);
    
    ifnd3 = ~(israte1 | israte2);
    
    
    
    alllent1 = alldatalen(ifnd1);
    alllent2 = headers.lentrace(ifnd2);
    
    alllent3 = headers.lentrace(ifnd3);
    
    
    replentraces = [ mode(alllent1), mode(alllent2)];  % length for each sample rate
    % use most common in
    % case of bad data
    % download
else
    repsrates = indsrates;
    numwaves = cntss;
    replentraces = mode(alldatalen);
    
end