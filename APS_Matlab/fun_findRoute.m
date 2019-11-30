function [SPL , SPR] = fun_findRoute(D , L , FS)

n = size(D,1);

S = FS(1);
SPR = num2str(S);
SPL = 0;
SPR_count = 1;

while S ~= FS(2)
    [temp,I] = max(D(S,:));
    SPR=[SPR,'->',num2str(I(1))];
    SPR_count = SPR_count + 1;
    D(S,I(1)) = 0;
    D(I(1),S) = D(I(1),S) - temp;
    SPL = SPL + L(S,I(1));
    
    S = I(1);
    
    if SPR_count >= n
        break;
    end
end