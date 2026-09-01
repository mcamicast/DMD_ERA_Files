function [bus_new] = wtg(i,k,bus,flag,busi_v,t)
% Syntax: [bus_new] = wtg(i,k,bus,flag,busi_v)
% 07/08/2012
% Purpose: Wind Turbine Generator Type 3 and Type 4. Based on the GE report 
% and the WECC model.
% Model only has vectorized computation
%
% NOTE - static var bus must be declared as a non-conforming load bus.
%
% Input: i - static var number
%            if i= 0, vectorized computation
%        k - integer time
%        bus - solved loadflow bus data
%        flag - 0 - initialization
%               1 - network interface computation
%               2 - generator dynamics computation
%        v_sbus - svc bus voltage


% system variables
global basmva bus_int bus_freqf
global bus_v line_compl line

% Wind Power Plant (wtg) Variables
global wtg_con n_wtg wtg_idx wtg_idx2 vw_wtg wtg_con_ini
global w0_wtg Pset_wtg Iswtg Itwtg delg0_wtg Kpwtg Pgv_wtg Qgv_wtg Ipcmdv_wtg Pmechv_wtg % since Kp is fudged
global Ipmxv_wtg Iqmxv_wtg Iqxv_wtg Vrfq_wtg Vreg_wtg

global wref_wtg wgSV_wtg wtSV_wtg delgt_wtg delerr1_wtg delerr2_wtg
global dwref_wtg dwgSV_wtg dwtSV_wtg ddelgt_wtg ddelerr1_wtg ddelerr2_wtg

global Eerr_wtg Pord_wtg th_wtg x0_wtg x1_wtg gam_wtg Efd_wtg Rerr_wtg
global dEerr_wtg dPord_wtg dth_wtg dx0_wtg dx1_wtg dgam_wtg dEfd_wtg dRerr_wtg

global IQcmd_wtg Edbr_wtg
global dIQcmd_wtg dEdbr_wtg

global Vlvpl_wtg dVlvpl_wtg

global Qset_wtg s2_wtg s3_wtg s4_wtg s6_wtg s7_wtg
global dQset_wtg ds2_wtg ds3_wtg ds4_wtg ds6_wtg ds7_wtg

global s1wini_wtg s2wini_wtg 
global ds1wini_wtg ds2wini_wtg dpwi_wtg

global swinif_wtg dswinif_wtg fst1_wtg fst2_wtg fst3_wtg fst4_wtg fst5_wtg fst6_wtg fst7_wtg
global dfst1_wtg dfst2_wtg dfst3_wtg dfst4_wtg dfst5_wtg dfst6_wtg dfst7_wtg 
global thrshldnfc thrshldwini thrshldthp

global sigpru1_wtg sigpru2_wtg sigpru3_wtg sigpru4_wtg sigpru5_wtg Usig0
 
% Global -inputs
global wth_sig_wtg Pth_sig_wtg th_sig_wtg wT_sig_wtg 
global T_sig_wtg x0_sig_wtg Ip_sig_wtg Pf_sig_wtg

global VQ_sig_wtg QQ_sig_wtg Vt_sig_wtg

global Vtm_sig_wtg Vta_sig_wtg Vtr_sig_wtg Vti_sig_wtg Vw_sig_wtg
global Ism_sig_wtg Isa_sig_wtg Isr_sig_wtg Isi_sig_wtg

bus_new = bus;
if ~isempty(wtg_con)
    if flag == 0 % initialization
        if i~=0
            %later
        else
            
            thrshldthp = ones(n_wtg,1)*[-0.018, 0.005];
            
            wtg_ix = 1:n_wtg;
%             wtg_ix2 = wtg_con(:,2); % bus number
            
            ixwtg3 = wtg_con(:,3) == 3;
            ixwtg4 = wtg_con(:,3) == 4;

            wtgbase = wtg_con(wtg_ix,4); % Base MVA of the wtg. 162 for the GE model
            genbasmva_wtg = wtgbase*10/9;
            % genbasmva_wtg = wtg_con(wtg_ix,5); - change mode of Pset
            Psmod_wtg = wtg_con(wtg_ix,5);
            Qmaxwtg = wtg_con(wtg_ix,8);
            Qminwtg = wtg_con(wtg_ix,9);
            Klwtg = wtg_con(wtg_ix,10); %****mirar donde lo voy a poner
            % Kpwtg = wtg_con(wtg_ix,11); % already deal with on wtg_indx.m
            
            %Dtgwtg = wtg_con(wtg_ix,13);
            %Hwtg = wtg_con(wtg_ix,14);
            Ktgwtg = wtg_con(wtg_ix,16);
            %Kipwtg = wtg_con(wtg_ix,18);
            %Kppwtg = wtg_con(wtg_ix,19);
            %Kicwtg = wtg_con(wtg_ix,20);
            %Kpcwtg = wtg_con(wtg_ix,21);
            %Kitrqwtg = wtg_con(wtg_ix,22);
            %Kptrqwtg = wtg_con(wtg_ix,23);
            Lppwtg = wtg_con(wtg_ix,33); % Type 3 (apparently)
            %Kpllpwtg = wtg_con(wtg_ix,34);
            %Tddelwtg = wtg_con(wtg_ix,35);
            
            %EBSTwtg = wtg_con(wtg_ix,47); % Type 4
            
            varflag = wtg_con(wtg_ix,52);
            Vregbuswtg = wtg_con(wtg_ix,53);
            
            Kpvwtg = wtg_con(wtg_ix,56);
            Kivwtg = wtg_con(wtg_ix,57);
            Kqdwtg = wtg_con(wtg_ix,61);
            % wrefmodwtg = wtg_con(wtg_ix,66);
          
%             vw_wtg_0 = vw_wtg(:,1); % not used
            
            xpp = Lppwtg*basmva./genbasmva_wtg;
            zpp = 1i*xpp;
            % From loadflow:
            Vtwtg = bus(wtg_idx2,2).*exp(1i*bus(wtg_idx2,3)*pi/180); %Cambioindx
            Vtmagwtg = abs(Vtwtg);
            Vtangwtg = angle(Vtwtg);
%             Vtrewtg = real(Vtwtg); % not used
%             Vtimwtg = imag(Vtwtg); % not used
%             Izpp = Vtwtg./zpp; % not used
            Szpp = Vtmagwtg.^2./conj(zpp);
            
            Plf = bus(wtg_idx2,4); Qlf = bus(wtg_idx2,5);
            
            Pslf_0 = Psmod_wtg == 0;
            Psmax_1 = Psmod_wtg == 1;
            if any(~(Pslf_0 | Psmax_1))
                error('Wrong setting for Pset_mode')
            end
            
            %*** Type 3  ***%               
            Pg_wtg  = (Plf - real(Szpp)).*(basmva./wtgbase);%Cambioindx
            % Pset_wtg  = (Plf - real(Szpp)).*(basmva./wtgbase);%Cambioindx
            %*** Type 4  ***%               
            Pg_wtg(ixwtg4) = Plf(ixwtg4).*(basmva./wtgbase(ixwtg4));
            % Pset_wtg(ixwtg4) = Plf(ixwtg4).*(basmva./wtgbase(ixwtg4));
            %*** ------  ***% 
            Pset_wtg = Pg_wtg;
            Pset_wtg(Psmax_1) = 1;
            
%             if any(abs(Pset_wtg - 1)<1e-6)
%                 disp('Set power is not equal to the rated power of the Wind Turbine')
%                 Pset_wtg(:) = 1;
%             end

            %*** Type 3  ***%             
            Qset_wtg(:,1)  = (Qlf - imag(Szpp)).*(basmva./genbasmva_wtg);
            %*** Type 4  ***% 
            Qset_wtg(ixwtg4,1)  = Qlf(ixwtg4).*(basmva./genbasmva_wtg(ixwtg4));

            % Pg_wtg = Pset_wtg;
            Qg_wtg = Qset_wtg(:,1); % PUEDE ESTAR MAL POR GEN_base hacer seguimiento a esas señales
            
%*************** --Reactive Power Control Initialization-- ***************%            
            % SEE BELOW FOR OTHER INITIALIZATIONS DEPENDING ON varflag
            
            if any(Qset_wtg(:,1) > Qmaxwtg)
                Qset_wtg(:,1)
                error('WTG reactive power out of limits')
            end
            
            if any(Qset_wtg(:,1) < Qminwtg)
                Qset_wtg(:,1)
                error('WTG reactive power out of limits')
            end
            
         
            % if varflag == 0 % case when it follows PF control           
            ixvarglaf_0 = varflag == 0;
            s6_wtg(ixvarglaf_0,1) = Pg_wtg(ixvarglaf_0,1);
            % Qset_wtg(ixvarglaf_0,1) as before
            
            % if varflag == 1 % case when it follows Voltage regulation            
            ixvarglaf_p1 = varflag == 1;
            ixvarglaf_p2 = varflag == 2;
            ixvarglaf_p3 = varflag == 3;
            ixvarglaf_p1_2 = ixvarglaf_p1 | ixvarglaf_p2;
% %         
            Qinput = Qg_wtg; % Qset_wtg(:,1); % One of the choices GE report page 4.9 top
            
            Vrfq = bus(bus_int(Vregbuswtg(ixvarglaf_p1_2)),2); % reference voltage magnitute from LF - checked in xxx--
            Vrfq = Vrfq(ixvarglaf_p1_2,1); % reference voltage taken from the load flow
            Vreg = bus(bus_int(Vregbuswtg(ixvarglaf_p1_2)),2); % Voltage to regulate is defined by user (from LF to initialize)
            Vreg = Vreg(ixvarglaf_p1_2,1);
            
            s7_wtg(ixvarglaf_p1_2,1) = Qinput(ixvarglaf_p1_2,1);
            s3_wtg(ixvarglaf_p1_2,1) = Vreg;
            Vqd = Kqdwtg(ixvarglaf_p1_2,1).*s7_wtg(ixvarglaf_p1_2,1); % Figure 4-5 GE report v4.5
            s2_wtg(ixvarglaf_p1_2,1) = 0;
            % Qset_wtg(ixvarglaf_p1,1) as before
            s4_wtg(ixvarglaf_p1_2,1) = (Qset_wtg(ixvarglaf_p1_2,1) - Kpvwtg(ixvarglaf_p1_2,1).*s2_wtg(ixvarglaf_p1_2,1))./Kivwtg(ixvarglaf_p1_2,1);
            s4_wtg(Kivwtg == 0,1)=0;
            
%*************** ----------------------------------------- ***************%

            Pmechwtg = Pg_wtg;
            Pelecwtg = Pg_wtg; 
            Pord_wtg(:,1) = Pg_wtg; % Pord_wtg(:,1) = Pset_wtg; % OJO - INITIALIZATION and CONSTANT
            
            % Determine generator speed 
%             wref_wtg(:,1) = 1.2 * ones(n_wtg,1);
%             ixaux = find(Pmechwtg <= 0.75+1e-12);
%             wrefx = (-0.67*Pmechwtg + 1.42 ).*Pmechwtg + 0.51;
%             ixaux = find(Pmechwtg <= 0.56+1e-12);
%             wrefx = -0.75*Pmechwtg.^2 + 1.59*Pmechwtg + 0.63;
%             wref_wtg(ixaux,1) = wrefx(ixaux);
            wref_wtg(:,1) = wtg_con_ini(:,2); % already taken care of in wtg_indx.m
            
            w0_wtg = wref_wtg(:,1); 
            wgSV_wtg(:,1) = 0; % is the deviation with respect to w0
            wtSV_wtg(:,1) = 0; % is the deviation with respect to w0
            
            wg_wtg = w0_wtg + wgSV_wtg(:,k); 
            wt_wtg = w0_wtg + wtSV_wtg(:,k); 

%************************** -Pwind determination- ************************%
            th_wtg(:,1) = wtg_con_ini(:,1);
%************************** --------------------- ************************%

            Vlvpl_wtg(:,1) = Vtmagwtg;
            %*** Type 4 ***%
            Edbr_wtg(:,1) = 0;
            %Edbr_wtg(:,1) = EBSTwtg;
            %*** ------ ***%
            
            delerr2_wtg(:,1) = Pord_wtg(:,1)./wref_wtg(:,1);
            delerr1_wtg(:,1) = th_wtg(:,1); %simulink model
            
            Eerr_wtg(:,1) = th_wtg(:,1) - delerr1_wtg(:,1);
            Rerr_wtg(:,1) = Vtmagwtg;
            
            delgt_wtg(:,1) = 0;
            
            delg0_wtg = -Pg_wtg./(Ktgwtg.*w0_wtg(:,1)); % line 391 onwards asyst5_init
            
            %*** Type 3  ***%            
            x0_wtg(:,1) = Qset_wtg(:,1).*Lppwtg./Vtmagwtg + Vtmagwtg;
            %*** Type 4  ***% 
            % correcting for Type 4
            x0_wtg(ixwtg4,1) = Qset_wtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1); % CONFIRMAR QSET
            %*** ------ ***%
            
            x1_wtg(:,1) = Pord_wtg(:,1).*(wtgbase./genbasmva_wtg)./Vtmagwtg;
            
            %*** Type 3  ***%
            Efd_wtg(:,1) = x0_wtg(:,1);
            %*** Type 4  ***%
            IQcmd_wtg(:,1) = x0_wtg(:,1);
            %*** ------ ***%
            
            gam_wtg(:,1) = Vtangwtg;
            
            % Correction Rerr when skipping one integrator in Q Control
            Rerr_wtg(ixvarglaf_p2,1) = x0_wtg(ixvarglaf_p2,1);
            
% ==================== Output current of WTG ============================ % 
% Need to be computed at initialization due to usage inside 'red_ybus'
            wtg_cur;
% ======================================================================= %
% ======================== Freq signal filtering ======================== %
            freqrefwtg = bus_freqf(wtg_idx2,1); % initial frequency - reference
            swinif_wtg(:,1) = freqrefwtg;
% ====================== End Freq signal filtering ====================== %            

            % windINERTIAf(flag,k, wtg_ix, wtg_idx2);
            wtg_winertia;
            if size(wtg_con,2)>75
                wtg_cont % script of files of WTG
            end
            
            Pgv_wtg(:,1) = Pg_wtg; Qgv_wtg(:,1) = Qg_wtg;
            Ipcmd_wtg = Pord_wtg(:,1).*(wtgbase./genbasmva_wtg)./Vtmagwtg;
            Ipcmdv_wtg(:,1) = Ipcmd_wtg; Pmechv_wtg(:,1) = Pmechwtg;
            Vrfq_wtg(ixvarglaf_p1_2,1) = Vrfq; Vreg_wtg(ixvarglaf_p1_2,1) = Vreg;
            bus_new = bus;

            clear ixaux wrefx
            
        end
    end
    if flag == 1 % network interface computation
        % no interface calculation required - done in nc_load
    end

    if flag == 2 % Dynamic model calculation
        if i~=0
            %later
        else %vectorized computation
            % wtg_ix = bus_int(wtg_con(:,2)); % bus number
            wtg_ix = 1:n_wtg; % OJO CAMBIAR
%             wtg_ix2 = wtg_con(:,2); % bus number
            
            ixwtg3 = wtg_con(:,3) == 3;
            ixwtg4 = wtg_con(:,3) == 4;

            wtgbase = wtg_con(wtg_ix,4); % Base MVA of the wtg. 162 for the GE model
            genbasmva_wtg = wtgbase*10/9; % change for 
            % genbasmva_wtg = wtg_con(wtg_ix,5);
            Pordmaxwtg = wtg_con(wtg_ix,6);
            Pordminwtg = wtg_con(wtg_ix,7);
            Qmaxwtg = wtg_con(wtg_ix,8);
            Qminwtg = wtg_con(wtg_ix,9);
            
            Klwtg = wtg_con(wtg_ix,10); %****mirar donde lo voy a poner
            % Kpwtg global variable
            nmasswtg = wtg_con(wtg_ix,12); % define one or two mass model
            Dtgwtg = wtg_con(wtg_ix,13);
            Hwtg = wtg_con(wtg_ix,14);
            Hgwtg = wtg_con(wtg_ix,15);           
            Ktgwtg = wtg_con(wtg_ix,16);
            Wbase = wtg_con(wtg_ix,17);
            Kipwtg = wtg_con(wtg_ix,18);
            Kppwtg = wtg_con(wtg_ix,19);
            Kicwtg = wtg_con(wtg_ix,20);
            Kpcwtg = wtg_con(wtg_ix,21);
            Kitrqwtg = wtg_con(wtg_ix,22);
            Kptrqwtg = wtg_con(wtg_ix,23);
            Tpwtg = wtg_con(wtg_ix,24);
            Tpcwtg = wtg_con(wtg_ix,25);
            thmaxwtg = wtg_con(wtg_ix,26);
            thminwtg = wtg_con(wtg_ix,27);
            thratemx = wtg_con(wtg_ix,28);
            thratemn = wtg_con(wtg_ix,29);
            Pordratemx = wtg_con(wtg_ix,30);
            Pordratemn = wtg_con(wtg_ix,31);
            wfflgwtg = wtg_con(wtg_ix,32);
            Lppwtg = wtg_con(wtg_ix,33); % Type 3 (apparently)
            Kpllpwtg = wtg_con(wtg_ix,34);
            Tddelwtg = wtg_con(wtg_ix,35);
            lvplflgwtg = wtg_con(wtg_ix,36); 
            rrpwrwtg = wtg_con(wtg_ix,37); 
            brkptwtg = wtg_con(wtg_ix,38); 
            zeroxwtg = wtg_con(wtg_ix,39);            
            kQiwtg = wtg_con(wtg_ix,40);
            kViwtg = wtg_con(wtg_ix,41);
            Ipmaxwtg = wtg_con(wtg_ix,42);
            Vmaxcwtg = wtg_con(wtg_ix,43); % Verify limits Rerr
            Vmincwtg = wtg_con(wtg_ix,44); % Verify limits Rerr
            xiqmaxwtg = wtg_con(wtg_ix,45);
            xiqminwtg = wtg_con(wtg_ix,46);
            EBSTwtg = wtg_con(wtg_ix,47); % Type 4
            Kdbrwtg = wtg_con(wtg_ix,48); % Type 4
            Iphlwtg = wtg_con(wtg_ix,49); % Type 4
            Iqhlwtg = wtg_con(wtg_ix,50); % Type 4
            pqflagwtg = wtg_con(wtg_ix,51); % Type 4
            varflag = wtg_con(wtg_ix,52);
            Vregbuswtg = wtg_con(wtg_ix,53);
            Trwtg = wtg_con(wtg_ix,54);
            Tvwtg = wtg_con(wtg_ix,55);
            Kpvwtg = wtg_con(wtg_ix,56);
            Kivwtg = wtg_con(wtg_ix,57);
            Tcwtg = wtg_con(wtg_ix,58);
            fNwtg = wtg_con(wtg_ix,59);
            Tlpqdwtg = wtg_con(wtg_ix,60);
            Kqdwtg = wtg_con(wtg_ix,61);
            Vermnwtg = wtg_con(wtg_ix,62);
            Vermxwtg = wtg_con(wtg_ix,63);
            Vfrzwtg = wtg_con(wtg_ix,64);            
            Tpwrwtg = wtg_con(wtg_ix,65);
            wrefmodwtg = wtg_con(wtg_ix,66);
%             wINIflagwtg = wtg_con(wtg_ix,67);
%             Kwiwtg = wtg_con(wtg_ix,68);
%             dbwiwtg = wtg_con(wtg_ix,69);
%             Tlpwiwtg = wtg_con(wtg_ix,70);
%             Twowiwtg = wtg_con(wtg_ix,71);

%           75. Pmnwi - Table4.13 GE Report
%           76. ... and onwards - space to input limitations (maybe)
            
            if size(wtg_con,2)>75
               fcflagwtg = wtg_con(wtg_ix,76);
               dbfcwtg = wtg_con(wtg_ix,77);
               p1fcwtg = wtg_con(wtg_ix,78);
               p2fcwtg = wtg_con(wtg_ix,79);
               p3fcwtg = wtg_con(wtg_ix,80);
               p4fcwtg = wtg_con(wtg_ix,81);
               p5fcwtg = wtg_con(wtg_ix,82);
               p6fcwtg = wtg_con(wtg_ix,83);
               p7fcwtg = wtg_con(wtg_ix,84);
               p8fcwtg = wtg_con(wtg_ix,85);
               p9fcwtg = wtg_con(wtg_ix,86);
            end
            
            vw_wtgk = vw_wtg(:,k) + Vw_sig_wtg(:,k);
            % sensing voltage
            % Vtwtg = busi_v(wtg_idx,k);
            % k2=1; if k~=1; k2=k-1; end;
            k2=k;
            Vtwtg = busi_v(wtg_idx2,k2);
            Vtwtg = (Vtwtg + Vtm_sig_wtg(:,k2)).*exp(1i*Vta_sig_wtg(:,k2));
            Vtwtg = Vtwtg + Vtr_sig_wtg(:,k2) + 1i*Vti_sig_wtg(:,k2);
            Vtmagwtg = abs(Vtwtg);
            Vtangwtg = angle(Vtwtg);
            % Vtrewtg = real(Vtwtg);
            % Vtimwtg = imag(Vtwtg);
            % if k==1; k=2; end
            % Iswtgk = Iswtg(:,k);
%             Iswtgk = Iswtg(:,k2).*(cos(Vtangwtg) + 1i*sin(Vtangwtg));
            Iswtgk = Iswtg(:,k2);
            % Iswtgk = Iswtg(:,k-1);
            % Itwtgk = Itwtg(:,k);
            
            Swtg = Vtwtg.*conj(Iswtgk);
            % Swtg = Vtwtg.*conj(Itwtgk);
               
            rpp = 0; %por el momento
            xpp = Lppwtg*basmva./genbasmva_wtg;
            zpp = rpp +1i*xpp;
            Izpp = Vtwtg./zpp;
            Szpp = Vtmagwtg.^2./conj(zpp);
            
            %*** Type 3 ***%
            Itwtg(:,k2) = Iswtgk - Vtwtg./zpp;
            %*** Type 4 ***%
            Itwtg(ixwtg4,k2) = Iswtgk(ixwtg4);
            
            %*** Type 3 ***%         
            Pg_wtg = (real(Swtg) - real(Szpp)).*(basmva./wtgbase);
            Qg_wtg = (imag(Swtg) - imag(Szpp)).*(basmva./genbasmva_wtg);            
            %*** Type 4 ***%
            Pg_wtg(ixwtg4) = real(Swtg(ixwtg4)).*(basmva./wtgbase(ixwtg4));
            Qg_wtg(ixwtg4) = imag(Swtg(ixwtg4)).*(basmva./genbasmva_wtg(ixwtg4));
            %*** ------ ***%
            
            Pelecwtg = Pg_wtg;
            
            PFArefwtg = atan(Qgv_wtg(:,1)*(10/9)./Pgv_wtg(:,1));

            % Verify Efd_wtg - from 'lim_exc_s1.m' in GE model
            ixdEfmx = (Efd_wtg(:,k) > (Vtmagwtg + xiqmaxwtg));
            ixdEfmn = (Efd_wtg(:,k) < (Vtmagwtg + xiqminwtg));
            Efd_wtg(ixdEfmx,k) = Vtmagwtg(ixdEfmx,1) + xiqmaxwtg(ixdEfmx,1);
            Efd_wtg(ixdEfmn,k) = Vtmagwtg(ixdEfmn,1) + xiqminwtg(ixdEfmn,1);           
            
            ixvarglaf_p2 = varflag == 2;
            ixvarglaf_p3 = varflag == 3;
            Efd_wtg(ixvarglaf_p2,k) = Rerr_wtg(ixvarglaf_p2,k);
            
            %*** New August 18 2013
            % ixthmn = th_wtg(:,k)<=(thminwtg+3*eps);
            ixthmn = th_wtg(:,k)<=(thminwtg+0.02+thrshldthp(:,1));
            
            thrshldauxp = thrshldthp(ixthmn,1);
            thrshldthp(ixthmn,1) = thrshldthp(ixthmn,2);
            thrshldthp(ixthmn,2) = thrshldauxp;

            
            th_wtg(ixthmn,k) = thminwtg(ixthmn);
            ix_dth = dth_wtg(:,k)<(0+3*eps);
            %dth_wtg(ix_dth,k) = zeros(length(ix_dth),1);
            % zaux = zeros(length(ix_dth),1);
            ddelerr1_wtg(ix_dth & ixthmn,k) = 0;% zaux(ix_dth);
            dEerr_wtg(ix_dth & ixthmn,k) = 0;%zaux(ix_dth);
            dth_wtg(ix_dth & ixthmn,k) = 0; % zaux(ix_dth);
            if size(wtg_con,2)>75 % new control should be turned of when pitch angle reaches its min
                ixfcwtg1 = fcflagwtg == 1;
                dfst1_wtg(ix_dth & ixthmn & ixfcwtg1,k) = 0;
            end
            
            % Verify limits of theta (pitch angle) - when it hits the upper
            % bound
            ixthmx = th_wtg(:,k)>=thmaxwtg;
            th_wtg(ixthmx,k) = thmaxwtg(ixthmx);
            
%             if k~=1
%                 deltat = t(k) - t(k-1);
%                 thrat = (th_wtg(:,k) - th_wtg(:,k-1))/deltat;
%                 thratix = (thrat > thratemx);
%                 th_wtg(thratix,k) = th_wtg(thratix,k-1) + deltat*thratemx(thratix,1);
%                 thratix  = (thrat < thratemn);
%                 th_wtg(thratix,k) = th_wtg(thratix,k-1) + deltat*thratemn(thratix,1);
%             else
%                 % only for the first time step k=1
%                 deltat = 1;
%             end

            %*** New August 18 2013
            
% Back up:
%             ixdEfmx = (Efd_wtg(:,k) > Vtmagwtg + xiqmaxwtg);
%             Efd_wtg(ixdEfmx,k) = Vtmagwtg(ixdEfmx,1) + xiqmaxwtg(ixdEfmx,1);
%             ixdEfmn = (Efd_wtg(:,k) < Vtmagwtg + xiqminwtg);
%             Efd_wtg(ixdEfmn,k) = Vtmagwtg(ixdEfmn,1) + xiqminwtg(ixdEfmn,1);            
            
%             Pordminwtg = 0.10; % line 207 asyst5_init (maximum power)
%             Pordmaxwtg = 1.12; % line 206 asyst5_init (maximum power)
            % Verify limits of Pord - when it hits the lower bound
            ixPordmn = Pord_wtg(:,k)<=Pordminwtg;
            Pord_wtg(ixPordmn,k) = Pordminwtg(ixPordmn,1);
            %ix_dPord = (dPord_wtg(ixPordmn,k)<=0);
            %dPord_wtg(ix_dPord,k) = zeros(length(ix_dPord),1);
            
            % Verify limits of Pord - when it hits the upper bound
            ixPordmx = Pord_wtg(:,k)>=Pordmaxwtg;
            Pord_wtg(ixPordmx,k) = Pordmaxwtg(ixPordmx,1);

%=========================== LPVL level limit ============================%
            lvplmax = 1.22;
            lvpl = lvplmax./(brkptwtg -zeroxwtg).*Vlvpl_wtg(:,k) + lvplmax.*zeroxwtg./(zeroxwtg - brkptwtg);
            lvpl(lvpl<=0) = 0;
            lvpl(lvpl>=lvplmax) = lvplmax;
            
            ixlvpl = ( (lvplflgwtg == 1) & (x1_wtg(:,k) > lvpl) );
            x1_wtg(ixlvpl,k) = lvpl(ixlvpl,1);
%========================== End LPVL level limit =========================%

%========================= Freq signal filtering =========================%
            freqrefwtg = bus_freqf(wtg_idx2,1); % initial frequency - reference
            busfreq_wtg = bus_freqf(wtg_idx2,k);% calculated through freqcalc            
            Tflpf_wtg = 0.01; %not a parameter to be defined
            % swinif_wtg is a signal with the filtered frequency
            dswinif_wtg(:,k) = 1./Tflpf_wtg.*(busfreq_wtg - swinif_wtg(:,k));
            
%======================= End Freq signal filtering =======================%

%============================== windINERTIA ==============================%
%             Pordext_wtg = windINERTIAf(flag,k, wtg_ix, wtg_idx2);
            wtg_winertia; % defines variable dpwiwtg
%============================ End windINERTIA ============================%

%===================== Freq control Diff Approaches ======================%
            if size(wtg_con,2)>75
                wtg_cont; % script for new frequency control
            end           
%=================== End Freq control Diff Approaches ====================%

%======================== Reactive Power Control =========================%
            % if varflag == -1 % case when Qord is held constant
            ixvarglaf_m1 = varflag == -1;
            dQset_wtg(ixvarglaf_m1,k) = 0;
            % if varflag == 0 % case when it follows PF control           
            ixvarglaf_0 = varflag == 0;
            ds6_wtg(ixvarglaf_0,k) = (1./Tpwrwtg(ixvarglaf_0,1)).*(Pg_wtg(ixvarglaf_0,1) - s6_wtg(ixvarglaf_0,k)); 
            Qset_wtg(ixvarglaf_0,k) = (9/10)*s6_wtg(ixvarglaf_0,k).*tan(PFArefwtg(ixvarglaf_0,1)); % Accomodate bases
            dQset_wtg(ixvarglaf_0,k) = 0; % So it's not overrided by s_simu
            % if varflag == 1 % case when it follows Voltage regulation
            ixvarglaf_p1 = varflag == 1;
            ixvarglaf_p2 = varflag == 2;
            ixvarglaf_p1_2 = ixvarglaf_p1 | ixvarglaf_p2;
            Vrfq = abs( busi_v(bus_int(Vregbuswtg(ixvarglaf_p1_2)),1) ); % reference voltage - checked in xxx--
            Vrfq = Vrfq(ixvarglaf_p1_2,1); % reference voltage taken from the load flow
            Vqd = Kqdwtg(ixvarglaf_p1_2,1).*s7_wtg(ixvarglaf_p1_2,k); % Figure 4-5 GE report v4.5
            Vreg = abs( busi_v(bus_int(Vregbuswtg(ixvarglaf_p1_2)),k) ); % Voltage to regulate is defined by user
            Vreg = Vreg(ixvarglaf_p1_2,1);
            ds3_wtg(ixvarglaf_p1_2,k) = (1./Trwtg(ixvarglaf_p1_2,1)).*(Vreg - s3_wtg(ixvarglaf_p1_2,k));
            
            % Limit the signal to be less than Vermx and more than Vermn:
            saux_rpc = Vrfq - s3_wtg(ixvarglaf_p1_2,k) - Vqd + VQ_sig_wtg(ixvarglaf_p1_2,k);
            ixsaux = saux_rpc <= Vermnwtg(ixvarglaf_p1_2,1);
            saux_rpc(ixsaux) = Vermnwtg(ixsaux);
            ixsaux = saux_rpc >= Vermxwtg(ixvarglaf_p1_2,1);
            saux_rpc(ixsaux) = Vermxwtg(ixsaux);
            ds2_wtg(ixvarglaf_p1_2,k) = (1./Tvwtg(ixvarglaf_p1_2,1)).*( (1./fNwtg(ixvarglaf_p1_2,1)).*saux_rpc - s2_wtg(ixvarglaf_p1_2,k) );
            ds4_wtg(ixvarglaf_p1_2,k) = (1./fNwtg(ixvarglaf_p1_2,1)).*saux_rpc;
            
            % Freeze 2 integrators if  <Vfrz
            ixVfrz = Vreg < Vfrzwtg(ixvarglaf_p1_2,1);
            ds2_wtg(ixVfrz,k) = 0; ds4_wtg(ixVfrz,k) = 0;
            
            % dQset - verifing limits of the reference signal
            saux2_rpc = Kivwtg(ixvarglaf_p1_2,1).*s4_wtg(ixvarglaf_p1_2,k) + Kpvwtg(ixvarglaf_p1_2,1).*s2_wtg(ixvarglaf_p1_2,k);
            ixsaux2 = saux2_rpc >= Qmaxwtg(ixvarglaf_p1_2,1);
            saux2_rpc(ixsaux2) = Qmaxwtg(ixsaux2);
            ixsaux2 = saux2_rpc <= Qminwtg(ixvarglaf_p1_2,1);
            saux2_rpc(ixsaux2) = Qminwtg(ixsaux2);
            dQset_wtg(ixvarglaf_p1_2,k) = (1./Tcwtg(ixvarglaf_p1_2,1)).*(saux2_rpc  - Qset_wtg(ixvarglaf_p1_2,k) );
            
            Qinput =  Qg_wtg; % One of the choices GE report page 4.9 top

            ds7_wtg(ixvarglaf_p1_2,k) = (1./Tlpqdwtg(ixvarglaf_p1_2,1)).*(Qinput(ixvarglaf_p1_2,1) - s7_wtg(ixvarglaf_p1_2,k));
%======================= End Reactive Power Control ======================%

            %*** Verify limits for Qset ***%
            Qset_wtg(Qset_wtg(:,k) >= Qmaxwtg,k) = Qmaxwtg(Qset_wtg(:,k) >= Qmaxwtg);
            Qset_wtg(Qset_wtg(:,k) <= Qminwtg,k) = Qminwtg(Qset_wtg(:,k) <= Qminwtg);
            %*** ---------------------- ***%
            
%**************************** -Two mass model- ***************************%            
            wg_wtg = w0_wtg + wgSV_wtg(:,k);
            wt_wtg = w0_wtg + wtSV_wtg(:,k);
%**************************** -One mass model- ***************************%
            nmass1idx = nmasswtg == 1;
            wg_wtg(nmass1idx,1) = wt_wtg(nmass1idx,1);
%**************************** ---------------- ***************************%

            cpwtg = zeros(n_wtg,1);
            lam_wtg = Klwtg.*wt_wtg./vw_wtgk;
            %verify limits of lambda
            lam_max = 15;
            lam_min = 3;
            ixlamx = (lam_wtg>=lam_max);
            lam_wtg(ixlamx) = lam_max;
            ixlamn = (lam_wtg<=lam_min);
            lam_wtg(ixlamn) = lam_min;
            if any(ixlamx)||any(ixlamn)
                disp('wtg lambda limited')
%                 error('wtg lambda limited')
            end
            
            for ix = 1:n_wtg
                cpwtg(ix) = cp_det(lam_wtg(ix),th_wtg(ix,k));
            end
            
            Pmechwtg = Kpwtg.* cpwtg .* vw_wtgk.^3; % remember Kpwtg was fudged at initialization
            % verify limits of Pmech - later
            
%             Ipcmd_wtg = Pord_wtg(:,k).*(wtgbase./genbasmva_wtg)./Vtmagwtg; %confirmar el orden de esta ecuacion       
            Ipcmd_wtg = (Pord_wtg(:,k) + dpwiwtg + Pf_sig_wtg(:,k)).*(wtgbase./genbasmva_wtg)./Vtmagwtg; %confirmar el orden de esta ecuacion
            % Verify limits of Ipcmd
            %*** Type 3 ***%
            Ipcmd_wtg( (Ipcmd_wtg>=Ipmaxwtg) & ixwtg3 ) = Ipmaxwtg((Ipcmd_wtg>=Ipmaxwtg)&ixwtg3);
            %*** ------ ***%
            [IQmn, IQmx, Ipmx, Iqmxv] = ConvCurrenLimit(k,Ipcmd_wtg,Vtmagwtg,Qmaxwtg,Iqhlwtg,Iphlwtg,pqflagwtg);
            % Verify limits of Ipcmd
            %*** Type 4 ***%
            Ipcmd_wtg( (Ipcmd_wtg>=Ipmx) & ixwtg4 ) = Ipmx( (Ipcmd_wtg>=Ipmx) & ixwtg4 );
            %*** ------ ***%
            % Verify limits of IQcmd_wtg
            %*** Type 4 ***%
            ixIQmx = IQcmd_wtg(ixwtg4,k)>= IQmx(ixwtg4,1);
            IQcmd_wtg(ixIQmx,k) = IQmx(ixIQmx);
            ixIQmn = IQcmd_wtg(ixwtg4,k)<= IQmn(ixwtg4,1);
            IQcmd_wtg(ixIQmn,k) = IQmn(ixIQmn);
            %*** ------ ***%

%             if any(ixIQmn)||any(ixIQmx)
%                 disp('IQ lim  on')
%             end
            
            %*** Type 4 ***%
            Eerrdbr_wtg = Edbr_wtg(:,k) - EBSTwtg;
            Eerrdbr_wtg(Eerrdbr_wtg < 0) = 0;
            dEdbr_wtg(:,k) = Pord_wtg(:,k) + dpwiwtg - Pelecwtg - Kdbrwtg.*Eerrdbr_wtg;
            dEdbr_wtg(dEdbr_wtg(:,k) >= 1, k) = 1; % diagram of dbr on Figure 5-2. pag 5.4 GE report v.4.5
            dEdbr_wtg(dEdbr_wtg(:,k) <= 0, k) = 0; % diagram of dbr on Figure 5-2. pag 5.4 GE report v.4.5
            Pdbr = dEdbr_wtg(:,k);
            %*** Type 3 ***%
            % correcting for Type 3
            Pdbr(ixwtg3) = 0; % setting this signal to 0 for Type 3
            %*** ------ ***%
%**************************** -Two mass model- ***************************%
            %nmass2idx = nmasswtg == 2;
% %             dwgSV_wtg(nmass2idx,k) = (1/(2*Hgwtg)).*(-Pelecwtg./wg_wtg - Dtgwtg.*(wgSV_wtg(:,k) - wtSV_wtg(:,k)) - Ktgwtg.*(delg_wtg(:,k) - delt_wtg(:,k) + delg0_wtg)); % DUDA
%             dwgSV_wtg(:,k) = (1./(2*Hgwtg)).*(-(Pelecwtg + Pdbr)./wg_wtg - Dtgwtg.*(wgSV_wtg(:,k) - wtSV_wtg(:,k)) - Ktgwtg.*(delg_wtg(:,k) - delt_wtg(:,k) + delg0_wtg)); % DUDA - changed for both type 3 and type 4
%             dwtSV_wtg(:,k) = (1./(2*Hwtg)).*(Pmechwtg./wt_wtg + Dtgwtg.*(wgSV_wtg(:,k) - wtSV_wtg(:,k)) + Ktgwtg.*(delg_wtg(:,k) - delt_wtg(:,k) + delg0_wtg)); % DUDA
%             
%             ddelg_wtg(:,k) = Wbase.*wgSV_wtg(:,k);
%             ddelt_wtg(:,k) = Wbase.*wtSV_wtg(:,k);
            dwgSV_wtg(:,k) = (1./(2*Hgwtg)).*(-(Pelecwtg + Pdbr)./wg_wtg - Dtgwtg.*(wgSV_wtg(:,k) - wtSV_wtg(:,k)) - Ktgwtg.*(delgt_wtg(:,k) + delg0_wtg)); % DUDA - changed for both type 3 and type 4
            dwtSV_wtg(:,k) = (1./(2*Hwtg)).*(Pmechwtg./wt_wtg + Dtgwtg.*(wgSV_wtg(:,k) - wtSV_wtg(:,k)) + Ktgwtg.*(delgt_wtg(:,k) + delg0_wtg)); % DUDA
            
            ddelgt_wtg(:,k) = Wbase.*(wgSV_wtg(:,k) - wtSV_wtg(:,k));

%**************************** -One mass model- ***************************%
            nmass1idx = nmasswtg == 1;
            dwtSV_aux = (1./(2*Hwtg.*wt_wtg)).*(Pmechwtg - (Pelecwtg + Pdbr)); % DUDA
            dwtSV_wtg(nmass1idx,k) = dwtSV_aux(nmass1idx,1);
%**************************** ---------------- ***************************%
            werr_wtg_k = wg_wtg - wref_wtg(:,k);
            werrth_wtg_k = werr_wtg_k + wth_sig_wtg(:,k);
            werrT_wtg_k = werr_wtg_k + wT_sig_wtg(:,k);
            Perr_wtg_k = Pord_wtg(:,k) - Pset_wtg + Pth_sig_wtg(:,k);
            
            ddelerr1_wtg(:,k) = Kipwtg.*(werrth_wtg_k); % DUDA 
            ddelerr2_wtg(:,k) = Kitrqwtg.*(werrT_wtg_k); % DUDA
            dEerr_wtg(:,k) = Kicwtg.*(Perr_wtg_k);
            
            dth_wtg(:,k) = (1./Tpwtg).*(-th_wtg(:,k) + Kppwtg.*(werrth_wtg_k) + delerr1_wtg(:,k) + Kpcwtg.*(Perr_wtg_k) + Eerr_wtg(:,k) + th_sig_wtg(:,k));
            sigpru2_wtg(:,k) = Kppwtg.*(werrth_wtg_k) + delerr1_wtg(:,k);
            sigpru3_wtg(:,k) = Kpcwtg.*(Perr_wtg_k) + Eerr_wtg(:,k);
            sigpru4_wtg(:,k) = Kptrqwtg.*(werrT_wtg_k) + delerr2_wtg(:,k);
            dPord_wtg(:,k) = (1./Tpcwtg).*( -Pord_wtg(:,k) + wg_wtg.*( Kptrqwtg.*(werrT_wtg_k) + delerr2_wtg(:,k) + T_sig_wtg(:,k) ) );
            
            dwref_wtg(:,k) = (1/5).*(1.2 - wref_wtg(:,k));
            ixaux_1 = ((Pg_wtg + Pdbr) <= (0.46 + 1e-12))&(wrefmodwtg == 1);
            dwrefx_1 = (1/5).*(-0.75*(Pg_wtg + Pdbr).^2 + 1.59*(Pg_wtg + Pdbr) + 0.63 - wref_wtg(:,k));
            ixaux_2 = ((Pg_wtg + Pdbr) <= (0.75 + 1e-12))&(wrefmodwtg == 2);
            dwrefx_2 = (1/5).*((-0.67*(Pg_wtg + Pdbr) + 1.42 ).*(Pg_wtg + Pdbr) + 0.51 - wref_wtg(:,k));
            
            dwref_wtg(ixaux_1,k) = dwrefx_1(ixaux_1);
            dwref_wtg(ixaux_2,k) = dwrefx_2(ixaux_2);
            
            % dx0_wtg(:,k) = (1./Tddelwtg).*(Efd_wtg(:,k) - x0_wtg(:,k)); % duda type 4
            %*** Type 3 ***%
            dx0_wtg(ixwtg3,k) = (1./Tddelwtg(ixwtg3,1)).*(Efd_wtg(ixwtg3,k) - x0_wtg(ixwtg3,k) + x0_sig_wtg(ixwtg3,k));
            %*** Type 4 ***%
            dx0_wtg(ixwtg4,k) = (1./Tddelwtg(ixwtg4,1)).*(IQcmd_wtg(ixwtg4,k) - x0_wtg(ixwtg4,k) + x0_sig_wtg(ixwtg4,k));
            %*** ------ ***%
            
            dx1_wtg(:,k) = (1./Tddelwtg).*(Ipcmd_wtg - x1_wtg(:,k) + Ip_sig_wtg(:,k));
            %*** LPVL ramp rate ***%
            ixlvplr = ( (lvplflgwtg == 1) & (dx1_wtg(:,k)) > rrpwrwtg );
            dx1_wtg(ixlvplr,k) = rrpwrwtg(ixlvplr,1);
            %*** -------------- ***%
            
            dVlvpl_wtg(:,k)  = (1./Tddelwtg).*(Vtmagwtg - Vlvpl_wtg(:,k));
            
            
%             dgam_wtg(:,k) = Kpllpwtg.*( Vtimwtg.*cos(gam_wtg(:,k)) - Vtrewtg.*sin(gam_wtg(:,k)) );
            dgam_wtg(:,k) = Kpllpwtg.*( Vtmagwtg.*sin(Vtangwtg - gam_wtg(:,k)) );            
            dgam_wtg(:,k) = dgam_wtg(:,k)/377;
            dgam_wtglim = 0.1;
            ixdgammx = dgam_wtg(:,k) >= dgam_wtglim;
            ixdgammn = dgam_wtg(:,k) <= -dgam_wtglim;
            dgam_wtg(ixdgammx,k) = dgam_wtglim;
            dgam_wtg(ixdgammn,k) = -dgam_wtglim;
            dgam_wtg(:,k) = dgam_wtg(:,k)*377;

            dRerr_wtg(:,k) = kQiwtg.*( Qset_wtg(:,k) - Qg_wtg  + QQ_sig_wtg(:,k) );
            ixRerrmx = Rerr_wtg(:,k) >= Vmaxcwtg;
            ixRerrmn = Rerr_wtg(:,k) <= Vmincwtg;
            Rerr_wtg( ixRerrmx,k ) = Vmaxcwtg( ixRerrmx,1 ); % not in simulink model
            Rerr_wtg( ixRerrmn,k ) = Vmincwtg( ixRerrmn,1 ); % not in simulink model
            dRerr_wtg(ixRerrmx,k) = 0;
            dRerr_wtg(ixRerrmn,k) = 0;
            
            %*** Type 3 ***%
            dEfd_wtg(ixwtg3,k) =  kViwtg(ixwtg3,1).*( Rerr_wtg(ixwtg3,k) - Vtmagwtg(ixwtg3,1) + Vt_sig_wtg(ixwtg3,1));
            %*** ------ ***%
            %*** Type 4 ***%
            dIQcmd_wtg(ixwtg4,k) = kViwtg(ixwtg4,1).*( Rerr_wtg(ixwtg4,k) - Vtmagwtg(ixwtg4,1) + Vt_sig_wtg(ixwtg4,1));
            %*** ------ ***%

%             %*** Type 3 ***%
%             Iinj = x0_wtg(:,k)./Lppwtg;
%             %*** Type 4 ***%
%             % correcting for type 4
%             Iinj(ixwtg4) = x0_wtg(ixwtg4,k);
%             
%             Isrewtg = x1_wtg(:,k).*cos(gam_wtg(:,k)) + Iinj.*(sin(gam_wtg(:,k)));
%             Isimwtg = -Iinj.*cos(gam_wtg(:,k)) + x1_wtg(:,k).*(sin(gam_wtg(:,k)));
%             Iswtg(:,k+1) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva); % CONFIRM k+1
            
            
            % Verify limits of dtheta/dt (pitch angle)
            %thrate = 10;  %line 205 asyst5_init (maximum pitch rate) 
            ixdth = dth_wtg(:,k)>=(thratemx);
            dth_wtg(ixdth,k) = thratemx(ixdth);
            ixdth = dth_wtg(:,k)<(thratemn);
            dth_wtg(ixdth,k) = thratemn(ixdth);
            
            % Verify limits of theta (pitch angle) - when it hits the lower
            % bound
            % ixthmn = th_wtg(:,k)<=(thminwtg+5*eps);
            th_wtg(ixthmn,k) = thminwtg(ixthmn);
            ix_dth = (dth_wtg(:,k)<0+2*eps);
            %dth_wtg(ix_dth,k) = zeros(length(ix_dth),1);
            % zaux = zeros(length(ix_dth),1);
            dth_wtg(ix_dth & ixthmn,k) = 0; % zaux(ix_dth);
%             ddelerr1_wtg(ix_dth & ixthmn,k) = 0; % zaux(ix_dth);
%             dEerr_wtg(ix_dth & ixthmn,k) = 0; % zaux(ix_dth);
            % New dec 2014
            ix_delerr1 = sigpru2_wtg(:,k)<0;
            ix_Eerr = sigpru3_wtg(:,k)<0;
            ddelerr1_wtg(ix_delerr1 & ixthmn,k) = 0; % zaux(ix_dth);
            dEerr_wtg(ix_Eerr & ixthmn,k) = 0; % zaux(ix_dth);
            
            
            if size(wtg_con,2)>75 % new control should be turned of when pitch angle reaches its min
                dfst1_wtg(ix_dth & ixthmn & ixfcwtg1,k) = 0;
            end
            
            % Verify limits of theta (pitch angle) - when it hits the upper
            % bound
            ixthmx = th_wtg(:,k)>=thmaxwtg;
            th_wtg(ixthmx,k) = thmaxwtg(ixthmx);
            ix_dth = (dth_wtg(:,k)>=0); % ??
            dth_wtg(ix_dth & ixthmx,k) = 0; % ??
            
            % Verify limits of dPord/dt
            % Pordrate = 0.45;  %line 205 asyst5_init (maximum pitch rate) 
            ixdPord =  dPord_wtg(:,k)>(Pordratemx);
            dPord_wtg(ixdPord,k) = (Pordratemx(ixdPord));
            ixdPord  = dPord_wtg(:,k)<(Pordratemn);
            dPord_wtg(ixdPord,k) = Pordratemn(ixdPord);
            
%             Pordminwtg = 0.10; % line 207 asyst5_init (maximum power)
%             Pordmaxwtg = 1.12; % line 206 asyst5_init (maximum power)
%             % Verify limits of Pord - when it hits the lower bound
%             ixPordmn = Pord_wtg(:,k)<=Pordminwtg;
%             Pord_wtg(ixPordmn,k) = Pordminwtg;
%             %ix_dPord = (dPord_wtg(ixPordmn,k)<=0);
%             %dPord_wtg(ix_dPord,k) = zeros(length(ix_dPord),1);
%             
%             % Verify limits of Pord - when it hits the upper bound
%             ixPordmx = Pord_wtg(:,k)>=Pordmaxwtg;
%             Pord_wtg(ixPordmx,k) = Pordmaxwtg;
            ix_dPord = (dPord_wtg(:,k)>0)&ixPordmx;
            %dPord_wtg(ix_dPord,k) = zeros(length(ix_dPord),1);
            zaux = zeros(length(ix_dPord),1);
            ddelerr2_wtg(ix_dPord,k) = zaux(ix_dPord);
            
            
            % Verify Efd_wtg % % Verify Efd_wtg - from 'lim_exc_s1.m' in GE model
%             ixdEfmx = (Efd_wtg(:,k) > (Vtmagwtg + xiqmaxwtg));
%             Efd_wtg(ixdEfmx,k) = Vtmagwtg(ixdEfmx,1) + xiqmaxwtg(ixdEfmx,1);
%             ixdEfmn = (Efd_wtg(:,k) < (Vtmagwtg + xiqminwtg));
%             Efd_wtg(ixdEfmn,k) = Vtmagwtg(ixdEfmn,1) + xiqminwtg(ixdEfmn,1); 
            
            % Verify dEfd_wtg % % Verify Efd_wtg - from 'lim_exc_s1.m' in GE model
%             ixdEfdmx = ((Efd_wtg(:,k) >= (Vtmagwtg + xiqmaxwtg)) & (dEfd_wtg(:,k) >= 0));
            toldEfd = 1e-9;
            ixdEfdmx = ((Efd_wtg(:,k) - (Vtmagwtg + xiqmaxwtg) >= -toldEfd) & (dEfd_wtg(:,k) >= 0));
            
            ixdEfdmn = ((Efd_wtg(:,k) - (Vtmagwtg + xiqminwtg) <= toldEfd) & (dEfd_wtg(:,k) <= 0));
            dEfd_wtg(ixdEfdmx,k) = 0;
            dEfd_wtg(ixdEfdmn,k) = 0;     
            
% Back up:
%             ixdEfdmx = ((Efd_wtg(:,k) >= Vtmagwtg + xiqmaxwtg) & (dEfd_wtg(:,k) >= 0));
%             dEfd_wtg(ixdEfdmx,k) = 0;
%             ixdEfdmn = ((Efd_wtg(:,k) <= Vtmagwtg + xiqminwtg) & (dEfd_wtg(:,k) <= 0));
%             dEfd_wtg(ixdEfdmn,k) = 0;            
            
% %             if any(ixdEfdmx)
% %                 disp('P2 on')
% %             elseif any(ixdEfdmn)
% %                 disp('P3 on')
% %             elseif any(dPord_wtg(:,k)>(Pordratemx))
% %                 disp('P4 on')
% %             elseif any(dPord_wtg(:,k)<(Pordratemn))
% %                 disp('P5 on')
% %             elseif any(ixPordmn)
% %                 disp('P6 on')
% %             elseif any(ixPordmx)
% %                 disp('P7 on')
% %             elseif any(dth_wtg(:,k)>=(thratemx))
% %                 disp('P8 on')
% %             elseif any(dth_wtg(:,k)<(thratemn))
% %                 disp('P9 on')
% %             end

%             if any(ixdgammx)
%                 disp('gammx on')
%             elseif any(ixdgammn)
%                 disp('gammn on')
%             end

            bus_new = bus;
            
            Pgv_wtg(:,k) = Pg_wtg; Qgv_wtg(:,k) = Qg_wtg;
            Ipcmdv_wtg(:,k) = Ipcmd_wtg; Pmechv_wtg(:,k) = Pmechwtg;
            Ipmxv_wtg(:,k) = Ipmx; Iqmxv_wtg(:,k) = IQmx; Iqxv_wtg(:,k) = Iqmxv;
            Vrfq_wtg(ixvarglaf_p1_2,k) = Vrfq; Vreg_wtg(ixvarglaf_p1_2,k) = Vreg;
        end
    
            

   
    end
end

function cp = cp_det(lambda,theta)
% taken from the cp_init.m function of the GE simulink model

u(1) = lambda;
u(2) = theta;
lm1 = u(1);
lm2 = lm1*u(1);
lm3 = lm2*u(1);
lm4 = lm3*u(1);
lambda_vec = [1 lm1 lm2 lm3 lm4].';

th1 = u(2);
th2 = th1*u(2);
th3 = th2*u(2);
th4 = th3*u(2);
theta_vec = [1 th1 th2 th3 th4].';

coeff = [-4.1909e-001  2.1808e-001 -1.2406e-002 -1.3365e-004  1.1524e-005;
	 -6.7606e-002  6.0405e-002 -1.3934e-002  1.0683e-003 -2.3895e-005;
	  1.5727e-002 -1.0996e-002  2.1495e-003 -1.4855e-004  2.7937e-006;
	 -8.6018e-004  5.7051e-004 -1.0479e-004  5.9924e-006 -8.9194e-008;
	  1.4788e-005 -9.4839e-006  1.6167e-006 -7.1535e-008  4.9686e-010 ];

cp = sum( ( coeff*lambda_vec ).*theta_vec );


% function Pordext_wtg = windINERTIAf(flag,k, wtg_ix, wtg_idx2)
      
function [IQmn, IQmx, Ipmx, Iqmxv] = ConvCurrenLimit(k,Ipcmd_wtg,Vtmagwtg,Qmaxwtg,Iqhlwtg,Iphlwtg,pqflagwtg)
    global IQcmd_wtg    
    ixq  = pqflagwtg == 0;
    ixp  = pqflagwtg == 1;
    
    IQmn = zeros(length(pqflagwtg),1); IQmx = IQmn; Ipmx = IQmn;
    
    ImaxTD = 1.7; % pag 5.3 GE report v4.5
    Iqmxv = ((Qmaxwtg - 1.6)/1.0).*Vtmagwtg + 1.6;
    Iqsal = min([Iqhlwtg Iqmxv],[],2);
    
    % Q priority
    Iaux = min(Iqsal,ImaxTD);
    IQmn(ixq) = -Iaux(ixq);
    IQmx(ixq) = Iaux(ixq);
    
    Imq = sqrt(ImaxTD.^2 - IQcmd_wtg(:,k).^2);
    Iaux = min([Imq Iphlwtg],[],2);
    Ipmx(ixq) = Iaux(ixq);
    
    % P priority
    Imp = sqrt(ImaxTD.^2 - Ipcmd_wtg.^2);
    Iaux = min([Imp Iqsal],[],2);
    IQmn(ixp) = -Iaux(ixp);
    IQmx(ixp) = Iaux(ixp);
    
    Iaux = min(Iphlwtg, ImaxTD);
    Ipmx(ixq) = Iaux(ixq);
    
    if isempty(IQmx)
        IQmx=nan;
    end
    if isempty(IQmn)
        IQmn=nan;
    end
    if isempty(Ipmx)
        Ipmx=nan;
    end
