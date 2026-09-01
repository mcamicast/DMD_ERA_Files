% clear all
close all
%% Case 1 without control

gold = [0.82 0.66 0.02];

% load('NYNE_WO_Control.mat')
% load('NYNE_Control_0p1Q3kR3em2p.mat')
t = sstr_1.t;
Pwoc = [sstr_2.P_L1_Pwoc; -sstr_2.P_L16_Pwoc; sstr_2.P_L73_Pwoc; sstr_2.P_L75_Pwoc; sstr_2.P_L76_Pwoc; sstr_2.P_L77_Pwoc; sstr_2.P_L78_Pwoc; sstr_2.P_L86_Pwoc]*-1;
Pwo = [sstr_1.P_L1; -sstr_1.P_L16; sstr_1.P_L73; sstr_1.P_L75; sstr_1.P_L76; sstr_1.P_L77; sstr_1.P_L78; sstr_1.P_L86]*-1;

figure(1)
h1 = subplot(2,2,1);
plot(t, Pwoc(1,:), 'r')
hold on
plot(t, Pwoc(2,:), 'b')
hold on
plot(t, Pwo(1,:), 'k :')
hold on
p1 = plot(t, Pwo(2,:), ':');
p1.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L1:17-18','L16:25-24','L1:17-18 WADC','L16:25-24 WADC','NumColumns',2)
ylim([-2 3.5])
xlim([0 25])
ylabel('Active power flow (pu)')
h1.Position = h1.Position + [0.02 0 -0.05 0.05];
set(gca,'xticklabel',[])
t1 = annotation('textbox', [0.28, 0.58, 0, 0], 'string', '(a)');
t1.FontName = 'Times New Roman';
t1.FontSize = 14;
grid on

h2= subplot(2,2,3);
plot(t, Pwoc(3,:), 'r')
hold on
plot(t, Pwoc(4,:), 'b')
hold on
plot(t, Pwo(3,:), 'k :')
hold on
p2 = plot(t, Pwo(4,:), ':');
p2.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L73:68-66','L75:68-65','L73:68-66 WADC','L75:68-65 WADC','NumColumns',2)
ylim([0 16])
xlim([0 25])
xlabel('Time (s)','Position',[12.5 -2.5]);
h2.Position = h2.Position + [0.02 0 -0.05 0.05];
ylabel('Active power flow (pu)')
t2 = annotation('textbox', [0.73, 0.58, 0, 0], 'string', '(b)');
t2.FontName = 'Times New Roman'; 
t2.FontSize = 14;
grid on

h3 = subplot(2,2,2);
plot(t, Pwoc(5,:), 'r')
hold on
plot(t, Pwoc(6,:), 'b')
hold on
plot(t, Pwo(5,:), 'k:')
hold on
p3 = plot(t, Pwo(6,:), ':');
p3.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L76:68-58','L77:57-58','L76:68-58 WADC','L77:57-58 WADC','NumColumns',2)
ylim([-0.5 3.5])
xlim([0 25])
set(gca,'xticklabel',[])
ylabel('Active power flow (pu)')
h3.Position = h3.Position + [0.02 0 -0.05 0.05];
t3 = annotation('textbox', [0.28, 0.085, 0, 0], 'string', '(c)');
t3.FontName = 'Times New Roman';
t3.FontSize = 14;
grid on

h4 = subplot(2,2,4);
plot(t, Pwoc(7,:), 'r')
hold on
plot(t, Pwoc(8,:), 'b')
hold on
plot(t, Pwo(7,:), 'k:')
hold on
p4 = plot(t, Pwo(8,:), ':');
p4.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L78:57-56','L86:17-43','L78:57-56 WADC','L86:17-43 WADC','NumColumns',2)
ylim([-1 4])
xlim([0 25])
xlabel('Time (s)') 
ylabel('Active power flow (pu)')
h4.Position = h4.Position + [0.02 0 -0.05 0.05];
xlabel('Time (s)','Position',[12.5 -1.8]);
t3 = annotation('textbox', [0.73, 0.085, 0, 0], 'string', '(d)');
t3.FontName = 'Times New Roman';
t3.FontSize = 14;
grid on
%% Case 2 with all controls
% load('NYNE_Control_0p1Q3kR3em2p.mat')
%% Case 3 with all controls
gold = [0.82 0.66 0.02];

load('NYNE_WO_Control.mat')
load('NYNE_Control_0p1Q10kR1em2_COI.mat')

Pwoc=[P_L1_Woc; -P_L16_Woc; P_L73_Woc; P_L75_Woc; P_L76_Woc; P_L77_Woc; P_L78_Woc; P_L86_Woc]*-1;
Pwo=[P_L1; -P_L16; P_L73; P_L75; P_L76; P_L77; P_L78; P_L86]*-1;

figure(1)
h1 = subplot(2,2,1);
plot(t, Pwoc(1,:), 'r')
hold on
plot(t, Pwoc(2,:), 'b')
hold on
plot(t, Pwo(1,:), 'k --')
hold on
p1 = plot(t, Pwo(2,:), '--');
p1.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L1:17-18','L16:25-24','L1:17-18 WADC','L16:25-24 WADC','NumColumns',2)
ylim([-2 3.5])
xlim([0 25])
ylabel('Active power flow (pu)')
h1.Position = h1.Position + [0.02 0 -0.05 0.05];
set(gca,'xticklabel',[])
t1 = annotation('textbox', [0.28, 0.58, 0, 0], 'string', '(a)');
t1.FontName = 'Times New Roman';
t1.FontSize = 14;
grid on

h2= subplot(2,2,3);
plot(t, Pwoc(3,:), 'r')
hold on
plot(t, Pwoc(4,:), 'b')
hold on
plot(t, Pwo(3,:), 'k --')
hold on
p2 = plot(t, Pwo(4,:), '--');
p2.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L73:68-66','L75:68-65','L73:68-66 WADC','L75:68-65 WADC','NumColumns',2)
ylim([0 16])
xlim([0 25])
xlabel('Time (s)','Position',[12.5 -2.5]);
h2.Position = h2.Position + [0.02 0 -0.05 0.05];
ylabel('Active power flow (pu)')
t2 = annotation('textbox', [0.73, 0.58, 0, 0], 'string', '(b)');
t2.FontName = 'Times New Roman'; 
t2.FontSize = 14;
grid on

h3 = subplot(2,2,2);
plot(t, Pwoc(5,:), 'r')
hold on
plot(t, Pwoc(6,:), 'b')
hold on
plot(t, Pwo(5,:), 'k--')
hold on
p3 = plot(t, Pwo(6,:), '--');
p3.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L76:68-58','L77:57-58','L76:68-58 WADC','L77:57-58 WADC','NumColumns',2)
ylim([-1.5 3.5])
xlim([0 25])
set(gca,'xticklabel',[])
ylabel('Active power flow (pu)')
h3.Position = h3.Position + [0.02 0 -0.05 0.05];
t3 = annotation('textbox', [0.28, 0.085, 0, 0], 'string', '(c)');
t3.FontName = 'Times New Roman';
t3.FontSize = 14;
grid on

h4 = subplot(2,2,4);
plot(t, Pwoc(7,:), 'r')
hold on
plot(t, Pwoc(8,:), 'b')
hold on
plot(t, Pwo(7,:), 'k--')
hold on
p4 = plot(t, Pwo(8,:), '--');
p4.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L78:57-56','L86:17-43','L78:57-56 WADC','L86:17-43 WADC','NumColumns',2)
ylim([-1 4])
xlim([0 25])
xlabel('Time (s)') 
ylabel('Active power flow (pu)')
h4.Position = h4.Position + [0.02 0 -0.05 0.05];
xlabel('Time (s)','Position',[12.5 -1.8]);
t3 = annotation('textbox', [0.73, 0.085, 0, 0], 'string', '(d)');
t3.FontName = 'Times New Roman';
t3.FontSize = 14;
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Case 1 Kundur without control
% load KU_WO_Control.mat
% % load KU_Control_10_Q1R1em2.mat
% load KU_with_Control.mat

%Color
dark_green = [0.0823 0.3372 0.0823];
orange = [0.8500 0.3250 0.0980];
gold = [0.82 0.66 0.02];

figure(1)
h1 = subplot(2,1,1);
Pwoc1=[P_L5_Woc; P_L6_Woc];
Pwc1=[P_L5; P_L6];
plot(t(1:end-1), Pwoc1(1,:),'r')
hold on
plot(t(1:end-1), Pwoc1(2,:),'-- b')
hold on
plot(t, Pwc1(1,:),'k')
hold on
p1 = plot(t, Pwc1(2,:),'-- y');
p1.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L05:3-101 Without WADC','L06:3-101 Without WADC','L05:3-101 With WADC','L06:3-101 With WADC','NumColumns',2)
ylim([-0.5 3.5])
ylabel('Active power flow (pu)')
set(gca,'xticklabel',[])
h1.Position = h1.Position + [0.07 0 -0.15 0.03];
t1 = annotation('textbox', [0.5, 0.58, 0, 0], 'string', '(a)');
t2 = annotation('textbox', [0.5, 0.1, 0, 0], 'string', '(b)');
t1.FontName = 'Times New Roman';
t2.FontName = 'Times New Roman';
t1.FontSize = 16;
t2.FontSize = 16;
grid on

h2 = subplot(2,1,2);
Pwoc2=[-P_L10_Woc; -P_L11_Woc];
Pwc2=[-P_L10; -P_L11];
p1 = plot(t(1:end-1), Pwoc2(1,:));
p1.Color = dark_green;
hold on
p2 = plot(t(1:end-1), Pwoc2(2,:),'--');
p2.Color = orange;
hold on
plot(t, Pwc2(1,:),'k');
hold on
p2 = plot(t, Pwc2(2,:),'-- y');
p2.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L10:13-101 without WADC','L11:13-101 without WADC','L10:13-101 with WADC','L11:13-101 with WADC','NumColumns',2)
ylim([-1 4])
xlabel('Time (s)') 
ylabel('Active power flow (pu)')
h2.Position = h2.Position + [0.07 0 -0.15 0.03];
x1h = xlabel('Time (s)','Position',[12.5 -1.8]);
grid on

%% Case 2 Kundur with control
load KU_WOControl.mat
load KU_Control_10_Q1R1em2_2_4.mat %Terminan en _1
load KU_Control_10_Q1R1em2_1_3.mat %Terminan en _2

%Color
dark_green =  [0.0823 0.3372 0.0823];
orange = [0.8500 0.3250 0.0980];
gold = [0.82 0.66 0.02];

figure(2)
h1 = subplot(2,2,1);
Pwoc1=[P_L5_Woc; P_L6_Woc];
Pwc1_1=[P_L5_1; P_L6_1];
plot(t, Pwoc1(1,:), 'r')
hold on
plot(t, Pwoc1(2,:),'-- b')
hold on
plot(t, Pwc1_1(1,:), 'k')
hold on
p1 = plot(t, Pwc1_1(2,:),'--');
p1.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L05:3-101','L06:3-101','L05:3-101 WADC G2 G4','L06:3-101 WADC G2 G4','NumColumns',2)
ylim([-0.5 3.5])
xlim([0 25])
ylabel('Active power flow (pu)')
h1.Position = h1.Position + [0.02 0 -0.05 0.05];
set(gca,'xticklabel',[])
t1 = annotation('textbox', [0.28, 0.58, 0, 0], 'string', '(a)');
t1.FontName = 'Times New Roman';
t1.FontSize = 14;
grid on

h2= subplot(2,2,3);
Pwoc2=[-P_L10_Woc; -P_L11_Woc];
Pwc1_2=[-P_L10_1; -P_L11_1];
p1 = plot(t, Pwoc2(1,:));
p1.Color = dark_green;
hold on
p2 = plot(t, Pwoc2(2,:),'--');
p2.Color = orange;
hold on
plot(t, Pwc1_2(1,:), 'k');
hold on
p3 = plot(t, Pwc1_2(2,:),'--');
p3.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L10:13-101','L11:13-101','L010:13-101 WADC G2 G4','L11:13-101 WADC G2 G4','NumColumns',2)
ylim([-1 4])
xlim([0 25])
x1h = xlabel('Time (s)','Position',[12.5 -1.8]);
h2.Position = h2.Position + [0.02 0 -0.05 0.05];
ylabel('Active power flow (pu)')
t2 = annotation('textbox', [0.73, 0.58, 0, 0], 'string', '(b)');
t2.FontName = 'Times New Roman';
t2.FontSize = 14;
grid on

h3 = subplot(2,2,2);
Pwoc1=[P_L5_Woc; P_L6_Woc];
Pwc2_1=[P_L5_2; P_L6_2];
plot(t, Pwoc1(1,:),'r')
hold on
plot(t, Pwoc1(2,:),'-- b')
hold on
plot(t, Pwc2_1(1,:), 'k')
hold on
p1 = plot(t, Pwc2_1(2,:),'--');
p1.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L10:13-101','L11:13-101','L010:13-101 WADC G1 G3','L11:13-101 WADC G1 G3','NumColumns',2)
ylim([-0.5 3.5])
xlim([0 25])
set(gca,'xticklabel',[])
ylabel('Active power flow (pu)')
h3.Position = h3.Position + [0.02 0 -0.05 0.05];
t3 = annotation('textbox', [0.28, 0.085, 0, 0], 'string', '(c)');
t3.FontName = 'Times New Roman';
t3.FontSize = 14;
grid on

h4 = subplot(2,2,4);
Pwoc2=[-P_L10_Woc; -P_L11_Woc];
Pwc2_2=[-P_L10_2; -P_L11_2];
p1 = plot(t, Pwoc2(1,:));
p1.Color = dark_green;
hold on
p2 = plot(t, Pwoc2(2,:),'--');
p2.Color = orange;
hold on
p3 = plot(t, Pwc2_2(1,:), 'k');
hold on
p4 = plot(t, Pwc2_2(2,:),'--');
p4.Color = gold;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L10:13-101','L11:13-101','L010:13-101 WADC G1 G3','L11:13-101 WADC G1 G3','NumColumns',2)
ylim([-1 4])
xlim([0 25])
xlabel('Time (s)') 
ylabel('Active power flow (pu)')
h4.Position = h4.Position + [0.02 0 -0.05 0.05];
x1h = xlabel('Time (s)','Position',[12.5 -1.8]);
t3 = annotation('textbox', [0.73, 0.085, 0, 0], 'string', '(d)');
t3.FontName = 'Times New Roman';
t3.FontSize = 14;
grid on

%% Case 4 Kundur with control
% load KU_Control_10_Q1R1em2_2_4.mat
%% Case 3 Kundur with control
% load KU_Control_10_Q1R1em2_1_3.mat
% Pwo=[P_L5; P_L6; -P_L10; -P_L11];
% plot(t, Pwo)
% grid on
% xlabel('Time (s)')
% ylabel('Active power flow (pu)')
% % ylim([-2 13])
% % legend('L05:3-101','L06:3-101','L10:13-101','L11:13-101')

%% Case 5 Kundur with control and latence
load KU_With_Control_0_delay.mat %acá es sin latencia
load KU_With_Control_50_delay.mat
load KU_With_Control_100_delay.mat
load KU_With_Control_150_delay.mat
load KU_With_Control_200_delay.mat
load KU_With_Control_250_delay.mat
load KU_With_Control_300_delay.mat
% % load KU_WO_Control_delay_110.mat
% load KU_WO_Control_delay_120.mat
% load KU_WO_Control_delay_130.mat
% load KU_WO_Control_delay_140.mat
% load KU_WO_Control_delay_150.mat

%Color
dark_green = [0.0823 0.3372 0.0823];
orange = [0.8500 0.3250 0.0980];
gold = [0.82 0.66 0.02];
aquamarine = [0 0.9882 0.4509];
purple = [0.4470 01411 0.9529];
blue = [0.1411 0.4980 0.9529]; 
gray = [0.7450 0.7725 0.8];

figure(1)
Pwc=[P_L5; P_L6];
Pwc_1=[P_L5_1; P_L6_1];
Pwc_2=[P_L5_2; P_L6_2];
Pwc_3=[P_L5_3; P_L6_3];
Pwc_4=[P_L5_4; P_L6_4];
Pwc_5=[P_L5_5; P_L6_5];
Pwc_6=[P_L5_6; P_L6_6];

plot(t, Pwc(1,:), 'k')
hold on
plot(t, Pwc_1(1,:),'y -.')
hold on
p3 = plot(t, Pwc_2(1,:),'k');
p3.Color = orange;
hold on
plot(t, Pwc_3(1,:),'b -.')
hold on
plot(t, Pwc_4(1,:),'g');
hold on
plot(t, Pwc_5(1,:),'c --')
hold on
plot(t, Pwc_6(1,:),'r :');

set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',24)
ylim([0.39 2.35])
xlim([0 15])
ylabel('Active power flow (pu)')
xlabel('Time (s)')
legend('D_{rt} =0ms','D_{rt} = 50ms','D_{rt} = 100ms','D_{rt} = 150ms','D_{rt} = 200ms','D_{rt} = 250ms','D_{rt} = 300ms','NumColumns',2)
grid on
%set(gca,'xticklabel',[])
t3 = annotation('textbox', [0.5, 0.1, 0, 0], 'string', '(b)');
t3.FontName = 'Times New Roman';
t3.FontSize = 18;

%% Case 5 NENY with control and latence
load NYNE_Control_DMD_Wind_0_ms.mat

load NYNE_Control_DMD_Wind_50_ms.mat 
% load NENY_WO_Control_delay_60.mat
load NYNE_Control_DMD_Wind_70_ms.mat
% load NENY_WO_Control_delay_80.mat
load NYNE_Control_DMD_Wind_90_ms.mat
% load NENY_WO_Control_delay_100.mat
load NYNE_Control_DMD_Wind_110_ms.mat
% load NENY_WO_Control_delay_120.mat
load NYNE_Control_DMD_Wind_130_ms.mat
% load NENY_WO_Control_delay_140.mat
load NYNE_Control_DMD_Wind_150_ms.mat

% load NENY_WO_Control_delay_150_prueba.mat
% load NENY_WO_Control_delay_0_prueba.mat

%Color
dark_green = [0.0823 0.3372 0.0823];
orange = [0.8500 0.3250 0.0980];
gold = [0.82 0.66 0.02];
aquamarine = [0 0.9882 0.4509];
purple = [0.4470 01411 0.9529];
blue = [0.1411 0.4980 0.9529]; 
gray = [0.7450 0.7725 0.8];

figure(1)
Pwc=[sstr_1.P_L1];
% Pwc_1=[P_L5_6]*-1;
Pwc_2=[sstr_2.P_L1];
% Pwc_3=[P_L5_8]*-1;
Pwc_4=[sstr_4.P_L1];
% Pwc_5=[P_L5_10]*-1;
Pwc_6=[sstr_6.P_L1];
% Pwc_7=[P_L5_12]*-1;
Pwc_8=[sstr_8.P_L1];
% Pwc_9=[P_L5_14]*-1;
Pwc_10=[sstr_10.P_L1];
Pwc_12=[sstr_12.P_L1];

t = sstr_1.t;

plot(t, Pwc(1,:), 'k')
hold on
% plot(t, Pwc_1(1,:),'b -.')
% hold on
plot(t, Pwc_2(1,:),'y')
hold on
% plot(t, Pwc_3(1,:),'m --')
% hold on
plot(t, Pwc_4(1,:),'m --')
hold on
% plot(t, Pwc_5(1,:),'c --')
% hold on
plot(t, Pwc_6(1,:),'r -.');
hold on
% plot(t, Pwc_7(1,:),'r -.');
% hold on
p3 = plot(t, Pwc_8(1,:),'');
p3.Color = gold;
hold on
% p4 = plot(t, Pwc_9(1,:), ':');
% p4.Color = gold;
% hold on
p5 = plot(t, Pwc_10(1,:));
p5.Color = blue;
hold on
p6 = plot(t, Pwc_12(1,:));
p6.Color = dark_green;

set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',24)
%ylim([0.39 2.35])
%xlim([0 15])
ylabel('Active power flow (pu)')
xlabel('Time (s)')
legend('D_{rt} =0ms','D_{rt} = 50ms','D_{rt} = 70ms','D_{rt} = 90ms','D_{rt} = 110ms','D_{rt} = 130ms','D_{rt} = 150ms','NumColumns',2)
grid on
%set(gca,'xticklabel',[])
% t3 = annotation('textbox', [0.5, 0.1, 0, 0], 'string', '(b)');
% t3.FontName = 'Times New Roman';
% t3.FontSize = 18;

%% Case 6 Comparison between ERA, Loewner and SSA
load KU_Control_Loewner_all_test.mat
load KU_Control_SSA_all_test.mat %SSA
load KU_Control_ERA_all_test.mat %ERA

%Color
dark_green = [0.0823 0.3372 0.0823];
orange = [0.8500 0.3250 0.0980];
gold = [0.82 0.66 0.02];

figure(1)
h1 = subplot(2,1,1);
Pwoc1=[P_L5; P_L6];
Pwc1=[P_L5_ERA; P_L6_ERA];
Pwc2=[P_L5_SSA; P_L6_SSA];
plot(t, Pwoc1(1,:),'r')
hold on
plot(t, Pwc1(1,:),'-.b')
hold on
p3 = plot(t, Pwc2(1,:),'--');
p3.Color = dark_green;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L05:3-101 Loewner','L05:3-101 ERA','L05:3-101 SSA','NumColumns',1)
ylim([-0.5 3.5])
ylabel('Active power flow (pu)')
set(gca,'xticklabel',[])
h1.Position = h1.Position + [0.07 0 -0.15 0.03];
t1 = annotation('textbox', [0.5, 0.58, 0, 0], 'string', '(a)');
t2 = annotation('textbox', [0.5, 0.1, 0, 0], 'string', '(b)');
t1.FontName = 'Times New Roman';
t2.FontName = 'Times New Roman';
t1.FontSize = 16;
t2.FontSize = 16;
grid on

% Create smaller axes in top right, and plot on it
% Store handle to axes 2 in ax2.
ax2 = axes('Position',[.7 .7 .2 .2]);
box on;
plot(t, Pwoc1(1,:),'r')
hold on
plot(t, Pwc1(1,:),'-.b')
hold on
p3 = plot(t, Pwc2(1,:),'--');
p3.Color = dark_green;
grid on;

h2 = subplot(2,1,2);
Pwoc1=[-P_L10;-P_L11];
Pwc1=[-P_L10_ERA;-P_L11_ERA];
Pwc2=[-P_L10_SSA;-P_L11_SSA];
plot(t, Pwoc1(1,:),'r')
hold on
plot(t, Pwc1(1,:),'-.b')
hold on
p3 = plot(t, Pwc2(1,:),'--');
p3.Color = dark_green;
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',15)
legend('L10:3-101 Loewner','L10:3-101 ERA','L10:3-101 SSA','NumColumns',1)
ylim([-1 4])
xlabel('Time (s)') 
ylabel('Active power flow (pu)')
h2.Position = h2.Position + [0.07 0 -0.15 0.03];
x1h = xlabel('Time (s)','Position',[12.5 -1.8]);
grid on

% Create smaller axes in top right, and plot on it
% Store handle to axes 2 in ax2.
ax3 = axes('Position',[.2 .2 .1 .1]);
box on;
plot(t, Pwoc1(1,:),'r')
hold on
plot(t, Pwc1(1,:),'-.b')
hold on
p3 = plot(t, Pwc2(1,:),'--');
p3.Color = dark_green;

%%
plot(t,P_L5_5)
hold on
plot(t,P_L5_13)

%%
% load("C:\Users\maria\Dropbox\Work_Cami\For_Amrit\HVDC_Wind\Kundur\KU_Control_DMD_150_ms.mat")
% P_L5_1 = P_L5;
% P_L6_1 = P_L6;
% load("C:\Users\maria\Dropbox\Work_Cami\For_Amrit\HVDC_Wind\Kundur\KU_With_Control.mat")
Pwc=[P_L5; P_L6];
Pwc_11=[P_L5_11; P_L6_11];
plot(t, Pwc(1,:), 'k')
hold on
plot(t, Pwc_11(1,:),'r :');
