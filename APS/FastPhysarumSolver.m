function [totalNumIteration,sd] = FastPhysarumSolver(distMatrix,numNodes, S, E)
%% Author: Cai Gao   Date: Jan. 13, 2018
%% This function takes two strategies to accelerate the physarum solver to find the shortest path
%% Params: distMatrix -->     distance matrix
%%         numNodes   -->     number of nodes in the network
%%            S       -->     index of source 
%%            E       -->     index of sink   
%% Return: totalNumIteration
%%         duration: the CPU running time of this program

%%
% startTime = cputime;

%% set up source and sink
global source;
global sink;
source = S;
sink = E;

%% number of edges in the original graph
numEdges = sum(sum(distMatrix > 0));

%% build distance matrix and conductivity matrix
distMatrix(distMatrix == 0) = inf;
%conducMatrix= sparse(ones(numNodes,numNodes));
conducMatrix= ones(numNodes,numNodes);
conducMatrix(distMatrix==inf) = 0;


%% some restricted parameters for the algorithm
smallestConducLimit =0.00001; % threshold of conductivity
activeEdgeConducLimit = 0.0001;
warmUpSteps = 15;

oneTimeFlag = false; %once a amount of edges turn into inactive edges, we start prunning inactive nodes


%% total number of inner iterations
totalNumIteration = 0;
global recordPaths;

%% some parameters used for the new smaller graph

global newSourceIdx; % new index of the source in the smaller graph
newSourceIdx = source; 
global newSinkIdx; % new index of the sink in the smaller graph
newSinkIdx = sink;

newNumNodes = numNodes; % the number of nodes in the smaller graph
oldNumNodes = numNodes;

global newIndexSet; % a vecotor to record the orginial index of nodes in the smaller graph
global oldIndexSet;
oldIndexSet = 1:numNodes;

%--------------------------- start iterating ------------------------------ 
while true
 
    %% ===> Step 1: solve a linear equations system
    % --- create coefficient matrix A
    coefMatrix = conducMatrix./distMatrix;  
    for i = 1:newNumNodes
        coefMatrix(i,i) = -sum(coefMatrix(i,:));
    end
    coefMatrix(newNumNodes + 1, :) = 0;
    coefMatrix(newNumNodes + 1, newSinkIdx) = 1;
    
    % --- create vector b
    b = zeros(newNumNodes + 1, 1); 
    b(newSourceIdx) = -1;
    b(newSinkIdx) = 1;
    
    % --- solve Ax=b
    pressureVector = coefMatrix\b; 
    
    %% ===> Step 2:  compute the flow matrix
    P1 = meshgrid(pressureVector);
    flowMatrix=(P1'-P1).* coefMatrix(1:newNumNodes,:);
    
    %% ===> Step 3:  update the conductivity matrix
    oldDMatrix = conducMatrix;
    conducMatrix = 0.5 * (abs(flowMatrix) + conducMatrix);    
   
    
    %% Cut edges that have almost zero flow
    conducMatrix(conducMatrix < smallestConducLimit) = 0;
    
    curGap=sum(sum(abs(conducMatrix-oldDMatrix)));
    
    if curGap < smallestConducLimit
        break;
    end
    
    
    %% total number of iterations
    totalNumIteration = totalNumIteration + 1;
    %% let program warm up for a couple of iterations
    if totalNumIteration <= warmUpSteps
        continue;
    else
        %% Acceleration Strategy II: find the shortest path from a  special graph that contains "near optimal paths"
        deltaConduc = conducMatrix - oldDMatrix;
        sizeN = size(deltaConduc,1); % the size of the current graph
        adjList = cell(sizeN,1); % adjList is adjacent list of graphs that has "Pi-Pj >= Lij" edge !!
%         [totalNumIteration, sizeN]
        for i = 1: sizeN
            vecTmp = [];
            for j = 1: sizeN
                if deltaConduc(i,j) > 0 && pressureVector(i) > pressureVector(j)
                    vecTmp = [vecTmp, j];                   
                end           
            end
            adjList(i) = {vecTmp};
        end
        
        recordPaths = [];
        mainDFS(adjList,sizeN,distMatrix);
        
        [sd, idxSP, fluxCoverage] = getCurrentOptimalPath(distMatrix, flowMatrix);
        % if those near optimal pathss cover more than 80 per. of flux, we
        % claim that we find the shortest path
        if fluxCoverage > 0.6 && length(recordPaths) < 10
%             disp(['The shortest distance is ', num2str(sd)]);
            disp(oldIndexSet(recordPaths{idxSP}));
            break;
        end
        
        %% Acceleration Strategy I: prunning inactive nodes

        if oneTimeFlag == false
            numInactiveEdges = sum(sum(conducMatrix > smallestConducLimit));
            if  (numEdges - numInactiveEdges)/numEdges > 0.4 % if over 60% of edges have been cutted, start prunning inactive nodes
                oneTimeFlag = true;
            end
        end
        
        if  oneTimeFlag == true
            idx = find(sum(conducMatrix > activeEdgeConducLimit) > 0); % get index of the active nodes
            newNumNodes = length(idx); % number of nodes in the new smaller graph
            if newNumNodes < oldNumNodes % if graph'size get smaller
                newIndexSet = idx;
                updateLabels();
                
                distMatrix = distMatrix(idx,idx); % smaller distance matrix
                conducMatrix = conducMatrix(idx,idx); % smaller conductivity matrix
                oldNumNodes = newNumNodes; % the number of nodes in the smaller graph
            end
        end
        
    end
    
end

% duration = cputime - startTime;
%disp(['CPU time: ', num2str(duration)]);
end

function  updateLabels()
%% This function is used to update the node labels for the new smaller graph 
global newIndexSet;
global oldIndexSet;
global source;
global sink;
global newSourceIdx;
global newSinkIdx;

lens = length(newIndexSet);
for i = 1:lens
    idxTmp = newIndexSet(i);
    newIndexSet(i) = oldIndexSet(idxTmp);
    if oldIndexSet(idxTmp) == source
        newSourceIdx = i;          
    elseif  oldIndexSet(idxTmp)== sink
        newSinkIdx = i;    
    end
end
oldIndexSet = newIndexSet;
end



function mainDFS(adjList,sizeN,distMatrix)
%% This mainDFS function to call DFS (depth first search) to find all near-optimal paths

global newSourceIdx;

global discovered;
discovered = false(sizeN,1);

global curPath;
curPath = newSourceIdx;

discovered(newSourceIdx) = true;
DFS(newSourceIdx, adjList, distMatrix);

end

function  DFS(curNode, adjList, distMatrix)
%% This is a sub-function for 'mainDFS' to recursively find all near-optimal paths

global discovered;

global recordPaths;
global curPath;
global newSinkIdx;

discovered(curNode) = true;
if curNode == newSinkIdx
    recordPaths = [recordPaths;{curPath}];
    return;
end

idx = find(discovered(adjList{curNode}') == false);

if isempty(idx)
    return; % all its leaves are discovered
else
    lens = size(idx,1);
    for i = 1:lens
        nextNode = adjList{curNode}(idx(i));
        if discovered(nextNode) == false
            curPath = [curPath, nextNode];
            DFS(nextNode, adjList, distMatrix);
            discovered(nextNode) = false;
            curPath(end) = [];
         
        end
        
    end
end
end

function [sd, idxSP, fluxCoverage] = getCurrentOptimalPath(distMatrix, flowMatrix)
%% This function is used for obtaining the current shortest path among those near-optimal paths
% Parameters: flowMatrix, distMatrix
% Return: fluxCoverage is the total flux on these near-optimal paths
% and sd is the length of shortest near-optimal path

global recordPaths;

sd = inf;
idxSP = inf;
fluxCoverage = 0;
% maxCond = 0;
% numPaths: the number of near-optimal paths that we find
numPaths = length(recordPaths);
if numPaths == 0

    return;
else    
%     condTmp = inf;
    minFlux = inf;
    for i = 1:numPaths
        % lensPath: the length of the i-th near-optimal path
        lensPath = length(recordPaths{i});          
        % distTmp: the total length of  the i-th near-optimal path
        distTmp = 0;
        for j= 1: lensPath - 1
            curIdx = recordPaths{i}(j);
            nextIdx = recordPaths{i}(j+1);
            distTmp = distTmp + distMatrix(curIdx, nextIdx);
            
            if flowMatrix(curIdx, nextIdx) < minFlux
                minFlux = flowMatrix(curIdx, nextIdx);
            end
%             if  conducMatrix(curIdx, nextIdx) < condTmp
%                 condTmp = conducMatrix(curIdx, nextIdx);
%             end
        end       
      
        if distTmp < sd
            sd = distTmp;
            idxSP = i;
        end
%       
        fluxCoverage = fluxCoverage + minFlux;
%         if maxCond < condTmp
%             maxCond = condTmp;
%         end
    end
    
end

end



