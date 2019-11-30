function [totalIterations,conducMatrix] = PhysarumSolver(distMatrix,numNodes,S,E,t1)
distMatrix(distMatrix == 0) = inf;

conducMatrix= ones(numNodes,numNodes);
%conducMatrix(distMatrix==inf) = 0;

source = S;
sink = E;

totalIterations = 0;   

smallestConducLimit = 10^-5;
smallestGap=10^-5;
curGap = 1;

while curGap > smallestGap
    %% solve a linear equation system
    coefMatrix = conducMatrix./distMatrix;
 %   totalIterations
    for i = 1:numNodes 
        coefMatrix(i,i) = -sum(coefMatrix(i,:));
    end
    
    coefMatrix(numNodes + 1, :) = 0;
    coefMatrix(numNodes + 1, sink) = 1;
    
    % --- create vector b
    b = zeros(numNodes + 1, 1); 
    b(source) = -1;
    b(sink) = 1;
    
    pressureVector = coefMatrix\b;   
        
    P1 = meshgrid(pressureVector);
    flowMatrix=(P1'-P1).* coefMatrix(1:numNodes,:);
    
    oldDMatrix = conducMatrix;

    conducMatrix = 0.5 * (abs(flowMatrix) + conducMatrix);
 %   conducMatrix(distMatrix == inf) = 0;

    conducMatrix(conducMatrix < smallestConducLimit) = 0;
    
    
    curGap=sum(sum(abs(conducMatrix-oldDMatrix)));
 
    totalIterations = totalIterations + 1;
%     cpuTime = toc(t1);
%     if cpuTime > 100
%         break;
%     end
    if  totalIterations > 300
        break;
    end
    
end
% multiPathsFlag = false;
% k = sum(sum(sum(conducMatrix(conducMatrix<0.95 & conducMatrix))));
% if k~=0 
%     multiPathsFlag = true;
% end
end



