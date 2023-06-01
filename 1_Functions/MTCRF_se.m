function [time, radRF, transRF, varR, varT] = ...
    MTCRF_se(R, T, Z, dnoi, PSI, K, Dt, fc)

% Author: Tolulope Olugboji

isplot = 0; isFreq = 1;

N    = length(Z);

% Initialize MTC RF matrices
SZT = repmat(complex(0), N, 1);
SZR = repmat(complex(0), N, 1);
SZZ = repmat(complex(0), N,1);
SRR = repmat(complex(0), N,1);
STT = repmat(complex(0), N,1);
So = repmat(complex(0), N, 1);

for k = 1: K
    
    w = PSI(:,k); % k-th slepian taper
    Dat = w .* [Z, R, T, dnoi];
    fDat = fft(Dat);
    
    % k-th multi-taper spectrum estimates
    YZ = fDat(:,1);
    YR = fDat(:,2);
    YT = fDat(:,3);
    So = fDat(:,4);  
    
    % cross-spectrum between components
    SZR = SZR + ( conj(YZ) .* YR );
    SZT = SZT + ( conj(YZ) .* YT );
    SZZ = SZZ + ( conj(YZ) .* YZ );
    SRR = SRR + ( conj(YR) .* YR );
    STT = STT + ( conj(YT) .* YT );
    
end

% frequency domain RFs
HR = SZR ./ (SZZ + So);
HT = SZT ./ (SZZ + So);

% Coherence estimates
CR = abs(SZR) ./ (sqrt(SZZ) .* sqrt(SRR) );
CT = abs(SZT) ./ (sqrt(SZZ) .* sqrt(STT) );



% low pass the spectrum by a cosine-squared function
if ~isFreq
    
    %fc = 2;
    [HR, ~] = costaper(HR, fc, Dt);
    [HT, ~] = costaper(HT, fc, Dt);

end

varR = ((1 - CR.^2) ./ ( (K-1) .*  (CR.^2))) .* (abs(HR).^2) ;
varT = ((1 - CT.^2) ./ ( (K-1) .*  (CT.^2))) .* (abs(HT).^2) ;


% only inverse fourier if computing single event-- otherwise stack before
% running routine below
if ~isFreq
    t = Dt*[0:N-1]';
    tmax = Dt*(N-1);
    fmax = 1/(2.0*Dt);
    Df = fmax/(N/2);
    f = Df*[0:N/2,-N/2+1:-1]';
    Nf = N/2+1;

    radRF = (2*fmax/fc) .* fftshift(real(ifft(HR)));  % -tlag to +tlag in time
    transRF = (2*fmax/fc) .* fftshift(real(ifft(HT)));
    time = [0:N-1]-floor(N/2); time = time * Dt;

    if isplot

        figure(10)
        set(gcf,'Position',[100,100,1200,1000]);
        clf

        subplot(2,1,1)
        plot(time,radRF);
        xlim([-6 12]);
        %set(gca,'XTickLabel','','fontsize',18);
        title('rRF','fontsize',20);
        grid on

        subplot(2,1,2)
        plot(time,transRF);
        xlim([-6 12]);
        %set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',18);
        xlabel('time (s)','fontsize',18);
        title('tRF','fontsize',20);
        grid on

        figure(11);clf
        f2 = fftshift(f); taper2 = fftshift(taper);
        plot(f2, taper2); %xlim([])


        figure(12); clf
        subplot(321)
        plot(time,radRF);
        xlim([-6 12]);


        subplot(322)
        plot(time,transRF);
        xlim([-6 12]);

        subplot(323);
        errorbar(f(1:N/2), abs(HR(1:N/2)), sqrt(varR(1:N/2)))
        xlim([0 2]); ylim([-.2 .7]);

        subplot(324);
        errorbar(f(1:N/2), abs(HT(1:N/2)), sqrt(varT(1:N/2)))
        xlim([0 2]); ylim([-.2 .7]);

        subplot(325);
        errorbar(f(1:N/2), angle(HR(1:N/2)), sqrt(varR(1:N/2)))
        xlim([0 2]); %ylim([-.2 .7]);

        subplot(326);
        errorbar(f(1:N/2), angle(HT(1:N/2)), sqrt(varT(1:N/2)))
        xlim([0 2]); %ylim([-.2 .7]);
    end
else
    radRF = HR;
    transRF = HT;
    time = [0:N-1]-floor(N/2); time = time * Dt;
end


