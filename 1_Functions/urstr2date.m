function [tdate] = urstr2date(tstring)
%urstr2date converts date strings from IRIS to the usable datetime format.
%   Input a date string in the format IRIS uses and the output will be in
%   the datetime format.
if tstring(5)=='-'
    tdate=datetime(tstring,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
else
    tdate=datetime(tstring,'InputFormat','yyyy/MM/dd HH:mm:ss');
end

