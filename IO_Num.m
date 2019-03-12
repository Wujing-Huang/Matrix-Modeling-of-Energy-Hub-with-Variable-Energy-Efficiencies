function [ In_Num, Out_Num ] = IO_Num( ehc )

Define_Consts;

node = ehc.node;

In_Num = 0;
Out_Num = 0;

for i = 1:size(node, 1)
    if node(i, Node_Type) == -1
        In_Num = In_Num + 1;
    elseif node(i, Node_Type) == 0
        Out_Num = Out_Num + 1;
    end
end

end
