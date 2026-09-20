function results = reproduce_all(which)
%REPRODUCE_ALL Rebuild the paper figures from frozen figure-level data.
% MATLAB R2022a is the reference environment. No simulation or training runs.

if nargin < 1
    which = 1:12;
end

root = fileparts(fileparts(mfilename('fullpath')));
dataDir = fullfile(root, 'data');
assetDir = fullfile(root, 'assets');
mainDir = fullfile(root, 'outputs', 'main');
suppDir = fullfile(root, 'outputs', 'supplementary');
if ~exist(mainDir, 'dir'), mkdir(mainDir); end
if ~exist(suppDir, 'dir'), mkdir(suppDir); end

if ~strcmp(version('-release'), '2022a')
    warning('Reference environment is MATLAB R2022a; running under %s.', version('-release'));
end

set(groot, 'defaultFigureColor', 'w', ...
    'defaultAxesFontName', 'Arial', 'defaultAxesFontSize', 9, ...
    'defaultTextFontName', 'Arial', 'defaultTextFontSize', 9, ...
    'defaultAxesLineWidth', 0.7, 'defaultLineLineWidth', 1.5, ...
    'defaultAxesTickDir', 'out', 'defaultAxesBox', 'off');
C = [.12 .35 .55; .84 .36 .12; .13 .52 .47; .47 .48 .51];

spec = { ...
    'M1_implementation_framework_revised', '', 'main'; ...
    'M2_nominal_stress_geometry', 'M2_nominal_stress_geometry.mat', 'main'; ...
    'M3_scalarization_loss', 'M3_scalarization_loss.mat', 'main'; ...
    'M4_nonlinear_replay', 'M4_nonlinear_replay.mat', 'main'; ...
    'M5_accurate_but_redundant', 'M5_accurate_but_redundant.mat', 'main'; ...
    'M6_claim_map', 'M6_claim_map.mat', 'supplementary'; ...
    'S1_nominal_domain', 'B1_nominal_domain.mat', 'supplementary'; ...
    'S2_physical_ablations', 'B2_physical_ablations.mat', 'supplementary'; ...
    'S3_local_gain_grid', 'B3_local_gain_grid.mat', 'supplementary'; ...
    'S4_port_frequency', 'B4_port_frequency.mat', 'supplementary'; ...
    'S5_information_age', 'B5_information_age.mat', 'supplementary'; ...
    'S6_credit_diagnostics', 'B6_credit_diagnostics.mat', 'supplementary'};

results = struct('id', {}, 'name', {}, 'outputDirectory', {});
for id = reshape(which, 1, [])
    assert(id >= 1 && id <= 12 && id == floor(id), 'Figure IDs must be integers from 1 to 12.');
    name = spec{id, 1};
    outDir = mainDir;
    if strcmp(spec{id, 3}, 'supplementary'), outDir = suppDir; end

    if id == 1
        src = fullfile(assetDir, 'M1_implementation_framework_revised.png');
        assert(isfile(src), 'Missing static architecture asset: %s', src);
        copyfile(src, fullfile(outDir, [name '.png']));
        fprintf('FIGURE %02d COPIED: %s (author-supplied static asset)\n', id, name);
    else
        S = load(fullfile(dataDir, spec{id, 2}), 'd');
        assert(isfield(S, 'd'), 'Expected variable d in %s.', spec{id, 2});
        d = S.d;
        switch id
            case 2, f = plotGeometry(d, C);
            case 3, f = plotScalarization(d, C);
            case 4, f = plotReplay(d, C);
            case 5, f = plotRedundancy(d, C);
            case 6, f = plotClaimMap(d, C);
            case 7, f = plotNominalDomain(d);
            case 8, f = plotPhysicalAblations(d, C);
            case 9, f = plotLocalGainGrid(d, C);
            case 10, f = plotPortFrequency(d, C);
            case 11, f = plotInformationAge(d, C);
            case 12, f = plotCreditDiagnostics(d, C);
        end
        savefig(f, fullfile(outDir, [name '.fig']));
        exportgraphics(f, fullfile(outDir, [name '.png']), 'Resolution', 400);
        exportgraphics(f, fullfile(outDir, [name '.pdf']), 'ContentType', 'vector');
        close(f);
        fprintf('FIGURE %02d COMPLETE: %s\n', id, name);
    end
    results(end+1) = struct('id', id, 'name', name, 'outputDirectory', outDir); %#ok<AGROW>
end
end

function f = canvas(h)
f = figure('Visible', 'off', 'Units', 'inches', 'Position', [.5 .5 7.2 h], 'Color', 'w');
end

function cleanAxes()
grid on;
ax = gca;
ax.GridAlpha = .12;
ax.MinorGridAlpha = .06;
ax.FontSize = 9;
end

function d = loadData(~) %#ok<DEFNU>
% Reserved for API compatibility; all data are loaded by reproduce_all.
d = [];
end

function f = plotGeometry(d, C)
f = canvas(3.55);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
for j = 1:2
    s = d.sections{j};
    a = s.context;
    B = s.boundary;
    P = B.points;
    nexttile; hold on;
    patch([a.lb(1) a.ub(1) a.ub(1) a.lb(1)], [a.lb(2) a.lb(2) a.ub(2) a.ub(2)], ...
        .94*[1 1 1], 'EdgeColor', C(4,:), 'LineStyle', '--', 'LineWidth', 1.3);
    patch(P(:,1), P(:,2), .90+.10*C(1,:), 'EdgeColor', C(1,:), 'LineWidth', 1.8);
    plot([a.lb(1) a.ub(1) a.ub(1) a.lb(1) a.lb(1)], ...
         [a.lb(2) a.lb(2) a.ub(2) a.ub(2) a.lb(2)], '--', 'Color', C(4,:));
    plot(0, 0, 'k+', 'MarkerSize', 7);
    axis equal; axis([-1.6 .7 -1.2 1.2]); cleanAxes();
    xlabel('p_F = r_F / 150 kN'); ylabel('p_\delta = r_\delta / 0.022 rad');
    if j == 1, title('(a) Nominal: trim 066'); else, title('(b) Existing stress: front demand 0.495'); end
    text(-1.5, -1.08, sprintf('max radial loss: %.1f%%', 100*max(1-B.rho./B.actuatorRho)), 'FontSize', 8.5);
    if j == 1
        legend('Actuator/governor box', 'Numerical hold section', 'Location', 'northoutside', 'FontSize', 8);
    end
end
sgtitle('Same normalized plane: p_{Mz}=0; finite one-hold demand criterion', 'FontSize', 10);
end

function f = plotScalarization(d, C)
r = d.rows;
f = canvas(3.15);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
nexttile;
h = bar(r(:,4:5), 'BarWidth', .78);
h(1).FaceColor = C(1,:); h(2).FaceColor = C(2,:);
xticklabels({'Straight', 'Negative curve', 'Positive curve'}); xtickangle(15);
ylabel('Normalized induced port gain'); ylim([0 7.4]); cleanAxes();
title('(a) Matrix product vs scalar product');
lg = legend('||P_5 ... P_1||_\infty', '\Pi_i ||P_i||_\infty', 'FontSize', 8, 'NumColumns', 2);
lg.Layout.Tile = 'north';
for i = 1:3
    text(i, 6.8, sprintf('%.3fx', r(i,6)), 'HorizontalAlignment', 'center', 'Color', C(2,:), 'FontWeight', 'bold');
    text(i-.15, r(i,4)+.22, sprintf('%.4f', r(i,4)), 'HorizontalAlignment', 'center', 'FontSize', 7.5);
    text(i+.15, r(i,5)+.22, sprintf('%.4f', r(i,5)), 'HorizontalAlignment', 'center', 'FontSize', 7.5);
end
nexttile; hold on;
semilogx(d.omega, d.chainFrequency, 'Color', C(1,:));
semilogx(d.omega, d.productFrequency, '--', 'Color', C(2,:));
set(gca, 'XScale', 'log'); cleanAxes();
xlabel('\omega (rad/s)'); ylabel('Frequency-wise port gain');
title('(b) Straight: loss persists before supremum');
legend('||P_5 ... P_1||_2', '\Pi_i ||P_i||_2', 'Location', 'northeast', 'FontSize', 8);
end

function f = plotReplay(d, C)
t = d.time;
f = canvas(4.5);
tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
followers = [2 4 5];
for j = 1:3
    i = followers(j);
    y = 5*squeeze(d.nonlinear(1,i+1,:));
    p = 5*squeeze(d.linear(1,i+1,:));
    nexttile;
    plot(t, y, 'Color', C(1,:)); hold on;
    plot(t, p, '--', 'Color', C(2,:)); cleanAxes();
    xlabel('Time (s)'); ylabel('\Delta v_i (m/s)');
    title(sprintf('(%c) Follower %d', 96+j, i));
    text(.04, .08, sprintf('max |error| = %.2g m/s', max(abs(y-p))), 'Units', 'normalized', 'FontSize', 8);
    if j == 1, legend('Nonlinear replay', 'Local operator', 'Location', 'northwest', 'FontSize', 8); end
end
nexttile;
bar(100*d.rows(:,8), 'FaceColor', C(3,:)); xticks(1:6);
xlabel('Archived replay case (all signs/curves)'); ylabel('Stacked-port relative error (%)');
title('(d) All six 40-s runs retained'); cleanAxes();
end

function f = plotRedundancy(d, C)
r = d.rows; y = r(:,6); p = r(:,9); cf = r(:,8); m = d.metrics;
f = canvas(3.25);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
nexttile;
scatter(y*1e4, p*1e4, 15, C(1,:), 'filled'); hold on;
lim = [min(y) max(y)]*1e4; plot(lim, lim, '--', 'Color', C(4,:));
axis equal; cleanAxes(); xlabel('True downstream credit (10^{-4})');
ylabel('Signed model prediction (10^{-4})'); title('(a) Accurate: all 240 candidates');
text(.06, .90, sprintf('R^2 = %.9f', m(5,1)), 'Units', 'normalized', 'FontSize', 9);
nexttile;
plot(y*1e4, (cf-y)*1e6, 'o', 'MarkerSize', 3, 'Color', C(3,:)); hold on;
plot(y*1e4, (p-y)*1e6, '.', 'MarkerSize', 8, 'Color', C(2,:));
yline(0, '-', 'Color', C(4,:)); cleanAxes();
xlabel('True downstream credit (10^{-4})'); ylabel('Credit prediction error (10^{-6})');
title('(b) No gain over exact difference reward');
legend('Exact difference reward', 'Full signed model', 'Location', 'southwest', 'FontSize', 8);
sgtitle(sprintf('Exact counterfactual identity error: %.2g   |   %sDeltaR^2_{signed-counterfactual}: %.3g', ...
    max(abs(cf-y)), char(92), m(5,1)-1), 'FontSize', 9);
end

function f = plotClaimMap(d, C)
f = canvas(3.7);
axes('Position', [.02 .02 .96 .96]); axis([0 100 0 100]); axis off; hold on;
headers = {'Physical activity', 'Preserve structure', 'Added information', 'Retained paper role'};
xx = [23 42 61 80];
for k = 1:4
    text(xx(k)+8, 90, headers{k}, 'HorizontalAlignment', 'center', 'FontSize', 8.5, 'FontWeight', 'bold');
end
names = {{'Capability','geometry'}, {'Scalarized','propagation'}, {'Signed residual','credit'}};
for r = 1:3
    y = 65-(r-1)*25;
    text(1, y+7, names{r}, 'FontWeight', 'bold', 'FontSize', 9);
    for k = 1:4
        col = C(min(r,3),:); if k == 4, col = C(4,:); end
        drawBox(xx(k), y, 17, 18, d.labels{r,k}, col);
    end
end
text(50, 5, 'Evidence-to-claim map, not a stability theorem or a training scorecard', ...
    'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', C(4,:));
end

function drawBox(x, y, w, h, s, col)
rectangle('Position', [x y w h], 'FaceColor', .94+.06*col, 'EdgeColor', col, 'LineWidth', .9);
text(x+w/2, y+h/2, s, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8.1);
end

function f = plotNominalDomain(d)
f = canvas(3.5);
tiledlayout(1, 3, 'Padding', 'compact', 'TileSpacing', 'compact');
mu = [.55 .75 .85];
for j = 1:3
    nexttile; imagesc(d.heatmaps{j}, [0 .5]); colormap(parula);
    xticks(1:5); xticklabels({'-4','-2','0','2','4'});
    labs = cell(9,1); n = 0;
    for v = [16 20 24]
        for m = [22 30 38]
            n = n+1; labs{n} = sprintf('%d / %d', v, m);
        end
    end
    yticks(1:9); yticklabels(labs); xlabel('\kappa (10^{-4} m^{-1})');
    if j == 1, ylabel('v (m/s) / mass (t)'); end
    title(sprintf('%smu = %.2f', char(92), mu(j))); if j == 3, colorbar; end
end
sgtitle('135 nominal points: max axle demand \chi; additional tire clipping = 0/135', 'FontSize', 10);
end

function f = plotPhysicalAblations(d, C)
s = d.summary;
f = canvas(3.2);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
nexttile;
bar(100*[s.maxArticulationRelativeRadius], 'FaceColor', C(1,:));
xticks(1:16); xlabel('Archived representative case'); ylabel('Max radial change (%)');
title('(a) Frozen-articulation ablation'); cleanAxes(); xlim([.3 16.7]);
nexttile;
bar(100*[s.maxAggregateOverstatement], 'FaceColor', C(2,:));
xticks(1:16); xlabel('Archived representative case'); ylabel('Max aggregation overstatement (%)');
title('(b) Loss of axle-level demand detail'); cleanAxes(); xlim([.3 16.7]);
sgtitle('Stress cases 10 and 11; all 16 representatives shown (different y-scales)', 'FontSize', 10);
end

function f = plotLocalGainGrid(d, C)
r = d.rows;
f = canvas(3.3);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
for j = 1:2
    nexttile; hold on; col = [10 13];
    for i = 1:5
        z = r(r(:,2)==i, col(j));
        scatter(i+.14*sin((1:numel(z))'), z, 8, C(1,:), 'filled', 'MarkerFaceAlpha', .28);
        plot([i-.22 i+.22], [median(z) median(z)], '-', 'Color', C(2,:), 'LineWidth', 2);
    end
    xticks(1:5); xlabel('Follower (135 operating points each)'); cleanAxes();
    if j == 1
        ylabel('g_{port} = ||G_p||_\infty'); title('(a) Predecessor port to local errors');
    else
        ylabel('h = ||G_r||_\infty'); title('(b) Residual to local errors');
    end
end
end

function f = plotPortFrequency(d, C)
f = canvas(3.2);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
styles = {'-', '--', ':'};
for j = 1:2
    nexttile; hold on;
    for i = 1:3
        if j == 1, z = d.localP(i,:); else, z = d.endToEnd(i,:); end
        semilogx(d.omega, z, styles{i}, 'Color', C(i,:));
    end
    set(gca, 'XScale', 'log'); cleanAxes(); xlabel('\omega (rad/s)'); ylabel('Largest singular value');
    if j == 1, title('(a) First follower P_1'); else, title('(b) Five-link P_5 ... P_1'); end
    legend('Straight', '\kappa=-4e-4 m^{-1}', '\kappa=+4e-4 m^{-1}', 'Location', 'southwest', 'FontSize', 8);
end
end

function f = plotInformationAge(d, C)
q = d.queueTrace; a = d.contract;
f = canvas(3.4);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
nexttile;
finite = isfinite(q(:,5)); stairs(q(finite,1)*.04, q(finite,5), 'Color', C(1,:)); hold on;
bad = finite & q(:,7)==0; plot(q(bad,1)*.04, q(bad,5), 'x', 'Color', C(2,:), 'MarkerSize', 6);
yline(.35, '--', 'Max accepted age', 'Color', C(4,:), 'FontSize', 8);
yline(.20, ':', 'Transport delay', 'Color', C(3,:), 'FontSize', 8);
cleanAxes(); ylim([.17 .40]); xlabel('Replay time (s)'); ylabel('Received packet age (s)');
title('(a) Actual queue / dropout trace');
text(.04, .88, sprintf('%d startup ages = Inf (not plotted)', sum(~finite)), 'Units', 'normalized', 'FontSize', 8);
nexttile;
v = a.valid; t = a.age(v); z = a.interval(v,:)/1000;
fill([t;flipud(t)], [z(:,1);flipud(z(:,2))], .88+.12*C(1,:), 'EdgeColor', 'none'); hold on;
plot(t, z, 'Color', C(1,:)); prior = a.interval(end,:)/1000;
fill([.35 .4 .4 .35], [prior(1) prior(1) prior(2) prior(2)], .88+.12*C(1,:), 'EdgeColor', 'none');
plot([.35 .4], [prior;prior], 'Color', C(1,:));
xline(.35, '--', 'Invalid beyond', 'Color', C(4,:), 'FontSize', 8); cleanAxes();
xlabel('Packet age (s)'); ylabel('Current actuator-force interval (kN)');
title('(b) First-order actuator information contract');
text(.03, .9, {'field 2 = F_{act}/30000, not acceleration', 'Example observed field = 0; error bound 4 kN'}, ...
    'Units', 'normalized', 'FontSize', 7.7);
end

function f = plotCreditDiagnostics(d, C)
labels = {'Reward', 'Position', 'Exact counterfactual', 'S summary', 'Full signed'};
f = canvas(3.35);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
for j = 1:2
    nexttile; hold on;
    for a = 1:5
        lo = d.ci(a,j,1); hi = d.ci(a,j,2);
        plot([a a], [lo hi], '-', 'Color', C(4,:), 'LineWidth', 1.2);
        plot(a, d.metrics(a,j), 'o', 'Color', C(1,:), 'MarkerFaceColor', C(1,:), 'MarkerSize', 5);
    end
    xticks(1:5); xticklabels(labels); xtickangle(25); cleanAxes(); xlim([.5 5.5]);
    if j == 1
        ylim([-.08 1.05]); ylabel('Out-of-case credit R^2'); title('(a) Prediction accuracy');
    else
        ylim([.25 1.05]); ylabel('AUC for positive downstream credit'); title('(b) Improvement discrimination');
    end
end
sgtitle('Five offline diagnostics; 95% case-block percentile intervals, 8 cases', 'FontSize', 10);
end
