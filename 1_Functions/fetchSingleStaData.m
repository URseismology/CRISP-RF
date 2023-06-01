function [stlas, stlos, netCodes, staCodes, staStart, staEnd, staStatus] = fetchSingleStaData(network, station)
%Author: Liam Moser
%Input: network, station as character array
%Output: station meta data

stations_info = irisFetch.Stations('channel', network, station, '*',...
    'BHZ'); %network, station, all location codes, channel

% stlos=zeros(length(stations_info),1); 
% stlas=zeros(length(stations_info),1);

for staI = 1:length(stations_info) %To account for multiple location codes
    stlas(staI) = stations_info(staI).Latitude;
    stlos(staI) = stations_info(staI).Longitude;
    netCodes{staI} = stations_info(staI).NetworkCode;
    staCodes{staI} = stations_info(staI).StationCode;
    staStart{staI} = stations_info(staI).StartDate;
    staEnd{staI} =stations_info(staI).EndDate;
    staStatus{staI} = stations_info(staI).RestrictedStatus;
end