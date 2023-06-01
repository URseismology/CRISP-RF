function [P, S, H] = psvrotate(Z, R, T, rayp, pvel, svel)
% see equation 3 of Upper Mantle Imaging with Array Recordings
% of Converted and Scattered Teleseismic Waves Stephane Rondenay

[nn, nwaves] = size(Z);
rotang = zeros(nwaves, 1);

P = zeros(nn, nwaves);
S = zeros(nn, nwaves);
H = zeros(nn, nwaves);

fs = 15;
fmin = 0.5; 
fmax = 1.5;


DT = 25e-3;
for iwave = 1:nwaves
    %iwave

    %phi_p = asind(pvel*rayp(iwave));
    %rotang(iwave) = phi_p;
    
    rp = rayp(iwave);
    qpvel = sqrt( (1/(pvel*pvel)) - (rp*rp)) ; % vertical p-wave slowness
    qsvel = sqrt( (1/(svel*svel)) - (rp*rp)) ; % vertical s-wave slowness

    rm11 = ( ((svel*rp)^2)  - 0.5) / (pvel*qpvel);
    rm12 = (rp*svel*svel) / pvel;
    rm21 = (rp*svel);
    rm22 = ( 0.5 -  ((svel*rp)^2) ) / (svel*qsvel);

    vpz = -(1 - (2 *(svel*rp)^2) )/ (2*pvel*qpvel);
    vsz =  rp*svel;
    vpr = (rp*svel^2) / pvel;
    vsr = (1 - (2 *(svel*rp)^2) )/ (2*svel*qpvel);




    %RM = [cosd(phi_p) sind(phi_p); -sind(phi_p) cosd(phi_p)];
    RM1 = [rm11 rm12; rm21 rm22];   % Bostock and Rondenay
    RM2 = [-vpz vpr; -vsz vsr];   % reading amd svemmomgsem. GRL 2004
    
    DZ = Z(:, iwave)';
    DR = R(:, iwave)';

    newD = RM2*[DZ; DR];

    P(:, iwave) = newD(1,:); S(:, iwave) = newD(2,:);
    H(:, iwave) = T(:, iwave);

end


end