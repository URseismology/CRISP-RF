function [outdata, Filter] = costaper(indata,fc, Dt)

N = length(indata);
fmax = 1/(2.0*Dt);
Df = fmax/(N/2);
f = Df*[0:N/2,-N/2+1:-1]';


Filter = zeros(N,1);
Fwin = round(fc/Df);
Fend = length(Filter);

FilterFull = cos(pi * f/ (2 * fc)).^2;
Filter(1:Fwin) = FilterFull(1:Fwin);
Filter(Fend:-1:Fend-Fwin+1)= fliplr(FilterFull(1:Fwin));

outdata = indata .* Filter;


end