function [Mk, mk] = shrink_tdsrt(mkm1, dmkm1, kstep, Ktot, alpha, stepsz, nfft)
%shrink radon model before updating ...
% Author: Tolulope Olugboji

[nt, nq] = size(mkm1);
mk = zeros(nt, nq);

scale = alpha * ( (Ktot - kstep) / Ktot);


% for iq= 1:nq
%     
%    mup = mkm1(:, iq) + (2*stepsz)*dmkm1(:,iq);
%    mtil = abs(mup); pol = sign(mup);
%    
%    Talp = mtil - scale*mtil;    % no 2d averaging... revisit
%    Talp(Talp <0) = 0;           % force positivity -- shrinkage step?
%    Talp = Talp .* pol;
%    
%    mk(:,iq) = Talp;
%      
% end

mup = mkm1 + (2*stepsz)*dmkm1;

%mtil = abs(mup); pol = sign(mup);
%Talp = mtil - scale*mtil;    % no 2d averaging... revisit

pol = sign(mup);
mabs = abs(mup);

m1 = max(mabs, [], 'all');
m2 = max(mup, [], 'all');

%mtil = mup.*( m1/ m2);
mtil = ones(size(mup)) .* (m1/m2);

Talp = mabs - scale.*mtil;

Talp(Talp <0) = 0;           % force positivity -- shrinkage step?
Talp = Talp .* pol;

mk = Talp;


 %nfft = 2*(2^nextpow2(nt));
 Mk = fft(mk,nfft,1);           % return fourier coefficients..


return