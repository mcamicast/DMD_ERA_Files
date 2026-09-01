% clear all; clc;
load Kundur_lqg_DMD_ERA_V2
%% Control Romel
Aco = A; Bco = B; Cco = C;
Ah=Aco; Bh=Bco; Ch=Cco;

As = A; Bs = B; Cs = C;
%


gengen = 1:4;
Hrse = ss(A,B,C,0);
Hrze = c2d(Hrse,1e-2,'zoh');
[Alqg,Blqg,Clqg,Dlqg] = ssdata(Hrze);
wA = abs(eig(Alqg));
Qlqg = diag(1./(wA./max(wA).^2))*0.1; %diag(ones(10,1))*1; % diag(ones(6,1))*0.1; %diag(1./(wA./max(wA).^2));
Rlqg = 0.01*eye(length(Blqg(1,:)));
Klqg = dlqr(Alqg,Blqg,Qlqg,Rlqg);
Glqg = dlqr(Alqg',Clqg',Qlqg,Rlqg);
xlqg = zeros(length(Alqg),1);


% gengen = 1:4;
% [nx,nu]=size(Bs);
% [ny,nx]=size(Cs);
% Q_factor = 1e-2;%40000; 
% % wA = abs(eig(A));
% % Qr = diag(1./(wA./max(wA).^2))*1;
% Qr = eye(nx)* Q_factor;
% Qr(1,1) = 5e8;
% Qr(2,2) = 5e8;
% Rr = eye(nu)*1e8; 
% Re = Rr*1e-5;
% Qe = Qr*1e-5;%Vars(3)*eye(nx);
% 
% 
% Klqg = lqr(As,Bs,Qr,Rr);
% Glqg = lqr(As',Cs',Qe,Re);
% Acc = As-Bs*Klqg-Glqg'*Cs;
% Bcc = -Glqg';
% Ccc = -1*Klqg;
% Hct_lqg = ss(Acc,Bcc,Ccc,0);
% Gh = ss(Ah,Bh,Ch,0);
% Gfl = feedback(Gh,Hct_lqg);
% [Ax, Bx, Cx, Dx] = ssdata(Gfl);
% Hdt_lqg = c2d(Hct_lqg,1/100,'zoh');
% [Alqg,Blqg,Clqg,Dlqg] = ssdata(Hdt_lqg);
% xlqg = zeros(length(Acc),1);
%%
% drx = -100*real(eig(Ax))./sqrt(real(eig(Ax)).^2 + imag(eig(Ax)).^2);
% freqx = imag(eig(Ax))/(2*pi);
% dr = -100*real(eig(Aco))./sqrt(real(eig(Aco)).^2 + imag(eig(Aco)).^2);
% freq = imag(eig(Aco))/(2*pi);
% plot( drx, freqx, '*'); grid on
% hold on
% plot( dr, freq, '+'); grid on

