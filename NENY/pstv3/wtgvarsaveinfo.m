
% CHANGE TO ACCOMODATE Pgv_wtg Qgv_wtg
if n_wtg ~= 0
    
% Iswtg(:,end) = [];
Vt_pst = (bus_v(bus_int(wtg_con(:,2)),[1:length(Iswtg)]));
Is_pst = Iswtg;

s1.t_wtg = t;
s1.vw_wtg = vw_wtg;
s1.Pmech_wtg = Pmechv_wtg;
%**States:
s1.wref_wtg = wref_wtg;
s1.wgSV_wtg = wgSV_wtg;
s1.wtSV_wtg = wtSV_wtg;
s1.delgt_wtg = delgt_wtg;
s1.delerr1_wtg = delerr1_wtg;
s1.delerr2_wtg =delerr2_wtg;
s1.Eerr_wtg = Eerr_wtg;
s1.Pord_wtg = Pord_wtg;
s1.th_wtg = th_wtg;
s1.x0_wtg = x0_wtg;
s1.x1_wtg = x1_wtg;
s1.gam_wtg = gam_wtg;
s1.Efd_wtg = Efd_wtg;
s1.Rerr_wtg = Rerr_wtg;

s1.dwref_wtg = dwref_wtg;
s1.dwgSV_wtg = dwgSV_wtg;
s1.dwtSV_wtg = dwtSV_wtg;
s1.ddelgt_wtg = ddelgt_wtg;
s1.ddelerr1_wtg = ddelerr1_wtg;
s1.ddelerr2_wtg = ddelerr2_wtg;
s1.dEerr_wtg = dEerr_wtg;
s1.dPord_wtg = dPord_wtg;
s1.dth_wtg = dth_wtg;
s1.dx0_wtg = dx0_wtg;
s1.dx1_wtg = dx1_wtg;
s1.dgam_wtg = dgam_wtg;
s1.dEfd_wtg = dEfd_wtg;
s1.dRerr_wtg = dRerr_wtg;

%**
s1.IQcmd_wtg = IQcmd_wtg;
s1.Edbr_wtg = Edbr_wtg;
%**
s1.Qset_wtg = Qset_wtg;
s1.s2_wtg = s2_wtg;
s1.s3_wtg = s3_wtg;
s1.s4_wtg = s4_wtg;
s1.s6_wtg = s6_wtg;
s1.s7_wtg = s7_wtg;
%**
s1.s1wini_wtg = s1wini_wtg;
s1.s2wini_wtg = s2wini_wtg;

s1.Vt_wtg = Vt_pst;
s1.Is_wtg = Is_pst;
s1.Pg_wtg = Pgv_wtg;
s1.Qg_wtg = Qgv_wtg;

s1.dgam_wtg = dgam_wtg;
s1.dEfd_wtg = dEfd_wtg;
end

% save('wtg_psvm_vbug1.mat', '-struct', 's1');

% save('wtg_PST072014_wgust1.mat', '-struct', 's1');
% save('wtg_PST072014_sfault1.mat', '-struct', 's1');

% save('wtg_psvm_wgust1.mat', '-struct', 's1');
% save('wtg_pst_sfault1.mat', '-struct', 's1');
% save('wtg_psvm_sfault2.mat', '-struct', 's1');
% save('wtg_psvm_sfault5gb.mat', '-struct', 's1');
% save('wtg_pst_sfault_a+2.mat', '-struct', 's1');
% save('wtg_psvk-1_sfault1.mat', '-struct', 's1');

% save('wtg3_GEr_f.mat', '-struct', 's1');
% save('wtg4_GEr_f.mat', '-struct', 's1');
% save('wtg3_wgust1_npcc_36vty.mat', '-struct', 's1');

% save('wtg4_nv_wgust1.mat', '-struct', 's1');
% save('wtg4_nv_sfault1.mat', '-struct', 's1');

% save('wtg_CR_wgust1.mat', '-struct', 's1');
% save('wtg_CR_sfault1.mat', '-struct', 's1');
% save('wtg4_CR_wgust1.mat', '-struct', 's1');
% save('wtg4_CR_sfault1.mat', '-struct', 's1');
% save('wtg4_1m_CR_wgust1.mat', '-struct', 's1');
% save('wtg4_1m_CR_sfault1.mat', '-struct', 's1');

% save('wtg_delgt_wgust1.mat', '-struct', 's1');
% save('wtg_delgt_sfault1.mat', '-struct', 's1');
