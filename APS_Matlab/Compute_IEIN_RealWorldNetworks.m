clc
clear
load("realWorld.mat");

distMatrix = BMPFMat;
numNodes = size(distMatrix,1);
S = 0;
E = 0;
maxSteps = 50;
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
            if S~=105 && E ~= 105
             break;
            end
        end
    end
    [S E]
    [IE,IN, itrs] = calInactiveEdgesInactiveNodes(distMatrix,numNodes,S,E);
    totalItr = totalItr + itrs;
    if (itrs < minItr)
        minItr = itrs;
    end
    IESet(i) = {IE};
    INSet(i) = {IN};
end
IEResults = zeros(maxSteps, minItr);
INResults = zeros(maxSteps, minItr);
for i = 1:maxSteps
    for j= 1:minItr
        IEResults(i,j) = IESet{i}(j);
        INResults(i,j) = INSet{i}(j);
    end    
end
% x = 1:minItr;
% meanIE = mean(IEResults,1);
% stdIE = std(IEResults,1);
% errorbar(x,meanIE,stdIE,'DisplayName','IE','Marker','*','Color',[1 0 0]);
% hold on
% meanIN = mean(INResults,1);
% stdIN = std(INResults,1);
% errorbar(x,meanIN,stdIN,'DisplayName','IN','Marker','*','Color',[0 1 0]);
% hold off