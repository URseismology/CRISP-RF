function [ horRad, horTrans ] = rotateWaveforms( horN, horE, cmpazNE, BAZ)
%rotateWaveforms Summary of this function goes here
% use horizontal component azimuths and bazz value to rotate horizontals
% into ray coordinates R, T
% Authors: Vedran Lekic, Tolulope Olugboji - University of Maryland
%          Updated - Jan 17. 2015

% baz is earthquake back azimuth

degTol = 5; % sometimes orientations are just a few degrees off - ignore then

% check orthogonality or right handedness ...
if(abs(cosd( cmpazNE(2) - cmpazNE(1) ))>1e-6 || ...
        abs(sind(cmpazNE(2) - cmpazNE(1))-1)>1e-6)
    
        angNE = abs( cmpazNE(2) - cmpazNE(1) );
        isLessTolerance = (angNE <= degTol) || (mod(angNe,90) <= degTol);
        
        if isLessTolerance
            disp('Not orthogonal, but within tolerance of 5 deg')
        else
            error('Horizontal components are not orthogonal and right-handed - 5 deg Tolerance!')
        end
end

k = wrapTo360(BAZ+180-cmpazNE(1));

ROT = [cosd(k) sind(k); -sind(k) cosd(k)];


H = double(ROT*[horN; horE]);

horRad = H(1,:); horTrans = H(2,:);


end


