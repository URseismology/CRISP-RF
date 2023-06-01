function [dataOut, headersOut] = dataresample(dataIn, headersIn, sr_old, sr_new, len_old, len_new, isplot)
% Author: Tolulope Olugboji
% -- resample and update data quality


ZZ = dataIn.ZZ;
RR = dataIn.RR;
TT = dataIn.TT;



tt_new = linspace(0,(len_new-1)*sr_new, len_new) ./ 1e3; % change to sec
tt_old = linspace(0,(len_old-1)*sr_old, len_old) ./ 1e3; % change to sec

[~,ntraces] = size(ZZ);
upsamplecount = 0;

for itr = 1: ntraces

    nlen = headersIn.lentrace(itr);  % length of data

    ntol = 10;
    islowsrate = abs(nlen-len_new) > ntol;

    if islowsrate
        upsamplecount = upsamplecount + 1;

        ZZ_old = ZZ(1:len_old, itr);
        RR_old = RR(1:len_old, itr);
        TT_old = TT(1:len_old, itr);

        ZZ(1:len_new, itr) = interpbl(tt_old, ZZ_old, tt_new);
        RR(1:len_new, itr) = interpbl(tt_old, RR_old, tt_new);
        TT(1:len_new, itr) = interpbl(tt_old, TT_old, tt_new);
    end

end

fprintf('%d of %d traces were upsampled.\n', upsamplecount, ntraces);

dataOut.ZZ = ZZ;
dataOut.RR = RR;
dataOut.TT = TT;

headersOut = headersIn;
headersOut.srate = sr_new;
headersOut.lentrace = len_new;


% if isplot
%     [~,ntraces] = size(ZZ);
%     zbef = dataIn.ZZ;
%     zaft = dataOut.ZZ;
% 
%     for ij = 1: ntraces
%         showbef(:,ij) = zbef(:,ij) ./ max(abs(zbef(:,ij)));
%         showaft(:,ij) = zaft(:,ij) ./ max(abs(zaft(:,ij)));
% 
%     end
% 
% 
%     snrs = headersIn.snrs;
%     [snrsrt, isrt ] = sort(snrs, 'descend');
%     
%     figure(11)
%     clf
%     fs = 20;
%     subplot(221)
%     plot(1:ntraces, snrs, 'linewidth', 1)
%     ylabel('SNR', 'fontsize', fs)
%     xlim([0 ntraces])
%     
%     subplot(223)
%     imagesc(1:ntraces, tt_new , showbef)
%     ylabel('Time', 'fontsize', fs)
%     xlabel('Trace Index', 'fontsize', fs)
%     title('ZZ normalized', 'fontsize', fs)
%     %colorbar
% 
%     subplot(222)
%     plot(1:ntraces, snrsrt , 'linewidth', 1); grid on
%     ylabel('SNR', 'fontsize', fs)
%     xlim([0 ntraces])
% 
%     subplot(224)
%     imagesc(1:ntraces, tt_new , showaft(:, isrt))
%     xlabel('Trace Index', 'fontsize', fs)
%     title('resampled + sorted by SNR', 'fontsize', fs)
%     %colorbar
%     colormap('gray')
% 
%     figure(4); clf
%     hold on
%     plot(tt_new, showaft(1:len_new, isrt(2)),  'linewidth', 2)
%     plot(tt_new, showaft(1:len_new, isrt(end)) ,  'linewidth', 2)
%     xlabel('Time (s)', 'fontsize', fs)
%     xline(120, 'linewidth', 2); grid on
%     legend('Best SNR', 'Worst SNR')
%     title('II-RAYN', 'fontsize', fs)
% 
% 
% end

end