function [Manifest, totRec, nRot, erMsgRotSAC] = rotSAC(WVFRMDIR, ntwrk, stNm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Tolulope Olugboji
% rotSAC
% This code rotates all ZNE files in WVFRMDIR to ZRT

useROTSAVE = 1;

sacFl_Z = dir([WVFRMDIR ntwrk '/' stNm '/*BHZ*']);
totRec = length(sacFl_Z);

Manifest = {''};

nRot = 0;
for iRec = 1:totRec
    nmSplit = strsplit(sacFl_Z(iRec).name, 'BHZ');
    nmApp = nmSplit{1};
    
    fDir = [WVFRMDIR ntwrk '/' stNm '/' nmApp];
    
  
    try
        
        [~, ~, ~, ~, ~, ~] = ...
            loadsac3cRotSave(fDir, useROTSAVE); % BHZ/HHZ!!!!!!!!!!!!!!!!!
        nRot = nRot + 1;
        Manifest{nRot} = fDir;
        erMsgRotSAC = 'nothing';
        
    catch error
        erMsgRotSAC = error.message;
    end
    
end


end