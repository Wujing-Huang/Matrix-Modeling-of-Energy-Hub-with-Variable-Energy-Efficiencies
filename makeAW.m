function [ A, W, flag ] = makeAW( ehc )

Define_Consts;
load('NTI.mat');

[In_Num, Out_Num] = IO_Num(ehc);
node = ehc.node;
branch = ehc.branch;
Node_Num = size(node, 1) - In_Num - Out_Num;
Branch_Num = size(branch, 1);

flag = 0;
pointer = Branch_Num;

Branch_NumTemp = Branch_Num;
for i = 1:Branch_Num
    Node_Source = branch(i, Source);
    Node_Sink = branch(i, Sink);
    
    if Node_Sink > 0    % 储能元件增加判断（SOC支路不拆分）
        Type_Source = node(Node_Source, Node_Type);
        if Type_Source ~= -1
            Seg_Source = node(Node_Source, Seg_Num);
            if Seg_Source > 0.5
                temp = [(branch(end, Node_I) + 1:branch(end, Node_I) + Seg_Source)', ...
                    ones(Seg_Source, 1) * branch(i, Branch_Type), ...
                    ones(Seg_Source, 1) * branch(i, Source), ...
                    zeros(Seg_Source, 1), ...
                    (1:Seg_Source)'];
                branch = [branch; temp];
                branch(i, Source) = 0;
                Branch_NumTemp = Branch_NumTemp + Seg_Source;
                
                temp = cell(1, 2);
                temp(1, 1) = {i};
                temp(1, 2) = {(pointer + 1):(pointer + Seg_Source)};
                pointer = pointer + Seg_Source;
                if flag
                    W_Raw = [W_Raw; temp];
                else
                    W_Raw = temp;
                    flag = 1;
                end
            end
        end
        
        Type_Sink = node(Node_Sink, Node_Type);
        if Type_Sink ~= 0
            Seg_Sink = node(Node_Sink, Seg_Num);
            if Seg_Sink > 0.5
                temp = [(branch(end, Node_I) + 1:branch(end, Node_I) + Seg_Sink)', ...
                    ones(Seg_Sink, 1) * branch(i, Branch_Type), ...
                    zeros(Seg_Sink, 1), ...
                    ones(Seg_Sink, 1) * branch(i, Sink), ...
                    (1:Seg_Sink)'];
                branch = [branch; temp];
                branch(i, Sink) = 0;
                Branch_NumTemp = Branch_NumTemp + Seg_Sink;
                
                temp = cell(1, 2);
                temp(1, 1) = {i};
                temp(1, 2) = {(pointer + 1):(pointer + Seg_Sink)};
                pointer = pointer + Seg_Sink;
                if flag
                    W_Raw = [W_Raw; temp];
                else
                    W_Raw = temp;
                    flag = 1;
                end
            end
        end
    end
end
Branch_Num = Branch_NumTemp;

A = cell(Node_Num, 1);
for i = 1:Node_Num
    k = i + In_Num + Out_Num;
    NTInfo = NT_Info(node(k, Node_Type), NTI);
    if node(k, Seg_Num) > 0
        if ~NTInfo.info(4)  % 储能（非线性）增加判断
            temp = zeros(size(NTInfo.port, 2) * node(k, Seg_Num), Branch_Num);
        else
            temp = zeros((2 * node(k, Seg_Num) + 1), Branch_Num);
        end
    else
        temp = zeros(size(NTInfo.port, 2), Branch_Num);
    end
    A(i, 1) = {temp};
end

for i = 1:Branch_Num
    Node_Source = branch(i, Source);
    Node_Sink = branch(i, Sink);
    
    if Node_Source > 0
        Type_Source = node(Node_Source, Node_Type);
        if Type_Source ~= -1
            NTInfo = NT_Info(Type_Source, NTI);% Get the information of source node.
            
            if ~NTInfo.info(4)
                if node(Node_Source, Seg_Num) > 0
                    NTInfo.port = repmat(NTInfo.port, node(Node_Source, Seg_Num), 1);
                    NTInfo.port = NTInfo.port(:);
                    A_row = find(NTInfo.port == branch(i, Branch_Type), 1);% Decide which row in A to fill.
                    A{Node_Source - In_Num - Out_Num}(A_row + branch(i, Branch_Class) - 1, i) = -1;
                else
                    A_row = find(NTInfo.port == branch(i, Branch_Type), 1);% Decide which row in A to fill.
                    A{Node_Source - In_Num - Out_Num}(A_row, i) = -1;
                end
            else    % 储能元件增加部分
                if Node_Sink < 0
                    A{Node_Source - In_Num - Out_Num}(end, i) = -1;
                else
                    if node(Node_Source, Seg_Num) > 0
                        A_row = (node(Node_Source, Seg_Num) + 1); % Decide which row in A to fill.
                        A{Node_Source - In_Num - Out_Num}(A_row + branch(i, Branch_Class) - 1, i) = -1;
                    else
                        A{Node_Source - In_Num - Out_Num}(2, i) = -1;
                    end
                end
            end
        end
    end
    
    if Node_Sink > 0
        Type_Sink = node(Node_Sink, Node_Type);
        if Type_Sink ~= 0
            NTInfo = NT_Info(Type_Sink, NTI);% Get the information of sink node.
            
            if ~NTInfo.info(4)
                if node(Node_Sink, Seg_Num) > 0
                    NTInfo.port = repmat(NTInfo.port, node(Node_Sink, Seg_Num), 1);
                    NTInfo.port = NTInfo.port(:);
                    A_row = find(NTInfo.port == branch(i, Branch_Type), 1);% Decide which row in A to fill.
                    A{Node_Sink - In_Num - Out_Num}(A_row + branch(i, Branch_Class) - 1, i) = 1;
                else
                    A_row = find(NTInfo.port == branch(i, Branch_Type), 1);% Decide which row in A to fill.
                    A{Node_Sink - In_Num - Out_Num}(A_row, i) = 1;
                end
            else  % 储能元件增加部分
                if node(Node_Sink, Seg_Num) > 0
                    A{Node_Sink - In_Num - Out_Num}(branch(i, Branch_Class), i) = 1;
                else
                    A{Node_Sink - In_Num - Out_Num}(1, i) = 1;
                end
            end
        end
    end
end

if flag
    W = sparse(1:size(W_Raw, 1), cell2mat(W_Raw(:, 1)), ones(1, size(W_Raw, 1)), size(W_Raw, 1), Branch_Num);
    for i = 1:size(W_Raw, 1)
        W(i, cell2mat(W_Raw(i, 2))) = -1;
    end
    W = full(W);
else
    W = [];
end

end