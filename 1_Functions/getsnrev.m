function [timeSnr, snrCell] = getsnrev(FILEDIR, snr_thresh, netCode, staCode)
% Author: Tolulope Olugboji
% Get SNR event times for network, station, using snr threshold
% loads from file defined in FILEDIR or
% uses irisfetch mustang metric webservice. 

    twin = 30; %seconds from snr travel time based on iris documentation

    snr_str =  num2str(snr_thresh);

    %FILEDIR = '/Users/liammoser/Documents/MATLAB/Output/';
    fname = [FILEDIR, netCode '_' staCode '_thresh_' snr_str '.txt'];

    if ~isfile(fname)
        stations_info = irisFetch.Stations('channel',netCode, ...
            staCode,'*','BHZ'); % BHZ/HHZ !!!!!!!!!!!!!

        strTime = stations_info.StartDate;

        getSnr(FILEDIR, snr_thresh, netCode, staCode, strTime); % BHZ/HHZ !!!!!!!!!!!!!
    end
    
    %read in SNR file as a table
    tablecols = readtable(fname, 'Delimiter', ' ');

    % feed me the times from column named var3...
    timeCell = tablecols.Var3;
    snrCell = tablecols.SampleSNR;

    lt = length(timeCell);

    timeSnr = NaT(lt,1);
    for it = 2:length(timeCell)
        timeSnr(it) =  seconds(twin) + urstr2date(timeCell{it});
    end

end