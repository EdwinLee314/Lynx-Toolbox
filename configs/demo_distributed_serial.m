% DEMO_DISTRIBUTED_SERIAL - Demo with data-distributed algorithms (serial version)

%add_model('B', 'Baseline', @BaselineModel);
add_model('ELM', 'Centralized ELM', @ExtremeLearningMachine);
add_model('LOC-ELM', 'Local ELM', @ExtremeLearningMachine);
%add_model('CONS-ELM', 'Distributed ELM (Consensus)', @ExtremeLearningMachine);
%add_model('ADMM-ELM', 'ADMM-ELM', @ExtremeLearningMachine);

set_training_algorithm('LOC-ELM', @SerialDataDistributedRVFL, 'consensus_max_steps', 0);
%set_training_algorithm('CONS-ELM', @SerialDataDistributedRVFL, 'consensus_max_steps', 250);
%set_training_algorithm('ADMM-ELM', @SerialDataDistributedRVFL, 'train_algo', 'admm', ...
%    'consensus_max_steps', 100, 'admm_max_steps', 100, 'admm_rho', 1, 'admm_reltol', -1, 'admm_abstol', -1);

%add_dataset('G', 'G50C', 'g50c');
add_dataset('S', 'Sylva', 'sylva ');

add_feature(SetSeedPRNG(1));

add_feature(DistributeData(RandomTopology(50, 0.2), 'disable_check', 'disable_parallel', 'disable_printing'));

add_feature(ExecuteOutputScripts('info_distributedrvfl'));

add_performance(Tasks.R, NormalizedRootMeanSquaredError(), true);
add_performance(Tasks.BC, RocCurve());
add_performance(Tasks.BC, PrecisionRecallCurve());
add_performance(Tasks.BC, ConfusionMatrix());

set_runs(3);