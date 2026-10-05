# Paper-to-code map

Equation, algorithm and figure numbers refer to the IEEE IoT-J paper
*Semantic-Aware Architecture Design for a Lifelong Swarm Metaverse*.

## System model (Sec. II)

| Paper | Description | Code |
|---|---|---|
| Table II | Semantic environments: m_k, s_k, λ_k, B, P, η, Δ | `online/environment/task_generation.m`, `online/environment/server_generation.m`, `online/environment/Task_description.m` (training: `training/environment/*`) |
| Eqs. (1)–(2) | A2A free-space path loss and transmission rate | `online/mobility/transmission_rate.m` (per-type B and P from `server_info` columns 7 and 4; G = 10) |
| Eq. (3) | Rate requirement with buffer margin ζ | `online/mobility/required_distance_and_D_max.m` (`D_max = ceil(#tasks/#servers) + zeta`) |
| Eq. (4) | Maximum distance that meets the rate requirement | `online/mobility/required_distance_and_D_max.m` |
| Eq. (5) | Computing energy α(η ε)³ | `online/mdp/reward_function.m` |
| — | Collection-UAV path (back and forth between x = 250 m and 750 m) | `online/mobility/moveInSquareMap.m` |

## P1 – Mobility (Sec. III-B/C, IV-A)

| Paper | Description | Code |
|---|---|---|
| Eq. (8) | Mobility utility | `online/mobility/calculate_reward_PSO.m` |
| Eqs. (9)–(11) | Slope of the rate w.r.t. distance | `online/mobility/calculate_slope.m` (numerical) |
| Eqs. (23)–(26) | Penalised PSO reward (ρ speed, μ distance, ν collision) | `online/mobility/calculate_reward_PSO.m` |
| Eqs. (27)–(30), Alg. 1 | PSO-CEMA | `online/mobility/PSO_update_location.m` |
| "w/o mobility" baseline | Move straight to the required distance | `online/mobility/location_change.m` |
| Exhaustive-search reference | Grid search with the same reward | `online/mobility/exhaustive_search_mobility.m` |

## P2 – Task allocation (Sec. III-D–F, IV-B)

| Paper | Description | Code |
|---|---|---|
| Eqs. (14)–(15) | Processing queue H and virtual queue Q | `online/run_online_*.m` (arrivals), `online/mdp/next_state.m` (departures) |
| Eqs. (16)–(19), (31) | Lyapunov drift-plus-penalty allocation reward | `online/allocation/getreward.m` |
| Alg. 2 | LDF-DPTAA (dynamic programming + backtracking) | `online/allocation/lyapunov_task_allocation.m` |
| Fair baseline | Equal split among servers of the same type | `online/allocation/fair_task_allocation.m` |

## P3 – Computing resource allocation with lifelong learning (Sec. III-G/H, IV-C)

| Paper | Description | Code |
|---|---|---|
| Eq. (21) | Computing cost (lifespan vs. energy, β = 0.4) | `*/mdp/reward_function.m` |
| MDP state / action | [average lifespan, queue length] / number of tasks to compute | `*/environment/Task_description.m`, `*/mdp/draw_action.m`, `*/mdp/next_state.m` |
| Base learner | Episodic Natural Actor-Critic | `*/learning/ENAC.m`, `*/learning/DlogPiDThetaNAC.m` |
| Eq. (36) | Hessian of the policy objective | `*/learning/computeHessianArray.m` |
| Eqs. (37)–(44) | PG-ELLA update of s_t (Lasso) and L | `*/learning/updatePGELLA.m`, `common/solve_lasso.m` |
| Alg. 3, lines 1–21 | Training in the central collection UAV | `training/learning/pretraining.m`, `training/run_training_lifelong.m` |
| Alg. 3, lines 22–34 | Online policies for the UAV servers + knowledge-base update | `online/run_online_lifelong.m` |
| Alg. 4 | PSO-LDF-LL integration | `online/run_online_lifelong.m` |

## Figures

The published figures are stored in [`figures/`](figures/) (`figNN_*.png`, numbered as in the paper).

| Figure | Content | Produced by | Shipped data |
|---|---|---|---|
| Figs. 3–4 | Approach / steady-following phases | `online/mobility/plotLocations.m` (called every τ) | — |
| Fig. 5 | Mobility reward vs. τ | `online/compare_online_results.m` (`loss_for_UAV_moving_PSO`) | — |
| Fig. 6 | Task-allocation reward per server type | no dedicated script: the saved `loss_for_allocation_*` is summed over server types | — |
| Fig. 7 | Total task-allocation reward, with/without mobility | `plotting/plot_task_allocation_mobility.m` | `data/results/main_runs` |
| Fig. 8 | Training: penalty, lifespan, energy | `training/run_training_lifelong.m` → `training/plot_training_results.m` | — |
| Figs. 9–12 | Online: penalty, lifespan, queue length, energy | `online/compare_online_results.m` | `data/results/main_runs` |
| Fig. 13 | Impact of ζ | `online/sweep_zeta.m` + `plotting/plot_zeta_*.m` | `data/results/zeta_sweep*` |

The Q-learning comparison in Fig. 7 comes from the authors' earlier work (IEEE ref. 10316024) and is
not part of this repository.
