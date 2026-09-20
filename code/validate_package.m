function report = validate_package()
%VALIDATE_PACKAGE Check required files and frozen numerical anchors.

root = fileparts(fileparts(mfilename('fullpath')));
dataDir = fullfile(root, 'data');
required = { ...
    'M2_nominal_stress_geometry.mat', 'M3_scalarization_loss.mat', ...
    'M4_nonlinear_replay.mat', 'M5_accurate_but_redundant.mat', ...
    'M6_claim_map.mat', 'B1_nominal_domain.mat', ...
    'B2_physical_ablations.mat', 'B3_local_gain_grid.mat', ...
    'B4_port_frequency.mat', 'B5_information_age.mat', ...
    'B6_credit_diagnostics.mat', 'paper_numeric_summary.json'};
for k = 1:numel(required)
    assert(isfile(fullfile(dataDir, required{k})), 'Missing required file: %s', required{k});
end
assert(isfile(fullfile(root, 'assets', 'M1_implementation_framework_revised.png')), ...
    'Missing revised architecture asset.');

ref = jsondecode(fileread(fullfile(dataDir, 'paper_numeric_summary.json')));
m2 = load(fullfile(dataDir, 'M2_nominal_stress_geometry.mat'), 'd');
m3 = load(fullfile(dataDir, 'M3_scalarization_loss.mat'), 'd');
m4 = load(fullfile(dataDir, 'M4_nonlinear_replay.mat'), 'd');
m5 = load(fullfile(dataDir, 'M5_accurate_but_redundant.mat'), 'd');

tol = 1e-9;
assert(abs(m3.d.rows(1,4)-ref.straightOperatorGain) < tol, 'Straight operator gain mismatch.');
assert(abs(m3.d.rows(1,5)-ref.straightScalarProduct) < tol, 'Straight scalar product mismatch.');
assert(abs(m3.d.rows(1,6)-ref.ratio) < tol, 'Scalarization ratio mismatch.');
assert(abs(max(m4.d.rows(:,8))-ref.allSixReplayMaxRelativeError) < tol, 'Replay error mismatch.');

s1 = m2.d.sections{1}; s2 = m2.d.sections{2};
loss = [max(1-s1.boundary.rho./s1.boundary.actuatorRho); ...
        max(1-s2.boundary.rho./s2.boundary.actuatorRho)];
assert(max(abs(loss-ref.geometryPlaneMaxRadialLoss(:))) < tol, 'Geometry radial-loss mismatch.');

trueCredit = m5.d.rows(:,6);
exactCounterfactual = m5.d.rows(:,8);
identityError = max(abs(trueCredit-exactCounterfactual));
assert(identityError < 1e-12, 'Counterfactual identity no longer holds numerically.');
assert(~ref.newLearnedPolicy, 'Reference summary unexpectedly claims a learned policy.');

report = struct( ...
    'matlabRelease', version('-release'), ...
    'straightOperatorGain', m3.d.rows(1,4), ...
    'straightScalarProduct', m3.d.rows(1,5), ...
    'scalarizationRatio', m3.d.rows(1,6), ...
    'maxReplayRelativeError', max(m4.d.rows(:,8)), ...
    'geometryPlaneMaxRadialLoss', loss, ...
    'counterfactualIdentityError', identityError, ...
    'trainedPolicyIncluded', false);

fprintf('PACKAGE VALIDATION PASS\n');
fprintf('  MATLAB release: %s\n', report.matlabRelease);
fprintf('  Straight operator/scalar product: %.7f / %.7f\n', ...
    report.straightOperatorGain, report.straightScalarProduct);
fprintf('  Scalarization ratio: %.7f\n', report.scalarizationRatio);
fprintf('  Max replay relative error: %.9g\n', report.maxReplayRelativeError);
fprintf('  Geometry losses: %.7f, %.7f\n', loss(1), loss(2));
fprintf('  Counterfactual identity error: %.9g\n', identityError);
end
