function [Kmask, qps_q] = KdiagMask(M, taus, qs, H, Vp, Vs, target)
% Author: Tolulope Olugboji
nn = 100;
hbot = linspace(20, 200, nn);
tps_umd = zeros(nn,1);
qps_umd = zeros(nn, 1);

for in = 1:nn
    H(end-1) = hbot(in);
    [q, tau] = get_q_t(H, Vp, Vs);

    tps_umd(in) = tau(target, 1);
    qps_umd(in) = q(target, 1);
end

qps_q = interp1(tps_umd, qps_umd, taus,"linear", "extrap");

[nq, nt] = size(M);
Kmask = ones(nq, nt);

for it = 1:nt
    
    qlq = qps_q(it) - 50; qlq(qlq<0) = 0;
    qhq = qps_q(it) + 50;

    ilwq = qs < (qlq);
    ihiq = qs > (qhq);

    
    Kmask(ilwq, it) = 0;
    Kmask(ihiq, it) = 0;

end

% % alternatively, simply mask all negative q
% Kmask(1:round(end/2), :) = 0;