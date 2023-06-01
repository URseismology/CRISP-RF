function RadonPlot(tau, q, m, twin, qwin, tqpts1, tqpts2)
%
% Authors: Tolulope Olugboji, Ziqi Zhang
%
% RadonPlot(tau, q, m, twin, qwin)
%
% Input:
% tau (time) and q (curvature) vectors
% m: radon image matrix, should have size of length(tau) by length(q)
% twin and qwin as two-element vectors
% tqpts1/2: points on radon image (e.g., from velocity model) as two-column
% matrices; (1) positive q, (2) negative q.

m = m';

max_org = max(abs(m), [], 'all');
m = m / max_org;
mxm = 0.3;

imagesc(tau, q, m);

set(gca, 'YDir', 'normal');
yline(0, 'linewidth', 2);

if mxm > 0
    caxis([-mxm mxm]);
end

colormap(seismic(3));
cb = colorbar;
cb.Location="southoutside";
xlim([twin(1) twin(2)]);
ylim([qwin(1) qwin(2)]);

grid on;

if ~isempty(tqpts1) % plot t-q points with positive q
    hold on;
    plot(tqpts1(:,1), tqpts1(:,2), 'o', 'Markersize', 10, 'MarkerFaceColor',...
        'w', 'MarkerEdgeColor', 'b', 'Linewidth', 2);
end
if ~isempty(tqpts1) % plot t-q points with negative q
    hold on;
    plot(tqpts2(:,1), tqpts2(:,2), 's', 'Markersize', 10, 'MarkerFaceColor',...
        'w', 'MarkerEdgeColor', 'b', 'Linewidth', 2);
end

px = (twin(2) - twin(1)) * 0.6 + twin(1);
py = (qwin(2) - qwin(1)) * 0.2 + qwin(1);
text(px, py, sprintf('Max amplitude = %6.3f', max_org), 'fontsize', 16);