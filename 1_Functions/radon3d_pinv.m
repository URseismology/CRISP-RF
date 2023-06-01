function [M, m] = radon3d_pinv(LLL, LLLINV, DD, nt, ilow, ihigh)
%forward radon in frequency domain -- return result in frequency and time
%domain
% Author: Tolulope Olugboji

[nfft, ~, nq] = size(LLL);
M = zeros(nfft, nq);


for ifreq=ilow:ihigh
    
    L = squeeze( LLL(ifreq, :,:) );
    y = DD(ifreq,:)';
    pinv_L = squeeze( LLLINV(ifreq, :,:) );
    
    xa = L'*y;
    
    %A = L'*L;
    %x  =  pinv(A)*xa;   % do pseudo inverse here
    
    x  =  pinv_L*xa;   % do pseudo inverse here
    
    M(ifreq,:) = x';
    M(nfft+2-ifreq,:) = conj(x)';
end

 M(nfft/2+1,:) = zeros(1,nq);
 m = real(ifft(M,[],1));
 m = m(1:nt,:);

return