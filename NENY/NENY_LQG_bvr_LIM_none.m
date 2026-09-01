% clear all; clc;
%% RSO_LIM_high accuracy
load Mat_LD_NE_01_10hz_46p;
Ah=A; Bh=B; Ch=C(1:16,:);
As=A; Bs=B; Cs=C(1:16,:);
% Ah=A; Bh=B(:,[4 12 14 15 16]); Ch=C(1:16,:);
% As=A; Bs=B(:,[4 12 14 15 16]); Cs=C(1:16,:);
[nx,nu]=size(Bs);[ny,nx]=size(Cs);
Ei5=eig(A);
par5=[abs(imag(Ei5)/(2*pi)) Ei5 real(Ei5) -real(Ei5)./abs(Ei5)];
Qr=eye(nx,nx);Qr=diag(Qr);
pos_1=find(par5(:,1)>0.01 & par5(:,1)<1 & par5(:,4)<0.6);
pos_2=find(par5(:,1)>1 & par5(:,1)<3.0 & par5(:,4)<0.6);
Qr(pos_1)=10;Qr(pos_2)=3000;% Qr(pos_2)=10000; %COI
Qr=diag(Qr)*0.1;
Rr=eye(nu)*0.03; %0.01; %COI
Qe=eye(nx,nx);Qe=Qr;
Re=eye(ny)*1;
Kq=0*lqr(As,Bs,Qr,Rr);Gq=lqr(As',Cs',Qe,Re);
Acc=As-Bs*Kq-Gq'*Cs;Bcc=-Gq';Ccc=-1*Kq;
Hct_lqg=ss(Acc,Bcc,Ccc,0);
Gh=ss(Ah,Bh,Ch,0); % Gh=ss(Ah,Bh,Ch,0);
Gfl=feedback(Gh,Hct_lqg);
Hdt_lqg=c2d(Hct_lqg,0.01,'zoh');
[Alqg,Blqg,Clqg,Dlqg]=ssdata(Hdt_lqg);
xlqg=zeros(length(Acc),1);

% plot(real(eig(Gh)),imag(eig(Gh))/(2*pi),'o'); hold on;
% plot(real(eig(Gfl)),imag(eig(Gfl))/(2*pi),'x'); hold on;
% xlim([-1,-.01])
% ylim([-2,2])
% text(-0.9,-0.5,'Hola')