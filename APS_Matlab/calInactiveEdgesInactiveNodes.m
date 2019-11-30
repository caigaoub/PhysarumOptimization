function [IE,IN,totalIterations] = calInactiveEdgesInactiveNodes(distMatrix,numNodes,S,E)


warning off all
warning on Simulink:actionNotTaken
numEdges = sum(sum(distMatrix ~= 0))/2 ;


distMatrix(distMatrix == 0) = inf;

conducMatrix= ones(numNodes,numNodes);
conducMatrix(distMatrix==inf) = 0;

source = S;
sink = E;

totalIterations = 0;   

smallestConducLimit = 10^-5;
smallestGap=10^-5;
curGap = 1;
IE = [];
IN = [];
while totalIterations < 30
    %% solve a linear equation system
    coefMatrix = conducMatrix./distMatrix;
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
    numInactiveEdges = 0;
    for i=1:numNodes
        for j= i+1:numNodes
            if (conducMatrix(i,j) < 10^(-5) && flowMatrix(i,j) < 10^(-5) && distMatrix(i,j) ~= inf)
                numInactiveEdges = numInactiveEdges + 1;
            end
        end
    end
    %     numActiveEdges = sum(sum(conducMatrix ~= 0))/2;
    
%     numInactiveEdges = numEdges - numActiveEdges;
    
%     DSum = sum(conducMatrix,1);
%     QSum = sum(abs(flowMatrix),1);
%     numInactiveNodes = 0;
%     for i=1:numNodes
%         if DSum(i)< 10^(-5)&& QSum(i) < 10^(-5)
%             numInactiveNodes = numInactiveNodes + 1;
%         end
%     end
%     
    numInactiveNodes = sum(sum(conducMatrix,1)==0);
    
    IE = [IE,numInactiveEdges];
    IN = [IN,numInactiveNodes];
    curGap=sum(sum(abs(conducMatrix-oldDMatrix)));
 
    totalIterations = totalIterations + 1;

    
end

end



