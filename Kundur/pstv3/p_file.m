% m.file  for  computing perturbations  
% 5:53 pm 29/12/98
% for svm_mgen.m  
% forms state space model of system
% Author Graham Rogers
% (c) Copyright Joe Chow/ Cherry Tree Scientific Software  1991-1997
% All Rights Reserved
% step 3a: network solution
flag = 1;
%generators
mac_ib(0,2,bus,flag);
mac_em(0,2,bus,flag);
mac_tra(0,2,bus,flag);
mac_sub(0,2,bus,flag);
mac_ind(0,2,bus,flag); 
mac_igen(0,2,bus,flag);
%====================== Similar to 'i_simu'===============================%
psi = psi_re(:,2) + jay*psi_im(:,2);

if n_mot~=0&&n_ig==0
   vmp = vdp(:,2) + jay*vqp(:,2);
   int_volt=[psi; vmp]; % internal voltages of generators and motors 
elseif n_mot==0&&n_ig~=0
   vmpig = vdpig(:,2) + jay*vqpig(:,2);
   int_volt=[psi; vmpig]; % internal voltages of sync and ind. generators  
elseif n_mot~=0&&n_ig~=0
   vmp = vdp(:,2) + jay*vqp(:,2);
   vmpig = vdpig(:,2) + jay*vqpig(:,2);
   int_volt = [psi;vmp;vmpig];
else
   int_volt = psi;
end
if n_conv~=0
   dc_cont(0,2,2,bus,flag);
end
cur(:,2) = Y_gprf*int_volt; % network solution currents into generators       
b_v(boprf(nload+1:nbus),1) = V_rgprf*int_volt;   % bus voltage reconstruction
if nload~=0
   vnc = v(boprf(1:nload),1);
   vnc = nc_load(bus,flag,Y_ncprf,Y_ncgprf,int_volt,vnc,1e-8,2,2);
   bvnc = full(V_rncprf*vnc);
   b_v(boprf(1:nload),1) = vnc;
   cur(:,2) = cur(:,2) + Y_gncprf*vnc;% modify currents for nc loads
   b_v(boprf(nload+1:nbus),1) =  b_v(boprf(nload+1:nbus),1) + bvnc; % adjust voltages for nc loads
end
v(bus_int(bus(:,1)),2) = b_v;
bus_v(bus_int(bus(:,1)),2) = b_v;
theta(bus_int(bus(:,1)),2) = angle(b_v); 
cur_re(1:n_mac,2) = real(cur(1:n_mac,2)); cur_im(1:n_mac,2) = imag(cur(1:n_mac,2));
cur_mag(1:n_mac,2) = abs(cur(1:n_mac,2)).*mac_pot(:,1);
if n_mot~=0
   idmot = -real(cur(n_mac+1:ngm,:));%induction motor currents
   iqmot = -imag(cur(n_mac+1:ngm,:));%current out of network
end
if n_ig~=0
   idig = -real(cur(ngm+1:ntot,:));%induction generator currents
   iqig = -imag(cur(ngm+1:ntot,:));%current out of network
end

if n_conv ~=0
   % calculate dc voltage and current
   V0(r_idx,1) = abs(v(rec_ac_bus,2)).*dcc_pot(:,7);
   V0(i_idx,1) = abs(v(inv_ac_bus,2)).*dcc_pot(:,8);
   Vdc(r_idx,2) = V0(r_idx,1).*cos(alpha(:,2)) - i_dcr(:,2).*dcc_pot(:,3);
   Vdc(i_idx,2) = V0(i_idx,1).*cos(gamma(:,2)) - i_dci(:,2).*dcc_pot(:,5);
   i_dc(r_idx,2) = i_dcr(:,2);
   i_dc(i_idx,2) = i_dci(:,2);
end
%===================== end Similar to 'i_simu' ===========================%
% DeltaP/omega filter
dpwf(0,2,bus,flag);
% pss
pss(0,2,bus,flag);
% exciters
smpexc(0,2,bus,flag);
smppi(0,2,bus,flag);
exc_dc12(0,2,bus,flag);
exc_st3(0,2,bus,flag);
% turbine/governor
tg(0,2,bus,flag);
tg_hydro(0,2,bus,flag);
% calculate rates of change
flag = 2;
mac_em(0,2,bus,flag);
mac_tra(0,2,bus,flag);
mac_sub(0,2,bus,flag); 
mac_ind(0,2,bus,flag); 
mac_igen(0,2,bus,flag);
dpwf(0,2,bus,flag);
pss(0,2,bus,flag);
smpexc(0,2,bus,flag);
smppi(0,2,bus,flag);
exc_dc12(0,2,bus,flag);
exc_st3(0,2,bus,flag);
tg(0,2,bus,flag);
tg_hydro(0,2,bus,flag);
% Mirar si lo que lee es dos en las variables que no son 'rate variables'
if n_wtg~=0
     wtg(0,2,bus,flag,v,[2 1]); % ADDED - wtg DYNAMIC COMPUTATION
     %** Ensure that P and Q are in system base
     [~,ccol] = size(Pgv_wtg);
     Pnfac = repmat(wtg_con(:,4),1,ccol);
     Qnfac = repmat(wtg_con(:,5),1,ccol);
     Pgb_wtg = (1/basmva).*Pnfac.*Pgv_wtg;
     Qgb_wtg = (1/basmva).*Qnfac.*Qgv_wtg;
end
if n_ccinj~=0
    ccinj(0,2,bus,flag,v,[2 1]);
end
if n_shtr~=0
    shtr(0,2,bus,flag);
end
if n_tcsr~=0
    tcsr(0,2,bus,flag);
    line_aux(tcsrlin_idx,4) = Xtcsr_or + X_tcsr(:,2);
end
line_compl(:,:,2) = line_aux;
if n_svc~=0 
   v_svc = abs(v(bus_int(svc_con(:,2)),2));
   svc(0,2,bus,flag,v_svc);
end
if n_tcsc~=0
   tcsc(0,2,bus,flag);
end
if n_lmod~=0 
   lmod(0,2,bus,flag);
end
if n_rlmod~=0 
   rlmod(0,2,bus,flag);
end

if n_conv ~=0
   dc_cont(0,2,2,bus,flag);
   dc_line(0,2,2,bus,flag);
end
telect(:,2) = pelect(:,2).*mac_pot(:,1)+mac_con(:,5).*cur_mag(:,2).*cur_mag(:,2);
% form state matrix
% form vector of d states
d_vector = zeros(max_state,1);
mac_state = 6*n_mac;
exc_state = mac_state+5*n_exc;
pss_state = exc_state + 3*n_pss;
dpw_state = pss_state +6*n_dpw;
d_vector(1:n_mac) = dmac_ang(:,2);
d_vector(n_mac+1:2*n_mac) = dmac_spd(:,2);
d_vector(2*n_mac+1:3*n_mac) = deqprime(:,2);
d_vector(3*n_mac+1:4*n_mac) = dpsikd(:,2);
d_vector(4*n_mac+1:5*n_mac) = dedprime(:,2);
d_vector(5*n_mac+1:6*n_mac) = dpsikq(:,2);
if n_exc~=0
   d_vector(mac_state+1:mac_state+n_exc) = dV_TR(:,2);
   d_vector(mac_state+n_exc+1:mac_state+2*n_exc) = dV_As(:,2);
   d_vector(mac_state+2*n_exc+1:mac_state+3*n_exc) = dV_R(:,2);
   d_vector(mac_state+3*n_exc+1:mac_state+4*n_exc) = dEfd(:,2);
   d_vector(mac_state+4*n_exc+1:mac_state+5*n_exc) = dR_f(:,2);
end
if n_pss~=0
   d_vector(exc_state+1:exc_state+n_pss) = dpss1(:,2);
   d_vector(exc_state+n_pss+1:exc_state+2*n_pss) = dpss2(:,2);
   d_vector(exc_state+2*n_pss+1:exc_state+3*n_pss) = dpss3(:,2);
end
if n_dpw~=0
   d_vector(pss_state+1:pss_state+n_dpw) = dsdpw1(:,2);
   d_vector(pss_state+n_dpw+1:pss_state+2*n_dpw) = dsdpw2(:,2);
   d_vector(pss_state+2*n_dpw+1:pss_state+3*n_dpw) = dsdpw3(:,2);
   d_vector(pss_state+3*n_dpw+1:pss_state+4*n_dpw) = dsdpw4(:,2);
   d_vector(pss_state+4*n_dpw+1:pss_state+5*n_dpw) = dsdpw5(:,2);
   d_vector(pss_state+5*n_dpw+1:pss_state+6*n_dpw) = dsdpw6(:,2);
end

if n_tg~=0||n_tgh~=0
   ngt = n_tg+n_tgh;
   d_vector(dpw_state+1:dpw_state+ngt) = dtg1(:,2);
   d_vector(dpw_state+ngt+1:dpw_state+2*ngt) = dtg2(:,2);
   d_vector(dpw_state+2*ngt+1:dpw_state+3*ngt) = dtg3(:,2);
   d_vector(dpw_state+3*ngt+1:dpw_state+4*ngt) = dtg4(:,2);
   d_vector(dpw_state+4*ngt+1:dpw_state+5*ngt) = dtg5(:,2);
end
if n_mot~=0
   mot_start = dpw_state+5*(n_tg+n_tgh);
   d_vector(mot_start+1:mot_start+n_mot) = dvdp(:,2);
   d_vector(mot_start+n_mot+1:mot_start+2*n_mot) = dvqp(:,2);
   d_vector(mot_start+2*n_mot+1:mot_start+3*n_mot) = dslip(:,2);
end
if n_ig~=0
   ig_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot;
   d_vector(ig_start+1:ig_start+n_ig) = dvdpig(:,2);
   d_vector(ig_start+n_ig+1:ig_start+2*n_ig) = dvqpig(:,2);
   d_vector(ig_start+2*n_ig+1:ig_start+3*n_ig) = dslig(:,2);
end

if n_svc ~= 0
   svc_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig;
   d_vector(svc_start+1:svc_start+n_svc) = dB_cv(:,2);
   d_vector(svc_start+n_svc+1:svc_start+2*n_svc) = dB_con(:,2);
end

if n_tcsc~=0
   tcsc_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig+2*n_svc;
   d_vector(tcsc_start+1:tcsc_start+n_tcsc)=dB_tcsc(:,2);
end
if n_lmod ~= 0
   lmod_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig+2*n_svc+n_tcsc;
   d_vector(lmod_start+1:lmod_start+n_lmod) = dlmod_st(:,2);
end
if n_rlmod ~= 0
   rlmod_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig+2*n_svc+n_tcsc+n_lmod;
   d_vector(rlmod_start+1:rlmod_start+n_rlmod) = drlmod_st(:,2);
end

if n_conv~=0
   dc_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig + 2*n_svc +n_tcsc+ n_lmod+n_rlmod;
   d_vector(dc_start+1: dc_start+n_dcl) = dv_conr(:,2);
   d_vector(dc_start+n_dcl+1: dc_start+2*n_dcl) = dv_coni(:,2);
   d_vector(dc_start+2*n_dcl+1: dc_start+3*n_dcl) = di_dcr(:,2);
   d_vector(dc_start+3*n_dcl+1: dc_start+4*n_dcl) = di_dci(:,2);
   d_vector(dc_start+4*n_dcl+1: dc_start+5*n_dcl) = dv_dcc(:,2);
end

if n_shtr~=0
    shtr_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig + 2*n_svc +n_tcsc+ n_lmod+n_rlmod+...
                 5*n_dcl;
    d_vector(shtr_start+1: shtr_start+n_shtr) = dYshtr(:,2);                % shtr (SVR) only state
end

if n_tcsr~=0
    tcsr_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig + 2*n_svc +n_tcsc+ n_lmod+n_rlmod+...
                 5*n_dcl+n_shtr;
    d_vector(tcsr_start+1: tcsr_start+n_tcsr) = dX_tcsr(:,2);               % TCSR only state
end

if n_wtg~=0
    wtg_start = dpw_state+5*(n_tg+n_tgh)+3*n_mot+3*n_ig + 2*n_svc +n_tcsc+ n_lmod+n_rlmod+...
                 5*n_dcl+n_shtr+n_tcsr;
             
    d_vector(wtg_start+1: wtg_start+n_wtg) = dwtSV_wtg(:,2);                % 1
    
    d_vector(wtg_start+n_wtg+1: wtg_start+2*n_wtg) = dwgSV_wtg(:,2);        % 2
    d_vector(wtg_start+2*n_wtg+1: wtg_start+3*n_wtg) = ddelgt_wtg(:,2);     % 3
    
    d_vector(wtg_start+3*n_wtg+1: wtg_start+4*n_wtg) = ddelerr1_wtg(:,2);   % 4
    d_vector(wtg_start+4*n_wtg+1: wtg_start+5*n_wtg) = ddelerr2_wtg(:,2);   % 5
    d_vector(wtg_start+5*n_wtg+1: wtg_start+6*n_wtg) = dEerr_wtg(:,2);      % 6
    d_vector(wtg_start+6*n_wtg+1: wtg_start+7*n_wtg) = dth_wtg(:,2);        % 7
    d_vector(wtg_start+7*n_wtg+1: wtg_start+8*n_wtg) = dPord_wtg(:,2);      % 8
    d_vector(wtg_start+8*n_wtg+1: wtg_start+9*n_wtg) = dwref_wtg(:,2);      % 9
    d_vector(wtg_start+9*n_wtg+1: wtg_start+10*n_wtg) = dx0_wtg(:,2);       % 10
    d_vector(wtg_start+10*n_wtg+1: wtg_start+11*n_wtg) = dx1_wtg(:,2);      % 11
    d_vector(wtg_start+11*n_wtg+1: wtg_start+12*n_wtg) = dgam_wtg(:,2);     % 12
    wtg_st13_aux = zeros(n_wtg,1);
    ixwtg3 = wtg_con(:,3) == 3;
    ixwtg4 = wtg_con(:,3) == 4;
    wtg_st13_aux(ixwtg3) = dEfd_wtg(ixwtg3,2);
    wtg_st13_aux(ixwtg4) = dIQcmd_wtg(ixwtg4,2);
    d_vector(wtg_start+12*n_wtg+1: wtg_start+13*n_wtg) = wtg_st13_aux;      % 13
    d_vector(wtg_start+13*n_wtg+1: wtg_start+14*n_wtg) = dRerr_wtg(:,2);    % 14
    
    d_vector(wtg_start+14*n_wtg+1: wtg_start+15*n_wtg) = dQset_wtg(:,2);    % 15
    d_vector(wtg_start+15*n_wtg+1: wtg_start+16*n_wtg) = ds2_wtg(:,2);      % 16
    d_vector(wtg_start+16*n_wtg+1: wtg_start+17*n_wtg) = ds3_wtg(:,2);      % 17
    d_vector(wtg_start+17*n_wtg+1: wtg_start+18*n_wtg) = ds4_wtg(:,2);      % 18
    d_vector(wtg_start+18*n_wtg+1: wtg_start+19*n_wtg) = ds7_wtg(:,2);      % 19
    
    d_vector(wtg_start+19*n_wtg+1: wtg_start+20*n_wtg) = ds6_wtg(:,2);      % 20
    
end

if ~isempty(lmon_con)
    R = squeeze(line_compl(lmon_con,3,:));
    X = squeeze(line_compl(lmon_con,4,:));
    B = squeeze(line_compl(lmon_con,5,:));
    tap = squeeze(line_compl(lmon_con,6,:));
    phi = squeeze(line_compl(lmon_con,7,:));
end

% form state matrix
if c_state == 0
   if k==1
      j_state = j;
   else
      j_state = j + sum(state(1:k-1));
   end
   if n_ib~=0
      k_nib_idx = find(not_ib_idx==k);
   else
      k_nib_idx = k;
   end
   if (j == 2)&&(isgen_v == 1)
      if ~isempty(k_nib_idx)
         c_spd(k_nib_idx,j_state) = 1;
      end
   end
   % form output matrices wtg - 
   if (iswtg_v == 1)
       if j == 1
            c_wtSV_wtg(k_wtg,j_state) = 1;
       end
       if nmasswtg(k_wtg)==2
           jc = j;
       else
           jc = j+2; % one-mass model to accomodate flow control variable jc
       end
       if (jc == 2)
            c_wgSV_wtg(k_wtg,j_state) = 1;
       end
       if (jc == 4)
            m_rwinderase(k_wtg,j_state) = 1; % state set as zero when wind is at rated
       end
       if (jc == 6)
            m_rwinderase(k_wtg,j_state) = 1; % state set as zero when wind is at rated
       end
       if (jc == 7)
            c_th_wtg(k_wtg,j_state) = 1;
            m_rwinderase(k_wtg,j_state) = 1; % state set as zero when wind is at rated
       end
       if (jc == 8)
            c_Pord_wtg(k_wtg,j_state) = 1;
       end
       if (jc == 13)
           m_m_Verrerase(k_wtg,j_state) = 1;
       end     
   end
   a_mat(:,j_state) = p_mat*d_vector/pert;
   % form output matrices (C)
   c_p(not_ib_idx,j_state) = (pelect(not_ib_idx,2)-pelect(not_ib_idx,1))...
      .*mac_pot(not_ib_idx,1)/pert;
   c_t(not_ib_idx,j_state) = (telect(not_ib_idx,2)-telect(not_ib_idx,1))/pert;
   c_pm(not_ib_idx,j_state) = (pmech(not_ib_idx,2)-pmech(not_ib_idx,1))/pert;
   c_v(:,j_state) = (abs(v(:,2)) - abs(v(:,1)))/pert;
   c_ang(:,j_state) = (theta(:,2) - theta(:,1))/pert;
   % form output matrices wtg - 
   if n_wtg~=0
       %** Pgb and Qqb are in system base -
       c_Is_wtg(:,j_state) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
       c_Isang_wtg(:,j_state) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
       c_Isre_wtg(:,j_state) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
       c_Isim_wtg(:,j_state) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
       c_P_wtg(:,j_state) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
       c_Q_wtg(:,j_state) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
   end
   if n_exc~=0
      c_Efd(:,j_state) = (Efd(:,2)-Efd(:,1))/pert;
   end
   if ~isempty(lmon_con) 
      from_idx = bus_int(line(lmon_con,1));
      to_idx = bus_int(line(lmon_con,2));
      V1 = v(from_idx,1);
      V2 = v(to_idx,1);
      [s11,s21] = line_pqf(V1,V2,R(:,1),X(:,1),B(:,1),tap(:,1),phi(:,1));
      [l_if1,l_it1] = line_curf(V1,V2,R(:,1),X(:,1),B(:,1),tap(:,1),phi(:,1));
%       [s11,s21] = line_pq(V1,V2,R,X,B,tap,phi);
%       [l_if1,l_it1] = line_cur(V1,V2,R,X,B,tap,phi);      
      V1 = v(from_idx,2);
      V2 = v(to_idx,2);
      [s12,s22] = line_pqf(V1,V2,R(:,2),X(:,2),B(:,2),tap(:,2),phi(:,2));%line_pq(V1,V2,R,X,B,tap,phi);
      [l_if2,l_it2]=line_curf(V1,V2,R(:,2),X(:,2),B(:,2),tap(:,2),phi(:,2));%line_cur(V1,V2,R,X,B,tap,phi);
%       [s12,s22] = line_pq(V1,V2,R,X,B,tap,phi);
%       [l_if2,l_it2]=line_cur(V1,V2,R,X,B,tap,phi);      
      c_pf1(:,j_state) = (real(s12-s11))/pert; 
      c_qf1(:,j_state) = (imag(s12-s11))/pert;
      c_pf2(:,j_state) = (real(s22-s21))/pert;
      c_qf2(:,j_state) = (imag(s22-s21))/pert;
      c_ilmf(:,j_state) = (abs(l_if2)-abs(l_if1))/pert;
      c_ilmt(:,j_state) = (abs(l_it2)-abs(l_it1))/pert;
      c_ilaf(:,j_state) = (angle(l_if2)-angle(l_if1))/pert;
      c_ilat(:,j_state) = (angle(l_it2)-angle(l_it1))/pert;
      c_ilrf(:,j_state) = real(l_if2-l_if1)/pert;
      c_ilif(:,j_state) = imag(l_if2-l_if1)/pert;
      c_ilrt(:,j_state) = real(l_it2-l_it1)/pert;
      c_ilit(:,j_state) = imag(l_it2-l_it1)/pert;
   end
   if n_conv~=0
      c_dcir(:,j_state) = (i_dcr(:,2)-i_dcr(:,1))/pert;
      c_dcii(:,j_state) = (i_dci(:,2)-i_dci(:,1))/pert;
      c_Vdcr(:,j_state) = (Vdc(r_idx,2)-Vdc(r_idx,1))/pert;
      c_Vdci(:,j_state) = (Vdc(i_idx,2)-Vdc(i_idx,1))/pert;
   end
else
   % form b and d matrices
   if c_state == 1
      b_vr(:,vr_input) = p_mat*d_vector/pert;
      d_pvr(:,vr_input) = (pelect(:,2)-pelect(:,1)).*mac_pot(:,1)/pert;
      d_vvr(:,vr_input) = abs(v(:,2) - v(:,1))/pert;
      d_angvr(:,vr_input) = (theta(:,2)-theta(:,1))/pert;
   elseif c_state == 2
      b_pr(:,pr_input) = p_mat*d_vector/pert;
      d_ppr(:,pr_input) = (pelect(:,2) - pelect(:,1)).*mac_pot(:,1)/pert;
      d_vpr(:,pr_input) = abs(v(:,2) - v(:,1))/pert;
      d_angpr(:,pr_input) = (theta(:,2)-theta(:,1))/pert; 
   elseif c_state == 3
      b_svc(:,svc_input) = p_mat*d_vector/pert;
      % note: d_svc is zero because of the time constant
   elseif c_state == 4
      b_tcsc(:,tcsc_input) = p_mat*d_vector/pert;
   elseif c_state == 5
      b_lmod(:,lmod_input) = p_mat*d_vector/pert;
      d_v_lmod = (abs(v(:,2)) - abs(v(:,1)))/pert;
      d_ang_lmod = (theta(:,2)-theta(:,1))/pert;
      % note: d_lmod is zero because of the time constant
   elseif c_state == 6
      b_rlmod(:,rlmod_input) = p_mat*d_vector/pert;
      d_v_rlmod = (abs(v(:,2)) - abs(v(:,1)))/pert;
      d_ang_rlmod = (theta(:,2)-theta(:,1))/pert;
      % note: d_lmod is zero because of the time constant
   elseif c_state == 7
      b_dcr(:,dcmod_input) = p_mat*d_vector/pert;
      d_pdcr(:,dcmod_input) = (pelect(:,2)-pelect(:,1)).*mac_pot(:,1)/pert;
      d_vdcr(:,dcmod_input) = abs(v(:,2) - v(:,1))/pert;
      d_angdcr(:,dcmod_input) = (theta(:,2)-theta(:,1))/pert;
      d_pdcr(:,dcmod_input)=(pelect(:,2) - pelect(:,1)).*mac_pot(:,1)/pert;
      d_idcdcr(:,dcmod_input) = (i_dcr(:,2)-i_dcr(:,1))/pert;
      d_Vdcrdcr(:,dcmod_input) = (Vdc(r_idx,2)-Vdc(r_idx,1))/pert;
      d_Vdcidcr(:,dcmod_input) = (Vdc(i_idx,2)-Vdc(i_idx,1))/pert;
      if ~isempty(lmon_con) 
         from_idx = bus_int(line(lmon_con,1));
         to_idx = bus_int(line(lmon_con,2));
         V1 = v(from_idx,1);
         V2 = v(to_idx,1);
         [s11,s21] = line_pqf(V1,V2,R,X,B,tap,phi);
         [l_if1,l_it1] = line_curf(V1,V2,R,X,B,tap,phi);
         V1 = v(from_idx,2);
         V2 = v(to_idx,2);
         [s12,s22] = line_pqf(V1,V2,R,X,B,tap,phi);
         [l_if2,l_it2]=line_curf(V1,V2,R,X,B,tap,phi);
         d_pf1cdr(:,dcmod_input) = (real(s12-s11))/pert; 
         d_qf1dcr(:,dcmod_input) = (imag(s12-s11))/pert;
         d_pf2dcr(:,dcmod_input) = (real(s22-s21))/pert;
         d_qf2dcr(:,dcmod_input) = (imag(s22-s21))/pert;
         d_ilmfdcr(:,dcmod_input) = (abs(l_if2)-abs(l_if1))/pert;
         d_ilmtdcr(:,dcmod_input) = (abs(l_it2)-abs(l_it1))/pert;
         d_ilrfdcr(:,dcmod_input) = real(l_if2-l_if1)/pert;
         d_ilifdcr(:,dcmod_input) = imag(l_if2-l_if1)/pert;
         d_ilrtdcr(:,dcmod_input) = real(l_it2-l_it1)/pert;
         d_ilitdcr(:,dcmod_input) = imag(l_it2-l_it1)/pert;
      end      
   elseif c_state == 8
      b_dci(:,dcmod_input) = p_mat*d_vector/pert;
      d_pdci(:,dcmod_input) = (pelect(:,2)-pelect(:,1)).*mac_pot(:,1)/pert;
      d_vdci(:,dcmod_input) = abs(v(:,2) - v(:,1))/pert;
      d_angdci(:,dcmod_input) = (theta(:,2)-theta(:,1))/pert;
      d_pdci(:,dcmod_input)=(pelect(:,2) - pelect(:,1)).*mac_pot(:,1)/pert;
      d_idcdci(:,dcmod_input) = (i_dci(:,2)-i_dci(:,1))/pert;
      d_Vdcrdci(:,dcmod_input) = (Vdc(r_idx,2)-Vdc(r_idx,1))/pert;
      d_Vdcdci(:,dcmod_input) = (Vdc(i_idx,2)-Vdc(i_idx,1))/pert;
      if ~isempty(lmon_con) 
         from_idx = bus_int(line(lmon_con,1));
         to_idx = bus_int(line(lmon_con,2));
         V1 = v(from_idx,1);
         V2 = v(to_idx,1);
         [s11,s21] = line_pqf(V1,V2,R,X,B,tap,phi);
         [l_if1,l_it1] = line_curf(V1,V2,R,X,B,tap,phi);
         V1 = v(from_idx,2);
         V2 = v(to_idx,2);
         [s12,s22] = line_pqf(V1,V2,R,X,B,tap,phi);
         [l_if2,l_it2]=line_curf(V1,V2,R,X,B,tap,phi);
         d_pf1cdi(:,dcmod_input) = (real(s12-s11))/pert; 
         d_qf1dci(:,dcmod_input) = (imag(s12-s11))/pert;
         d_pf2dci(:,dcmod_input) = (real(s22-s21))/pert;
         d_qf2dci(:,dcmod_input) = (imag(s22-s21))/pert;
         d_ilmfdci(:,dcmod_input) = (abs(l_if2)-abs(l_if1))/pert;
         d_ilmtdci(:,dcmod_input) = (abs(l_it2)-abs(l_it1))/pert;
         d_ilrfdci(:,dcmod_input) = real(l_if2-l_if1)/pert;
         d_ilifdci(:,dcmod_input) = imag(l_if2-l_if1)/pert;
         d_ilrtdci(:,dcmod_input) = real(l_it2-l_it1)/pert;
         d_ilitdci(:,dcmod_input) = imag(l_it2-l_it1)/pert;
      end
      % Generation of input matrices for shtr (SVR)
      elseif c_state == 9
            b_shtr(:,shtr_input) = p_mat*d_vector/pert;
      % Generation of input matrices for TCSR
      elseif c_state == 10
            b_tcsr(:,tcsr_input) = p_mat*d_vector/pert;
      % Generation of input matrices for WTG
      elseif c_state == 11
            b_wth_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_wth_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_wth_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_wth_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_wth_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_wth_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_wth_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 12
            b_Pth_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_Pth_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_Pth_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_Pth_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_Pth_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_Pth_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_Pth_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
            d_Pord_Pth_wtg(:,wtg_input) = (Pord_wtg(:,2) - Pord_wtg(:,1))/pert;
            d_t_Pth_wtg(:,wtg_input) = (telect(:,2)-telect(:,1))/pert;
      elseif c_state == 13
            b_th_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_th_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_th_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_th_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_th_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_th_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_th_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 14
            b_wT_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_wT_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_wT_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_wT_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_wT_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_wT_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_wT_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 15
            b_T_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_T_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_T_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_T_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_T_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_T_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_T_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 16
            b_x0_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_x0_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_x0_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_x0_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_x0_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_x0_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_x0_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 17
            b_Ip_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_Ip_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_Ip_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_Ip_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_Ip_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_Ip_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_Ip_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 18
            b_Pf_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_Pf_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_Pf_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_Pf_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_Pf_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_Pf_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_Pf_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
            d_t_Pf_wtg(:,wtg_input) = (telect(:,2)-telect(:,1))/pert;
      elseif c_state == 19
            b_VQ_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_VQ_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_VQ_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_VQ_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_VQ_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_VQ_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_VQ_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 20
            b_QQ_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_QQ_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_QQ_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_QQ_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_QQ_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_QQ_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_QQ_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
            d_t_QQ_wtg(:,wtg_input) = (telect(:,2)-telect(:,1))/pert;
      elseif c_state == 21
            b_Vt_wtg(:,wtg_input) = p_mat*d_vector/pert;
            % d matrices
            d_Is_Vt_wtg(:,wtg_input) = (abs( Iswtg(:,2) ) - abs( Iswtg(:,1) ))/pert;
            d_Isang_Vt_wtg(:,wtg_input) = (angle( Iswtg(:,2) ) - angle( Iswtg(:,1) ))/pert;
            d_Isre_Vt_wtg(:,wtg_input) = (real( Iswtg(:,2) ) - real( Iswtg(:,1) ))/pert;
            d_Isim_Vt_wtg(:,wtg_input) = (imag( Iswtg(:,2) ) - imag( Iswtg(:,1) ))/pert;
            d_P_Vt_wtg(:,wtg_input) = (Pgb_wtg(:,2) - Pgb_wtg(:,1))/pert;
            d_Q_Vt_wtg(:,wtg_input) = (Qgb_wtg(:,2) - Qgb_wtg(:,1))/pert;
      elseif c_state == 22
            b_Vtm_wtg(:,wtg_input) = p_mat*d_vector/pert;
      elseif c_state == 23
            b_Vta_wtg(:,wtg_input) = p_mat*d_vector/pert;
      elseif c_state == 24
            b_Vtr_wtg(:,wtg_input) = p_mat*d_vector/pert;
      elseif c_state == 25
            b_Vti_wtg(:,wtg_input) = p_mat*d_vector/pert;
      elseif c_state == 26
            b_Vw_wtg(:,wtg_input) = p_mat*d_vector/pert;
      elseif c_state == 27
            b_Ism_wtg(:,wtg_input) = p_mat*d_vector/pert;
            d_t_Ism_wtg(:,wtg_input) = (telect(:,2)-telect(:,1))/pert;
      elseif c_state == 28
            b_Isa_wtg(:,wtg_input) = p_mat*d_vector/pert;
            d_t_Isa_wtg(:,wtg_input) = (telect(:,2)-telect(:,1))/pert;
      elseif c_state == 29
            b_Isr_wtg(:,wtg_input) = p_mat*d_vector/pert;
            d_t_Isr_wtg(:,wtg_input) = (telect(:,2)-telect(:,1))/pert;
      elseif c_state == 30
            b_Isi_wtg(:,wtg_input) = p_mat*d_vector/pert;
            d_t_Isi_wtg(:,wtg_input) = (telect(:,2)-telect(:,1))/pert;
      elseif c_state == 31
            b_Im_ccinj(:,ccinj_input) = p_mat*d_vector/pert;
      elseif c_state == 32
            b_Iang_ccinj(:,ccinj_input) = p_mat*d_vector/pert;
   end
end
%reset states to initial values
eterm(:,2) = eterm(:,1);
pelect(:,2) = pelect(:,1);
qelect(:,2) = qelect(:,1);
psi_re(:,2) = psi_re(:,1);
psi_im(:,2) = psi_im(:,1);
v(:,2) = v(:,1);
bus_v(:,2)=bus_v(:,1);
theta(:,2) = theta(:,1);
pmech(:,2) = pmech(:,1);
telect(:,2) = telect(:,1);
mac_ang(:,2) = mac_ang(:,1);
dmac_ang(:,2) = dmac_ang(:,1);
mac_spd(:,2) = mac_spd(:,1);
dmac_spd(:,2) = dmac_spd(:,1);
eqprime(:,2) = eqprime(:,1);
deqprime(:,2) = deqprime(:,1);
psikd(:,2) = psikd(:,1);
dpsikd(:,2) = dpsikd(:,1);
edprime(:,2) = edprime(:,1);
dedprime(:,2) = dedprime(:,1);
psikq(:,2)=psikq(:,1);
if n_exc ~= 0
   V_TR(:,2)=V_TR(:,1);
   dV_TR(:,2)=dV_TR(:,1);
   V_As(:,2) = V_As(:,1);
   dV_As(:,2) = dV_As(:,1);
   V_A(:,2) = V_A(:,1);
   dV_R(:,2) = dV_R(:,1);
   V_R(:,2)=V_R(:,1);
   Efd(:,2)=Efd(:,1);
   dEfd(:,2) = dEfd(:,1);
   R_f(:,2)=R_f(:,1);
   dR_f(:,2) = dR_f(:,1);
end
if n_pss~=0
   pss1(:,2)=pss1(:,1);
   pss2(:,2)=pss2(:,1);
   pss3(:,2)=pss3(:,1);
   dpss1(:,2)=dpss1(:,1);
   dpss2(:,2)=dpss2(:,1);
   dpss3(:,2)=dpss3(:,1);
end
if n_dpw~=0
   sdpw1(:,2)=sdpw1(:,1);
   sdpw2(:,2)=sdpw2(:,1);
   sdpw3(:,2)=sdpw3(:,1);
   sdpw4(:,2)=sdpw4(:,1);
   sdpw5(:,2)=sdpw5(:,1);
   sdpw6(:,2)=sdpw6(:,1);   
   dsdpw1(:,2)=dsdpw1(:,1);
   dsdpw2(:,2)=dsdpw2(:,1);
   dsdpw3(:,2)=dsdpw3(:,1);
   dsdpw4(:,2)=dsdpw4(:,1);
   dsdpw5(:,2)=dsdpw5(:,1);
   dsdpw6(:,2)=dsdpw6(:,1);

end

if n_tg~=0||n_tgh~=0
   tg1(:,2)=tg1(:,1);
   tg2(:,2)=tg2(:,1);
   tg3(:,2)=tg3(:,1);
   tg4(:,2)=tg4(:,1);
   tg5(:,2)=tg5(:,1);
   dtg1(:,2)=dtg1(:,1);
   dtg2(:,2)=dtg2(:,1);
   dtg3(:,2)=dtg3(:,1);
   dtg4(:,2)=dtg4(:,1);
   dtg5(:,2)=dtg5(:,1);
end
if n_mot~=0
   vdp(:,2) = vdp(:,1);
   vqp(:,2) = vqp(:,1);
   slip(:,2) = slip(:,1);
   dvdp(:,2) = dvdp(:,1);
   dvqp(:,2) = dvqp(:,1);
   dslip(:,2) = dslip(:,1);
end
if n_ig~=0
   vdpig(:,2) = vdpig(:,1);
   vqpig(:,2) = vqpig(:,1);
   slig(:,2) = slig(:,1);
   dvdpig(:,2) = dvdpig(:,1);
   dvqpig(:,2) = dvqpig(:,1);
   dslig(:,2) = dslig(:,1);
end
if n_svc ~=0
   B_cv(:,2) = B_cv(:,1);
   dB_cv(:,2) = dB_cv(:,1);
   B_con(:,2) = B_con(:,1);
   dB_con(:,2) = dB_con(:,1);
   svc_sig(:,2) = svc_sig(:,1);
end
if n_tcsc~=0
   B_tcsc(:,2)=B_tcsc(:,1);
   dB_tcsc(:,2)=dB_tcsc(:,1);
   tcsc_sig(:,2)=tcsc_sig(:,1);
end
if n_lmod ~=0
   lmod_st(:,2) = lmod_st(:,1);
   dlmod_st(:,2) = dlmod_st(:,1);
   lmod_sig(:,2) = lmod_sig(:,1);
end
if n_rlmod ~=0
   rlmod_st(:,2) = rlmod_st(:,1);
   drlmod_st(:,2) = drlmod_st(:,1);
   rlmod_sig(:,2) = rlmod_sig(:,1);
end

if n_conv~=0
   v_conr(:,2) = v_conr(:,1);
   v_coni(:,2) = v_coni(:,1);
   i_dcr(:,2) = i_dcr(:,1);
   i_dci(:,2) = i_dci(:,1);
   v_dcc(:,2) = v_dcc(:,1);
   dv_conr(:,2) = dv_conr(:,1);
   dv_coni(:,2) = dv_coni(:,1);
   di_dcr(:,2) = di_dcr(:,1);
   di_dci(:,2) = di_dci(:,1);
   dv_dcc(:,2) = dv_dcc(:,1);
   Vdc(:,2) = Vdc(:,1);
   i_dc(:,2) = i_dc(:,1);
   alpha(:,2) = alpha(:,1);
   gamma(:,2) = gamma(:,1); 
   dc_sig(:,2)=dc_sig(:,1);
end

line_aux = line_or;
line_compl(:,:,2) = line_or;

if n_shtr~=0
    Yshtr(:,2) = Yshtr(:,1); 
    frfilt_shtr(:,2) = frfilt_shtr(:,1); % not perturbed, but anyway
    dYshtr(:,2) = dYshtr(:,1); 
    dfrfilt_shtr(:,2) = dfrfilt_shtr(:,1); % not perturbed, but anyway
    shtr_sig(:,2) = shtr_sig(:,1);
end

if n_tcsr~=0
    X_tcsr(:,2) = X_tcsr(:,1);
    frfilt_tcsr(:,2) = frfilt_tcsr(:,1);
    dX_tcsr(:,2) = dX_tcsr(:,1);
    dfrfilt_tcsr(:,2) = dfrfilt_tcsr(:,1);
    tcsr_sig(:,2) = tcsr_sig(:,1);
end

if n_wtg~=0
    
    wtSV_wtg(:,2) = wtSV_wtg(:,1);          % 1
    wgSV_wtg(:,2) = wgSV_wtg(:,1);          % 2
    delgt_wtg(:,2) = delgt_wtg(:,1);        % 3
    delerr1_wtg(:,2) = delerr1_wtg(:,1);	% 4
    delerr2_wtg(:,2) = delerr2_wtg(:,1);	% 5
    Eerr_wtg(:,2) = Eerr_wtg(:,1);          % 6
    th_wtg(:,2) = th_wtg(:,1);              % 7
    Pord_wtg(:,2) = Pord_wtg(:,1);          % 8
    wref_wtg(:,2) = wref_wtg(:,1);          % 9
    x0_wtg(:,2) = x0_wtg(:,1);              % 10
    x1_wtg(:,2) = x1_wtg(:,1);              % 11
    gam_wtg(:,2) = gam_wtg(:,1);            % 12
    Efd_wtg(:,2) = Efd_wtg(:,1);            % 13
    Rerr_wtg(:,2) = Rerr_wtg(:,1);          % 14


    dwtSV_wtg(:,2) = dwtSV_wtg(:,1);        % 1
    dwgSV_wtg(:,2) = dwgSV_wtg(:,1);        % 2
    ddelgt_wtg(:,2) = ddelgt_wtg(:,1);      % 3
    ddelerr1_wtg(:,2) = ddelerr1_wtg(:,1);	% 4
    ddelerr2_wtg(:,2) = ddelerr2_wtg(:,1);	% 5
    dEerr_wtg(:,2) = dEerr_wtg(:,1);        % 6
    dth_wtg(:,2) = dth_wtg(:,1);            % 7
    dPord_wtg(:,2) = dPord_wtg(:,1);        % 8
    dwref_wtg(:,2) = dwref_wtg(:,1);        % 9
    dx0_wtg(:,2) = dx0_wtg(:,1);            % 10
    dx1_wtg(:,2) = dx1_wtg(:,1);            % 11
    dgam_wtg(:,2) = dgam_wtg(:,1);          % 12
    dEfd_wtg(:,2) = dEfd_wtg(:,1);          % 13
    dRerr_wtg(:,2) = dRerr_wtg(:,1);        % 14
    
    IQcmd_wtg(:,2) = IQcmd_wtg(:,1); 
    dIQcmd_wtg(:,2) = dIQcmd_wtg(:,1); 

    Edbr_wtg(:,2) = Edbr_wtg(:,1); 
    Vlvpl_wtg(:,2) = Vlvpl_wtg(:,1); 

    dEdbr_wtg(:,2) = dEdbr_wtg(:,1); 
    dVlvpl_wtg(:,2) = dVlvpl_wtg(:,1);

    Qset_wtg(:,2) = Qset_wtg(:,1);
    s2_wtg(:,2) = s2_wtg(:,1);
    s3_wtg(:,2) = s3_wtg(:,1);
    s4_wtg(:,2) = s4_wtg(:,1);
    s6_wtg(:,2) = s6_wtg(:,1);
    s7_wtg(:,2) = s7_wtg(:,1); 

    dQset_wtg(:,2) = dQset_wtg(:,1);
    ds2_wtg(:,2) = ds2_wtg(:,1);
    ds3_wtg(:,2) = ds3_wtg(:,1);
    ds4_wtg(:,2) = ds4_wtg(:,1);
    ds6_wtg(:,2) = ds6_wtg(:,1);
    ds7_wtg(:,2) = ds7_wtg(:,1);
    
    s1wini_wtg(:,2) = s1wini_wtg(:,1);
    s2wini_wtg(:,2) = s2wini_wtg(:,1);

    ds1wini_wtg(:,2) = ds1wini_wtg(:,1);
    ds2wini_wtg(:,2) = ds2wini_wtg(:,1);
    dpwi_wtg(:,2) = dpwi_wtg(:,1);
    
    %Iswtg(:,2) = Iswtg(:,1);
    bus_freq(:,2) = bus_freq(:,1);
    
    wth_sig_wtg(:,2) = wth_sig_wtg(:,1);
    Pth_sig_wtg(:,2) = Pth_sig_wtg(:,1);
    th_sig_wtg(:,2) = th_sig_wtg(:,1);
    wT_sig_wtg(:,2) = wT_sig_wtg(:,1);
    T_sig_wtg(:,2) = T_sig_wtg(:,1);
    x0_sig_wtg(:,2) = x0_sig_wtg(:,1);
    Ip_sig_wtg(:,2) = Ip_sig_wtg(:,1);
    Pf_sig_wtg(:,2) = Pf_sig_wtg(:,1);
    VQ_sig_wtg(:,2) = VQ_sig_wtg(:,1);
    QQ_sig_wtg(:,2) = QQ_sig_wtg(:,1);
    Vt_sig_wtg(:,2) = Vt_sig_wtg(:,1);
    
    Vtm_sig_wtg(:,2) = Vtm_sig_wtg(:,1); 
    Vta_sig_wtg(:,2) = Vta_sig_wtg(:,1); 
    Vtr_sig_wtg(:,2) = Vtr_sig_wtg(:,1); 
    Vti_sig_wtg(:,2) = Vti_sig_wtg(:,1); 

    Vw_sig_wtg(:,2) = Vw_sig_wtg(:,1);

    Ism_sig_wtg(:,2) = Ism_sig_wtg(:,1); 
    Isa_sig_wtg(:,2) = Isa_sig_wtg(:,1); 
    Isr_sig_wtg(:,2) = Isr_sig_wtg(:,1); 
    Isi_sig_wtg(:,2) = Isi_sig_wtg(:,1);

end