global Iccinj
global ccinj_con load_con n_ccinj ccinj_idx ccinj_idx2
global Pccinj Qccinj Im_sig_ccinj Iang_sig_ccinj

global mac_ang mac_spd


if k>1
    
%     curr_nc(hv_idx) = -conj((load_pot(hv_idx,1)+load_pot(hv_idx,2).*abs(V_nc(hv_idx)))./V_nc(hv_idx));
    Vccinj = V_nc(ccinj_idx);
    Iccinj(:,k) = Iccinj(:,k-1);
    
    Iccinj_sys_k = -conj(Iccinj(:,k).*abs(Vccinj)./Vccinj);
    
%     %*********************************************************************%
%     if size(ccinj_con,2)>2
%         
%         ix_ccc1 = ccinj_con(:,3) == 1; % control Im with mac. angles
%         ix_ccc2 = ccinj_con(:,3) == 2; % control Im with mac. speeds
%         ix_ccc3 = ccinj_con(:,3) == 3; % control Iang with mac. angles
%         ix_ccc4 = ccinj_con(:,3) == 4; % control Iang with mac. speeds
%         
%         ix_cc_pr = [1 4];
%         k_tns = ccinj_con(:,4);
%         ang_ref0 = mac_ang(ix_cc_pr,1) - mean(mac_ang(:,1),1);
%         ang_mac_ref_0 = mean(ang_ref0,1);
%         
%         ang_mac_ref = mac_ang(ix_cc_pr,k) - mean(mac_ang(:,k),1);
%         ang_mac_ref_k = mean(ang_mac_ref,1);
%         
%         Icc_act = 0;
%         Iangcc_act = 0;
%         
%         Icc_act(ix_ccc1) = k_tns*(ang_mac_ref_0 - ang_mac_ref_k);
% %         Icc_act(ix_ccc2) = k_tns*(ang_mac_ref_k - ang_mac_ref_0);
%         
%         Icc_act(ix_ccc2) = k_tns*(mean(mac_spd(ix_cc_pr,1),1) - mean(mac_spd(ix_cc_pr,k),1)); % Works
% %         Icc_act(ix_ccc2) = k_tns*(mean(mac_spd(ix_cc_pr,k),1) - mean(mac_spd(ix_cc_pr,1),1));
%         
%         Iangcc_act(ix_ccc3) = k_tns*(ang_mac_ref_0 - ang_mac_ref_k);
% %         Iangcc_act(ix_ccc3) = k_tns*(ang_mac_ref_k - ang_mac_ref_0);
%         Iangcc_act(ix_ccc4) = k_tns*(mean(mac_spd(ix_cc_pr,k),1) - mean(mac_spd(ix_cc_pr,1),1));
%         
% %         Icc_lim = abs(Iccinj(:,1));
% %         Icc_act( Icc_act > Icc_lim ) = Icc_lim;
% %         Icc_act( Icc_act < -Icc_lim ) = -Icc_lim;
% %         Iccinj(:,k) = (abs(Iccinj(:,k)) + Icc_act).*exp(1i*angle(Iccinj(:,k)));
% 
%         Iccinj_sys_k = (abs(Iccinj_sys_k) + Icc_act)...
%                         .*exp(1i*angle(Iccinj_sys_k + Iangcc_act));
%         
%     end
    Iccinj_sys_k = ( abs(Iccinj_sys_k) + Im_sig_ccinj(:,k) ).*...
                    exp( 1i*(angle(Iccinj_sys_k) + Iang_sig_ccinj(:,k)) );

%     %*********************************************************************%

else
    Vccinj = V_nc(ccinj_idx);
    Iccinj_sys_k = -conj(Iccinj(:,1).*abs(Vccinj)./Vccinj);
    
end


