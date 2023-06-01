
function [EQmeta] = matchEvents(eqStruct, timesSnr, stlas, stlos, tolerance)
%Authors: Liam Moser and Trey Brink
%Adds TauP travel times to the earthquake starts times and compares this
%value to event time of desired SNR events. If they match them the
%earthquake data is returned.
%Input: Takes in a structure holding all earthquake information, start
%times of our SNR events
%Output: EQmeta stucture contains all needed variables for getSAC function

%Structure to fill with matched earthquakes and TauP output
EQmeta = struct('Time', 1 , 'evBaz', 1 , 'evDistDeg', 1 , 'evMg' , 1, 'evDp' , ...
    1 , 'evLat' , 1 , 'evLon' , 1 , 'phsNme' , 1 , 'evPslow' , 1);

%How many earthquakes occurred during station operatio time frame
totEv = length(eqStruct);

%an index for EQmeta
match = 0;

arrivalT = NaT(totEv,1);
%allTaup = struct([]);

%Look through all events that occured during time frame and extract
%event depth, lat, lon
for iEv = 1:totEv
    
    evDepth = eqStruct(iEv).PreferredDepth; %Earthquakwe depth
    evLat = eqStruct(iEv).PreferredLatitude; %Earthquake latitude
    evLon = eqStruct(iEv).PreferredLongitude; %Eathquake longitude
    
    %Catch to see if evDepth is bad
    if evDepth < 0
        evDepth = 0;
    end
    
    %TauP model for wave travel times
    taupOutput = Matlab_TauP('Time',  'ak135', evDepth, {'P', 'PKP', 'Pdiff'}, 'evt', [evLat, evLon], ...
        'sta', [stlas, stlos]);
    
    eqTime = eqStruct(iEv).PreferredTime; 
    eqTimeM = urstr2date(eqTime); % 'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
    tTimeP = taupOutput(1).time;
    %arrivalT is when we anticipate the station detecting the Eq
    arrivalT(iEv) = eqTimeM + seconds(tTimeP); 
    
    %This stores all TauP output, selects second (PKP) if more than two
    %predicted arrivals
    if length(taupOutput) > 1
        allTaup(iEv) = taupOutput(2);
    else
        allTaup(iEv) = taupOutput(1);
    end

    % Calculate S arrival
    taupOutputS = Matlab_TauP('Time',  'ak135', evDepth, {'S', 'Sdiff'}, 'evt', [evLat, evLon], ...
        'sta', [stlas, stlos]);
    if length(taupOutputS) > 1
        allTaupS(iEv) = taupOutputS(2);
    else
        allTaupS(iEv) = taupOutputS(1);
    end
    
end

%Sort ArrivalT by time
[arrivalT, ind] = sort(arrivalT, 'ascend');
allTaup_s = allTaup(ind); %Sort data
allTaupS_s = allTaupS(ind); %Sort data for S
eqStruct_s  = eqStruct(ind); %Sort data

%Sort time SNR by date
[timesSnr, ~] = sort(timesSnr, 'ascend');

%This loop checks from matches 
for iSnr = 1:length(timesSnr)
    
    %Indetifes the arrivalT that is minimized when removing a single SNR
    %event time
    candT = abs(arrivalT- timesSnr(iSnr));
    iFnd = find(candT <= seconds(tolerance), 1);
    
    %If the match occurs then we store all the data of the event so we can
    %retruve the save file..
    if length(iFnd) == 1
        
        match = match + 1;
        
        %Data coming from TauP
        EQmeta(match).evBaz = wrapTo360(allTaup_s( iFnd).bAzimuth);
        EQmeta(match).phsNme = allTaup_s( iFnd).phaseName;

        % two new fields for S
        EQmeta(match).phsNmeS = allTaupS_s( iFnd).phaseName;
        EQmeta(match).phsArrS = allTaupS_s( iFnd).time - allTaup_s(iFnd).time; % with respect to P (!! possibly Pdiff/PKP - revise later !!)

        EQmeta(match).evPslow = allTaup_s( iFnd).rayParam;
        EQmeta(match).evDistDeg = allTaup_s( iFnd).distance;
        
        %Data coming from eqStruct
        EQmeta(match).Time = arrivalT( iFnd);
        EQmeta(match).evMg = eqStruct_s( iFnd).PreferredMagnitudeValue;
        EQmeta(match).evDp = eqStruct_s( iFnd).PreferredDepth;
        EQmeta(match).evLat = eqStruct_s( iFnd).PreferredLatitude;
        EQmeta(match).evLon = eqStruct_s( iFnd).PreferredLongitude;
    end
    
end

%Show number of matches
noMatch = totEv - match;
fprintf('Match: %d, Not match: %d\n', match, noMatch);

end