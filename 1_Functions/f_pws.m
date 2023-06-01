function [out_sig, phase_stacks] = f_pws(data,p)
%Phase-Weighted Stacks (PWS) after Schimmel, M., Paulssen H. (1997): 
%Noise reduction and detection of weak, coherent signals through
%phase-weighted stacks, Geophys. J. Int. 130, 497-505.
%Implemented 2022 by Vilhelm J., Fischer T., Alexa M., and Valenta J.
%
%   data = matrix of signals to be averaged: signals are columns of matrix
%   p = exponent (usually in the interval from 2 to 5; for p=0 PWS becomes
%   simple average)
%   out_sig = vector = resulting non-linear stack of signals data
complex_data=hilbert(data);
complex_data_norm=complex_data./abs(complex_data);
phase_stacks=squeeze(abs(mean(complex_data_norm,2)));
aver_signals=squeeze(mean(data,2));
aver_data=aver_signals.*(phase_stacks.^p);
out_sig=real(aver_data);
end