clc
clear
load("realWorld.mat");

distMatrix = Ahm;
numNodes = size(distMatrix,1);
S = 0;
E = 0;
maxSteps = 10;
totalItr1 = 0;
totalTime1 = 0;
totalItr2 = 0;
totalTime2 = 0;
totalItr3 = 0;
totalTime3 = 0;
i =  1;
while i <= maxSteps
    i
    while true
        S = randi([1,numNodes]);
        E = randi([1,numNodes]);
        if S ~=E
            break;
        end
    end
    t1 = tic;
    [itrs1] = PhysarumSolver(distMatrix,numNodes,S,E, t1);
    %     if multiPathsFlag == false
    CPUTime1 = toc(t1);
    totalTime1 = totalTime1 + CPUTime1;
    totalItr1 = totalItr1 + itrs1;
    
    t2 = tic;
    [itrs2,lens2] = EHPA(distMatrix,S,E);
    CPUTime2 = toc(t2);
    totalTime2 = totalTime2 + CPUTime2;
    totalItr2 = totalItr2 + itrs2;
    
    t3 = tic;
    [itrs3, lens3] = FastPhysarumSolver(distMatrix,numNodes,S,E);
    CPUTime3 = toc(t3);
    totalTime3 = totalTime3 + CPUTime3;
    totalItr3 = totalItr3 + itrs3;
    i = i + 1;
    %     end
end

totalItr1 = totalItr1 / maxSteps;
totalTime1 = totalTime1 / maxSteps;

totalItr2 = totalItr2 / maxSteps;
totalTime2= totalTime2 / maxSteps;

totalItr3 = totalItr3 / maxSteps;
totalTime3= totalTime3 / maxSteps;

