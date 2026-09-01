% cd C:\Users\USER\Dropbox\Romel_MSc_Thesis\PST_Work\03_SSA_SVC\Power_System_Toolbox\Power_System_Toolbox\pstv3
% clear all; clc;

load Mat_paper_ku_15esta
% load Mat_ERA_NE_35estados
Hrse = ss(A,B,C(1:4,:),0);
Hrze = c2d(Hrse,1e-2,'zoh');
[Alqg,Blqg,Clqg,Dlqg] = ssdata(Hrze);
Klqg=dlqr(Alqg,Blqg,eye(length(Alqg)),eye(length(Blqg(1,:))));
Glqg=dlqr(Alqg',Clqg',eye(length(Alqg)),eye(length(Clqg(:,1))));
xlqg=zeros(length(Alqg),1);
% save 'Control_KD.mat' Assa Bssa Cssa Dssa Kssa Gssa Sts;   

% load Mat_LD_NE_01_10hz_46p
% Hrs1 = ss(A,B,C(1:16,:),0);
% Hrz1 = c2d(Hrs1,5e-3,'zoh');
% [Amil,Bmil,Cmil,Dmil] = ssdata(Hrz1);
% Kmil=dlqr(Amil,Bmil,eye(length(Amil)),eye(length(Bmil(1,:))));
% Gmil=dlqr(Amil',Cmil',eye(length(Amil)),eye(length(Cmil(:,1))));
% Sts=zeros(length(Amil),1);
% save 'Control_Lwnr_LQG_full_5e3.mat' Amil Bmil Cmil Dmil Kmil Gmil Sts;   
% 
% load Mat_paper_NE_SalidasSelectas
% Hrs2 = ss(A,B,C,0);
% Hrz2 = c2d(Hrs2,5e-3,'zoh');
% [AmilCOI,BmilCOI,CmilCOI,DmilCOI] = ssdata(Hrz2);
% KmilCOI=dlqr(AmilCOI,BmilCOI,eye(length(AmilCOI)),eye(length(BmilCOI(1,:))));
% GmilCOI=dlqr(AmilCOI',CmilCOI',eye(length(AmilCOI)),eye(length(CmilCOI(:,1))));
% Sts=zeros(length(AmilCOI),1);
% save 'Control_Lwnr_LQG_COI_5e3.mat' AmilCOI BmilCOI CmilCOI...
%       DmilCOI KmilCOI GmilCOI Sts;   