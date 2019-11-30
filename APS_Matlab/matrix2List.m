function [adjList,m] =  matrix2List(adjMat)
 n = size(adjMat,1);
 
 m = (n*n - n)/2;
 adjList = zeros(m,3);
 count = 1;
 temp = zeros(1,3);
 for i=1:n-1
     for j=i+1:n
         temp = [i , j , adjMat(i,j)];
         adjList(count,:) = temp;
         count = count + 1;
     end
 end
 
end