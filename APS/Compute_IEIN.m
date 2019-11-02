clc
clear
load("CG_Data_Complete.mat");

distMatrix = RPS_C_1200;
numNodes = size(distMatrix,1);
S = 0;
E = 0;
maxSteps = 10;
IESet = cell(maxSteps,1);
INSet = cell(maxSteps,1);
totalItr = 0;
minItr = inf;
for i = 1:maxSteps
    i
    while true
        S = randi([1,numNodes]);
        E = randi([1,numNodes]);
        if S ~=E
            break;
        end
    end
%     distMatrix = distMatrix/10000;
    [IE,IN, itrs] = calInactiveEdgesInactiveNodes(distMatrix,numNodes,S,E);
    totalItr = totalItr + itrs;
    if (itrs < minItr)
        minItr = itrs;
    end
    IESet(i) = {IE};
    INSet(i) = {IN};
end
averageIE = zeros(minItr,1);
averageIN = zeros(minItr,1);
for i = 1:maxSteps
    for j= 1:minItr
        averageIE(j) = averageIE(j) + IESet{i}(j);
        averageIN(j) = averageIN(j) + INSet{i}(j);
    end    
end

% averageIE =  (averageIE / maxSteps)/(11950);
% averageIN = (averageIN / maxSteps) / 2000;
% averageItr = totalItr / maxSteps;

averageIE = 2* (averageIE / maxSteps)/(numNodes*numNodes -numNodes);
averageIN = (averageIN / maxSteps) / numNodes;
averageItr = totalItr / maxSteps;
