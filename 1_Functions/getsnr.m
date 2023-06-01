function getSnr(FILEDIR, snr_thresh, netCode, staCode, strTime)
% Authors: Trey Brink and Liam Moser
% Gets the text data (when the snr_thresh was exceeded) given the signal to noise ratio threshold,
% NET code, station code, start time, and end time. 
% Inputs: File directory, snr threshold value, network code, station code,
% and station start time.

%% Puts information into IRIS query format
str_snr = num2str(snr_thresh);
timesplit = strsplit(strTime);
frmtTime_str = [ timesplit{1} 'T' timesplit{2} ];

% change datetime to char array
endTime = char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss.SSS'));

% Declaring we want the SNR metric
defMetric = 'sample_snr';

% csv format
format = 'csv';



% Formatting start time, end time, and snr threshold.
timeWD=[frmtTime_str ',' endTime '&value_gt=' str_snr ];

%% build the mustang query for this station and calls it...
%   url2=strcat('http://service.iris.edu/mustang/measurements/1/query?', ...
%       'metric=', defMetric, '&', ...
%       'net=', netCode, '&sta=', staCode, '&loc=*&chan=BHZ&', ...
%       'format=', format, '&timewindow=', timeWD)
%   options=weboptions('ContentType','table', 'Timeout', 2147);
%   textData=webread(url2,options);
%   whos textData
%     SAVEMETRICFILE = strcat(FILEDIR, netCode{1}, '_', staCode{1}, 'thresh=', str_snr, '.txt');
%   
%     if ~isempty(textData)
%       %textData=webread(url2)
%       disp(['Saved... ' netCode ' : ' staCode ' : thresh=' str_snr ]);
%       writetable(textData, SAVEMETRICFILE,'Delimiter',' ');
%     else
%       disp(['No Metric for...' netCode ' : ' staCode ' : thresh=' str_snr  ]);
%     end
  
url2 = ['http://service.iris.edu/mustang/measurements/1/query?' ...
  'metric=' defMetric '&' ...
  'net=' netCode '&sta=' staCode '&loc=*&chan=BHZ&' ...
  'format=' format '&timewindow=' timeWD];
options = weboptions('ContentType','table', 'Timeout', 2147);
textData = webread(url2, options);

SAVEMETRICFILE = [FILEDIR netCode '_' staCode '_thresh_' str_snr '.txt'];

% Displays whether a file was saved or not
if ~isempty(textData)
  writetable(textData, SAVEMETRICFILE,'Delimiter',' ');
  disp(['Saved... ' netCode ' : ' staCode ' : thresh=' str_snr ]);
else
  disp(['No Metric for...' netCode ' : ' staCode ' : thresh=' str_snr  ]);
end