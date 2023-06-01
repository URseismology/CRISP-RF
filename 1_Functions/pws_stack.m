function stackRF = pws_stack(RF1, RF2)
%
% stackRF = pws_stack(RF1, RF2)
%
% Authors: Steve Carr, Ziqi Zhang
%
% Using coherence information in RF1 to perform phase-weighted stack on
% RF2. If RF2 is empty ([]), will perform PWS on RF1 instead.

% load data for testing
% data=load("pws_test.mat");
% d = data.rawRF_migrated;
% dhat = data.filteredRF_migrated;


if isempty(RF2)
    RF2 = RF1;
end

% Section for phase weighted stack
n_params = size(RF1, 1);
p = 3;

% Compute the average trace as the reference signal
mean_stack = mean(RF1, 1);
mean_stack = mean_stack./max(mean_stack);

c_phase = zeros(n_params, length(mean_stack));

% Loop over all the ray parameters
for ii = 1:n_params
    % Compute the complex trace of the current parameter
    complex_trace = hilbert(RF1(ii, :));
    
    % Compute the instantaneous phase of the complex trace
    phase = angle(complex_trace);

    c_phase(ii, :) = exp(1i * phase); % complex Instantaneous phase for every rf trace
          
end

% Compute phase weights (coherency).
phase_wts = abs(mean(c_phase, 1)).^p; % Equation 2 in Schimmel and Paulssen (1997) coherency measure is independent of the amplitude

% Apply phase weighting to data
wtdata = RF2 .* phase_wts; % Apply the absolute value only to the phase weights
%wtdata = data .* (phase_wts); % 

% Stack data
stackRF = mean(wtdata);
stackRF = stackRF / max(abs(stackRF));