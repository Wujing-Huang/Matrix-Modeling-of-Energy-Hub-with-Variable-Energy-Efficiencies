function [ Z ] = makeZ( H, A )

Node_Num = size(A, 1);
Z = cell(Node_Num, 1);

for i = 1:Node_Num
    Z(i, 1) = {H{i} * A{i}};
end

% for i = 1:Node_Num
%     Z(i, 1) = {cell2mat(H(i, 1)) * cell2mat(A(i, 1))};
% end

end