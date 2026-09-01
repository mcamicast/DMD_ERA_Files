function [sstr] = svm_mgenf(dfile,pathname,sys_freq_i,basmva_i)
% svm_mgen.m  
% 6:27 PM 18/8/97
% m.file to generate state variable models  
% This m file takes the load flow and dynamic data from a data m file
% and calulates the state space matrices:
% 		A matrix in  a_mat
%               B matrices 
%                 for a change in Exciter Vref in b_vr 
%                 for a change in Turbine governor Pref b_pr 
%                 for a change in generator mechanical torque b_pm
%                 for a change in svc reference voltage b_svc
%                 for a change in tcsc input  b_tcsc
%                 for a change in active power modulation b_lmod
%                 for a change in reactive load modulation b_rlmod
%                 b_shtr for a change in Shunt Variable Reactor
%                 b_tcsr for a change in TCSR (DSR)
%               WTG input matrices (internal inputs)
%                 b_wth_wtg
%                 b_Pth_wtg
%                 b_th_wtg
%                 b_wT_wtg
%                 b_T_wtg
%                 b_x0_wtg
%                 b_Ip_wtg
%                 b_Pf_wtg
%                 b_VQ_wtg
%                 b_QQ_wtg
%                 b_Vt_wtg


%               WTG inputs (external inputs)
%                 b_Vtm_wtg 
%                 b_Vta_wtg 
%                 b_Vtr_wtg 
%                 b_Vti_wtg 
% 
%                 b_Vw_wtg
% 
%                 b_Ism_wtg 
%                 b_Isa_wtg 
%                 b_Isr_wtg 
%                 b_Isi_wtg

%               C matrices
%                 change in generator speed  c_spd
%                 change in generator electrical torque c_t on generator base
%                 change in generator electrical power c_p on generator base
%                 change in bus voltage angles c_ang
%                 change in bus voltage magnitude  c_v
%                 change in from_bus line active power c_pf1
%                 change in from_bus line reactive power c_qf1
%                 change in to_bus line active power c_pf2
%                 change in to_bus line reactive power c_qf2
%                 change in from bus current magnitude c_ilmf
%                 change in to bus current magnitude c_ilmt
%                 change in from bus current angle c_ilaf -(NEW)
%                 change in to bus current angle c_ilat  -(NEW)
%                 change in from bus real current  c_ilrf
%                 change in to bus real current c_ilrt
%                 change in from bus imaginary current c_ilif
%                 change in to bus imaginary current c_ilit

%               WTG output matrices
%                 c_Isre_wtg
%                 c_Isim_wtg
%                 c_Is_wtg - magnitude of WTG current
%                 c_Isang_wtg - angle of WTG current
%                 c_wtSV_wtg
%                 c_wgSV_wtg
%                 c_th_wtg
%                 c_Pord_wtg

%               D matrices
%                 combination of output and input, e.g.,
%                 for power out and p_ref in --- d_ppr
% l is the eigenvalue vector of a_mat
% u is the right eigenvector matrix of a_mat
% v is the left eigenvector matrix of a_mat (vu = I)
% p is the unscaled participation matrix
% p_norm is the scaled participation matrix 
% the maximum value of each column in p_norm is unity
% all scaled participations less than 0.1 are set to zero
% to find the states associated with the jth eigenvalue
% use sparse(abs(p_norm(:,j)))
% pr gives the participation factors of the eigenvalues 
% associated with the rotor angle states of each generator
% use sparse(abs(pr(k,:))) to find the modes associated 
% with the rotor angle of the kth generator
% 
% Author: Graham Rogers
% Modified December 1998
% tcsc model added
% Modified July 1998
% deltaP/omega filter added
% Modified June 1998
% hydraulic turbine/governor added
% Modified: August 1997
% Induction Generator added
% Modified: August 1997
%           load modulation and output matrices for line flow added
% Modified: April 1997
%           HVDC added
% Version 1.0
% Date: September 1996
% Copyright - Joe Chow/Cherry Tree Scientific Software 1991-1997
%

clearvars -except dfile pathname sys_freq_i basmva_i
clear global
close %graphics windows
% set up global variables
pst_var; svm_var;
line = [];

jay = sqrt(-1);
%
% load input data from m.file
disp('linearized model development by perturbation of the non-linear model')
%set user defined SVC and TCSC models to empty 
svc_dc = [];
dci_dc=[]; dcr_dc=[];
% input data file
% [dfile,pathname]=uigetfile('d*.m','Select Data File');
% if pathname == 0
%    error(' you must select a valid data file')
% else
lfile = length(dfile); curpath = cd; cd(pathname); 
% check either a mat file or a m file
switch dfile(find(dfile=='.'):end)
    case '.mat'
        load(dfile)
    case '.m'
        % strip off .m and convert to lower case %msgbox('case .m')
        dfile = dfile(1:lfile-2); % dfile = lower(dfile(1:lfile-2));
        run(dfile)% eval(dfile);
    otherwise
        error('file extension not supported')
end
cd(curpath);

% check for valid dynamic data file
if isempty(mac_con)
   error(' the selected file is not a valid data file')
end
% basdat = inputdlg({'Base MVA:','Base Frequency Hz:'},'Input Base Data',1,{'100','60'}); 
% sys_freq = str2double(basdat{2});
sys_freq = sys_freq_i;
basrad = 2*pi*sys_freq; % default system frequency is 60 Hz
% basmva = str2double(basdat{1});
basmva = basmva_i;
syn_ref = 0 ;     % synchronous reference frame

% disp(' ')
% lfpf = inputdlg('do you wish to perform a post fault load flow?Y/N[N]','s');
% if isempty(lfpf); lfpf{1} = 'N';end
% if lfpf{1} =='y'; lfpf{1} = 'Y'; end
% if lfpf{1} == 'Y'
%    disp('enter the changes to bus and line required to give the post fault condition')
%    disp('when you have finished, type return and press enter')
%    keyboard
% end

% solve for loadflow - loadflow parameter
wtg_vervw([]);
bus = wtg_indx(bus,line); % must be before loadflow - includes param of WTGs
bus = ccinj_indx(bus,line);
if isempty(dcsp_con)
  n_conv = 0;
  n_dcl = 0;
  tol = 1e-5;   % tolerance for convergence
  iter_max = 30; % maximum number of iterations
  acc = 1.0;   % acceleration factor
  [bus_sol,line,line_flw] = ...
     loadflow(bus,line,tol,iter_max,acc,'n',2);
  bus = bus_sol;  % solved loadflow solution needed for
  % initialization
  % save sim_fle bus line n_conv n_dcl
else
  [bus_sol,line,line_flw,rec_par,inv_par, line_par] = lfdcs(bus,line,dci_dc,dcr_dc);
  bus = bus_sol;
  % save sim_fle bus line rec_par  inv_par line_par
end 
% else
%    load sim_fle 
% end
n_bus = length(bus(:,1));
n_exc= 0;
n_dc = 0;
n_smp = 0;
n_st3 = 0;
n_pss= 0;
n_dpw = 0;
n_tg = 0;
n_tgh = 0;
n_svc = 0;
n_tcsc = 0;
n_lmod = 0;
n_rlmod = 0;
n_shtr = 0; n_tcsr = 0;

% note dc_indx called in load flow
mac_indx;% identifies generators
ntot = n_mac+n_mot+n_ig;
ngm = n_mac+n_mot;
pm_sig = zeros(n_mac,2);
mac_exc=0;
% check for infinite buses
if n_ib~=0
   %remove controls associated with infinite bus generators
   %remove exciters
   if ~isempty(exc_con)
      n_exc = length(exc_con(:,1));
      net_idx = zeros(n_exc,1);
      for j = 1:n_ib
         net_idx = net_idx|exc_con(:,2)==mac_con(mac_ib_idx(j),1);
      end
      if length(net_idx)==1;
         if net_idx ==1;exc_con=[];end
      else
         perm = diag(~net_idx);
         perm = perm(~net_idx,:);
         exc_con = perm*exc_con;
      end
   end
   % remove pss
   if ~isempty(pss_con)
      n_pss = length(pss_con(:,1));
      net_idx = zeros(n_pss,1);
      for j = 1:n_ib
         net_idx = net_idx|pss_con(:,2) == mac_con(mac_ib_idx(j),1);
      end
      if length(net_idx)==1
         if net_idx == 1;pss_con = [];end
      else
         perm = diag(~net_idx);
         perm = perm(~net_idx,:);
         pss_con = perm*pss_con;
      end
   end
      % remove deltaP/omega filter
   if ~isempty(dpw_con)
      n_dpw = length(dpw_con(:,1));
      net_idx = zeros(n_dpw,1);
      for j = 1:n_ib
         net_idx = net_idx|dpw_con(:,1) == mac_con(mac_ib_idx(j),1);
      end
      if length(net_idx)==1
         if net_idx == 1;dpw_con = [];end
      else
         perm = diag(~net_idx);
         perm = perm(~net_idx,:);
         dpw_con = perm*dpw_con;
      end
   end
   % remove turbine/governors
   if ~isempty(tg_con)
      n_tg = length(tg_con(:,1));
      net_idx= zeros(n_tg,1);
      for j=1:n_ib
         net_idx =net_idx| tg_con(:,2) == mac_con(mac_ib_idx(j),1);
      end
      if length(net_idx)==1
         if net_idx==1;tg_con = [];end
      else
         perm = diag(~net_idx);
         perm = perm(~net_idx,:);
         tg_con = perm*tg_con;
      end
   end
end

if ~isempty(exc_con)
   exc_indx;%identifies exciters
   mac_exc = mac_int(exc_con(:,2));
else
   n_exc=0;
end
mac_pss=0;
if ~isempty(pss_con)
   pss_indx;%identifies power system stabilizers
   mac_pss=mac_int(pss_con(:,2));
else
   n_pss=0;
end
mac_dpw=0;
if ~isempty(dpw_con)
   dpwf_indx;%identifies deltaP/omega filters
   mac_dpw=mac_int(dpw_con(:,1));
else
   n_dpw=0;
end

mac_tg=0;mac_tgh=0;
if ~isempty(tg_con)
   tg_indx;%identifies turbine/governor
   mac_tg = mac_int(tg_con(tg_idx,2));
   mac_tgh = mac_int(tg_con(tgh_idx,2));
else
   n_tg =0;
   n_tgh = 0;
end
if ~isempty(svc_con)~=0
   svc_dc=[];
   svc_indx(svc_dc);
else
   n_svc = 0;
end
tcsc_dc=[];n_tcscud=0;
if ~isempty(tcsc_con)
   tcsc_indx(tcsc_dc);
else
   n_tcsc = 0;
end
if ~isempty(lmod_con)~=0
   lm_indx; % identifies load modulation buses
else
   n_lmod = 0;
end
if ~isempty(rlmod_con)~=0
   rlm_indx; % identifies load modulation buses
else
   n_rlmod = 0;
end
shtr_indx(bus,line); % n_shtr should be set to zero when needed
tcsr_indx(bus,line); % n_tcsr should be set to zero when needed


%initialize induction motor
if n_mot~=0
   vdp = zeros(n_mot,2);
   vqp = zeros(n_mot,2);
   slip = zeros(n_mot,2);
   dvdp = zeros(n_mot,2);
   dvqp = zeros(n_mot,2);
   dslip = zeros(n_mot,2);
end
bus = mac_ind(0,1,bus,0);

%initialize induction generator
if n_ig~=0
   vdpig = zeros(n_ig,2);
   vqpig = zeros(n_ig,2);
   slig = zeros(n_ig,2);
   dvdpig = zeros(n_ig,2);
   dvqpig = zeros(n_ig,2);
   dslig = zeros(n_ig,2);
   tmig = zeros(n_ig,2);
end
bus = mac_igen(0,1,bus,0);

%initialize svc
if n_svc ~=0
   B_cv = zeros(n_svc,2);
   dB_cv = zeros(n_svc,2);
   B_con = zeros(n_svc,2);
   dB_con = zeros(n_svc,2);
   if n_dcud~=0
      error('user defined svc damping control not allowed in small signal simulation')
   else
      svc_dsig = zeros(n_svc,2);
   end
end
bus = svc(0,1,bus,0);

if n_conv~=0
   % pick up HVDC initial variables from load flow
   Vdc(r_idx,1) = rec_par(:,2); Vdc(i_idx,1) = inv_par(:,2);
   i_dc(r_idx,1) = line_par; i_dc(i_idx,1) = line_par;
   i_dcr(:,1) = i_dc(r_idx,1); i_dci(:,1) = i_dc(i_idx,1);
   alpha(:,1) = rec_par(:,1)*pi/180;
   gamma(:,1) = inv_par(:,1)*pi/180;
   dcr_dsig=zeros(n_dcl,2); dci_dsig=zeros(n_dcl,2);
   dc_sig=zeros(n_conv,2);
end
dc_cont(0,1,1,bus,0); % initialize the dc controls - sets up data for red_ybus
% this has to be done before red_ybus is used since the induction motor,svc and
% dc link initialization alters the bus matrix

%initialize WTG
if n_wtg ~=0
    %
    wtg_con(:,36) = 0;              % Turn off lvpl for linearization
    wtg_con(:,67) = 0;              % Turn off WindINERTIA for linarization
    wtSV_wtg = zeros(n_wtg,2);      % 1
    wgSV_wtg = zeros(n_wtg,2);      % 2
    delgt_wtg = zeros(n_wtg,2);     % 3
    delerr1_wtg = zeros(n_wtg,2);   % 4
    delerr2_wtg = zeros(n_wtg,2);   % 5
    Eerr_wtg = zeros(n_wtg,2);      % 6
    th_wtg = zeros(n_wtg,2);        % 7
    Pord_wtg = zeros(n_wtg,2);      % 8
    wref_wtg = zeros(n_wtg,2);      % 9
    x0_wtg = zeros(n_wtg,2);        % 10
    x1_wtg = zeros(n_wtg,2);        % 11
    gam_wtg = zeros(n_wtg,2);       % 12
    Efd_wtg = zeros(n_wtg,2);       % 13
    Rerr_wtg = zeros(n_wtg,2);      % 14    
    
    dwtSV_wtg = zeros(n_wtg,2);     % 1
    dwgSV_wtg = zeros(n_wtg,2);     % 2
    ddelgt_wtg = zeros(n_wtg,2);    % 3
    ddelerr1_wtg = zeros(n_wtg,2);  % 4
    ddelerr2_wtg = zeros(n_wtg,2);  % 5
    dEerr_wtg = zeros(n_wtg,2);     % 6
    dth_wtg = zeros(n_wtg,2);       % 7
    dPord_wtg = zeros(n_wtg,2);     % 8
    dwref_wtg = zeros(n_wtg,2);     % 9
    dx0_wtg = zeros(n_wtg,2);       % 10
    dx1_wtg = zeros(n_wtg,2);       % 11
    dgam_wtg = zeros(n_wtg,2);      % 12
    dEfd_wtg = zeros(n_wtg,2);      % 13
    dRerr_wtg = zeros(n_wtg,2);     % 14
    
    IQcmd_wtg = zeros(n_wtg,2);
    dIQcmd_wtg  = zeros(n_wtg,2);

    Edbr_wtg = zeros(n_wtg,2);
    Vlvpl_wtg = zeros(n_wtg,2);

    dEdbr_wtg = zeros(n_wtg,2);
    dVlvpl_wtg = zeros(n_wtg,2);

    Qset_wtg = zeros(n_wtg,2);
    s2_wtg = zeros(n_wtg,2);
    s3_wtg = zeros(n_wtg,2);
    s4_wtg = zeros(n_wtg,2);
    s6_wtg = zeros(n_wtg,2);
    s7_wtg = zeros(n_wtg,2);

    dQset_wtg = zeros(n_wtg,2);
    ds2_wtg = zeros(n_wtg,2);
    ds3_wtg = zeros(n_wtg,2);
    ds4_wtg = zeros(n_wtg,2);
    ds6_wtg = zeros(n_wtg,2);
    ds7_wtg = zeros(n_wtg,2);
    
    s1wini_wtg = zeros(n_wtg,2);
    s2wini_wtg = zeros(n_wtg,2); 

    ds1wini_wtg = zeros(n_wtg,2);
    ds2wini_wtg = zeros(n_wtg,2);
    dpwi_wtg = zeros(n_wtg,2);
    
    Iswtg = zeros(n_wtg,2);
    
    swinif_wtg = zeros(n_wtg,2);
    dswinif_wtg = zeros(n_wtg,2);
%     fst1_wtg = zeros(n_wtg,2);
%     fst2_wtg = zeros(n_wtg,2);
%     fst3_wtg = zeros(n_wtg,2);
%     fst4_wtg = zeros(n_wtg,2);
%     fst5_wtg = zeros(n_wtg,2);
%     fst6_wtg = zeros(n_wtg,2);
%     fst7_wtg = zeros(n_wtg,2);
% 
%     dfst1_wtg = zeros(n_wtg,2);
%     dfst2_wtg = zeros(n_wtg,2);
%     dfst3_wtg = zeros(n_wtg,2);
%     dfst4_wtg = zeros(n_wtg,2);
%     dfst5_wtg = zeros(n_wtg,2);
%     dfst6_wtg = zeros(n_wtg,2);
%     dfst7_wtg = zeros(n_wtg,2);

    Ism_sig_wtg = zeros(n_wtg,2);
    Isa_sig_wtg = zeros(n_wtg,2);
    Isr_sig_wtg = zeros(n_wtg,2);
    Isi_sig_wtg = zeros(n_wtg,2);
else  
end
if n_ccinj ~= 0
    Iccinj = zeros(n_ccinj,2); Pccinj = zeros(n_ccinj,2); Qccinj = zeros(n_ccinj,2);
    Im_sig_ccinj = zeros(n_ccinj,2); Iang_sig_ccinj = zeros(n_ccinj,2);
end

theta = zeros(length(bus(:,1)),2);
bf_hpf = zeros(length(bus(:,1)),2);
dbf_hpf = zeros(length(bus(:,1)),2);
freqcalc(1,[0 1e-3],0);
bus = wtg(0,1,bus,0,bus_v,[2 1]); % note bus_v is not important for initialization as is this case
bus = ccinj(0,1,bus,0,bus_v,[2 1]);%initialize Constant current injection
% initialize (shtr) SVR variables
if n_shtr ~=0
    Yshtr = zeros(n_shtr,2);
    frfilt_shtr = zeros(n_shtr,2);
    dYshtr = zeros(n_shtr,2);
    dfrfilt_shtr = zeros(n_shtr,2); 
end
shtr(0,1,bus,0);%initialize Shunt Reactor
% initialize TCSR variables
if n_tcsr ~=0
    X_tcsr = zeros(n_tcsr,2);
    frfilt_tcsr = zeros(n_tcsr,2);
    dX_tcsr = zeros(n_tcsr,2); 
    dfrfilt_tcsr = zeros(n_tcsr,2);
end
tcsr(0,1,bus,0);%initialize TCSR

v = ones(length(bus(:,1)),2);
bus_v=v;
theta = zeros(length(bus(:,1)),2);
disp(' ')
disp('Performing linearization')
% set line parameters
if ~isempty(lmon_con)
  R = line(lmon_con,3); X = line(lmon_con,4); B = line(lmon_con,5);
  tap = line(lmon_con,6); phi = line(lmon_con,7);
end
% if ~isempty(lmon_con)
%     line_compl = zeros([size(line(lmon_con,:)),2]);
%     line_compl(:,:,1) = line(lmon_con,:);
% end
line_compl(:,:,1) = line;
line_aux = line;
line_or = line;
% step 1: construct reduced Y matrix
[Y_gprf,Y_gncprf,Y_ncgprf,Y_ncprf,V_rgprf,V_rncprf,boprf] = red_ybus(bus,line);
bus_intprf = bus_int;% store the internal bus numbers for the pre_fault system
nbus = length(bus(:,1));
if isempty(load_con)
   nload = 0;
else
   nload = length(load_con(:,1));
end
state = zeros(n_mac,1);
gen_state = state;
TR_state = state;
TB_state = state;
TA_state = state;
Efd_state = state;
R_f_state = state;
pss1_state = state;
pss2_state = state;
pss3_state = state;
dpw_state = state;
tg_state = state;
state = zeros(n_mac + n_mot + n_ig + n_svc + n_tcsc + n_lmod + n_rlmod +...
              n_dcl + n_shtr + n_tcsr + n_wtg,1);
max_state = 6*n_mac + 5*n_exc + 3*n_pss + 6*n_dpw...
            + 5*n_tg + 5*n_tgh + 3*n_mot + 3*n_ig + 2*n_svc + n_tcsc + n_lmod...
            + n_rlmod + 5*n_dcl + n_shtr + n_tcsr + 20*n_wtg;% change if 1mass model - do afterwards
%25 states per generator,3 per motor, 3 per ind. generator,
% 2 per SVC, 1 per TCSC, 1 per lmod,1 per rlmod, 5 per dc line
% 1 state per shtr (SVR) and 1 state per TCSR
% 14 states per WTG Type 3 (2mass model) + 5 if reactive power WCE active
% + 1 a different one (other 5 not active at the same time) if PFA active
theta(:,1) = bus(:,3)*pi/180;
freqcalc(1,[0 1e-3],0);
v(:,1) = bus(:,2).*exp(jay*theta(:,1));
if n_conv ~= 0
   % convert dc LT to Equ HT bus
   Pr = bus(rec_ac_bus,6);
   Pi = bus(inv_ac_bus,6);
   Qr = bus(rec_ac_bus,7);
   Qi = bus(inv_ac_bus,7);
   VLT= v(ac_bus,1);
   i_acr = (Pr-jay*Qr)./conj(VLT(r_idx));
   i_aci = (Pi - jay*Qi)./conj(VLT(i_idx));
   v(rec_ac_bus,1) = VLT(r_idx) + jay*dcc_pot(:,2).*i_acr;
   v(inv_ac_bus,1) = VLT(i_idx) + jay*dcc_pot(:,4).*i_aci;
   theta(ac_bus,1) = angle(v(ac_bus,1));
end
bus_v(:,1) = v(:,1);  
v(:,2) = v(:,1);
bus_v(:,2) = v(:,1);
theta(:,2) = theta(:,1);
% find total number of states
ns_file
NumStates = sum(state); % 'state' has the same number of rows as there are devices and the value of each row correspond to the number of states per device
exc_sig = zeros(n_mac,2);
if n_dpw~=0; dpw_out = zeros(n_dpw,2);else dpw_out = zeros(1,2);end
if n_tg ~=0||n_tgh ~= 0
   tg_sig = zeros(n_tg+n_tgh,2);
else
   tg_sig = zeros(1,2);
end
if n_svc ~=0
   svc_sig = zeros(n_svc,2);
else
   svc_sig = zeros(1,2);
end
if n_shtr~=0
    shtr_sig = zeros(n_shtr,k);
end
if n_tcsr~=0
    tcsr_sig = zeros(n_tcsr,k);
end
if n_wtg ~= 0
    zwwp = zeros(n_wtg,2); 
else
    zwwp = zeros(1,2);
end
wth_sig_wtg = zwwp;
Pth_sig_wtg = zwwp;
th_sig_wtg = zwwp;
wT_sig_wtg = zwwp;
T_sig_wtg = zwwp;
x0_sig_wtg = zwwp;
Ip_sig_wtg = zwwp;
Pf_sig_wtg = zwwp;

VQ_sig_wtg = zwwp;
QQ_sig_wtg = zwwp;
Vt_sig_wtg = zwwp;

Vtm_sig_wtg = zwwp;
Vta_sig_wtg = zwwp;
Vtr_sig_wtg = zwwp;
Vti_sig_wtg = zwwp; 
Vw_sig_wtg = zwwp;

Ism_sig_wtg = zwwp; 
Isa_sig_wtg = zwwp;
Isr_sig_wtg = zwwp; 
Isi_sig_wtg = zwwp;

if n_tcsc ~=0
   tcsc_sig = zeros(n_tcsc,2);
else
   tcsc_sig = zeros(1,2);
end
if n_lmod ~= 0
   lmod_sig = zeros(n_lmod,2);
else
   lmod_sig = zeros(1,2);
end
if n_rlmod ~= 0
   rlmod_sig = zeros(n_rlmod,2);
else
   rlmod_sig = zeros(1,2);
end

if n_conv ~= 0
   dc_sig = zeros(n_conv,2);
else
   dc_sig = zeros(2,2);
end
% set initial state and rate matrices to zero

eterm = zeros(n_mac,2);
pelect = zeros(n_mac,2);
qelect = zeros(n_mac,2);
psi_re = zeros(n_mac,2);
psi_im = zeros(n_mac,2);
psi = zeros(n_mac,2);
mac_ang = zeros(n_mac,2);
mac_spd = zeros(n_mac,2);
edprime = zeros(n_mac,2);
eqprime = zeros(n_mac,2);
psikd = zeros(n_mac,2);
psikq = zeros(n_mac,2);
dmac_ang = zeros(n_mac,2);
dmac_spd = zeros(n_mac,2);
dedprime = zeros(n_mac,2);
deqprime = zeros(n_mac,2);
dpsikd = zeros(n_mac,2);
dpsikq = zeros(n_mac,2);
if n_exc~=0
   V_TR = zeros(n_exc,2);
   V_As = zeros(n_exc,2);
   V_A = zeros(n_exc,2);
   V_R =zeros(n_exc,2);
   Efd = zeros(n_exc,2);
   R_f = zeros(n_exc,2);
   dV_TR = zeros(n_exc,2);
   dV_As = zeros(n_exc,2);
   dV_R =zeros(n_exc,2);
   dEfd = zeros(n_exc,2);
   dR_f = zeros(n_exc,2);
   pss_out = zeros(n_exc,2);
end
if n_pss~=0
   pss1 = zeros(n_pss,2);
   pss2 = zeros(n_pss,2);
   pss3 = zeros(n_pss,2);
   dpss1 = zeros(n_pss,2);
   dpss2 =zeros(n_pss,2);
   dpss3 =zeros(n_pss,2);
end
if n_dpw~=0
   sdpw1 = zeros(n_dpw,2);
   sdpw2 = zeros(n_dpw,2);
   sdpw3 = zeros(n_dpw,2);
   sdpw4 = zeros(n_dpw,2);
   sdpw5 = zeros(n_dpw,2);
   sdpw6 = zeros(n_dpw,2);
   dsdpw1 = zeros(n_dpw,2);
   dsdpw2 = zeros(n_dpw,2);
   dsdpw3 = zeros(n_dpw,2);
   dsdpw4 = zeros(n_dpw,2);
   dsdpw5 = zeros(n_dpw,2);
   dsdpw6 = zeros(n_dpw,2);
end
if n_tg~=0||n_tgh~=0
   tg1 = zeros(n_tg+n_tgh,2);
   tg2 = zeros(n_tg+n_tgh,2);
   tg3 = zeros(n_tg+n_tgh,2);
   tg4 = zeros(n_tg+n_tgh,2);
   tg5 = zeros(n_tg+n_tgh,2);
   dtg1 =zeros(n_tg+n_tgh,2);
   dtg2 = zeros(n_tg+n_tgh,2);
   dtg3 = zeros(n_tg+n_tgh,2);
   dtg4 = zeros(n_tg+n_tgh,2);
   dtg5 = zeros(n_tg+n_tgh,2);
end
if n_lmod~=0
   lmod_st = zeros(n_lmod,2);
   dlmod_st = zeros(n_lmod,2);
end
if n_rlmod~=0
   rlmod_st = zeros(n_rlmod,2);
   drlmod_st = zeros(n_rlmod,2);
end

%HVDC links
if n_conv~= 0
   dv_conr = zeros(n_dcl,2);
   dv_coni = zeros(n_dcl,2);
   di_dcr = zeros(n_dcl,2);
   di_dci = zeros(n_dcl,2);
   dv_dcc = zeros(n_dcl,2);
end
% set dimensions for A matrix and permutation matrix
a_mat = zeros(NumStates);
p_mat = sparse(zeros(NumStates,max_state));
c_spd = zeros(length(not_ib_idx),NumStates);
c_p = zeros(length(not_ib_idx),NumStates);
c_t = zeros(length(not_ib_idx),NumStates);
if n_wtg~=0
    c_Is_wtg = zeros(n_wtg,NumStates);
    c_Isang_wtg = zeros(n_wtg,NumStates); % check with Isang...
    c_Isre_wtg = zeros(n_wtg,NumStates);
    c_Isim_wtg = zeros(n_wtg,NumStates);
    c_wtSV_wtg = zeros(n_wtg,NumStates);
    c_wgSV_wtg = zeros(n_wtg,NumStates);
    c_th_wtg = zeros(n_wtg,NumStates);
    c_Pord_wtg = zeros(n_wtg,NumStates);
    m_rwinderase = zeros(n_wtg,NumStates); % signal states to erase from matrix fromr rated wind speed.
    m_Verrerase = zeros(n_wtg,NumStates); % signal states to erase from matrix from skipping voltage control Rerr=Efdcmd
end
%determine p_mat: converts the vector of length max_states to 
%a column of a_mat or b

p_m_file

% step 2: initialization
flag = 0;
%machines
mac_em(0,1,bus,flag);
mac_tra(0,1,bus,flag);
mac_sub(0,1,bus,flag);
mac_ib(0,1,bus,flag);
%====================== Similar to 'i_simu'===============================%
%calculate initial electrical torque
psi = psi_re(:,1)+jay*psi_im(:,1);
if n_mot~=0&&n_ig==0
   vmp = vdp(:,1) + jay*vqp(:,1);
   int_volt=[psi; vmp]; % internal voltages of generators and motors 
elseif n_mot==0&&n_ig~=0
   vmpig = vdpig(:,1) + jay*vqpig(:,1);
   int_volt = [psi; vmpig]; % int volt of synch and ind generators
elseif n_mot~=0&&n_ig~=0
   vmp = vdp(:,1) + jay*vqp(:,1);
   vmpig = vdpig(:,1) + jay*vqpig(:,1);
   int_volt = [psi; vmp; vmpig];   
else
   int_volt = psi;
end
cur(:,1) = Y_gprf*int_volt; % network solution currents into generators       
b_v(boprf(nload+1:nbus),1) = V_rgprf*int_volt;   % bus voltage reconstruction
if nload~=0
   vnc = nc_load(bus,flag,Y_ncprf,Y_ncgprf);%vnc is a dummy variable
   cur(:,1) = cur(:,1) + Y_gncprf*v(bus_intprf(load_con(:,1)),1);% modify currents for nc loads 
end
cur_re(1:n_mac,1) = real(cur(1:n_mac,1)); 
cur_im(1:n_mac,1) = imag(cur(1:n_mac,1));
cur_mag(1:n_mac,1) = abs(cur(1:n_mac,1)).*mac_pot(:,1);
if n_mot~=0
   idmot(:,1) = -real(cur(n_mac+1:ngm,1));%induction motor currents
   iqmot(:,1) = -imag(cur(n_mac+1:ngm,1));%current out of network
end 
if n_ig~=0
   idig(:,1) = -real(cur(ngm+1:ntot,1));%induction generator currents
   iqig(:,1) = -imag(cur(ngm+1:ntot,1));%current out of network
end 

if n_conv ~=0
   % calculate dc voltage and current
   V0(r_idx,1) = abs(v(rec_ac_bus,1)).*dcc_pot(:,7);
   V0(i_idx,1) = abs(v(inv_ac_bus,1)).*dcc_pot(:,8);
   Vdc(r_idx,1) = V0(r_idx,1).*cos(alpha(:,1)) - i_dcr(:,1).*dcc_pot(:,3);
   Vdc(i_idx,1) = V0(i_idx,1).*cos(gamma(:,1)) - i_dci(:,1).*dcc_pot(:,5);
   Vdc_ref = Vdc(i_idx,1);
   i_dc(r_idx,1) = i_dcr(:,1);
   i_dc(i_idx,1) = i_dci(:,1);
end
%===================== end Similar to 'i_simu' ===========================%
telect(:,1) = pelect(:,1).*mac_pot(:,1)...
   + cur_mag(:,1).*cur_mag(:,1).*mac_con(:,5);
% DeltaP/omega filter
dpwf(0,1,bus,flag);
%pss 
pss(0,1,bus,flag); 
%exciters
smpexc(0,1,bus,flag);
smppi(0,1,bus,flag);
exc_dc12(0,1,bus,flag);
exc_st3(0,1,bus,flag);
% turbine governors
tg(0,1,bus,flag);
tg_hydro(0,1,bus,flag);
%initialize tcsc
if n_tcsc ~=0
    B_tcsc = zeros(n_tcsc,2);
    dB_tcsc = zeros(n_tcsc,2);
    if n_tcscud~=0
        error('user defined tcsc damping control not allowed in small signal simulation')
    else
        tcsc_dsig = zeros(n_tcsc,2);
    end
end
tcsc(0,1,bus,0);

if ~isempty(lmod_con)
   disp('load modulation')
   lmod(0,1,bus,flag);
end
if ~isempty(rlmod_con)
   disp('reactive load modulation')
   rlmod(0,1,bus,flag);
end

% initialize non-linear loads
if ~isempty(load_con)
   disp('non-linear loads')
   vnc = nc_load(bus,flag,Y_ncprf,Y_ncgprf);
else
   nload = 0;
end
% hvdc lines
dc_line(0,1,1,bus,flag);

mach_ref(1) = 0;
mach_ref(2) = 0;
sys_freq(1) = 1;
sys_freq(2) = 1;

%set states
%generators
mac_ang(:,2) = mac_ang(:,1);
mac_spd(:,2) = mac_spd(:,1);
eqprime(:,2) = eqprime(:,1);
psikd(:,2) = psikd(:,1);
edprime(:,2) = edprime(:,1);
psikq(:,2)=psikq(:,1);
%exciters
if n_exc~=0
   V_TR(:,2)=V_TR(:,1);
   V_As(:,2) = V_As(:,1);
   V_A(:,2) = V_A(:,1);
   V_R(:,2)=V_R(:,1);
   Efd(:,2)=Efd(:,1);
   R_f(:,2)=R_f(:,1);
end
%pss
if n_pss~=0
   pss1(:,2)=pss1(:,1);
   pss2(:,2)=pss2(:,1);
   pss3(:,2)=pss3(:,1);
end
% DeltaP/omega filter
if n_dpw~=0
   sdpw1(:,2)=sdpw1(:,1);
   sdpw2(:,2)=sdpw2(:,1);
   sdpw3(:,2)=sdpw3(:,1);
   sdpw4(:,2)=sdpw4(:,1);
   sdpw5(:,2)=sdpw5(:,1);
   sdpw6(:,2)=sdpw6(:,1);
end
%turbine governor
if n_tg~=0||n_tgh~=0
   tg1(:,2)=tg1(:,1);
   tg2(:,2)=tg2(:,1);
   tg3(:,2)=tg3(:,1);
   tg4(:,2)=tg4(:,1);
   tg5(:,2)=tg5(:,1);
end
telect(:,2) =telect(:,1);
if n_mot~=0
   vdp(:,2) = vdp(:,1);
   vqp(:,2) = vqp(:,1);
   slip(:,2) = slip(:,1);
end
if n_ig~=0
   vdpig(:,2) = vdpig(:,1);
   vqpig(:,2) = vqpig(:,1);
   slig(:,2) = slig(:,1);
   tmig(:,2) = tmig(:,1);
end
if n_svc ~= 0
   B_cv(:,2) = B_cv(:,1);
   B_con(:,2) = B_con(:,1);
end
if n_tcsc ~= 0
   B_tcsc(:,2) = B_tcsc(:,1);
end
if n_lmod ~=0
   lmod_st(:,2) = lmod_st(:,1);
end
if n_rlmod ~=0
   rlmod_st(:,2) = rlmod_st(:,1);
end
if n_conv~=0
   v_conr(:,2) = v_conr(:,1);
   v_coni(:,2) = v_coni(:,1);
   i_dcr(:,2) = i_dcr(:,1);
   i_dci(:,2) = i_dci(:,1);
   v_dcc(:,2) = v_dcc(:,1);
end

% SVR variables
if n_shtr ~=0
    Yshtr(:,2) = Yshtr(:,1);
    frfilt_shtr(:,2) = frfilt_shtr(:,1);
    dYshtr(:,2) = dYshtr(:,1);
    dfrfilt_shtr(:,2) = dfrfilt_shtr(:,1); 
end
%  TCSR variables
if n_tcsr ~=0
    X_tcsr(:,2) = X_tcsr(:,1);
    frfilt_tcsr(:,2) = frfilt_tcsr(:,1);
    dX_tcsr(:,2) = dX_tcsr(:,1); 
    dfrfilt_tcsr(:,2) = dfrfilt_tcsr(:,1);
end

% WTG
if n_wtg ~=0
    % second point in time is taken from first. Then in p_cont each state
    % individually is perturbed at this same point in time (second point).
    wtSV_wtg(:,2) = wtSV_wtg(:,1);          % 1
    wgSV_wtg(:,2) = wgSV_wtg(:,1);          % 2
    delgt_wtg(:,2) = delgt_wtg(:,1);        % 3
    delerr1_wtg(:,2) = delerr1_wtg(:,1);    % 4
    delerr2_wtg(:,2) = delerr2_wtg(:,1);    % 5
    Eerr_wtg(:,2) = Eerr_wtg(:,1);          % 6
    th_wtg(:,2) = th_wtg(:,1);              % 7
    Pord_wtg(:,2) = Pord_wtg(:,1);          % 8
    wref_wtg(:,2) = wref_wtg(:,1);          % 9
    x0_wtg(:,2) = x0_wtg(:,1);              % 10
    x1_wtg(:,2) = x1_wtg(:,1);              % 11
    gam_wtg(:,2) = gam_wtg(:,1);            % 12
    Efd_wtg(:,2) = Efd_wtg(:,1);            % 13
    Rerr_wtg(:,2) = Rerr_wtg(:,1);          % 14    
    
    IQcmd_wtg(:,2) = IQcmd_wtg(:,1);
    Edbr_wtg(:,2) = Edbr_wtg(:,1);
    dEdbr_wtg(:,2) = dEdbr_wtg(:,1); % since is also an output
    
    Vlvpl_wtg(:,2) = Vlvpl_wtg(:,1);

    Qset_wtg(:,2) = Qset_wtg(:,1); 
    s2_wtg(:,2) = s2_wtg(:,1); 
    s3_wtg(:,2) = s3_wtg(:,1); 
    s4_wtg(:,2) = s4_wtg(:,1); 
    s6_wtg(:,2) = s6_wtg(:,1); 
    s7_wtg(:,2) = s7_wtg(:,1); 
    
    s1wini_wtg(:,2) = s1wini_wtg(:,1); 
    s2wini_wtg(:,2) = s2wini_wtg(:,1); 

    dpwi_wtg(:,2) = dpwi_wtg(:,1); 
    
    Iswtg(:,2) = Iswtg(:,1); 
    bus_freq(:,2) = bus_freq(:,1); 
    swinif_wtg(:,2) = swinif_wtg(:,1);
    dswinif_wtg(:,2) = dswinif_wtg(:,1);

%     fst1_wtg(:,2) = fst1_wtg(:,1);
%     fst2_wtg(:,2) = fst2_wtg(:,1);
%     fst3_wtg(:,2) = fst3_wtg(:,1);
%     fst4_wtg(:,2) = fst4_wtg(:,1);
%     fst5_wtg(:,2) = fst5_wtg(:,1);
%     fst6_wtg(:,2) = fst6_wtg(:,1);
%     fst7_wtg(:,2) = fst7_wtg(:,1);

%     dfst1_wtg(:,2) = dfst1_wtg(:,1);
%     dfst2_wtg(:,2) = dfst2_wtg(:,1);
%     dfst3_wtg(:,2) = dfst3_wtg(:,1);
%     dfst4_wtg(:,2) = dfst4_wtg(:,1);
%     dfst5_wtg(:,2) = dfst5_wtg(:,1);
%     dfst6_wtg(:,2) = dfst6_wtg(:,1);
%     dfst7_wtg(:,2) = dfst7_wtg(:,1);
end

% set interconnection variables in perturbation stage to defaults
% this accounts for any generators which do not have the
% corresponding controls
eterm(:,2) = eterm(:,1);
pmech(:,2) = pmech(:,1);
vex(:,2) = vex(:,1);
exc_sig(:,2) = exc_sig(:,1);
tg_sig(:,2) = tg_sig(:,1);
svc_sig(:,2) = svc_sig(:,1);
tcsc_sig(:,2) = tcsc_sig(:,1);
lmod_sig(:,2) = lmod_sig(:,1);
rlmod_sig(:,2) = rlmod_sig(:,1);

if n_conv~=0
   Vdc(:,2) = Vdc(:,1);
   i_dc(:,2) = i_dc(:,1);
   dc_sig(:,2) = dc_sig(:,1);
   cur_ord(:,2) = cur_ord(:,1);
   alpha(:,2) = alpha(:,1);
   gamma(:,2) = gamma(:,1);
end
%perform perturbation of state variables

p_cont

% setup matrix giving state numbers for generators
mac_state = zeros(sum(state(1:n_mac)),3);
for k = 1:n_mac
   if state(k)~=0
      if k == 1
         j = 1;
      else
         j = 1+sum(state(1:k-1));
      end
      jj = sum(state(1:k));
      mac_state(j:jj,1) = (j:jj)';
      mac_state(j:jj,2) = st_name(k,1:state(k))';
      mac_state(j:jj,3) = k*ones(state(k),1);
   end
end
ang_idx = find(mac_state(:,2)==1);
b_pm = zeros(NumStates,n_mac-n_ib);b_pm(ang_idx+1,:)=diag(0.5./mac_con(not_ib_idx,16));
% Form transformation matrix to get rid of zero eigenvalue
% Use generator 1 as reference
% check for infinite buses

% ***** commented so it will not ask for setting gen 1 as reference
% if isempty(ibus_con)
%    ref_gen = questdlg('Set gen 1 as reference');
%    if strcmp(ref_gen,'Yes')
%       p_ang = eye(NumStates);
%       p_ang(ang_idx,1) = -ones(length(ang_idx),1);
%       p_ang(1,1) = 1;
%       p_angi = inv(p_ang);
%       %transform state matrix
%       a_mat = p_ang*a_mat*p_angi;
%       %transform the c matrices
%       c_v = c_v*p_angi;
%       c_ang = c_ang*p_angi;
%       c_spd = c_spd*p_angi;
%       c_pm = c_pm*p_angi;
%       c_t = c_t*p_angi;
%       c_p = c_p*p_angi;
%       if ~isempty(lmon_con)
%          c_pf1 = c_pf1*p_angi;
%          c_qf1 = c_qf1*p_angi;
%          c_pf2 = c_pf2*p_angi;
%          c_qf2 = c_qf2*p_angi;
%          c_ilmf = c_ilmf*p_angi;
%          c_ilmt = c_ilmt*p_angi;
%          c_ilrf = c_ilrf*p_angi;
%          c_ilrt = c_ilrt*p_angi;
%          c_ilif = c_ilif*p_angi;
%          c_ilit = c_ilit*p_angi;
%       end
%       if n_conv~=0; 
%          c_dcir=c_dcir*p_angi;
%          c_dcii=c_dcii*p_angi;
%          c_Vdcr=c_dcVr*p_angi;
%          c_Vdci=c_Vdci*p_angi;
%       end
%       %transform the b matrices
%       b_pm = p_ang*b_pm; 
%       if n_tg~=0;b_pr = p_ang*b_pr;end
%       if n_exc~=0;b_vr = p_ang*b_vr;end
%       if n_svc~=0;b_svc = p_ang*b_svc;end
%       if n_tcsc~=0;b_tcsc = p_ang*b_tcsc;end
%       if n_lmod~=0;b_lmod = p_ang*b_lmod;end
%       if n_rlmod~=0;b_rlmod = p_ang*b_rlmod;end
%       if n_dc~=0;b_dcr=p_ang*b_dcr;b_dci=p_ang*b_dci;end
%    end 
% end

disp('calculating eigenvalues and eigenvectors')
%eigenvectors and eigenvalues of a_mat
[u l] = eig(a_mat); % u is the right eigenvector

% sort the eigenvalues
[l l_idx] =sort( diag(l));


%reorder the eigenvector matrix
u = u(:,l_idx);

for j = 1:NumStates
   if imag(l(j))~=0
      %scale the complex eigenvectors so that the maximum element is 1+j0
      [maxu,mu_idx] = max(abs(u(:,j)));
      u(:,j) = u(:,j)/u(mu_idx,j);
   end
end
v = inv(u); % left eigenvectors
% find the participation factors
p=zeros(NumStates);p_norm=p;
for j = 1:NumStates
   p(:,j) = (conj(v(j,:)))'.*u(:,j);% p are the unnormalized participation vectors
   [p_max,p_max_idx] = max((p(:,j)));
   p_norm(:,j) = p(:,j)/p(p_max_idx,j);% p_norm has biggest element = 1
   p_big = abs(p_norm(:,j))>0.1;%big sorts out normalized participation > 1
   p_norm(:,j) = p_big.*p_norm(:,j);% p_norm now contains only values of p_norm > 0.1
end

% find states associated with the generator angles
pr = p_norm(ang_idx,:);
% frequency and damping ratio
freq = abs(imag(l))/2/pi;
zero_eig = find(abs(l)<=1e-4);
if ~isempty(zero_eig)
   damp(zero_eig,1)= ones(length(zero_eig),1);
end
nz_eig = find(abs(l)>1e-4);
damp(nz_eig,1) = -real(l(nz_eig))./abs(l(nz_eig));

figure;hold;box on;
stab_idx =find(damp>=0.05);
plot(damp(stab_idx),freq(stab_idx),'k+')
fmax = ceil(max(freq));
plot([0.05 0.05],[0 fmax],'r')
title(['Calculated Modes ' dfile])
xlabel('damping ratio')
ylabel('frequency Hz')
us_idx = find(damp<0);
plot(damp(us_idx),freq(us_idx),'r+')
ud_idx = find(damp>0&damp<0.05);
plot(damp(ud_idx),freq(ud_idx),'g+')

% Output structure
sstr.mac_con = mac_con;
sstr.exc_con = exc_con;
sstr.pss_con = pss_con;
sstr.tg_con = tg_con;
sstr.wtg_con = wtg_con;

sstr.n_wtg = n_wtg;
if n_wtg~=0
    sstr.m_rwinderase = m_rwinderase;
    sstr.m_Verrerase = m_Verrerase ;
    
    sstr.b_wth_wtg = b_wth_wtg;
    sstr.b_Pth_wtg = b_Pth_wtg;
    sstr.b_th_wtg = b_th_wtg;
    sstr.b_wT_wtg = b_wT_wtg;
    sstr.b_T_wtg = b_T_wtg;
    sstr.b_x0_wtg = b_x0_wtg;
    sstr.b_Ip_wtg = b_Ip_wtg;
    sstr.b_Pf_wtg = b_Pf_wtg;
    sstr.b_VQ_wtg = b_VQ_wtg;
    sstr.b_QQ_wtg = b_QQ_wtg;
    sstr.b_Vt_wtg = b_Vt_wtg;
     
    sstr.b_Vtm_wtg = b_Vtm_wtg;
    sstr.b_Vta_wtg = b_Vta_wtg;
    sstr.b_Vtr_wtg = b_Vtr_wtg;
    sstr.b_Vti_wtg  = b_Vti_wtg;
    sstr.b_Vw_wtg = b_Vw_wtg;
    
    sstr.b_Ism_wtg = b_Ism_wtg;
    sstr.b_Isa_wtg = b_Isa_wtg;
    sstr.b_Isr_wtg = b_Isr_wtg;
    sstr.b_Isi_wtg = b_Isi_wtg;
    sstr.d_t_Ism_wtg = d_t_Ism_wtg;
    sstr.d_t_Isa_wtg = d_t_Isa_wtg;
    sstr.d_t_Isr_wtg = d_t_Isr_wtg;
    sstr.d_t_Isi_wtg = d_t_Isi_wtg;

    sstr.c_Is_wtg = c_Is_wtg;
    sstr.c_Isang_wtg = c_Isang_wtg;
    sstr.c_Isre_wtg = c_Isre_wtg;
    sstr.c_Isim_wtg = c_Isim_wtg;
    sstr.c_wtSV_wtg = c_wtSV_wtg;
    sstr.c_wgSV_wtg = c_wgSV_wtg;
    sstr.c_th_wtg = c_th_wtg;
    sstr.c_Pord_wtg = c_Pord_wtg;
    sstr.c_P_wtg = c_P_wtg;
    sstr.c_Q_wtg = c_Q_wtg;
    
    sstr.d_Is_wth_wtg = d_Is_wth_wtg;
    sstr.d_Isang_wth_wtg = d_Isang_wth_wtg;
    sstr.d_P_wth_wtg = d_P_wth_wtg;
    sstr.d_Q_wth_wtg = d_Q_wth_wtg;
    
    sstr.d_Is_Pth_wtg = d_Is_Pth_wtg;
    sstr.d_Isang_Pth_wtg = d_Isang_Pth_wtg;
    sstr.d_P_Pth_wtg = d_P_Pth_wtg;
    sstr.d_Q_Pth_wtg = d_Q_Pth_wtg;
    sstr.d_Pord_Pth_wtg = d_Pord_Pth_wtg;
    sstr.d_t_Pth_wtg = d_t_Pth_wtg;
    
    sstr.d_Is_th_wtg = d_Is_th_wtg;
    sstr.d_Isang_th_wtg = d_Isang_th_wtg;
    sstr.d_P_th_wtg = d_P_th_wtg;
    sstr.d_Q_th_wtg = d_Q_th_wtg;
    
    sstr.d_Is_wT_wtg = d_Is_wT_wtg;
    sstr.d_Isang_wT_wtg = d_Isang_wT_wtg;
    sstr.d_P_wT_wtg = d_P_wT_wtg;
    sstr.d_Q_wT_wtg = d_Q_wT_wtg;
    
    sstr.d_Is_T_wtg = d_Is_T_wtg;
    sstr.d_Isang_T_wtg = d_Isang_T_wtg;
    sstr.d_P_T_wtg = d_P_T_wtg;
    sstr.d_Q_T_wtg = d_Q_T_wtg;
    
    sstr.d_Is_x0_wtg = d_Is_x0_wtg;
    sstr.d_Isang_x0_wtg = d_Isang_x0_wtg;
    sstr.d_P_x0_wtg = d_P_x0_wtg;
    sstr.d_Q_x0_wtg = d_Q_x0_wtg;
    
    sstr.d_Is_Ip_wtg = d_Is_Ip_wtg;
    sstr.d_Isang_Ip_wtg = d_Isang_Ip_wtg;
    sstr.d_P_Ip_wtg = d_P_Ip_wtg;
    sstr.d_Q_Ip_wtg = d_Q_Ip_wtg;
    
    sstr.d_Is_Pf_wtg = d_Is_Pf_wtg;
    sstr.d_Isang_Pf_wtg = d_Isang_Pf_wtg;
    sstr.d_P_Pf_wtg = d_P_Pf_wtg;
    sstr.d_Q_Pf_wtg = d_Q_Pf_wtg;
    sstr.d_t_Pf_wtg = d_t_Pf_wtg;
    
    sstr.d_Is_VQ_wtg = d_Is_VQ_wtg;
    sstr.d_Isang_VQ_wtg = d_Isang_VQ_wtg;
    sstr.d_P_VQ_wtg = d_P_VQ_wtg;
    sstr.d_Q_VQ_wtg = d_Q_VQ_wtg;
    
    sstr.d_Is_QQ_wtg = d_Is_QQ_wtg;
    sstr.d_Isang_QQ_wtg = d_Isang_QQ_wtg;
    sstr.d_P_QQ_wtg = d_P_QQ_wtg;
    sstr.d_Q_QQ_wtg = d_Q_QQ_wtg;
    sstr.d_t_QQ_wtg = d_t_QQ_wtg;
    
    sstr.d_Is_Vt_wtg = d_Is_Vt_wtg;
    sstr.d_Isang_Vt_wtg = d_Isang_Vt_wtg;
    sstr.d_P_Vt_wtg = d_P_Vt_wtg;
    sstr.d_Q_Vt_wtg = d_Q_Vt_wtg;
    
    sstr.Iswtg = Iswtg;
end
sstr.Ipcmdv_wtg = Ipcmdv_wtg;

if n_ccinj~=0
    sstr.b_Im_ccinj = b_Im_ccinj;
    sstr.b_Iang_ccinj = b_Iang_ccinj;
end

% c_delm output matrix of angle of the machine -obtained from c_spd
c_del = [c_spd(:,2:end) zeros( size( c_spd(:,1) ) )];
% Output structure
sstr.state = state;
sstr.NumStates = NumStates;
sstr.a_mat = a_mat;
sstr.ang_idx = ang_idx;
sstr.b_pm = b_pm;
sstr.b_vr = b_vr;
sstr.bus = bus;
sstr.bus_sol = bus_sol;
sstr.c_Efd = c_Efd;
sstr.c_ang = c_ang;
sstr.c_p = c_p;
sstr.c_pm = c_pm;
sstr.c_spd = c_spd;
sstr.c_del = c_del;
sstr.c_t = c_t;
sstr.c_v = c_v;
sstr.chk_st3 = chk_st3;
sstr.d_angvr = d_angvr;
sstr.d_pvr = d_pvr;
sstr.d_vvr = d_vvr;
sstr.damp = damp;
sstr.dcr_dc = dcr_dc;
sstr.fmax = fmax;
sstr.freq = freq;
sstr.k_em = k_em;
sstr.k_st3 = k_st3;
sstr.l = l;
sstr.line = line;
sstr.line_flw = line_flw;
sstr.mac_state = mac_state;
sstr.p = p;
sstr.p_norm = p_norm;
sstr.stab_idx = stab_idx;
sstr.svc_dc = svc_dc;
sstr.tcsc_dc = tcsc_dc;
sstr.ud_idx = ud_idx;
sstr.us_idx = us_idx;
sstr.v = v;
%===
sstr.Efd = Efd;
sstr.edprime = edprime;
sstr.eqprime = eqprime;
sstr.mac_ang = mac_ang;

%==
if ~isempty(lmon_con)
    sstr.c_ilmf = c_ilmf;
    sstr.c_ilmt = c_ilmt;
    sstr.c_ilaf = c_ilaf;
    sstr.c_ilat = c_ilat;
    sstr.c_ilrf = c_ilrf;
    sstr.c_ilrt = c_ilrt;
    sstr.c_ilif = c_ilif;
    sstr.c_ilit = c_ilit;
    
    sstr.c_pf1 = c_pf1;
    sstr.c_qf1 = c_qf1;
    sstr.c_pf2 = c_pf2;
    sstr.c_qf2 = c_qf2;
end
sstr.Y_gprf = Y_gprf;
sstr.Y_gncprf = Y_gncprf;
sstr.Y_ncgprf = Y_ncgprf;
sstr.Y_ncprf = Y_ncprf;

sstr.basmva_i = basmva_i;
sstr.sys_freq_i = sys_freq_i;

sstr.ibus_con = ibus_con;

%look at B Matrix for load changes...
sstr.b_lmod = b_lmod;
sstr.b_rlmod = b_rlmod;

sstr.d_v_lmod = d_v_lmod;
sstr.d_v_rlmod = d_v_rlmod;
sstr.d_ang_lmod = d_ang_lmod;
sstr.d_ang_rlmod = d_ang_rlmod;

% tidy work space
clear global
 clear B Efd_state Pi Pr Qi Qr R R_f_state           
  clear TA_state TB_state TR_state V0 V1 V2 VLT V_rgprf V_rncprf            
  clear X Y_gncprf Y_gprf Y_ncgprf Y_ncprf             
  clear ans b_v boprf bus_intprf bvnc                
  clear c_state chk_dc chk_smp cur cur_mag             
  clear d_vector dc_start dci_dc dcmod_input              
  clear dfile  dpw_count dpw_state exc_count exc_number exc_state           
  clear f   flag from_idx  gen_state  gh                  
  clear i_aci  i_acr int_volt inv_par             
  clear j  j_state jay jj k k_cex k_col k_colg k_ctg k_dc k_exc k_exc_idx           
  clear k_hvdc k_idx k_lmod k_nib_idx k_rlmod k_row k_smp k_sub k_tg k_tgh k_tra  kgs                 
  clear l_idx l_if1 l_if2 l_it1 l_it2 lf lfile                 
  clear line_flw line_par lmod_input lmod_start mac_dpw mac_exc mac_pss mac_tg mac_tgh             
  clear max_state maxu mu_idx n_hvdc1 n_hvdc_states n_ig_states n_lmod1 n_lmod_states       
  clear n_mot_states n_rlmod1 n_rlmod_states n_svc_states n_tcsc_states nbus ngm ngt                 
  clear no_mac nominal not_TA not_TB not_TE not_TF not_TR not_ib              
  clear ntdc  ntf  ntl ntot ntrl nts nz_eig              
  clear p_ang p_angi p_big p_mat p_max p_max_idx p_ratio pathname pert                
  clear phi pr pr_input  psi pss1_state pss2_state pss3_state  pss_count  pss_state           
  clear rec_par ref_gen rlmod_input rlmod_start  s11 s12  s21  s22                 
  clear s_TA s_TB s_TE s_TR s_idx sel st_name             
  clear state  state_hvdc state_lmod state_rlmod              
  clear telect tg_count tg_number tg_state to_idx vnc vr_input zero_eig




  