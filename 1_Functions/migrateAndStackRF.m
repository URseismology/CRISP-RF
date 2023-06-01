function [stackRF, RF] = migrateAndStackRF(RF, tt, p, H, Vp, Vs, target)
% Usage: [stackRF, RF] = migrateAndStackRF(RF, tt, p, H, Vp, Vs, target)
%
% Author: Ziqi Zhang
% Migrate each RF trace according to its ray parameter and the target
% phase. Then stack all RFs to get a stacked trace that emphasize the
% target phase.
%
% Input: RF (each row is a trace) matrix and tt (time) vector; p (ray
% parameter vector); H, Vp, Vs (velocity model); target (targeting
% interface counting from top)

[all_q, ~] = get_q_t(H, Vp, Vs);
q = all_q(target, 1); % q value for the 3rd interface direct Ps conversion

tShift = q * p .^ 2; % time shift w.r.t. p = 0

for itr = 1:size(RF, 1)
    
    RF(itr,:) = stat(RF(itr,:), tt, -tShift(itr));
    
end

stackRF = mean(RF, 1);
stackRF = stackRF / max(abs(stackRF));