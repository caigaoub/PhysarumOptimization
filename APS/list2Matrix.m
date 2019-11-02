m = size(EuCoreNet,1);
n = max(max(EuCoreNet));
EuCoreMatrix = zeros(n,n);
for i = 1:m
    temp = rand()*10 + 1;
    EuCoreMatrix(EuCoreNet(i,1),EuCoreNet(i,2)) = temp;
    EuCoreMatrix(EuCoreNet(i,2),EuCoreNet(i,1)) = temp;
end

    