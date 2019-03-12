function [ NTInfo ] = NT_Info( typeNum, NTI )
% Return corresponding information of certain node
% NTI = formNTI;
NTInfo.port = [NTI(typeNum).input, NTI(typeNum).output]; % Determine the sequence of ports in matrix A.
NTInfo.info = [size(NTI(typeNum).input, 2), size(NTI(typeNum).output, 2), NTI(typeNum).adj, NTI(typeNum).storage]; % Input port number,Output port number,adjustability.
end