% visually check pre-processed data: waveform, spectoram, Z-R coherence

% load in data from mat structure
if ~exist('dataAllComp', 'var')
    try
        maindir = [SACDIR netname '/' staname '/'];
        load([maindir netname '_' staname '_allComp.mat']);
    catch
        disp([netname '_' staname '_allComp.mat does not exist!']);
        disp('Run a1_preprocess first!')
        return;
    end
end

R = dataAllComp.R;
T = dataAllComp.T;
Z = dataAllComp.Z;
N = dataAllComp.N;
tt = dataAllComp.tt;
Dt = tt(2) - tt(1);
fs = round(1 / Dt);

len = size(R, 1);
P = 2;
K = 2*P-1;
[PSI, ~] = sleptap(len, P, K);

for it = 1:size(R, 2)

    ymax = max([max(abs(R(:,it)), [], 'all'), max(abs(T(:,it)), [], 'all'),...
        max(abs(Z(:,it)), [], 'all'), max(abs(N(:,it)), [], 'all')]);

    figure(1);
    clf;

    subplot(5,2,1);
    plot(tt, R(:,it));
    xlim([min(tt) max(tt)]);
    ylim([-ymax ymax]);
    xline(Pwindow);
    title('R Waveform');

    subplot(5,2,3);
    [~, f, t, p] = spectrogram(R(:,it), 80, 40, 80, fs, 'yaxis');
    imagesc(t, f, 10*log10(p));
    axis xy;
    ylim([0 5]);
    xlim([min(tt) max(tt)]);
    caxis([0 50]);
    title('R Spectrogram');

    subplot(5,2,2);
    plot(tt, T(:,it));
    xlim([min(tt) max(tt)]);
    ylim([-ymax ymax]);
    xline(Pwindow);
    title('T Waveform');

    subplot(5,2,4);
    [~, f, t, p] = spectrogram(T(:,it), 80, 40, 80, fs, 'yaxis');
    imagesc(t, f, 10*log10(p));
    axis xy;
    ylim([0 5]);
    xlim([min(tt) max(tt)]);
    caxis([0 50]);
    title('T Spectrogram');

    subplot(5,2,5);
    plot(tt, Z(:,it));
    ylim([-ymax ymax]);
    xlim([min(tt) max(tt)]);
    xline(Pwindow);
    title('Z Waveform');

    subplot(5,2,7);
    [~, f, t, p] = spectrogram(Z(:,it), 80, 40, 80, fs, 'yaxis');
    imagesc(t, f, 10*log10(p));
    axis xy;
    ylim([0 5]);
    xlim([min(tt) max(tt)]);
    caxis([0 50]);
    title('Z Spectrogram');

    subplot(5,2,6);
    plot(tt, N(:,it));
    xlim([min(tt) max(tt)]);
    ylim([-ymax ymax]);
    title('N Waveform');

    subplot(5,2,8);
    [~, f, t, p] = spectrogram(N(:,it), 80, 40, 80, fs, 'yaxis');
    imagesc(t, f, 10*log10(p));
    axis xy;
    ylim([0 5]);
    xlim([min(tt) max(tt)]);
    caxis([0 50]);
    title('N Spectrogram');

    subplot(5,2,9:10);
    [F,SXX,SYY,SXY] = mspec(Dt, Z(:,it), R(:,it) ,PSI);
    coher = (abs(SXY) ./ (sqrt(SXX) .* sqrt(SYY) )).^2;
    plot(F / (2 * pi), abs(coher), 'k-');
    xlabel('Frequency (Hz)');
    xlim([0 5]);
    title('Z-R Coherence');

    sgtitle([netname '.' staname ' Waveform ' num2str(it)]);

    pause;

end

