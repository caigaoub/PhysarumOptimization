function testDFS(net6)
sizeN = size(net6,1);
adjList = cell(6,1);
for i = 1: sizeN
    adjList(i) = {find(net6(i,:) > 0)};
end
distMatrix = net6;
mainDFS(adjList,sizeN,distMatrix);
end


function mainDFS(adjList,sizeN,distMatrix)

global source;

source = 1;

global discovered;
discovered = false(sizeN,1);

global numPaths;
numPaths = 0;

global distPaths;
distPaths =[];

global curDist;
curDist = 0;
discovered(source) = true;
DFS(source, adjList, distMatrix);

end

function  DFS(curNode, adjList, distMatrix)
sink = 6;

global discovered;
global numPaths;
global distPaths;
global curDist;


discovered(curNode) = true;
if curNode == sink
    numPaths = numPaths + 1;
    distPaths = [distPaths;curDist];
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
            curDist = curDist + distMatrix(curNode,nextNode);
            DFS(nextNode, adjList, distMatrix);
            discovered(nextNode) = false;
            curDist = curDist - distMatrix(curNode,nextNode);
        end

    end
end
end