function [eqStruct] = getEqData(magMax, magMin, degMax, degMin, staStart, staEnd, stlas, stlos, catalog)
%% getEqData
%Authors: Liam Moser and Trey Brink
%Gets all earthquake that were recorded by IRIS between a specified 2-D
%annulus (e.g 30-100 deg from stations), magnitude range, and timeframe.
%Input: maximum and minimum earthquake magnitudes desired, radii of circles
%that define desired ring of earthquake locations, station start and end
%times, and station latitude and longitude.
%Output: n x m matrix where m = # of event and each row is a metric/value
%retrived from IRIS...TO BE EXPLAINED

%% - Body of function
%Convert magnitude values into string
degMax = num2str(degMax);
degMin = num2str(degMin);


eqStruct = irisFetch.Events('startTime',staStart,'endTime',staEnd,...
    'MinimumMagnitude',magMin,'maximumMagnitude',magMax, ...
    'lat', stlas, 'lon', stlos,'minradius', degMin, ...
    'maxradius', degMax, 'catalog', catalog);

%'ISC' 'NEIC%20PDE'