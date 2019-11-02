clc
clear
load("realWorld.mat");

distMatrix = BMPFMat;
numNodes = size(distMatrix,1);
S = 0;
E = 0;
maxSteps = 50;
totalIterations = zeros(maxSteps,3);
totalTime = zeros(maxSteps,3);
i =  1;
count = 0;
while i <= maxSteps
    i
    while true
        S = randi([1,numNodes]);
        E = randi([1,numNodes]);
        if S ~=E
            if S~=105 && E ~=105
                break;
            end        
        end
    end
    [S E]
    t1 = tic;
    [itrs1] = PhysarumSolver(distMatrix,numNodes,S,E, t1);
    %     if multiPathsFlag == false
    CPUTime1 = toc(t1);
    totalTime(i,1) = CPUTime1;
    totalIterations(i,1) = itrs1;
    a = 1
    t2 = tic;
    [itrs2,lens2] = EHPA(distMatrix,S,E,t2);
    CPUTime2 = toc(t2);
    totalTime(i,2) = CPUTime2;
     totalIterations(i,2) = itrs2;
    a = 2
    t3 = tic;
    [itrs3, lens3] = FastPhysarumSolver(distMatrix,numNodes,S,E);
    CPUTime3 = toc(t3);
    totalTime(i,3) = CPUTime3;
    totalIterations(i,3) = itrs3;
    a =3
    if lens2 ~= lens3
        count = count + 1;
        [i, S, E]
    end
    i = i + 1;
    %     end
end


