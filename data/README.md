# Data

All files are MATLAB `.mat` files saved by the scripts in this repository. They are the
results used to prepare the figures of the paper, so the figures can be re-plotted without
re-running the simulations, which take many hours.

New runs never overwrite this folder; they write to `outputs/` (git-ignored).

## `pretrained/`

| File | Content | Produced by |
|---|---|---|
| `policy_base.mat` | `policy_base`: NAC policy trained in the central collection UAV | `training/run_training_base_learner.m` |
| `modelsPGELLA.mat` | `modelsPGELLA`: lifelong-learning knowledge base (latent basis `L`, task codes `S`) | `training/run_training_lifelong.m` |

Both are loaded automatically by the `online/run_online_*` scripts when the variables are not
already in the workspace.

## `results/`

Two kinds of files, one per method (`base` = NAC base learner, `LL` = lifelong learning):

- `mean_new_system_<method>_<suffix>.mat`: 1×5 struct array, one entry per server type /
  semantic environment. The fields `reward`, `Averagelifespan`, `ScaledEC` and `queue_length`
  hold one value per hovering position τ, averaged over the servers of that type.
- `loss_for_allocation_<method>_<suffix>.mat`: matrix (τ × time step) of the LDF-DPTAA
  allocation loss. The allocation reward is the negative of this loss.

`<suffix>` is the buffer margin ζ, `nopso` (no mobility optimisation) or `fair`
(equal-split allocation).

| Folder | Content | Used by |
|---|---|---|
| `main_runs/` | Full runs with ζ = 5 and the no-mobility ablation | `plotting/plot_task_allocation_mobility.m` (Fig. 7), Figs. 9–12 |
| `zeta_sweep/` | Short runs for every ζ in 0…50, plus `fair`/`nopso` | `plotting/plot_zeta_allocation_reward.m`, `plotting/plot_zeta_penalty_trend.m` |
| `zeta_sweep_full/` | Full runs for ζ ∈ {0, 5, …, 25} and `fair` | `plotting/plot_zeta_penalty_per_env.m` |

The `zeta_sweep/` runs (25 positions τ × 25 time steps per ζ) are a run of the same experiment
as Fig. 13, not the exact one behind the published curves. The computing penalties of
Fig. 13(b)–(c) are close (e.g. LL at ζ = 0: 0.17 / 0.75 / 1.00 / 0.75 / 0.30 for environments 1–5,
versus about 0.18 / 0.76 / 0.99 / 0.82 / 0.40 in the paper). The task-allocation reward of
Fig. 13(a) is about 3× lower than in the paper (LL ≈ 1.3–1.6 × 10⁴ instead of ≈ 4.8–5 × 10⁴),
so it should be compared only in its trend.
