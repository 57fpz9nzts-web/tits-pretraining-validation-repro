# Minimal Reproducibility Package

This repository accompanies the manuscript **“Before Training: Implementation-Faithful Validation of Candidate Learning Mechanisms for Articulated Heavy-Truck Platoons.”** It reconstructs the reported main and supplementary figures from frozen, machine-readable figure-level data.

## Reproducibility scope

The package provides a deterministic **figure-level reproduction** of the reported evidence. It:

- validates the frozen numerical anchors used in the manuscript;
- regenerates the data-driven main figures M2--M5 and supplementary figures S1--S6;
- copies the author-supplied implementation framework image M1 without modifying it; and
- exports MATLAB FIG, 400 dpi PNG, and vector PDF files for generated plots.

The package does **not** rerun the nonlinear plant simulations, local linearizations, controller design, Monte Carlo studies, reinforcement-learning training, or raw-data generation. It contains no trained policy. It must therefore not be described as an end-to-end simulation or training reproduction package.

## Requirements

- MATLAB R2022a (reference version: 9.12.0.1884302)
- Base MATLAB plotting and file I/O

No additional toolbox is required because all frequency responses and analysis outputs used by the plots are stored as frozen numerical arrays.

## Quick start

From the package root in MATLAB:

```matlab
run_reproduction
```

The script first checks file completeness and numerical anchors, then writes the reconstructed files to:

- `outputs/main`
- `outputs/supplementary`

To run the stages separately:

```matlab
addpath('code');
validate_package;
reproduce_all;
```

Individual figures can be selected by numeric identifier, for example:

```matlab
reproduce_all([2 3 4]);
```

## Figure map

| ID | Manuscript item | Output basename | Source | Reproduction mode |
|---:|---|---|---|---|
| 1 | Fig. 1 / M1 | `M1_implementation_framework_revised` | PNG asset | Exact file copy |
| 2 | M2 | `M2_nominal_stress_geometry` | `M2_nominal_stress_geometry.mat` | Regenerated |
| 3 | M3 | `M3_scalarization_loss` | `M3_scalarization_loss.mat` | Regenerated |
| 4 | M4 | `M4_nonlinear_replay` | `M4_nonlinear_replay.mat` | Regenerated |
| 5 | M5 | `M5_accurate_but_redundant` | `M5_accurate_but_redundant.mat` | Regenerated |
| 6 | Claim map | `M6_claim_map` | `M6_claim_map.mat` | Regenerated |
| 7 | Fig. S1 | `S1_nominal_domain` | `B1_nominal_domain.mat` | Regenerated |
| 8 | Fig. S2 | `S2_physical_ablations` | `B2_physical_ablations.mat` | Regenerated |
| 9 | Fig. S3 | `S3_local_gain_grid` | `B3_local_gain_grid.mat` | Regenerated |
| 10 | Fig. S4 | `S4_port_frequency` | `B4_port_frequency.mat` | Regenerated |
| 11 | Fig. S5 | `S5_information_age` | `B5_information_age.mat` | Regenerated |
| 12 | Fig. S6 | `S6_credit_diagnostics` | `B6_credit_diagnostics.mat` | Regenerated |

M6 is retained as supporting material even if it is not uploaded as a standalone main-paper figure in a particular submission version.

## Frozen numerical anchors

The validation script checks, among other fields:

- straight-chain operator gain: `1.41421356303719`;
- scalarized straight-chain product: `5.6568543352059848`;
- scalarization ratio: `4.0000000587303273`;
- six-vehicle replay maximum relative error: `4.1465404689042338e-5`;
- nominal/stress radial losses: `[0, 0.54044246673584007]`;
- exact counterfactual identity within numerical precision; and
- absence of a learned policy in the reported experiment.

These checks guard against accidental file substitution; they are not independent re-estimation from raw simulations.

## Data provenance and integrity

Every MAT file stores a compact frozen structure named `d`, exported from the scientifically frozen project in MATLAB R2022a. See [DATA_MANIFEST.md](DATA_MANIFEST.md) for item-level provenance and [MANIFEST.sha256](MANIFEST.sha256) for checksums.

## Citation and license

Citation metadata are provided in [CITATION.cff](CITATION.cff). No public repository URL, DOI, ORCID, or license has been invented. The authors must choose a distribution license before making the repository public; see [LICENSE_NOTICE.md](LICENSE_NOTICE.md).
