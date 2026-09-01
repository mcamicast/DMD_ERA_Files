function [sstr] = standa_wtg(dfile,pathname,sys_freq_i,basmva_i,PQT,sQ)
% Inputs:
% dfile         -name of file to read data
% pathname,     -the directory path were dfile is
% sys_freq_i    -frequency NOTE it should align with the measured one
% basmva_i      -MVA system NOTE it should align with the measured one
% PQT           -flag to determine which P or Q order to keep constant
% sQ            - use the measured P and Q as inputs

% Inputs from file to read:
% vtwtg_pr  -measured voltage
% t         -time profile
% Swtg_pr   -measured apparent power (P+jQ)
% wtg_con
clear global
pst_var % set up global variables 
line = [];
% close % close graphics windows

if isempty(sQ)
    sQ = 0;
end

if (sQ~=1) && (sQ~=0)
    error('sQ is either 0, 1 or []')
end
%=========================================================================%

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

sys_freq = sys_freq_i;
basrad = 2*pi*sys_freq; % default system frequency is 60 Hz
basmva = basmva_i;
n_bus = 1; % for bus_freq

bus_int = 1;
vw_wtg = 0;
wtg_vervw(t);

S0 = Swtg_pr(1);
P0 = real(S0);
Q0 = imag(S0);

% change in vw_wtg
bus = wtg_indx_st(P0*basmva/wtg_con(1,4),[]); % must be before loadflow - includes param of WTGs

ixwtg3 = wtg_con(:,3) == 3;
Lppwtg = wtg_con(1,33); % Type 3 (apparently)
wtgbase = wtg_con(1,4); % Base MVA of the wtg. 162 for the GE model
genbasmva_wtg = wtgbase*10/9;

k = length(t);
if ixwtg3 
    Vtmagwtg = abs(vtwtg_pr(1));
    xpp = Lppwtg*basmva./genbasmva_wtg;
    zpp = 1i*xpp;
    Szpp = Vtmagwtg.^2./conj(zpp);
    Q0 = Q0 + imag(Szpp);
end

%***add wtg
if n_wtg ~= 0
    zwwp = zeros(n_wtg,k); 
else
    zwwp = zeros(1,k); w0_wtg = 0;
end
Iswtg = zwwp; Iswtg = zwwp; Pgv_wtg = zwwp; Qgv_wtg = zwwp; Ipcmdv_wtg = zwwp; Pmechv_wtg = zwwp;
Ipmxv_wtg = zwwp; Iqmxv_wtg = zwwp; Iqxv_wtg = zwwp; Vrfq_wtg = zwwp; Vreg_wtg = zwwp;
wref_wtg = zwwp; wgSV_wtg = zwwp; wtSV_wtg = zwwp; delgt_wtg = zwwp; delerr1_wtg = zwwp; delerr2_wtg = zwwp;
dwref_wtg = zwwp; dwgSV_wtg = zwwp; dwtSV_wtg = zwwp; ddelgt_wtg = zwwp; ddelerr1_wtg = zwwp; ddelerr2_wtg = zwwp;
Eerr_wtg = zwwp; Pord_wtg = zwwp; th_wtg = zwwp; x0_wtg = zwwp; x1_wtg = zwwp; gam_wtg = zwwp; Efd_wtg = zwwp; Rerr_wtg = zwwp;
dEerr_wtg = zwwp; dPord_wtg = zwwp; dth_wtg = zwwp; dx0_wtg = zwwp; dx1_wtg = zwwp; dgam_wtg = zwwp; dEfd_wtg = zwwp; dRerr_wtg = zwwp;
Edbr_wtg = zwwp; IQcmd_wtg = zwwp;
dEdbr_wtg = zwwp; dIQcmd_wtg = zwwp;
Vlvpl_wtg = zwwp; dVlvpl_wtg = zwwp;
Qset_wtg = zwwp; s2_wtg = zwwp; s3_wtg = zwwp; s4_wtg = zwwp; s6_wtg = zwwp; s7_wtg = zwwp; 
dQset_wtg = zwwp; ds2_wtg = zwwp; ds3_wtg = zwwp; ds4_wtg = zwwp; ds6_wtg = zwwp; ds7_wtg = zwwp; 
s1wini_wtg = zwwp; s2wini_wtg = zwwp; swinif_wtg = zwwp; ds1wini_wtg = zwwp; ds2wini_wtg = zwwp; dswinif_wtg = zwwp;

fst1_wtg = zwwp; fst2_wtg = zwwp; fst3_wtg = zwwp; fst4_wtg = zwwp; fst5_wtg = zwwp; fst6_wtg = zwwp; fst7_wtg = zwwp;
dfst1_wtg = zwwp; dfst2_wtg = zwwp; dfst3_wtg = zwwp; dfst4_wtg = zwwp; dfst5_wtg = zwwp; dfst6_wtg = zwwp; dfst7_wtg = zwwp;
sigpru1_wtg = zwwp; sigpru2_wtg = zwwp; sigpru3_wtg = zwwp; sigpru4_wtg = zwwp; sigpru5_wtg = zwwp;
wth_sig_wtg = zwwp; Pth_sig_wtg = zwwp; th_sig_wtg = zwwp; wT_sig_wtg = zwwp; T_sig_wtg = zwwp;
x0_sig_wtg = zwwp; Ip_sig_wtg = zwwp; Pf_sig_wtg = zwwp;
VQ_sig_wtg = zwwp; QQ_sig_wtg = zwwp; Vt_sig_wtg = zwwp;

Vtm_sig_wtg = zwwp; Vta_sig_wtg = zwwp; Vtr_sig_wtg = zwwp; Vti_sig_wtg = zwwp; Vw_sig_wtg = zwwp;
Ism_sig_wtg = zwwp; Isa_sig_wtg = zwwp; Isr_sig_wtg = zwwp; Isi_sig_wtg = zwwp;
%*** end add wtg

sys_freq = sys_freq*ones(1,k); % sys_freq = ones(1,k);
disp('Simulating WTG -stand alone model V(intput)')
% step 1: construct reduced Y matrices 

% % disp('initializing motor,induction generator, svc and dc control models')       
% % bus = mac_ind(0,1,bus,0);% initialize induction motor
% % bus = mac_igen(0,1,bus,0); % initialize induction generator
% % bus = svc(0,1,bus,0);%initialize svc
% % f = dc_cont(0,1,1,bus,0);% initialize dc controls
theta = zeros(size(t));
freqcalc(1,t,0); % KEEP to initialize
% % bus = wtg2(0,1,bus,0,bus_v);%initialize wtg type 2
bus = [nan abs(vtwtg_pr(1)), angle(vtwtg_pr(1))*180/pi, P0, Q0];
bus_v = vtwtg_pr;
wtg_con(1,53) = 1; % change the voltage regulation
bus = wtg(0,1,bus,0,bus_v,t);%initialize wtg types 3 and 4
wtg_sens(0,1,bus,0,bus_v);%initialize wtg types 3 and 4

k_start = 1;
k_end = length(t)-1;
dt = diff(t);

for kc = k_start:k_end
    k = kc;
%     h_sol = dt(k-1);
    h_sol = dt(kc);
    flag = 2;

    if n_wtg~=0
        bus_sim = bus;
        wtg_cur;
        
        if sQ == 1
            Iwtgch = conj(Swtg_pr(:,k)./bus_v(:,k)) + bus_v(:,k)./zpp;
            Iwtgaux = Iswtg(:,k);
            Iswtg(:,k) = Iwtgch;
        end
        
        wtg(0,k,bus_sim,flag,bus_v,t); % ADDED - wtg DYNAMIC COMPUTATION (bus or bus_sim??)
        
        if sQ == 1
            Iswtg(:,k) = Iwtgaux;
            Itwtg(:,k) = Iswtg(:,k) - bus_v(:,k)./zpp;
        end
        
        if ~isempty(PQT)
            switch PQT
                case 'P'
                    dx1_wtg(:,k) = 0;
                case 'Q'
                    dx0_wtg(:,k) = 0;
                otherwise
                    error('Flag PQT is only  P or Q')
            end
        end
    end

    j = k+1;
    % *** add wtg states
    wref_wtg(:,j) = wref_wtg(:,k) + h_sol*dwref_wtg(:,k);
    wgSV_wtg(:,j) = wgSV_wtg(:,k) + h_sol*dwgSV_wtg(:,k);
    wtSV_wtg(:,j) = wtSV_wtg(:,k) + h_sol*dwtSV_wtg(:,k);
    delgt_wtg(:,j) = delgt_wtg(:,k) + h_sol*ddelgt_wtg(:,k);
    delerr1_wtg(:,j) = delerr1_wtg(:,k) + h_sol*ddelerr1_wtg(:,k);
    delerr2_wtg(:,j) = delerr2_wtg(:,k) + h_sol*ddelerr2_wtg(:,k);
    Eerr_wtg(:,j) = Eerr_wtg(:,k) + h_sol*dEerr_wtg(:,k);
    Pord_wtg(:,j) = Pord_wtg(:,k) + h_sol*dPord_wtg(:,k);
    th_wtg(:,j) = th_wtg(:,k) + h_sol*dth_wtg(:,k);
    x0_wtg(:,j) = x0_wtg(:,k) + h_sol*dx0_wtg(:,k);
    x1_wtg(:,j) = x1_wtg(:,k) + h_sol*dx1_wtg(:,k);
    gam_wtg(:,j) = gam_wtg(:,k) + h_sol*dgam_wtg(:,k);
    Efd_wtg(:,j) = Efd_wtg(:,k) + h_sol*dEfd_wtg(:,k); % Type 3
    Rerr_wtg(:,j) = Rerr_wtg(:,k) + h_sol*dRerr_wtg(:,k);
    IQcmd_wtg(:,j) = IQcmd_wtg(:,k) + h_sol*dIQcmd_wtg(:,k); % Type 4
    Edbr_wtg(:,j) = Edbr_wtg(:,k) + h_sol*dEdbr_wtg(:,k); % Type 4
    Qset_wtg(:,j) = Qset_wtg(:,k) + h_sol*dQset_wtg(:,k);
    Vlvpl_wtg(:,j) = Vlvpl_wtg(:,k) + h_sol*dVlvpl_wtg(:,k); % LVPL
    s2_wtg(:,j) =  s2_wtg(:,k) + h_sol*ds2_wtg(:,k);
    s3_wtg(:,j) =  s3_wtg(:,k) + h_sol*ds3_wtg(:,k);
    s4_wtg(:,j) =  s4_wtg(:,k) + h_sol*ds4_wtg(:,k);
    s6_wtg(:,j) =  s6_wtg(:,k) + h_sol*ds6_wtg(:,k);
    s7_wtg(:,j) =  s7_wtg(:,k) + h_sol*ds7_wtg(:,k);
    s1wini_wtg(:,j) = s1wini_wtg(:,k) + h_sol*ds1wini_wtg(:,k);
    s2wini_wtg(:,j) = s2wini_wtg(:,k) + h_sol*ds2wini_wtg(:,k);
    swinif_wtg(:,j) = swinif_wtg(:,k) + h_sol*dswinif_wtg(:,k);
    fst1_wtg(:,j) = fst1_wtg(:,k) + h_sol*dfst1_wtg(:,k);
    fst2_wtg(:,j) = fst2_wtg(:,k) + h_sol*dfst2_wtg(:,k);
    fst3_wtg(:,j) = fst3_wtg(:,k) + h_sol*dfst3_wtg(:,k);
    fst4_wtg(:,j) = fst4_wtg(:,k) + h_sol*dfst4_wtg(:,k);
    fst5_wtg(:,j) = fst5_wtg(:,k) + h_sol*dfst5_wtg(:,k);
    fst6_wtg(:,j) = fst6_wtg(:,k) + h_sol*dfst6_wtg(:,k);
    fst7_wtg(:,j) = fst7_wtg(:,k) + h_sol*dfst7_wtg(:,k);
    %*** end add wtg states
    
    if n_wtg~=0
        bus_sim = bus;
        k = j; % need to do this to 'fool' the script wtg_cur
        wtg_cur;
        k=k-1; % need to do this to 'fool' the script wtg_cur
        
        if sQ == 1
            Iwtgch = conj(Swtg_pr(:,j)./bus_v(:,j)) + bus_v(:,j)./zpp;
            Iwtgaux = Iswtg(:,j);
            Iswtg(:,j) = Iwtgch;
        end
        
        wtg(0,j,bus_sim,flag,bus_v,t); % ADDED - wtg DYNAMIC COMPUTATION
        
        if sQ == 1
            Iswtg(:,j) = Iwtgaux;
            Itwtg(:,j) = Iswtg(:,j) - bus_v(:,j)./zpp;
        end
        
        if ~isempty(PQT)
            switch PQT
                case 'P'
                    dx1_wtg(:,k) = 0; dx1_wtg(:,j) = 0;
                case 'Q'
                    dx0_wtg(:,k) = 0; dx0_wtg(:,j) = 0;
                otherwise
            end
        end
    end
    %*** add wtg states
    wref_wtg(:,j) = wref_wtg(:,k) + h_sol*(dwref_wtg(:,j) + dwref_wtg(:,k))/2;
    wgSV_wtg(:,j) = wgSV_wtg(:,k) + h_sol*(dwgSV_wtg(:,j) + dwgSV_wtg(:,k))/2;
    wtSV_wtg(:,j) = wtSV_wtg(:,k) + h_sol*(dwtSV_wtg(:,j) + dwtSV_wtg(:,k))/2;
    delgt_wtg(:,j) = delgt_wtg(:,k) + h_sol*(ddelgt_wtg(:,j) + ddelgt_wtg(:,k))/2;
    delerr1_wtg(:,j) = delerr1_wtg(:,k) + h_sol*(ddelerr1_wtg(:,j) + ddelerr1_wtg(:,k))/2;
    delerr2_wtg(:,j) = delerr2_wtg(:,k) + h_sol*(ddelerr2_wtg(:,j) + ddelerr2_wtg(:,k))/2;
    Eerr_wtg(:,j) = Eerr_wtg(:,k) + h_sol*(dEerr_wtg(:,j) + dEerr_wtg(:,k))/2;
    Pord_wtg(:,j) = Pord_wtg(:,k) + h_sol*(dPord_wtg(:,j) + dPord_wtg(:,k))/2;
    th_wtg(:,j) = th_wtg(:,k) + h_sol*(dth_wtg(:,j) + dth_wtg(:,k))/2;
    x0_wtg(:,j) = x0_wtg(:,k) + h_sol*(dx0_wtg(:,j) + dx0_wtg(:,k))/2;
    x1_wtg(:,j) = x1_wtg(:,k) + h_sol*(dx1_wtg(:,j) + dx1_wtg(:,k))/2;
    gam_wtg(:,j) = gam_wtg(:,k) + h_sol*(dgam_wtg(:,j) + dgam_wtg(:,k))/2;
    Efd_wtg(:,j) = Efd_wtg(:,k) + h_sol*(dEfd_wtg(:,j) + dEfd_wtg(:,k))/2; % Type 3
    Rerr_wtg(:,j) = Rerr_wtg(:,k) + h_sol*(dRerr_wtg(:,j) + dRerr_wtg(:,k))/2;
    IQcmd_wtg(:,j) = IQcmd_wtg(:,k) + h_sol*(dIQcmd_wtg(:,j) + dIQcmd_wtg(:,k))/2; % Type 4
    Edbr_wtg(:,j) = Edbr_wtg(:,k) + h_sol*(dEdbr_wtg(:,j) + dEdbr_wtg(:,k))/2; % Type 4
    Qset_wtg(:,j) = Qset_wtg(:,k) + h_sol*(dQset_wtg(:,j) + dQset_wtg(:,k))/2;
    Vlvpl_wtg(:,j) = Vlvpl_wtg(:,k) + h_sol*(dVlvpl_wtg(:,j) + dVlvpl_wtg(:,k))/2; % LVPL
    s2_wtg(:,j) = s2_wtg(:,k) + h_sol*(ds2_wtg(:,j) + ds2_wtg(:,k))/2;
    s3_wtg(:,j) = s3_wtg(:,k) + h_sol*(ds3_wtg(:,j) + ds3_wtg(:,k))/2;
    s4_wtg(:,j) = s4_wtg(:,k) + h_sol*(ds4_wtg(:,j) + ds4_wtg(:,k))/2;
    s6_wtg(:,j) = s6_wtg(:,k) + h_sol*(ds6_wtg(:,j) + ds6_wtg(:,k))/2;
    s7_wtg(:,j) = s7_wtg(:,k) + h_sol*(ds7_wtg(:,j) + ds7_wtg(:,k))/2;
    s1wini_wtg(:,j) = s1wini_wtg(:,k) + h_sol*(ds1wini_wtg(:,j) + ds1wini_wtg(:,k))/2;
    s2wini_wtg(:,j) = s2wini_wtg(:,k) + h_sol*(ds2wini_wtg(:,j) + ds2wini_wtg(:,k))/2;
    swinif_wtg(:,j) = swinif_wtg(:,k) + h_sol*(dswinif_wtg(:,j) + dswinif_wtg(:,k))/2;
    fst1_wtg(:,j) = fst1_wtg(:,k) + h_sol*(dfst1_wtg(:,j) + dfst1_wtg(:,k))/2;
    fst2_wtg(:,j) = fst2_wtg(:,k) + h_sol*(dfst2_wtg(:,j) + dfst2_wtg(:,k))/2;
    fst3_wtg(:,j) = fst3_wtg(:,k) + h_sol*(dfst3_wtg(:,j) + dfst3_wtg(:,k))/2;
    fst4_wtg(:,j) = fst4_wtg(:,k) + h_sol*(dfst4_wtg(:,j) + dfst4_wtg(:,k))/2;
    fst5_wtg(:,j) = fst5_wtg(:,k) + h_sol*(dfst5_wtg(:,j) + dfst5_wtg(:,k))/2;
    fst6_wtg(:,j) = fst6_wtg(:,k) + h_sol*(dfst6_wtg(:,j) + dfst6_wtg(:,k))/2;
    fst7_wtg(:,j) = fst7_wtg(:,k) + h_sol*(dfst7_wtg(:,j) + dfst7_wtg(:,k))/2;
    %*** end add wtg states
    
end

bus_freq(end,:)=[];
bus_freqf(end,:)=[];

% Output structure
sstr.bus_int = bus_int;
sstr.t = t;
sstr.basmva = basmva;

%** WTG
sstr.wtg_idx2 = wtg_idx2;
sstr.wtg_con = wtg_con;
sstr.vw_wtg = vw_wtg;
sstr.w0_wtg = w0_wtg;
sstr.sigpru1_wtg = sigpru1_wtg;
sstr.sigpru2_wtg = sigpru2_wtg;
sstr.sigpru3_wtg = sigpru3_wtg;
sstr.sigpru4_wtg = sigpru4_wtg;
sstr.sigpru5_wtg = sigpru5_wtg;

%**States:
sstr.wref_wtg = wref_wtg;
sstr.wgSV_wtg = wgSV_wtg;
sstr.wtSV_wtg = wtSV_wtg;
sstr.delgt_wtg = delgt_wtg;
sstr.delerr1_wtg = delerr1_wtg;
sstr.delerr2_wtg =delerr2_wtg;
sstr.Eerr_wtg = Eerr_wtg;
sstr.Pord_wtg = Pord_wtg;
sstr.th_wtg = th_wtg;
sstr.x0_wtg = x0_wtg;
sstr.x1_wtg = x1_wtg;
sstr.gam_wtg = gam_wtg;
sstr.Efd_wtg = Efd_wtg;
sstr.Rerr_wtg = Rerr_wtg;
%**
sstr.IQcmd_wtg = IQcmd_wtg;
sstr.Edbr_wtg = Edbr_wtg;
%**
sstr.Qset_wtg = Qset_wtg;
sstr.s2_wtg = s2_wtg;
sstr.s3_wtg = s3_wtg;
sstr.s4_wtg = s4_wtg;
sstr.s6_wtg = s6_wtg;
sstr.s7_wtg = s7_wtg;
%**
sstr.s1wini_wtg = s1wini_wtg;
sstr.s2wini_wtg = s2wini_wtg;
sstr.ds2wini_wtg = ds2wini_wtg; % equivalent to dpwiwtg (only no limits)


%**States -rates of change:
sstr.dwref_wtg = dwref_wtg;
sstr.dwgSV_wtg = dwgSV_wtg;
sstr.dwtSV_wtg = dwtSV_wtg;
sstr.ddelgt_wtg = ddelgt_wtg;
sstr.ddelerr1_wtg = ddelerr1_wtg;
sstr.ddelerr2_wtg = ddelerr2_wtg;
sstr.dEerr_wtg = dEerr_wtg;
sstr.dPord_wtg = dPord_wtg;
sstr.dth_wtg = dth_wtg;
sstr.dx0_wtg = dx0_wtg;
sstr.dx1_wtg = dx1_wtg;
sstr.dgam_wtg = dgam_wtg;
sstr.dEfd_wtg = dEfd_wtg;
sstr.dRerr_wtg = dRerr_wtg;
%**
sstr.dIQcmd_wtg = dIQcmd_wtg;
sstr.dEdbr_wtg = dEdbr_wtg;
%**
sstr.dQset_wtg = dQset_wtg;
sstr.ds2_wtg = ds2_wtg;
sstr.ds3_wtg = ds3_wtg;
sstr.ds4_wtg = ds4_wtg;
sstr.ds6_wtg = ds6_wtg;
sstr.ds7_wtg = ds7_wtg;
%**
sstr.ds1wini_wtg = ds1wini_wtg;

%**
sstr.Pth_sig_wtg = Pth_sig_wtg;
sstr.VQ_sig_wtg = VQ_sig_wtg;
sstr.QQ_sig_wtg = QQ_sig_wtg;
sstr.Vt_sig_wtg = Vt_sig_wtg;

sstr.Is_wtg = Iswtg;
sstr.It_wtg = Itwtg;
sstr.Pg_wtg = Pgv_wtg;
sstr.Qg_wtg = Qgv_wtg;

sstr.Pset_wtg = Pset_wtg;
sstr.Pmech_wtg = Pmechv_wtg;
sstr.Ipcmd_wtg = Ipcmdv_wtg;

sstr.Vrfq_wtg = Vrfq_wtg;
sstr.Vreg_wtg = Vreg_wtg;

if n_wtg ~= 0 
    [~,ccol] = size(Pgv_wtg);
    Pnfac = repmat(wtg_con(:,4),1,ccol);
%     Qnfac = repmat(wtg_con(:,5),1,ccol);
    Qnfac = repmat(wtg_con(:,4),1,ccol)*10/9;
    sstr.Pgb_wtg = (1/basmva).*Pnfac.*Pgv_wtg; %REPLACED Pgn_wtg
    sstr.Qgb_wtg = (1/basmva).*Qnfac.*Qgv_wtg;
    
    [~,ccol] = size(Pgv_wtg);
    vnormPwtg = repmat(abs(Pgv_wtg(:,1)),1,ccol);
    sstr.Pgnn_wtg = Pgv_wtg./vnormPwtg;
    vnormQwtg = repmat(abs(Qgv_wtg(:,1)),1,ccol);
    sstr.Qgnn_wtg = Qgv_wtg./vnormQwtg;
else
    sstr.Pgb_wtg = 0;
    sstr.Qgb_wtg = 0;
end


% sstr.dEfd_dkVi_swtg = dEfd_dkVi_swtg;
% sstr.dEfd_dkQi_swtg = dEfd_dkQi_swtg;
% sstr.dRerr_dkQi_swtg = dRerr_dkQi_swtg;
% sstr.dEfd_dkiv_swtg = dEfd_dkiv_swtg;
% sstr.dRerr_dkiv_swtg = dRerr_dkiv_swtg;
% sstr.dQord_dkiv_swtg = dQord_dkiv_swtg;
% sstr.dEfd_dkpv_swtg = dEfd_dkpv_swtg;
% sstr.dRerr_dkpv_swtg = dRerr_dkpv_swtg;
% sstr.dQord_dkpv_swtg = dQord_dkpv_swtg;
% 
% sstr.ddEfd_dkVi_swtg = ddEfd_dkVi_swtg;
% sstr.ddEfd_dkQi_swtg = ddEfd_dkQi_swtg;
% sstr.ddRerr_dkQi_swtg = ddRerr_dkQi_swtg;
% sstr.ddEfd_dkiv_swtg = ddEfd_dkiv_swtg;
% sstr.ddRerr_dkiv_swtg = ddRerr_dkiv_swtg;
% sstr.ddQord_dkiv_swtg = ddQord_dkiv_swtg;
% sstr.ddEfd_dkpv_swtg = ddEfd_dkpv_swtg;
% sstr.ddRerr_dkpv_swtg = ddRerr_dkpv_swtg;
% sstr.ddQord_dkpv_swtg = ddQord_dkpv_swtg;
% 
% sstr.dx0_dkVi_swtg = dx0_dkVi_swtg;
% sstr.dx0_dkQi_swtg = dx0_dkQi_swtg;
% sstr.dx0_dkiv_swtg = dx0_dkiv_swtg;
% sstr.dx0_dkpv_swtg = dx0_dkpv_swtg;
% 
% sstr.ddx0_dkVi_swtg = ddx0_dkVi_swtg;
% sstr.ddx0_dkQi_swtg = ddx0_dkQi_swtg;
% sstr.ddx0_dkiv_swtg = ddx0_dkiv_swtg;
% sstr.ddx0_dkpv_swtg = ddx0_dkpv_swtg;
% 
% sstr.dIsre_dkVi_swtg = dIsre_dkVi_swtg;
% sstr.dIsre_dkQi_swtg = dIsre_dkQi_swtg;
% sstr.dIsre_dkiv_swtg = dIsre_dkiv_swtg;
% sstr.dIsre_dkpv_swtg = dIsre_dkpv_swtg;
% 
% sstr.dIsim_dkVi_swtg = dIsim_dkVi_swtg;
% sstr.dIsim_dkQi_swtg = dIsim_dkQi_swtg;
% sstr.dIsim_dkiv_swtg = dIsim_dkiv_swtg;
% sstr.dIsim_dkpv_swtg = dIsim_dkpv_swtg;
