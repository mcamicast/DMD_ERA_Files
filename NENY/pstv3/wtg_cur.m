global basmva wtg_con x0_wtg x1_wtg gam_wtg n_wtg Iswtg
global Ism_sig_wtg Isa_sig_wtg Isr_sig_wtg Isi_sig_wtg
wtg_ix = 1:n_wtg;
ixwtg4 = wtg_con(:,3) == 4;
wtgbase = wtg_con(wtg_ix,4); % Base MVA of the wtg. 162 for the GE model
genbasmva_wtg = wtgbase*10/9;
% genbasmva_wtg = wtg_con(wtg_ix,5); - change mode of Pset
Lppwtg = wtg_con(wtg_ix,33); % Type 3 (apparently)

% %             %*** Type 3  ***%
% Isrewtg  = x1_wtg(:,1).*Vtrewtg./Vtmagwtg + (Vtimwtg./Lppwtg).*x0_wtg(:,1)./Vtmagwtg;
% Isimwtg  = x1_wtg(:,1).*Vtimwtg./Vtmagwtg - (Vtrewtg./Lppwtg).*x0_wtg(:,1)./Vtmagwtg;
% %*** Type 4  ***% 
% % correcting for Type 4            
% Isrewtg(ixwtg4) = x1_wtg(ixwtg4,1).*Vtrewtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1) + Vtimwtg(ixwtg4,1).*x0_wtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1);
% Isimwtg(ixwtg4) = x1_wtg(ixwtg4,1).*Vtimwtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1) - Vtrewtg(ixwtg4,1).*x0_wtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1);
% %*** ------ ***%
% 
% Iswtg(:,1) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva); % CONFIRM


%*** Type 3 ***%
Iinj = x0_wtg(:,k)./Lppwtg;
%*** Type 4 ***%
% correcting for type 4
Iinj(ixwtg4) = x0_wtg(ixwtg4,k);

Isrewtg = x1_wtg(:,k).*cos(gam_wtg(:,k)) + Iinj.*(sin(gam_wtg(:,k)));
Isimwtg = -Iinj.*cos(gam_wtg(:,k)) + x1_wtg(:,k).*(sin(gam_wtg(:,k)));

% Isrewtg = x1_wtg(:,k).*cos(Vtangwtg) + Iinj.*sin(Vtangwtg);
% Isimwtg = -Iinj.*cos(Vtangwtg) + x1_wtg(:,k).*sin(Vtangwtg);

% Iswtg(:,k+1) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva);
Iswtg(:,k) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva);
% Iswtg(:,k) = (x1_wtg(:,k) - 1i*Iinj).*(genbasmva_wtg./basmva);

% PERTURBATION AT OUTPUT, NOTE THE BASES, PERTURBATION IN SYSTEM BASE
% Iswtg(:,k) = (Iswtg(:,k) + Ism_sig_wtg(:,k)).*exp(1i*Isa_sig_wtg(:,k)); % change to below
Iswtg(:,k) = (abs(Iswtg(:,k)) + Ism_sig_wtg(:,k)).*...
              exp( 1i*( Isa_sig_wtg(:,k) + angle(Iswtg(:,k)) ) );
Iswtg(:,k) = Iswtg(:,k) + Isr_sig_wtg(:,k) + 1i*Isi_sig_wtg(:,k);



