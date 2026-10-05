%SWEEP_ZETA  Sweep the buffer margin zeta of Eq. (3) (Fig. 13).
%
%   Runs RUN_ONLINE_BASE_LEARNER (and therefore RUN_ONLINE_LIFELONG) once per zeta value.
%   Results are written to outputs/results/*_<zeta>.mat and can be plotted with the
%   plotting/plot_zeta_*.m scripts.
%
%   Warning: every value runs a full online simulation and takes a long time.

for zeta = 0:30
    run('run_online_base_learner.m')
end








