ehc = caseN10B13_NonLin;
data_EGY2228;
formNTI;
load_raw = demand_intermediate';
demand(1, :) = load_raw(3, :);
demand(2, :) = load_raw(1, :);
demand(3, :) = load_raw(2, :);
price = prices_intermediate' / 1000;
capacity = ones(2, 24) * 10000;
probability = 1 / 365;
load('v0.mat');
load('vin0.mat');
load('S0.mat')
ops = sdpsettings('fmincon.MaxFunEvals', Inf, 'fmincon.MaxIter', 3000);
tic;
[v, vin, S, objective] = runehopf_NonLin( ehc, demand, price, capacity, probability, v0, vin0, S0, ops );
toc;