%perturbation control file  
% 5:40 pm 29/12/1996
% modified to include induction generators
% modified to include load modulation
% input disturbance modulation added to svc and lmod
% Author: Graham Rogers
% (c) Copyright Joe Chow/Cherry Tree Scientific Software 1991-1998
% All right reserved
% step 3: perform 0.1% perturbation on each state in turn
vr_input = 0;
pr_input = 0;
c_state = 0;
p_ratio = 1e-5;
isgen_v = 0; iswtg_v = 0;
for k = 1:n_mac
   isgen_v = 1;
   not_ib = 1;
   if ~isempty(mac_ib_idx);
      ib_chk = find(mac_ib_idx==k);
      if ~isempty(ib_chk);not_ib = 0;end
   end
   if not_ib==1
      j = 1;
      disp('disturb generator')
      pert = p_ratio*abs(mac_ang(k,1));   
      pert = max(pert,p_ratio);
      mac_ang(k,2) = mac_ang(k,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 1;
      
      j = j+1;
      pert = p_ratio*abs(mac_spd(k,1));   
      pert = max(pert,p_ratio);
      mac_spd(k,2) = mac_spd(k,1) + pert;
      p_file  % m file of perturbations
      st_name(k,j) = 2;
      k_tra = 0;
      k_sub = 0;
      if ~isempty(mac_tra_idx)
         k_idx = find(mac_tra_idx==k);
         if ~isempty(k_idx);k_tra = 1;end
      end
      if ~isempty(mac_sub_idx)
         k_idx = find(mac_sub_idx==k);
         if ~isempty(k_idx);k_sub=1;end
      end
      if k_tra==1|k_sub==1
         j=j+1;
         pert = p_ratio*abs(eqprime(k,1));   
         pert = max(pert,p_ratio);
         eqprime(k,2) = eqprime(k,1) + pert;
         p_file   % m file of perturbations
         st_name(k,j) = 3; 
      end
      if k_sub==1
         j=j+1;
         pert = p_ratio*abs(psikd(k,1));   
         pert = max(pert,p_ratio);
         psikd(k,2) = psikd(k,1) + pert;
         p_file   % m file of perturbations
         st_name(k,j) = 4;
      end
      
      if k_tra==1|k_sub==1
         j=j+1;
         pert = p_ratio*abs(edprime(k,1));   
         pert = max(pert,p_ratio);
         edprime(k,2) = edprime(k,1) + pert;
         p_file   % m file of perturbations
         st_name(k,j) = 5;
      end 
      
      if k_sub==1 
         j=j+1;
         pert = p_ratio*abs(psikq(k,1));   
         pert = max(pert,p_ratio);
         psikq(k,2) = psikq(k,1) + pert;
         p_file  % m file of perturbations
         st_name(k,j) = 6;
      end 
      
      % exciters
      if ~isempty(exc_con)
         p_exc    
      end
      %pss
      if ~isempty(pss_con)
         p_pss
      end
      if ~isempty(dpw_con)
         p_dpw
      end
      % turbine/governor
      if ~isempty(tg_con)
         p_tg
      end
      
      % disturb the input variables
      if n_exc ~= 0
         c_state = 1;
         exc_number = find(mac_int(exc_con(:,2)) ==k);
         if ~isempty(exc_number)
            disp('disturb V_ref')
            vr_input = vr_input + 1;  
            pert = p_ratio*abs(exc_pot(exc_number,3));
            pert = max(pert,p_ratio);
            nominal = exc_pot(exc_number,3);
            exc_pot(exc_number,3) = exc_pot(exc_number,3) + pert;
            p_file
            exc_pot(exc_number,3) = nominal;
         end
      end
      
      if n_tg ~=0||n_tgh~=0
         c_state = 2;
         tg_number = find(mac_tg == k);
         if isempty(tg_number)
            tg_number = find(mac_tgh==k);
         end
         if ~isempty(tg_number)
            disp('disturb P_ref')
            pr_input = pr_input + 1;
            pert = p_ratio*abs(tg_pot(tg_number,5));
            pert = max(pert,p_ratio);
            nominal = tg_pot(tg_number,5);
            tg_pot(tg_number,5) = tg_pot(tg_number,5) + pert;
            p_file
            tg_pot(tg_number,5) = nominal;
         end
      end
      c_state = 0;           
   end
end
isgen_v = 0;

% disturb induction motor states
if n_mot~=0
   disp('disturbing induction motors')
   for k = n_mac+1:ngm
      j=1;
      k_ind = k - n_mac;
      pert = p_ratio*abs(vdp(k_ind,1));   
      pert = max(pert,p_ratio);
      vdp(k_ind,2) = vdp(k_ind,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 26;
      j=j+1;
      pert = p_ratio*abs(vqp(k_ind,1));   
      pert = max(pert,p_ratio);
      vqp(k_ind,2) = vqp(k_ind,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 27;
      j=j+1;
      pert = p_ratio*abs(slip(k_ind,1));   
      pert = max(pert,0.000001);
      slip(k_ind,2) = slip(k_ind,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 28;
   end
end

% disturb induction generator states
if n_ig~=0
   disp('disturbing induction generators')
   for k = ngm+1:ntot
      j=1;
      k_ig = k - ngm;
      pert = p_ratio*abs(vdpig(k_ig,1));   
      pert = max(pert,p_ratio);
      vdpig(k_ig,2) = vdpig(k_ig,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 29;
      j=j+1;
      pert = p_ratio*abs(vqpig(k_ig,1));   
      pert = max(pert,p_ratio);
      vqpig(k_ig,2) = vqpig(k_ig,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 30;
      j=j+1;
      pert = p_ratio*abs(slig(k_ig,1));   
      pert = max(pert,0.000001);
      slig(k_ig,2) = slig(k_ig,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 31;
   end
end

nts = ntot + n_svc;
% disturb svc states
if n_svc~=0
   disp('disturbing svc')
   for k = ntot+1:nts
      j=1;
      k_svc = k - ntot;
      pert = p_ratio*abs(B_cv(k_svc,1));   
      pert = max(pert,p_ratio);
      B_cv(k_svc,2) = B_cv(k_svc,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 32;
      % disturb B_con
      if ~isempty(svcll_idx)
         j = j+1;
         kcon = find(svcll_idx==k_svc);
         if ~isempty(kcon)
            pert = p_ratio*abs(B_con(k_svc,1));
            pert = max(pert,p_ratio);
            B_con(k_svc,2) = B_con(k_svc,1) + pert;
            p_file %m-file of perturbations
            st_name(k,j)= 33;
         end
      end
      % disturb the input variable
      disp('disturbing svc_sig') 
      c_state = 3; 
      svc_input = k_svc;
      pert = p_ratio;
      nominal = 0.0;
      svc_sig(k_svc,2) = svc_sig(k_svc,2) + pert;
      p_file
      svc_sig(k_svc,2) = nominal; 
      c_state = 0;
   end
end
nts = ntot + n_svc;
ntf = ntot + n_svc + n_tcsc;
% disturb tcsc states
if n_tcsc~=0
   disp('disturbing tcsc')
   for k = nts+1:ntf
      j=1;
      k_tcsc = k - nts;
      pert = p_ratio*abs(B_tcsc(k_tcsc,1));   
      pert = max(pert,p_ratio);
      B_tcsc(k_tcsc,2) = B_tcsc(k_tcsc,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 34;
   end
   % disturb the input variable
   disp('disturbing tcsc_sig') 
   c_state = 4; 
   tcsc_input = k_tcsc;
   pert = p_ratio;
   nominal = 0.0;
   tcsc_sig(k_tcsc,2) = tcsc_sig(k_tcsc,2) + pert;
   p_file
   tcsc_sig(k_tcsc,2) = nominal; 
   c_state = 0;
end

ntl = ntf + n_lmod;
% disturb lmod states
if n_lmod~=0
   disp('disturbing load modulation')
   for k = ntf+1:ntl
      j=1;
      k_lmod = k - ntf;
      pert = p_ratio*abs(lmod_st(k_lmod,1));   
      pert = max(pert,p_ratio);
      lmod_st(k_lmod,2) = lmod_st(k_lmod,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 35;
      % disturb the input variable
      disp('disturbing lmod_sig') 
      c_state = 5; 
      lmod_input = k_lmod;
      pert = p_ratio;
      nominal = 0.0;
      lmod_sig(k_lmod,2) = lmod_sig(k_lmod,2) + pert;
      p_file
      lmod_sig(k_lmod,2) = nominal;  
      c_state = 0;
   end
end
ntrl = ntl + n_rlmod;
% disturb rlmod states
if n_rlmod~=0
   disp('disturbing reactive load modulation')
   for k = ntl+1:ntrl
      j=1;
      k_rlmod = k - ntl;
      pert = p_ratio*abs(rlmod_st(k_rlmod,1));   
      pert = max(pert,p_ratio);
      rlmod_st(k_rlmod,2) = rlmod_st(k_rlmod,1) + pert;
      p_file   % m file of perturbations
      st_name(k,j) = 36;
      % disturb the input variable
      disp('disturbing rlmod_sig') 
      c_state = 6; 
      rlmod_input = k_rlmod;
      pert = p_ratio;
      nominal = 0.0;
      rlmod_sig(k_rlmod,2) = rlmod_sig(k_rlmod,2) + pert;
      p_file
      rlmod_sig(k_rlmod,2) = nominal;  
      c_state = 0;
   end
end
ntdc = ntrl + n_dcl;
% disturb the HVDC states
if n_conv~=0
   disp('disturbing HVDC')
   for k = ntrl+1:ntdc
      j = 1;
      k_hvdc = k - ntrl;
      pert = p_ratio*abs(v_conr(k_hvdc,1));
      pert = max(pert,p_ratio);
      v_conr(k_hvdc,2) = v_conr(k_hvdc,1) + pert;
      p_file;
      st_name(k,j) = 37;
      j = j + 1;
      pert = p_ratio*abs(v_coni(k_hvdc,1));
      pert = max(pert,p_ratio);
      v_coni(k_hvdc,2) = v_coni(k_hvdc,1) + pert;
      p_file;
      st_name(k,j) = 38;
      j= j+1;
      pert = p_ratio*abs(i_dcr(k_hvdc,1));
      pert = max(pert,p_ratio);
      i_dcr(k_hvdc,2) = i_dcr(k_hvdc,1) + pert;
      p_file;
      st_name(k,j) = 39;
      if ~isempty(cap_idx)
         k_cap_idx = find(cap_idx == k_hvdc);
         if ~isempty(k_cap_idx)
            pert = p_ratio*abs(i_dci(k_hvdc,1));
            pert = max(pert,p_ratio);
            i_dci(k_hvdc,2) = i_dci(k_hvdc,1) + pert;
            p_file;
            st_name(k,j) = 40;
            j = j + 1;
            pert = p_ratio*abs(v_dcc(k_hvdc,1));
            pert = max(pert,p_ratio);
            v_dcc(k_hvdc,2) = v_dcc(k_hvdc,1) + pert;
            p_file;
            st_name(k,j) = 41;
         end
      end
      disp('disturbing rectifier dc_sig') 
      c_state = 7; 
      dcmod_input = k_hvdc;
      pert = p_ratio;
      nominal = 0.0;
      dc_sig(r_idx(k_hvdc),2) = dc_sig(r_idx(k_hvdc),1) + pert;
      p_file
      dc_sig(r_idx(k_hvdc),2) = nominal;  
      c_state = 0;
      disp('disturbing inverter dc_sig') 
      c_state = 8; 
      dcmod_input = k_hvdc;
      pert = p_ratio;
      nominal = 0.0;
      dc_sig(i_idx(k_hvdc),2) = dc_sig(i_idx(k_hvdc),1) + pert;
      p_file
      dc_sig(i_idx(k_hvdc),2) = nominal;  
      c_state = 0;
   end
end

ntshtr = ntdc + n_shtr;
% disturb the shtr (SVR) states
if n_shtr~=0
    disp('disturbing Shunt Variable Reactor (SVR)')
    for k = ntdc+1:ntshtr
        j=1;
        k_shtr = k - ntdc;
        pert = p_ratio*abs(Yshtr(k_shtr,1)); % only state considered of shtr (SVR)  
        pert = max(pert,p_ratio);
        Yshtr(k_shtr,2) = Yshtr(k_shtr,1) + pert;
        p_file   % m file of perturbations
        st_name(k,j) = 42; % previous HVDC state was 41
    
        % disturb the input variable
        disp('disturbing shtr_sig') 
        c_state = 9; % last 'c_state' for HVDC index was 8
        shtr_input = k_shtr;
        pert = p_ratio;
        nominal = 0.0;
        shtr_sig(k_shtr,2) = shtr_sig(k_shtr,2) + pert;
        p_file
        shtr_sig(k_shtr,2) = nominal; 
        c_state = 0;
    end
end
nttcsr = ntshtr + n_tcsr;
% disturb the TCSR states
if n_tcsr~=0
    disp('disturbing Load Series Reactor (TCSR/LSR)')
    for k = ntshtr+1:nttcsr
        j=1;
        k_tcsr = k - ntshtr;
        pert = p_ratio*abs(X_tcsr(k_tcsr,1)); % only state considered of TCSR/LSR  
        pert = max(pert,p_ratio);
        X_tcsr(k_tcsr,2) = X_tcsr(k_tcsr,1) + pert;
        p_file   % m file of perturbations
        st_name(k,j) = 43; % previous shtr (SVR) state was 42
    
        % disturb the input variable
        disp('disturbing tcsr_sig') 
        c_state = 10; % last 'c_state' index for shtr (SVR) was 9
        tcsr_input = k_tcsr;
        pert = p_ratio;
        nominal = 0.0;
        tcsr_sig(k_tcsr,2) = tcsr_sig(k_tcsr,2) + pert;
        p_file
        tcsr_sig(k_tcsr,2) = nominal; 
        c_state = 0;
    end
end

ntwtg = nttcsr + n_wtg;%ntwtg = ntdc + n_wtg;
% disturb the WTG states
if n_wtg~=0
    disp('disturbing WTGs')
    
    wtg_ix = 1:n_wtg;
    nmasswtg = wtg_con(wtg_ix,12); % define one or two mass model
    ixwtg3 = wtg_con(:,3) == 3;
    ixwtg4 = wtg_con(:,3) == 4;
    typewtg = wtg_con(:,3);
    Varflagwtg = wtg_con(wtg_ix,52); % reactive power control flag
    iswtg_v = 1;
    for k = nttcsr+1:ntwtg
        
        k_wtg = k - nttcsr;

        j = 1;
        pert = p_ratio*abs(wtSV_wtg(k_wtg,1));              % WTG state 1
        pert = max(pert,p_ratio);
        wtSV_wtg(k_wtg,2) = wtSV_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 44; % previous TCSR state was 43
        
        if nmasswtg(k_wtg)==2 % only for 2-mass model
            j = j+1;
            pert = p_ratio*abs(wgSV_wtg(k_wtg,1));          % WTG state 2
            pert = max(pert,p_ratio);
            wgSV_wtg(k_wtg,2) = wgSV_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 45;

            j = j+1;
            pert = p_ratio*abs(delgt_wtg(k_wtg,1));         % WTG state 3
            pert = max(pert,p_ratio);
            delgt_wtg(k_wtg,2) = delgt_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 46;
        end
        
        j = j+1;
        pert = p_ratio*abs(delerr1_wtg(k_wtg,1));           % WTG state 4
        pert = max(pert,p_ratio);
        delerr1_wtg(k_wtg,2) = delerr1_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 47;
        
        j = j+1;
        pert = p_ratio*abs(delerr2_wtg(k_wtg,1));           % WTG state 5
        pert = max(pert,p_ratio);
        delerr2_wtg(k_wtg,2) = delerr2_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 48;
        
        j = j+1;
        pert = p_ratio*abs(Eerr_wtg(k_wtg,1));              % WTG state 6
        pert = max(pert,p_ratio);
        Eerr_wtg(k_wtg,2) = Eerr_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 49;
        
        j = j+1;
        pert = p_ratio*abs(th_wtg(k_wtg,1));                % WTG state 7
        pert = max(pert,p_ratio);
        th_wtg(k_wtg,2) = th_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 50;
        
        j = j+1;
        pert = p_ratio*abs(Pord_wtg(k_wtg,1));              % WTG state 8
        pert = max(pert,p_ratio);
        Pord_wtg(k_wtg,2) = Pord_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 51;
        
        j = j+1;
        pert = p_ratio*abs(wref_wtg(k_wtg,1));              % WTG state 9
        pert = max(pert,p_ratio);
        wref_wtg(k_wtg,2) = wref_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 52;
        
        j = j+1;
        pert = p_ratio*abs(x0_wtg(k_wtg,1));                % WTG state 10
        pert = max(pert,p_ratio);
        x0_wtg(k_wtg,2) = x0_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 53;
        
        j = j+1;
        pert = p_ratio*abs(x1_wtg(k_wtg,1));                % WTG state 11
        pert = max(pert,p_ratio);
        x1_wtg(k_wtg,2) = x1_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 54;
        
        j = j+1;
        pert = p_ratio*abs(gam_wtg(k_wtg,1));               % WTG state 12
        pert = max(pert,p_ratio);
        gam_wtg	(k_wtg,2) = gam_wtg	(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 55;
        
        if typewtg(k_wtg)==3 % only for Type-3
            j = j+1;
            pert = p_ratio*abs(Efd_wtg(k_wtg,1));           % WTG state 13 (Type 3)
            pert = max(pert,p_ratio);
            Efd_wtg(k_wtg,2) = Efd_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 56;
        elseif typewtg(k_wtg)==4 % only for Type-4
            j = j+1;
            pert = p_ratio*abs(IQcmd_wtg(k_wtg,1));         % WTG state 13 (Type 4)
            pert = max(pert,p_ratio);
            IQcmd_wtg(k_wtg,2) = IQcmd_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 56;
        else
            error('not a valid WTG Type') % should never get here since WTG are checked before
        end
        
        j = j+1;
        pert = p_ratio*abs(Rerr_wtg(k_wtg,1));              % WTG state 14
        pert = max(pert,p_ratio);
        Rerr_wtg(k_wtg,2) = Rerr_wtg(k_wtg,1) + pert; 
        p_file   % m file of perturbations
        st_name(k,j) = 57;
        
        if (Varflagwtg(k_wtg)==1) || (Varflagwtg(k_wtg)==2) % only if WCE is active
            j = j+1;
            pert = p_ratio*abs(Qset_wtg(k_wtg,1));          % WTG (reactive power control WCE) state 15
            pert = max(pert,p_ratio);
            Qset_wtg(k_wtg,2) = Qset_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 58;
            
            j = j+1;
            pert = p_ratio*abs(s2_wtg(k_wtg,1));            % WTG (reactive power control WCE) state 16
            pert = max(pert,p_ratio);
            s2_wtg(k_wtg,2) = s2_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 59;
            
            j = j+1;
            pert = p_ratio*abs(s3_wtg(k_wtg,1));            % WTG (reactive power control WCE) state 17
            pert = max(pert,p_ratio);
            s3_wtg(k_wtg,2) = s3_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 60;
            
            j = j+1;
            pert = p_ratio*abs(s4_wtg(k_wtg,1));            % WTG (reactive power control WCE) state 18
            pert = max(pert,p_ratio);
            s4_wtg(k_wtg,2) = s4_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 61;
            
            j = j+1;
            pert = p_ratio*abs(s7_wtg(k_wtg,1));            % WTG (reactive power control WCE) state 19
            pert = max(pert,p_ratio);
            s7_wtg(k_wtg,2) = s7_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 62;
        elseif (Varflagwtg(k_wtg)==0) || (Varflagwtg(k_wtg)==3) % only if reactive power factor control is active
            j = j+1;
            pert = p_ratio*abs(s6_wtg(k_wtg,1));            % WTG (reactive power control WCE) state 19
            pert = max(pert,p_ratio);
            s6_wtg(k_wtg,2) = s6_wtg(k_wtg,1) + pert; 
            p_file   % m file of perturbations
            st_name(k,j) = 63;
        end
        % Disturbing WTGs inputs
        disp('disturbing WTG wth_sig_wtg')
        c_state = 11; % last c_state for tcsr was 10
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        wth_sig_wtg(k_wtg,2) = wth_sig_wtg(k_wtg,2) + pert;
        p_file
        wth_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;

        disp('disturbing WTG Pth_sig_wtg')
        c_state = 12;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Pth_sig_wtg(k_wtg,2) = Pth_sig_wtg(k_wtg,2) + pert;
        p_file
        Pth_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG th_sig_wtg')
        c_state = 13;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        th_sig_wtg(k_wtg,2) = th_sig_wtg(k_wtg,2) + pert;
        p_file
        th_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG wT_sig_wtg')
        c_state = 14;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        wT_sig_wtg(k_wtg,2) = wT_sig_wtg(k_wtg,2) + pert;
        p_file
        wT_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG T_sig_wtg')
        c_state = 15;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        T_sig_wtg(k_wtg,2) = T_sig_wtg(k_wtg,2) + pert;
        p_file
        T_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG x0_sig_wtg')
        c_state = 16;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        x0_sig_wtg(k_wtg,2) = x0_sig_wtg(k_wtg,2) + pert;
        p_file
        x0_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG Ip_sig_wtg')
        c_state = 17;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Ip_sig_wtg(k_wtg,2) = Ip_sig_wtg(k_wtg,2) + pert;
        p_file
        Ip_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG Pf_sig_wtg')
        c_state = 18;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Pf_sig_wtg(k_wtg,2) = Pf_sig_wtg(k_wtg,2) + pert;
        p_file
        Pf_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG VQ_sig_wtg')
        c_state = 19;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        VQ_sig_wtg(k_wtg,2) = VQ_sig_wtg(k_wtg,2) + pert;
        p_file
        VQ_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG QQ_sig_wtg ')
        c_state = 20;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        QQ_sig_wtg(k_wtg,2) = QQ_sig_wtg(k_wtg,2) + pert;
        p_file
        QQ_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG Vt_sig_wtg')
        c_state = 21;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Vt_sig_wtg(k_wtg,2) = Vt_sig_wtg(k_wtg,2) + pert;
        p_file
        Vt_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Vtm_sig_wtg')
        c_state = 22;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Vtm_sig_wtg(k_wtg,2) = Vtm_sig_wtg(k_wtg,2) + pert;
        p_file
        Vtm_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Vta_sig_wtg')
        c_state = 23;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Vta_sig_wtg(k_wtg,2) = Vta_sig_wtg(k_wtg,2) + pert;
        p_file
        Vta_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Vtr_sig_wtg')
        c_state = 24;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Vtr_sig_wtg(k_wtg,2) = Vtr_sig_wtg(k_wtg,2) + pert;
        p_file
        Vtr_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Vti_sig_wtg')
        c_state = 25;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Vti_sig_wtg(k_wtg,2) = Vti_sig_wtg(k_wtg,2) + pert;
        p_file
        Vti_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Vw_sig_wtg')
        c_state = 26;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Vw_sig_wtg(k_wtg,2) = Vw_sig_wtg(k_wtg,2) + pert;
        p_file
        Vw_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Itm_sig_wtg')
        c_state = 27;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Ism_sig_wtg(k_wtg,2) = Ism_sig_wtg(k_wtg,2) + pert;
        p_file
        Ism_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Ita_sig_wtg')
        c_state = 28;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Isa_sig_wtg(k_wtg,2) = Isa_sig_wtg(k_wtg,2) + pert;
        p_file
        Isa_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Itr_sig_wtg')
        c_state = 29;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Isr_sig_wtg(k_wtg,2) = Isr_sig_wtg(k_wtg,2) + pert;
        p_file
        Isr_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
        disp('disturbing WTG: Iti_sig_wtg')
        c_state = 30;
        wtg_input = k_wtg;
        pert = p_ratio;
        nominal = 0.0;
        Isi_sig_wtg(k_wtg,2) = Isi_sig_wtg(k_wtg,2) + pert;
        p_file
        Isi_sig_wtg(k_wtg,2) = nominal; 
        c_state = 0;
        
    end
    iswtg_v = 0;
end

ntccinj = ntwtg + n_ccinj;
% disturb CCinj inputs (NO states so far)
if n_ccinj~=0
    disp('disturbing CC Injection input')
    for k = ntwtg+1:ntccinj % ntshtr+1:nttcsr % ntdc+1:ntshtr
        j=1;
        k_ccinj = k - ntwtg;
        
        % disturb the input variables
        disp('disturbing ccinj_m_sig') 
        c_state = 31; % last 'c_state' index for WTG was 30
        ccinj_input = k_ccinj;
        pert = p_ratio;
        nominal = 0.0;
        Im_sig_ccinj(k_ccinj,2) = Im_sig_ccinj(k_ccinj,2) + pert;
        p_file
        Im_sig_ccinj(k_ccinj,2) = nominal; 
        c_state = 0;
        
        disp('disturbing ccinj_a_sig') 
        c_state = 32;
        ccinj_input = k_ccinj;
        pert = p_ratio;
        nominal = 0.0;
        Iang_sig_ccinj(k_ccinj,2) = Iang_sig_ccinj(k_ccinj,2) + pert;
        p_file
        Iang_sig_ccinj(k_ccinj,2) = nominal; 
        c_state = 0;
    end
end
