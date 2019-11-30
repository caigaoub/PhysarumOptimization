clear;
clc;
n = 800;
L1 = randi([1,100],n,n);

L = triu(L1,1)' + triu(L1,1);

RPS_C_800 = L;


% 
% flag = 1;
% while flag == 1
%     
%     n = 2000;
%     network = zeros(n,n);
%     p = 0.006;
%     for i = 1:n
%         for j=i+1:n
%             if rand() <= p
%                 network(i,j) = randi([1,10000]);
%             end
%         end
%     end
%     
%     network = network' + network;
%     
%     if sum(sum(network,1) == 0) == 0
%         find(sum(network,1)==0)
%         disp(['one component graph'])
%         flag = 2;
%         numNodes = n;
%         numEdges = sum(sum(network~=0))/2;
%         
%         RPS_S_2000 = network;
%     end
%     
%     
% end