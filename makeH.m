function [ H ] = makeH( ehc )

Define_Consts;
load('NTI.mat');

[In_Num, Out_Num] = IO_Num(ehc);
node = ehc.node;
Node_Num = size(node, 1) - In_Num - Out_Num;

H = cell(Node_Num, 1);

for i = 1:Node_Num
    k = i + In_Num + Out_Num;
    NTInfo = NT_Info(node(k, Node_Type), NTI);
    
    if ~NTInfo.info(4)
        if node(k, Seg_Num) > 0.5
            if NTInfo.info(1) == 1 && NTInfo.info(2) == 1 % Case1 SISO
                h = PiecewiseLin(node(k, Para_a:Para_d), node(k, In_Max), node(k, Seg_Num), 1);
                temp = [diag(h), eye(node(k, Seg_Num))];
                H(i, 1) = {temp};
            elseif NTInfo.info(1) == 1 && NTInfo.info(2) > 1 % Case2 SIMO
                if ~NTInfo.info(3) % The ratio of output cannnot be adjusted ( back pressure operation ).
                    h = PiecewiseLin(node(k, Para_a:Para_f), node(k, In_Max), node(k, Seg_Num), 2);
                    temp = zeros((NTInfo.info(2) * node(k, Seg_Num)), ((NTInfo.info(1) + NTInfo.info(2)) * node(k, Seg_Num)));
                    counter = 1;
                    for j = 1:NTInfo.info(2)
                        for l = 1:node(k, Seg_Num)
                            temp(counter, l) = h(counter);
                            temp(counter, node(k, Seg_Num) + counter) = 1;
                            counter = counter + 1;
                        end
                    end
                else
                    
                end
                H(i,1)={temp};
            elseif NTInfo.info(1) > 1 && NTInfo.info(2) == 1 % Case3 MISO
                
            elseif NTInfo.info(1) > 1 && NTInfo.info(2) > 1 % Case4 MIMO
                
            end
            
        else
            if NTInfo.info(1) == 1 && NTInfo.info(2) == 1 % Case1 SISO
                H(i, 1)={[node(k, Para_c), 1]};
            elseif NTInfo.info(1) == 1 && NTInfo.info(2) > 1 % Case2 SIMO
                if ~NTInfo.info(3) % The ratio of output cannnot be adjusted ( back pressure operation ).
                    temp = zeros(NTInfo.info(2), NTInfo.info(1) + NTInfo.info(2));
                    for j = 1:NTInfo.info(2)
                        temp(j, 1) = node(k, end - 4 - NTInfo.info(2) + j);  %%
                        temp(j, j + 1) = 1;
                    end
                else
                    temp(1, 1) = 1;
                    for j = 1:NTInfo.info(2)
                        temp(1, j + 1)= node(k, end - 3 - NTInfo.info(2) + j);  %%
                    end
                end
                H(i,1)={temp};
            elseif NTInfo.info(1) > 1 && NTInfo.info(2) == 1 % Case3 MISO
                
            elseif NTInfo.info(1) > 1 && NTInfo.info(2) > 1 % Case4 MIMO
                
            end
        end
    else    % 储能元件增加部分
        if node(k, Seg_Num) > 0.5
            h = PiecewiseLin(node(k, Para_a:Para_d), node(k, In_Max), node(k, Seg_Num), 4);
            H(i, 1)={[h, 1 ./ h, 1]};
        else
            H(i, 1)={[node(k, Para_d), 1 / node(k, Para_d), 1]};
        end
    end
end

end