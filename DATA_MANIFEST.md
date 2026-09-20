# Data Manifest

All MAT files below contain a frozen MATLAB structure named `d`. They are compact figure-level exports, not raw simulator logs. The original scientific project remains the authoritative archive.

| File | Content and role | Original project provenance |
|---|---|---|
| `data/M2_nominal_stress_geometry.mat` | Nominal/stress physical-activity geometry and radial-loss data | `paper_figures/data_exports/` |
| `data/M3_scalarization_loss.mat` | Structured operator and scalarized-product frequency data | `paper_figures/data_exports/` |
| `data/M4_nonlinear_replay.mat` | Six-vehicle nonlinear replay comparison arrays | `paper_figures/data_exports/` |
| `data/M5_accurate_but_redundant.mat` | Signed diagnostic, exact counterfactual baseline, and incremental-value data | `paper_figures/data_exports/` |
| `data/M6_claim_map.mat` | Frozen claim-scope map data | `paper_figures/data_exports/` |
| `data/B1_nominal_domain.mat` | Nominal-domain supplementary heatmaps | `paper_figures/data_exports/` |
| `data/B2_physical_ablations.mat` | Physical-activity ablation results | `paper_figures/data_exports/` |
| `data/B3_local_gain_grid.mat` | Local gain grid | `paper_figures/data_exports/` |
| `data/B4_port_frequency.mat` | Port-frequency response data | `paper_figures/data_exports/` |
| `data/B5_information_age.mat` | Information-age sensitivity data | `paper_figures/data_exports/` |
| `data/B6_credit_diagnostics.mat` | Credit diagnostic summary | `paper_figures/data_exports/` |
| `data/paper_numeric_summary.json` | Machine-readable numerical anchors used by package validation | `paper_figures/data_exports/` |
| `data/supplement_protocol.json` | Frozen supplementary evaluation-protocol metadata | `paper_figures/data_exports/` |
| `assets/M1_implementation_framework_revised.png` | Author-supplied architecture/implementation framework used as Fig. 1 | `paper_figures/main/` |

## Deliberate exclusions

To keep the repository minimal and avoid overstating reproducibility, it excludes:

- complete Phase Q-R, S-N, and AA-R archives;
- production control and Simulink files;
- raw simulation and local-linearization caches;
- training checkpoints or learned actors (none are evaluated in the paper);
- Monte Carlo or out-of-distribution campaigns; and
- LaTeX manuscript sources, which are maintained separately from this code/data artifact.

The figure-level data retain the values needed to reproduce the displayed evidence. They do not permit independent regeneration of the frozen data from first-principles simulation.

