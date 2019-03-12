function [ v, vin, S, objective ] = runehopf( ehc, demand, price, capacity, probability )

Define_Consts;
load('NTI.mat');

[A, W, flag] = makeAW(ehc);
H = makeH(ehc);
Z = makeZ(H, A);
[X, Y] = makeXY(ehc);
if flag
    XYZW = cell2mat([X; Y; Z; W]);
else
    XYZW = cell2mat([X; Y; Z]);
end

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
vinout0 = [vin; demand; zeros((size(XYZW, 1) - In_Num - Out_Num), T)];

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
Constraints = [Constraints, XYZW * v == vinout0];

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

optimize(Constraints, Objective);
objective = value(Objective);

end