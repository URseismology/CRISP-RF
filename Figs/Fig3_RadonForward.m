% ---------------------------------------------------------------------
% Copyright 2023 Tolulope Olugboji (Dr O)
% Please cite as: 
% Tolulope Olugboji, Ziqi Zhang, Steve Carr, Canberk Ekmekci, Mujdat Cetin, 
% On the Detection of Upper Mantle Discontinuities with Radon-Transformed 
% Ps Receiver Functions (CRISP-RF), Geophysical Journal 
% International, 2023;, ggad447, https://doi.org/10.1093/gji/ggad447
%
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to
% the following conditions:
%
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% --------------------------------------------------------------------


addpath('/scratch/tolugboj_lab/Prj4_Nomelt/seus_test/RFImager_EvansVersion/1_Functions')
localBaseDir = '/scratch/tolugboj_lab/';
%localBaseDir = '/Users/stevecarr/Documents/bluehive/';
workDir = [localBaseDir 'Prj7_RadonT/Prj2_SEUS_RF/0_startHere/'];
addpath([localBaseDir 'Prj7_RadonT/0_RFImager_Upload/1_Functions/1_RFCodes/1_MTC/']);
addpath([workDir 'Radon_codes/radon_transforms/']);
addpath(genpath([workDir 'Radon_codes/crewes/']));
addpath([workDir 'Radon_codes/CgMethod/']);
addpath([workDir 'Radon_codes/CgMethod/Methods/']);
addpath([workDir 'Radon_codes/']);
DOTM = [localBaseDir 'softwares/DOTM/']; 

%addpath(DOTM);
rmpath([localBaseDir '/softwares/DOTM/'])
%% define radon synthesis panel
clc; clf; 

rayP = linspace(0,0.08,20); % #  of events
% intercept time resolution -
dt=.02;           %time sample size -- data receiver functions
nt = 2450;        % number of taus
taus = (0:1:nt-1)*dt; %generate taus scaled by the sample time
tlen = ceil(taus(end));

% travel time curvature resolution
absq = 1000;
qmin = -absq;
qmax = absq;                % Radon function parameters
nq = 200;
dq = (qmax-qmin)/(nq-1);  %value increament of qs
qs = qmin+dq*[0:1:nq-1];   % generate all q values from qmin to qmax

nlayers = 3;  % each layer generates 3 phases
nPhases = 3;  % each phase: Ps, and 2 crustal multiples

%set velocity model
H  = [24 14 82 0]; %35 used to be 52
Vp = [6.22 6.54 8.20 8.20];
Vs = [3.57 3.76 4.60 4.14];
rho = [2.600 2.600 2.900 3.300];

[q, ~, tau] = get_q_m_t(H, Vp, Vs, rho);

m=[0.31 0.50 -0.34;1 0.58 -0.19;-0.58 0.122 -0.122]; % radon amplitude for each phase
m = m ./max(abs(m), [], 'all') ;

%-- frequency and wavelets
fmin = 0;
fmax = 1/(2*dt); 
fdom = 2; %dominant frequency
fbw = 5 ;  % bandwidth of 1 Hz

%--Generating Ricker Wave
[wr,twr]=ricker(dt,fdom,2*tlen);  % this generates a ricker wave with a defined dominant frequency

[gwr,gtwr]=gauswvlet(dt,fbw,2*tlen);  % this generates a gausssian wave with a defined dominant frequency

% --Creating Radon doamin
Min = zeros(nq, nt); %initialize Min (radon domain) 

for ilyr = 1:nlayers
    for jphs = 1: nPhases
                        
        %rickwvlt = abs(m(ilyr,jphs)).*stat(wr,twr,tau(ilyr, jphs)); %shift pulses in time. A sample at time t on input will be at t+delt on output
        rickwvlt = abs(m(ilyr,jphs)).*stat(gwr,gtwr,tau(ilyr, jphs)); %shift pulses in time. A sample at time t on input will be at t+delt on output

    if m(ilyr, jphs) < 0 
            rickwvlt = phsrot(rickwvlt, 180); % rotate this ricker wavelet to negative phase
    end
    indq = find(qs> q(ilyr, jphs), 1);
        
%     [q(ilyr, jphs), tau(ilyr, jphs), m(ilyr, jphs)]

    Min(indq-1, :) = rickwvlt(end-nt+1:end);
    Min(indq, :) = rickwvlt(end-nt+1:end);
    Min(indq+1, :) = rickwvlt(end-nt+1:end);
        
    end
end

mm = max(abs(Min), [], 'all'); Min = Min ./ mm;
%%
N=2;
[tx] = forward_radon_freq_umd(Min',dt,rayP,qs,N,fmin,fmax);
tx = tx';
[dx, dy] = size(tx); 

%%
%Filter Radon domain
qcut = qs<0;
Min_filt = Min;
Min_filt(qcut,:)=0;

[tx_filt] = forward_radon_freq_umd(Min_filt',dt,rayP,qs,N,fmin,fmax);

%%
hh = figure(1);
clf
subplot(5,6,[1:6:13,3:6:15])
imagesc(taus, qs, Min); colormap(seismic(3))
caxis([-.1 .1])
xlim([0 25])
ylim([-220 250]) 
ylabel('curvature, q (s/km)^2', 'FontSize',20)
% xlabel('intercept time, \tau (sec)', 'Fontsize', 20);
% set(gca,'xticklabel', '')
cb=colorbar;
cb.Location="northoutside";
set(gca,"YDir",'normal')
yline(0, 'linewidth', 2)
title('Radon: m (\tau , q)', 'Fontsize', 20)

grid on

subplot(5,6,[4:6:10,6:6:12])
plot_data(tx,taus,rayP,0)
title('d (t , p): $\mathbf{m}  \mathbf{d}$', 'interpreter', 'latex', 'Fontsize', 20)
ylabel('Slowness(p)','FontSize', 20)
set(gca,'YAxisLocation','right')
% xlabel('Time (s)','FontSize', 20) 
%daspect([1 1 .6])

subplot(5,6,[22:6:28,24:6:30])
plot_data(tx_filt',taus,rayP,0)
title('d (t , p): $\mathbf{m}  \mathbf{d}$', 'interpreter', 'latex', 'Fontsize', 20)
ylabel('Slowness(p)','FontSize', 20)
set(gca,'YAxisLocation','right')

subplot(5,6,[19:21])
stacks(tx,taus,rayP'); grid on
text(15, 0.5, '$\Sigma \mathbf{d}$', 'interpreter', 'latex',  'Fontsize', 20 )

subplot(5,6,[25:27])
stacks(tx_filt',taus,rayP')
xlabel('Time (s)','FontSize', 20) ; grid on
text(15, 0.5, '$\Sigma \mathbf{ \hat{d}}$', 'interpreter', 'latex',  'Fontsize', 20 )
set(gca,'XAxisLocation','bottom')

yy = figure(2);
stacks(tx_filt',taus,rayP')
xlabel('Time (s)','FontSize', 20) ; grid on
set(gca,'XAxisLocation','bottom')
