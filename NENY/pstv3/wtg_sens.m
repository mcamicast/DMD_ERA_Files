function [] = wtg_sens(i,k,bus,flag,busi_v)


global dEfd_dkVi_swtg dEfd_dkQi_swtg dRerr_dkQi_swtg dEfd_dkiv_swtg dRerr_dkiv_swtg
global dQord_dkiv_swtg dEfd_dkpv_swtg dRerr_dkpv_swtg dQord_dkpv_swtg

global ddEfd_dkVi_swtg ddEfd_dkQi_swtg ddRerr_dkQi_swtg ddEfd_dkiv_swtg ddRerr_dkiv_swtg
global ddQord_dkiv_swtg ddEfd_dkpv_swtg ddRerr_dkpv_swtg ddQord_dkpv_swtg


global dx0_dkVi_swtg dx0_dkQi_swtg dx0_dkiv_swtg dx0_dkpv_swtg
global ddx0_dkVi_swtg ddx0_dkQi_swtg ddx0_dkiv_swtg ddx0_dkpv_swtg


global dIsre_dkVi_swtg dIsre_dkQi_swtg dIsre_dkiv_swtg dIsre_dkpv_swtg
global dIsim_dkVi_swtg dIsim_dkQi_swtg dIsim_dkiv_swtg dIsim_dkpv_swtg

% global ddIsre_dkVi_swtg ddIsre_dkQi_swtg ddIsre_dkiv_swtg ddIsre_dkpv_swtg
% global ddIsim_dkVi_swtg ddIsim_dkQi_swtg ddIsim_dkiv_swtg ddIsim_dkpv_swtg

global basmva

global wtg_idx2 wtg_con n_wtg Rerr_wtg
global Iswtg gam_wtg
global Vtm_sig_wtg Vta_sig_wtg Vtr_sig_wtg Vti_sig_wtg

global Qset_wtg s2_wtg s3_wtg s4_wtg s6_wtg s7_wtg

wtg_ix = 1:n_wtg; % OJO CAMBIAR
ixwtg3 = wtg_con(:,3) == 3;
ixwtg4 = wtg_con(:,3) == 4;
wtgbase = wtg_con(wtg_ix,4); % Base MVA of the wtg. 162 for the GE model
genbasmva_wtg = wtgbase*10/9;

Lppwtg = wtg_con(wtg_ix,33); % Type 3 (apparently)
Tddelwtg = wtg_con(wtg_ix,35);

kQiwtg = wtg_con(wtg_ix,40);
kViwtg = wtg_con(wtg_ix,41);

varflag = wtg_con(wtg_ix,52);

Kpvwtg = wtg_con(wtg_ix,56);
Kivwtg = wtg_con(wtg_ix,57);
Tcwtg = wtg_con(wtg_ix,58);


ixvarglaf_p1 = varflag == 1;

k2=k;
Vtwtg = busi_v(wtg_idx2,k2);
Vtwtg = (Vtwtg + Vtm_sig_wtg(:,k2)).*exp(1i*Vta_sig_wtg(:,k2));
Vtwtg = Vtwtg + Vtr_sig_wtg(:,k2) + 1i*Vti_sig_wtg(:,k2);
Vtmagwtg = abs(Vtwtg);
Vtangwtg = angle(Vtwtg);

Iswtgk = Iswtg(:,k2);
Swtg = Vtwtg.*conj(Iswtgk);
% Swtg = Vtwtg.*conj(Itwtgk);

rpp = 0; %por el momento
xpp = Lppwtg*basmva./genbasmva_wtg;
zpp = rpp +1i*xpp;
Izpp = Vtwtg./zpp;
Szpp = Vtmagwtg.^2./conj(zpp);

%*** Type 3 ***%         
Pg_wtg = (real(Swtg) - real(Szpp)).*(basmva./wtgbase);
Qg_wtg = (imag(Swtg) - imag(Szpp)).*(basmva./genbasmva_wtg);            

if flag == 0 % initialization
    if i~=0
        %later
    else % Assumes the other states have been initialized before
        dQord_dkiv_swtg(ixvarglaf_p1,k) = s4_wtg(ixvarglaf_p1,k);
        dQord_dkpv_swtg(ixvarglaf_p1,k) = s2_wtg(ixvarglaf_p1,k);
    end
end

if flag == 2 % Dynamic model calculation
    if i~=0
        %later
    else %vectorized computation
        % States of the Trajectory Sensitivities
        
        ddEfd_dkVi_swtg(:,k) = Rerr_wtg(:,k) -  Vtmagwtg(ixwtg3,1);

        ddEfd_dkQi_swtg(:,k) = kViwtg(ixwtg3,1).*dRerr_dkQi_swtg(ixwtg3,k);
        ddRerr_dkQi_swtg(:,k) = Qset_wtg(:,k) - Qg_wtg;

        ddEfd_dkiv_swtg(:,k) = kViwtg.*dRerr_dkiv_swtg(:,k);
        ddRerr_dkiv_swtg(:,k) = kQiwtg.*dQord_dkiv_swtg(:,k);
        ddQord_dkiv_swtg(ixvarglaf_p1,k) = (1./Tcwtg(ixvarglaf_p1,1)).*(s4_wtg(:,k) - dQord_dkiv_swtg(:,k));

        ddEfd_dkpv_swtg(:,k) = kViwtg.*dRerr_dkpv_swtg(:,k);
        ddRerr_dkpv_swtg(:,k) = kQiwtg.*dQord_dkpv_swtg(:,k);
        ddQord_dkpv_swtg(ixvarglaf_p1,k) = (1./Tcwtg(ixvarglaf_p1,1)).*(s2_wtg(:,k) - dQord_dkpv_swtg(:,k));
        
        % xo states wrt to trajectory sensitivities to relate to output
        
        ddx0_dkVi_swtg(ixwtg3,k) = (1./Tddelwtg(ixwtg3,1)).*(dEfd_dkVi_swtg(ixwtg3,k) - dx0_dkVi_swtg(ixwtg3,k));
        ddx0_dkQi_swtg(ixwtg3,k) = (1./Tddelwtg(ixwtg3,1)).*(dEfd_dkQi_swtg(ixwtg3,k) - dx0_dkQi_swtg(ixwtg3,k));
        ddx0_dkiv_swtg(ixwtg3,k) = (1./Tddelwtg(ixwtg3,1)).*(dEfd_dkiv_swtg(ixwtg3,k) - dx0_dkiv_swtg(ixwtg3,k));
        ddx0_dkpv_swtg(ixwtg3,k) = (1./Tddelwtg(ixwtg3,1)).*(dEfd_dkpv_swtg(ixwtg3,k) - dx0_dkpv_swtg(ixwtg3,k));
        
        % Output (namely, real and imaginary currents) wrt parameters using
        % trajectory sensitivities
        
        s_con_re = sin(gam_wtg(:,k))./Lppwtg;
        s_con_im = -cos(gam_wtg(:,k))./Lppwtg;
        
        dIsre_dkVi_swtg(:,k) = s_con_re.*dx0_dkVi_swtg(:,k);
        dIsre_dkQi_swtg(:,k) = s_con_re.*dx0_dkQi_swtg(:,k);
        dIsre_dkiv_swtg(:,k) =  s_con_re.*dx0_dkiv_swtg(:,k);
        dIsre_dkpv_swtg(:,k) = s_con_re.*dx0_dkpv_swtg(:,k);
        
        dIsim_dkVi_swtg(:,k) = s_con_im.*dx0_dkVi_swtg(:,k);
        dIsim_dkQi_swtg(:,k) = s_con_im.*dx0_dkQi_swtg(:,k);
        dIsim_dkiv_swtg(:,k) =  s_con_im.*dx0_dkiv_swtg(:,k);
        dIsim_dkpv_swtg(:,k) = s_con_im.*dx0_dkpv_swtg(:,k);
        
    end
end




