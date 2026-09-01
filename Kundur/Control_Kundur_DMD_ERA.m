% clear all
% clc
load Kundur_lqg_DMD_ERA
Q_factor = 0.001; 
Q = diag(p_vector) * Q_factor;
Q(5,5) = 30;
%
R = eye(size(B,2)) * 10; 
R(1,1) = 0.1;
R(2,2) = 0.1;
% Re = eye(size(B,2)) * 10;
%
Klqg = lqr(A, B, Q, R);
%
% % % Vd = B * B' * 1; 
% % % % Vd = eye(size(A,1)) * 0.001;
% % % Vn = eye(size(C,1)) * 0.01; %0.01;
% % % % Vn = eye(size(C,1)) * 1; % Sube de 0.01 a 0.5
% % % [Glqg, ~, ~] = lqe(A, Vd, C, Vd, Vn);
Glqg = lqr(A', C', Q , R);
%
Alqg = A - B*Klqg - Glqg'*C;
Blqg = Glqg;
Clqg = -Klqg;
Dlqg = zeros(size(B,2), size(C,1));
xlqg = zeros(size(Alqg,1),1);
sys_lqg = ss(Alqg, Blqg', Clqg, Dlqg);
sys_planta = ss(A, B, C, 0);
sys_cl = feedback(sys_planta, sys_lqg, +1); % Realimentación negativa





