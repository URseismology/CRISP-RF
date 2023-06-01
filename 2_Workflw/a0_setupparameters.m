%  Reference: 
%  Olugboji, Zhang, Carr (2023) 
%  On the Detection of Upper Mantle Discontinuities with Radon-Transformed Ps Receiver Functions (CRISP-RF)
%
%  Copyright (C) 2023, URSeismology lab
%  
%  Author: Tolulope Olugboji, Ziqi Zhang, Steve Carr
% 
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation, either version 3 of the License, or
%  any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details: http://www.gnu.org/licenses/
%

%% All functions and helper directiories
% localBaseDir = '/Users/evan/Documents/bluehive/';
localBaseDir = '/scratch/tolugboj_lab/';
FUNCDIR = [localBaseDir 'Prj4_Nomelt/seus_test/RFImager_EvansVersion/1_Functions/'];

addpath(FUNCDIR);

%% Data directories
% SACDIR = [localBaseDir 'Prj4_Nomelt/2_Data_Mar23/SAC/'];
% SACDIR = [localBaseDir 'Prj4_Nomelt/2_Data/SAC/'];
RFDIR  = [localBaseDir 'Prj4_Nomelt/2_Data_Mar23/MTCRF/'];

% SACDIR = [localBaseDir 'Prj4d_GlobalRadon/2_Data/SAC/'];
% RFDIR  = [localBaseDir 'Prj4d_GlobalRadon/2_Data/MTCRF/'];

% SACDIR = [localBaseDir 'Prj7_RadonT/2_Data/SAC/'];
SACDIR = [localBaseDir 'Prj7_RadonT/2_Data/Parallel_Download/SAC/'];
% RFDIR  = [localBaseDir 'Prj7_RadonT/2_Data/Parallel_Download/MTCRF/'];

%% Parameters for preprocessing
netname = 'CCP'; % single station
staname = 'Grid_2019'; % single station
isplot = 1;
rebuild = 1;
skipsave = 1;
checknan = 1;
beforeP = 2 * 60; % in second
afterP  = 5 * 60; % in second
sortby = 'epidist';
rotation = 0; % 0 - None, 1 - LQT, 2 - PSV, 3 - Both

%% Parameters for QC procedure
fband = [0.05 0];   % frequency bandwidth for computing SNR
bazrnge = [0, 360];
distrnge = [30, 90];
snrrnge = [2, 100];

%% Specify windows and shifting for moving window receiver function
Pwindow = 23; 
nsewin = 90; 
timedur = 120;
timeshft = 0;

%% Veloicty structure for LQT and PSH rotation
pvel = 7.5; svel = pvel / 1.7;

%% MTCRF parameters
from_b1 = 0;
% bin parameters
Fcut = 1.5; % 2 Hz maximum frequency limit of RF computation
binmin = 30;
binmax = 80;
bindelta = 1;
binwidth = 5;

binparams = [binmin, binmax, bindelta, binwidth];

% slepian taper parameters
P = 2.5;
K = 2;

%% Radon parameters

qmin = -3000;
qmax = 3000;
nq = 400;

fmin=0; fmax = 10;
mu = 50.0;
alpha = .01;
tstep = 0.5;
maxiter = 30;
kstop = 0;

H = [31 34 0];
Vp = [6.4 8.1 8.0];
Vs = [3.85 4.5 4.3];
vmodel = [H; Vp; Vs];

migration = 0;

twin = [0 20];
qwin = [-400 400];

