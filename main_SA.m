data_EGY2228;
formNTI;
load_raw = demand_intermediate';
demand(1, :) = load_raw(3, :);
demand(2, :) = load_raw(1, :);
demand(3, :) = load_raw(2, :);
price = prices_intermediate' / 1000;
capacity = ones(2, 24) * 10000;
probability = 1 / 365;

Set_SegNum = [1, 2:2:200, 300];
Set_Error = zeros(1, length(Set_SegNum));
Set_Time = zeros(1, length(Set_SegNum));

for i = 1:length(Set_SegNum)
    ehc = caseN10B13;
    ehc.node(6, 10) = Set_SegNum(i);
    ehc.node(8, 10) = Set_SegNum(i);
    ehc.node(10, 10) = Set_SegNum(i);
    tic;
    [v, vin, S, objective] = runehopf( ehc, demand, price, capacity, probability );
    Set_Time(i) = toc;
    Set_Error(i) = abs(objective - 306.4203756680) / 306.4203756680 * 100;
end

plotyy(Set_SegNum(2:end - 1), Set_Error(2:end - 1), Set_SegNum(2:end - 1), Set_Time(2:end - 1));
Set = [Set_SegNum(2:end)', Set_Time(2:end)', Set_Error(2:end)'];