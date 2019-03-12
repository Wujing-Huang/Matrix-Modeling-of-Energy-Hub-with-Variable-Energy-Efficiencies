function [ X, Y ] = makeXY( ehc )

Define_Consts;

node = ehc.node;
branch = ehc.branch;
Branch_Num = size(branch, 1);
[In_Num, Out_Num] = IO_Num(ehc);

X = zeros(In_Num, Branch_Num);
for i = 1:In_Num
    for j = 1:Branch_Num
        if branch(j, Source) == i
            X(i, j) = 1;
        end
    end
end

Y = zeros(Out_Num, Branch_Num);
for i = (In_Num + 1):(In_Num + Out_Num)
    for j = 1:Branch_Num
        if branch(j, Sink) == i
            Y(i - In_Num, j) = 1;
        end
    end
end

counter = 0;
for i = 1:Branch_Num
    Node_Source = branch(i, Source);
    Node_Sink = branch(i, Sink);
    
    if Node_Sink > 0    % 储能元件增加判断
        Type_Source = node(Node_Source, Node_Type);
        if Type_Source ~= -1
            Seg_Source = node(Node_Source, Seg_Num);
            if Seg_Source > 0.5
                counter = counter + Seg_Source;
            end
        end
        
        Type_Sink = node(Node_Sink, Node_Type);
        if Type_Sink ~= 0
            Seg_Sink = node(Node_Sink, Seg_Num);
            if Seg_Sink > 0.5
                counter = counter + Seg_Sink;
            end
        end
    end
end

if counter > 0.5
    X = [X, zeros(In_Num, counter)];
    Y = [Y, zeros(Out_Num, counter)];
end

end