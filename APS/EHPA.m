function [iter, SPL, D] = EHPA( L, S, E, t2 )

warning off all
warning on Simulink:actionNotTaken
L(L==0) = inf;


%---------------------------------initialization---------------------------------
n = size(L,1);    % number of nodes
D = triu(0.5*ones(n), 1);

flag = 1;   % loop end condition
iter = 0;  % 

b = zeros(n+1,1);
b(S) = -1;
b(E) = 1;

Q_pre=zeros(n,n);   % previous flow matrix
Q_record=zeros(n,n);  %flow change

C1=log10(n);

while flag ~= 0
    iter = iter + 1;
    
    %----------------------------pressure --------------begin 
    % ¹
    var_D_L = triu(D./L,1);
    var_P_M = var_D_L + var_D_L';
    var_P_A = var_P_M - diag(sum(var_P_M));
    var_P_A = [var_P_A;zeros(1,n)];
    var_P_A(n+1, E) = 1;
    
    % 
    var_P = var_P_A\b;

    %----------------------------pressure----------------end 
    
    %----------------------------Q and D------------------begin
    var_Q = zeros(n,n);
    for i = 1:n-1
        for j = i+1:n
            % compute Q
            var_Q(i,j) = (var_D_L(i,j)) * (var_P(i) - var_P(j));

            %update 
            k = abs(var_Q(i,j)) - abs(Q_pre(i,j));
            if k >= -10^(-7) && k <= 10^(-7) % flow remain same
                                
            elseif k < 0  %less flow
                if Q_record(i,j) <= 0
                    Q_record(i,j) = Q_record(i,j) - 1;
                    % 
                    if Q_record(i,j) <= -(2+ceil(10*abs(var_Q(i,j)))+C1)
                        var_Q(i,j) = 0;
                        Q_record(i,j) = 0;
                    end
                else
                    Q_record(i,j) = -1;
                end
            else  % more flow
                if Q_record(i,j) >= 0
                    Q_record(i,j) = Q_record(i,j) + 1;
                else
                    Q_record(i,j) = 1;
                end
            end
            if var_Q(i,j) == 0
                D(i,j) = 0;
                D(j,i) = 0;
            else
                D(i,j) = 0.5*(abs(var_Q(i,j)) + D(i,j));
                D(j,i) = D(i,j);
            end
        end
    end
    %-------------------------------------------------------------------end
    
    
    
    %----------------------------loop stop condition-----------begin
    var_temp = abs(var_Q - Q_pre);
    var_temp_max = max(max(var_temp));
    if var_temp_max < 10^(-5)
        flag = 0;
    end
    
    CPUTime = toc(t2);
    if CPUTime > 100
        break;
    end
    
    %---------------------------- -------------end
    Q_pre = var_Q;
end
[SPL, ~] = fun_findRoute(D , L , [S,E]);
end