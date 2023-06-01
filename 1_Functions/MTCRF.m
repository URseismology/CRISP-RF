function [time, binvals,radRF,transRF, varR, varT] = ...
    MTCRF(RR,TT,ZZ, NN, Dt, Fcut, binparams, dist,rayp, isplot)
% Author: Tolulope Olugboji
% define stack parameters from input

binmin = binparams(1);
binmax = binparams(2);
bindelta = binparams(3);

hdist = histogram(dist, 'BinMethod', 'sqrt');

stackparams.binedge = binmin:bindelta:binmax;
stackparams.nbins = length(stackparams.binedge)-1;
stackparams.deltabin = binparams(4);

stackparams.bincnt = hdist.Values;
stackparams.binlims = hdist.BinLimits;
stackparams.distvals = hdist.Data;

% define ray parameter (x) and epicentral distance (y) column vectors for
% the stacked receiver functions

x = dist;
if isrow(x)
    x = x';
end

y = rayp;
if isrow(y)
    y = y';
end

% find unique values of ray parameter (x) and corresponding epicentral
% distance (y), then define the ray parameter bin and corresponding
% epicentral distance bin using inter(extra)polation

[xu, iu, ~] = unique(x);
yu = y(iu);

xbin = stackparams.binedge(1:stackparams.nbins);
ybin = interp1(xu, yu, xbin, 'linear', 'extrap');
binvals = [xbin; ybin]';

[N, nwaves] = size(RR);

% initialize output matrices for RF and variance

radRF = zeros(N, nwaves);
transRF = zeros(N, nwaves);
varR = zeros(N, nwaves);
varT = zeros(N, nwaves);


% pre-define slepian taper
P = 2.5;
K = 2;

[PSI,~] = sleptap(N,P,K);

for iwave = 1: nwaves
    
    R = RR(:, iwave);
    T = TT(:, iwave);
    Z = ZZ(:, iwave);
    dnoi = NN(:, iwave);
    
    
    [~, radRF(:, iwave), transRF(:,iwave), varR(:, iwave), varT(:,iwave)] = ...
        MTCRF_se(R, T, Z, dnoi, PSI, K, Dt, Fcut);
    
end

% -- stack
%[radRFstck, transRFstck] = stackRFs(radRF, transRF, varR, varT, stackparams);
[radRFstck, transRFstck] = stackwithovlpRFs(radRF, transRF, varR, varT, stackparams);

[ntime, nbins] = size(radRFstck);

% time domain receiver functions after stackign
radRF = zeros(ntime, nbins);
transRF = zeros(ntime, nbins);


% -- transform to time
fmax = 1/(2.0*Dt);
Df = fmax/(N/2);
f = Df*[0:N/2,-N/2+1:-1]';
Nf = N/2+1;

for ibin = 1: nbins
    
    HRin = radRFstck(:, ibin);
    HTin = transRFstck(:, ibin);
    
    [HR, ~] = costaper(HRin, Fcut, Dt);
    [HT, taper] = costaper(HTin, Fcut, Dt);
    
    
    radRF(:, ibin) = (2*fmax/Fcut) .* fftshift(real(ifft(HR)));  % -tlag to +tlag in time
    transRF(:, ibin) = (2*fmax/Fcut) .* fftshift(real(ifft(HT)));
    
    %mr = max(abs(fftshift( real( ifft(HR) ) )), [], 'all');
    %mt = max(abs(fftshift(real(ifft(HT)))), [], 'all');
    
    %radRF(:, ibin) = (1 ./ mr ) .* fftshift(real(ifft(HR)));  % -tlag to +tlag in time
    %transRF(:, ibin) = (1 ./ mt) .* fftshift(real(ifft(HT)));
    
end

time = [0:N-1]-floor(N/2); time = time * Dt;



if isplot
    %%
    y = 1:nwaves;
    
    figure(12)
    subplot(131)
    imagesc(timetrace, y, ZZ)
    
    subplot(132)
    imagesc(timetrace, y, RR)
    
    subplot(132)
    imagesc(timetrace, y, TT)
    
    
    
    % compute psd
    
    %jLab
    
    %n2 = length(dsig);
    %P = 2.5;
    %K = 3;
    %[PSI,~] = sleptap(n2,P,K);
    %[~,s2sig] = mspec(dsig,PSI,'detrend');
    %[~,s2noi] = mspec(dnoi,PSI,'detrend');
    
    
    % Visualize
    %figure(1);
    %set(gcf,'Position',[100,100,1200,1000]);
    %clf;
    %figure(1);
    %set(gcf,'Position',[100,100,1200,1000]);
    %clf;
    
    figure(1); %clf
    
    subplot(3,2,2*ic-1,'Xscale','linear','Yscale','log');
    
    set(gca,'LineWidth',2);
    hold on;
    
    loglog(f(2:Nf),s2noi(2:Nf),'k:','DisplayName','Noise');
    hold on;
    
    loglog(f(2:Nf),s2sig(2:Nf),'k-','DisplayName','P Signal');
    hold on;
    
    yt = get(gca, 'YTick');
    ytkvct = 10.^linspace(1, 10*size(yt,2), 10*size(yt,2));
    set(gca, 'YTick', ytkvct);
    set(gca, 'YMinorTick','off')
    
    legend('fontsize',16);
    
    xlim([0.0 1.4]);
    
    if ic == 3
        
        xlabel('Frequenct (Hz)');
        
    end
    
    title(strcat('PSD of',{' '},cmp(ic),' Component'),'FontSize',18);
    
    subplot(3,2,2);
    
    set(gca,'LineWidth',2);
    hold on;
    
    loglog(f(2:Nf),s2sig(2:Nf),style(ic),'DisplayName',cmp(ic));
    hold on;
    legend;
    
    xlim([0.0 1.4]);
    
    title('P Spectrum','FontSize',18);
    %tsig = t;
    
end
end