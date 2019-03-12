function [ v, vin, S, objective ] = runehopf_NonLin( ehc, demand, price, capacity, probability, v0, vin0, S0, ops )

Define_Consts;
load('NTI.mat');

[A, W, flag] = makeAW(ehc);
H = makeH(ehc);
Z2 = H{2} * A{2};
Z4 = H{4} * A{4};
[X, Y] = makeXY(ehc);

node = ehc.node;
branch = ehc.branch;
[In_Num, Out_Num] = IO_Num(ehc);
Branch_Num = size(X, 2);
T = size(demand, 2);
Scene_Num = length(probability);
T1 = T / Scene_Num;
vin_max = node(:, In_Max);

v = sdpvar(Branch_Num, T);
vin = sdpvar(In_Num, T);
counter_row = 0;
for i = 1:size(H, 1)
    counter_row = counter_row + size(cell2mat(H(i)), 1);
end
vinout0 = [vin; demand; zeros(counter_row, T)];

% 储能增加部分
S_max = [];
for i = 1:size(node, 1)
    Type_Node = node(i, Node_Type);
    if Type_Node > 0
        NTInfo = NT_Info(Type_Node, NTI);
        if NTInfo.info(4)
            S_max = [S_max; node(i, Para_f)];
        end
    end
end
S = sdpvar(size(S_max, 1), (T + 1));
S_raw = find(branch(:, Sink) == -2);
S_not_raw = find(branch(:, Sink) ~= -2);

Constraints = [];

for  t = 1:T
    H1 = [-0.00003041 * v(2, t)^2 + 0.01901 * v(2, t) + 0.2593, 1];
    H3 = [0.000115 * v(4, t) + 0.2305, 1, 0
        0.0001611 * v(4, t) + 0.3228, 0, 1];
    H5 = [-0.00005 * v(11, t) + 0.93, 1 / (-0.00005 * v(12, t) + 0.93), 1];
    Z1 = H1 * A{1};
    Z3 = H3 * A{3};
    Z5 = H5 * A{5};
    Z = [Z1; Z2; Z3; Z4; Z5];
    XYZ = [X; Y; Z];
    Constraints = [Constraints, XYZ * v(:, t) == vinout0(:, t)];
end

p1 = size(branch, 1);
p2 = 1;
for i = 1:size(branch, 1)
    Node_Source = branch(i, Source);
    Node_Sink = branch(i, Sink);
    
    if Node_Sink > 0    % 储能增加判断
        Type_Source = node(Node_Source, Node_Type);
        if Type_Source ~= -1
            Seg_Source = node(Node_Source, Seg_Num);
            if Seg_Source > 0.5
                NTInfo = NT_Info(Type_Source, NTI);
                if NTInfo.info(4)
                    vout_seg_max = vin_max(Node_Source) / Seg_Source * eye(Seg_Source);
                    u{p2} = binvar((Seg_Source - 1), T);
                    Ua = [u{p2}; zeros(1, T)];
                    Ub = [ones(1, T); u{p2}];
                    Constraints = [Constraints, vout_seg_max * Ua <= v((p1 + 1):(p1 + Seg_Source), :) <= vout_seg_max * Ub];
                    p2 = p2 + 1;
                end
                p1 = p1 + Seg_Source;
            end
        end
        
        Type_Sink = node(Node_Sink, Node_Type);
        if Type_Sink ~= 0
            NTInfo = NT_Info(Type_Sink, NTI);
            if (NTInfo.info(1) == 1 && NTInfo.info(2) == 1) || (NTInfo.info(1) == 1 && NTInfo.info(2) > 1 && NTInfo.info(3) == 0)
                Seg_Sink = node(Node_Sink, Seg_Num);
                if Seg_Sink > 0.5
                    vin_seg_max = vin_max(Node_Sink) / Seg_Sink * eye(Seg_Sink);
                    u{p2} = binvar((Seg_Sink - 1), T);
                    Ua = [u{p2}; zeros(1, T)];
                    Ub = [ones(1, T); u{p2}];
                    Constraints = [Constraints, vin_seg_max * Ua <= v((p1 + 1):(p1 + Seg_Sink), :) <= vin_seg_max * Ub];
                    p1 = p1 + Seg_Sink;
                    p2 = p2 + 1;
                end
            end
        end
    end
end

% (线性)设备出力约束
for i = 1:size(A, 1)
    k = i + In_Num + Out_Num;
    Seg_Node = node(k, Seg_Num);
    if ~Seg_Node  % MatEH4.2增加判断
        AA = A{i};
        AA = AA(1, 1:(size(branch, 1)));
        Constraints = [Constraints, AA * v(1:(size(branch, 1)), :) <= vin_max(k)];
        Type_Node = node(k, Node_Type);
        NTInfo = NT_Info(Type_Node, NTI);
        if NTInfo.info(4)
            AA = A{i};
            AA = -AA(2, 1:(size(branch, 1)));
            Constraints = [Constraints, AA * v(1:(size(branch, 1)), :) <= vin_max(k)];
        end
    end
end

% 储能增加部分
if(~isempty(S))
    Constraints = [Constraints, 0 <= S, S <= repmat(S_max, 1, (T + 1))];
    Constraints = [Constraints, S(:, 2:end) == S(:, 1:(end - 1)) + v(S_raw, :)];
    for i = 1:Scene_Num
        Constraints = [Constraints, S(:, ((i - 1) * T1 +1)) == S(:, (i * T1 + 1))];
    end
end

Constraints = [Constraints, vin >= 0, v(S_not_raw, :) >= 0];    % 增加储能后修改约束

Constraints = [Constraints, vin <= capacity];    % 能量枢纽输入约束

Objective = 0;
for i = 1:Scene_Num
    Objective = Objective + sum(sum(vin(:, ((i - 1) * T1 + 1):(i * T1)) .* price(:, ((i - 1) * T1 + 1):(i * T1)))) * 365 * probability(i);
end

if nargin == 9
    assign(v, v0);
    assign(vin, vin0);
    assign(S, S0);
    ops = sdpsettings(ops, 'usex0', 1);
    optimize(Constraints, Objective, ops);
elseif nargin == 8
    assign(v, v0);
    assign(vin, vin0);
    assign(S, S0);
    optimize(Constraints, Objective, sdpsettings('usex0', 1));
else
    optimize(Constraints, Objective);
end
objective = value(Objective);

end