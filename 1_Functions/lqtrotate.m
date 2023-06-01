function [L, Q, T] = lqtrotate(Z, R, T, rayp, pvel)

[nn, nwaves] = size(Z);
rotang = zeros(nwaves, 1);

L = zeros(nn, nwaves);
Q = zeros(nn, nwaves);

fs = 15;
fmin = 0.5; 
fmax = 1.5;


DT = 25e-3;
for iwave = 1:nwaves


    phi_p = asind(pvel*rayp(iwave));
    rotang(iwave) = phi_p;

    RM = [cosd(phi_p) sind(phi_p); -sind(phi_p) cosd(phi_p)];
    DZ = Z(:, iwave)';
    DR = R(:, iwave)';

    newD = RM*[DZ; DR];

    L(:, iwave) = newD(1,:); Q(:, iwave) = newD(2,:);


end


end

