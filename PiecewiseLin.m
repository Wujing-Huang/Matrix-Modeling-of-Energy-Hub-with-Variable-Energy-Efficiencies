function [ h ] = PiecewiseLin( Para, In_Max, Seg_Num, flag )

if flag == 1  % out = a in^3 + b in^2 + c in + d
    Delta_In_Max = In_Max / Seg_Num;
    In = Delta_In_Max * (1:Seg_Num);
    Out = Para(1) * In.^3 + Para(2) * In.^2 + Para(3) * In + Para(4);
    Delta_Out_Max = diff([0, Out]);
    h = Delta_Out_Max / Delta_In_Max;
end

if flag == 2  % out1 = a in^2 + c in + e & out2 = b in^2 + d in + f
    Delta_In_Max = In_Max / Seg_Num;
    In = Delta_In_Max * (1:Seg_Num);
    Out1 = Para(1) * In.^2 + Para(3) * In + Para(5);
    Out2 = Para(2) * In.^2 + Para(4) * In + Para(6);
    Delta_Out1_Max = diff([0, Out1]);
    Delta_Out2_Max = diff([0, Out2]);
    h1 = Delta_Out1_Max / Delta_In_Max;
    h2 = Delta_Out2_Max / Delta_In_Max;
    h = [h1, h2];
end

if flag == 3  % in = ax^2 + by^2 + cxy + dx + ey + f
   a1 = Para(1);
   b1 = Para(4);
   c1 = Para(6) / 2;
   a2 = Para(2) - Para(3)^2 / (4 * Para(1));
   b2 = Para(5) - Para(3) * Para(4) / (2 * Para(1));
   c2 = Para(6) / 2;
end

if flag == 4  % efficieney = a power^3 + b power^2 + c power + d
    Delta_In_Max = In_Max / Seg_Num;
    P1 = [0, Delta_In_Max * (1:(Seg_Num - 1))];
    P2 = Delta_In_Max * (1:Seg_Num);
    P = (P1 + P2) / 2;
    h = Para(1) * P.^3 + Para(2) * P.^2 + Para(3) * P + Para(4);
end

end

