function [a_pf] = a_partfact(a_mat)

% a_mat = [0 0 1 0; 0 0 0 1; -104.096 -59.524 0 0; -33.841 -153.46 0 0]; 
n_st = size(a_mat,1);
if n_st ~= size(a_mat,2)
    error('a_mat is not a square matrix')
end

[Y, D]=eig(a_mat); 
UT=inv(Y); 
U=UT'; 

% ic - index on columns (modes) 
% ir - index on rows (states) 

for ic = 1:n_st  
    for ir = 1:n_st
        P(ir,ic) = U(ir,ic)*Y(ir,ic); 
    end
end 
a_pf = P;



% a=[0 0 1 0; 0 0 0 1; -104.096 -59.524 0 0; -33.841 -153.46 0 0]; 
% [P, D]=eig(a); 
% QT=inv(P); 
% Q=QT'; 
% j=1; 
% % j is index on columns (modes) 
% % i is index on rows (states) 
% while j<5, 
%  i=1; 
% while i<5, 
%  pf(i,j)=Q(i,j)*P(i,j); 
%  i=i+1; 
% end 
%  j=j+1; 
% end 
% pf 