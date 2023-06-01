function [q, tau] = get_q_t(H, Vp, Vs)
% function [q, tau] = get_q_t(H, Vp, Vs)
%
% Author: Ziqi Zhang
%
% Input: H (Thickness), Vp, Vs as row vectors.
%
% Both outputs (q and tau) are n (interface) by 3 (phase) matrices.
% E.g., tau[i, j] is intercept time for ith interface (from the top) and
% jth phase (1 - Ps, 2 - Pps, 3 - Pss).

%% Parameter setup

% preset model parameters for test
% H  = [24 14 52 80 0];
% Vp = [6.22 6.54 8.20 8.20 8.5];
% Vs = [3.57 3.76 4.60 4.14 4.6];

% rayP for q & tau calculation - no need to change
% rayP must start at 0 to calculated intercept
rayP = (0:0.01:0.08);

%% Calculate q & tau
nlyrs = length(H) - 1;

q   = zeros(3, nlyrs);
tau = zeros(3, nlyrs);

tPs  = zeros(length(rayP), 3);
tPps = zeros(length(rayP), 3);
tPss = zeros(length(rayP), 3);

for i = 1 : nlyrs % for 3 interfaces
    
    [tPs(:, i), tPps(:, i), tPss(:, i)] = travelTimesAppx(Vp, Vs, H, rayP, i, 1);
    
end

for i = 1 : nlyrs % for 3 interfaces
    
    fit_param = polyfit(rayP', tPs(:, i)  - tPs(1, i),  2);
    q(1, i) = fit_param(1);
    fit_param = polyfit(rayP', tPps(:, i) - tPps(1, i), 2);
    q(2, i) = fit_param(1);
    fit_param = polyfit(rayP', tPss(:, i) - tPss(1, i), 2);
    q(3, i) = fit_param(1);
    
    for j = 1 : 3 % for 3 phases
        
        switch j
            case 1
                tau(j, i) = tPs(1, i);
            case 2
                tau(j, i) = tPps(1, i);
            case 3
                tau(j, i) = tPss(1, i);
        end
        
    end
    
end

tau = tau'; q = q';