function [bus_new] = wtg(i,k,bus,flag)
% BACK UP ON 7/14/2013 - CHANGE Iswtg calculation
% Syntax: [bus_new] = wtg(i,k,bus,flag)
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
global  basmva bus_int bus_v bus_freq

% Wind Power Plant (wtg) Variables
global wtg_con n_wtg wtg_idx wtg_idx2 vw_wtg
global w0_wtg Pset_wtg Iswtg delg0_wtg Kpwtg Pgv_wtg Qgv_wtg Ipcmdv_wtg Pmechv_wtg % since Kp is fudged
global Ipmxv_wtg Iqmxv_wtg Iqxv_wtg

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

bus_new = bus;
if ~isempty(wtg_con)
    if flag == 0 % initialization
        if i~=0
            %later
        else
            wtg_ix = 1:n_wtg;
%             wtg_ix2 = wtg_con(:,2); % bus number
            
            ixwtg3 = wtg_con(:,3) == 3;
            ixwtg4 = wtg_con(:,3) == 4;

            wtgbase = wtg_con(wtg_ix,4); % Base MVA of the wtg. 162 for the GE model
            genbasmva_wtg = wtg_con(wtg_ix,5);
            Qmaxwtg = wtg_con(wtg_ix,8);
            Qminwtg = wtg_con(wtg_ix,9);
            Klwtg = wtg_con(wtg_ix,10); %****mirar donde lo voy a poner
            Kpwtg = wtg_con(wtg_ix,11);
            
            Dtgwtg = wtg_con(wtg_ix,13);
            Hwtg = wtg_con(wtg_ix,14);
            Ktgwtg = wtg_con(wtg_ix,16);
            Kipwtg = wtg_con(wtg_ix,18);
            Kppwtg = wtg_con(wtg_ix,19);
            Kicwtg = wtg_con(wtg_ix,20);
            Kpcwtg = wtg_con(wtg_ix,21);
            Kitrqwtg = wtg_con(wtg_ix,22);
            Kptrqwtg = wtg_con(wtg_ix,23);
            Lppwtg = wtg_con(wtg_ix,33); % Type 3 (apparently)
            Kpllpwtg = wtg_con(wtg_ix,34);
            Tddelwtg = wtg_con(wtg_ix,35);
            
            EBSTwtg = wtg_con(wtg_ix,47); % Type 4
            
            varflag = wtg_con(wtg_ix,52);
            Vregbuswtg = wtg_con(wtg_ix,53);
            
            Kpvwtg = wtg_con(wtg_ix,56);
            Kivwtg = wtg_con(wtg_ix,57);
            Kqdwtg = wtg_con(wtg_ix,61);
            
            vw_wtg_0 = vw_wtg(:,1); %%*** definir despues
            
            rpp = 0; %por el momento
            xpp = Lppwtg*basmva./genbasmva_wtg;
            zpp = rpp +1i*xpp;
            % From loadflow:
            Vtwtg = bus(wtg_idx2,2).*exp(1i*bus(wtg_idx2,3)*pi/180); %Cambioindx
            Vtmagwtg = abs(Vtwtg);
            Vtangwtg = angle(Vtwtg);
            Vtrewtg = real(Vtwtg);
            Vtimwtg = imag(Vtwtg);
            Izpp = Vtwtg./zpp;
            Szpp = Vtmagwtg.^2./conj(zpp);
            
            Plf = bus(wtg_idx2,4); Qlf = bus(wtg_idx2,5);
           
            %*** Type 3  ***%               
            Pset_wtg  = (Plf - real(Szpp)).*(basmva./wtgbase);%Cambioindx
            %*** Type 4  ***%               
            Pset_wtg(ixwtg4) = Plf(ixwtg4).*(basmva./wtgbase(ixwtg4));
            %*** ------  ***% 
            
            Pg_wtg = Pset_wtg;
            Qg_wtg = Qset_wtg(:,1); % PUEDE ESTAR MAL POR GEN_base hacer seguimiento a esas señales

            if any(Pset_wtg ~= 1)
                disp('Set power is not equal to the rated power of the Wind Turbine')
                Pset_wtg(:) = 1;
            end
           
            %*** Type 3  ***%             
            Qset_wtg(:,1)  = (Qlf - imag(Szpp)).*(basmva./genbasmva_wtg);
            %*** Type 4  ***% 
            Qset_wtg(ixwtg4,1)  = Qlf(ixwtg4).*(basmva./genbasmva_wtg(ixwtg4));

            
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
            Qinput = 0;
            
            Vrfq = bus(bus_int(Vregbuswtg),2); % reference voltage magnitute from LF - checked in xxx--
            Vrfq = Vrfq(ixvarglaf_p1,1); % reference voltage taken from the load flow
            Vreg = bus(bus_int(Vregbuswtg),2); % Voltage to regulate is defined by user (from LF to initialize)
            Vreg = Vreg(ixvarglaf_p1,1);
            
            s7_wtg(ixvarglaf_p1,1) = Qinput;
            s3_wtg(ixvarglaf_p1,1) = Vreg;
            Vqd = Kqdwtg(ixvarglaf_p1,1).*s7_wtg(ixvarglaf_p1,1); % Figure 4-5 GE report v4.5
            s2_wtg(ixvarglaf_p1,1) = 0;
            % Qset_wtg(ixvarglaf_p1,1) as before
            s4_wtg(ixvarglaf_p1,1) = (Qset_wtg(ixvarglaf_p1,1) - Kpvwtg(ixvarglaf_p1,1).*s2_wtg(ixvarglaf_p1,1))./Kivwtg(ixvarglaf_p1,1);
%*************** ----------------------------------------- ***************%

            Pmechwtg = Pg_wtg;
            Pelecwtg = Pg_wtg; 
            Pord_wtg(:,1) = Pg_wtg; % Pord_wtg(:,1) = Pset_wtg; % OJO - INITIALIZATION and CONSTANT
            
            % Determine generator speed 
            wref_wtg(:,1) = 1.2 * ones(n_wtg,1);
            ixaux = find(Pmechwtg <= 0.75);
            wrefx = (-0.67*Pmechwtg + 1.42 ).*Pmechwtg + 0.51;
            wref_wtg(ixaux,1) = wrefx(ixaux);
            w0_wtg = wref_wtg(:,1); 
            
            wgSV_wtg(:,1) = 0; % is the deviation with respect to w0
            wtSV_wtg(:,1) = 0; % is the deviation with respect to w0
            
            wg_wtg = w0_wtg + wgSV_wtg(:,k); 
            wt_wtg = w0_wtg + wtSV_wtg(:,k); 
            

%************************** -Pwind determination- ************************%
            % Determine lambda given a wind speed
            lam_wtg = Klwtg.*wt_wtg./vw_wtg_0;
            
            % The two dimensional Cp approximation is only valid for lambda
            % between 3 and 15. Page 4.19 GE report.
            lam_max = 15;
            lam_min = 3;
            if any(find(lam_wtg>lam_max))
                disp('Lambda Above limits for a wtg') % this will prompt an error later
                return
            end
            if any(find(lam_wtg<lam_min))
                disp('Lambda below limits for a wtg') % this will prompt an error later
                return
            end
            
            % Determine the minimum pitch angle to produce the Pmech (Pelec)having
            % lambda
            for idx = 1:n_wtg
                
                th_min = wtg_con(idx,27);
                th_max = wtg_con(idx,26);
                
                if vw_wtg_0(idx) > 25.0
                    error('Initial wind speed too high')
                end

                cpwtg = cp_det(lam_wtg(idx),th_min);
                Pwindmax = Kpwtg(idx)* cpwtg * vw_wtg_0(idx)^3;
            
                if Pwindmax < Pmechwtg(idx)
                    disp('It is not possible with the initial wind speed to obtain the desired output power')
                    disp('Change either Pset for the WTG in the loadflow or the initial wind speed in the wind profile')
                    error('Output power not feasible with input wind speed')
                end                
                
                cploop = 1;
                th_swp = th_min; % th_swp = (th_max - th_min)/2;
                tol_pwind = 1e-5;                

                while cploop
                    cpwtg = cp_det(lam_wtg(idx),th_swp);
                    Pwind = Kpwtg(idx)* cpwtg * vw_wtg_0(idx)^3;
                    errP = Pwind - Pmechwtg(idx);

                    if errP > tol_pwind % should increase theta to decrease Cp
                        th_min = th_swp;
                        th_swp = (th_max - th_swp)/2 + th_swp;
                    elseif errP < -tol_pwind % should decrease theta
                        th_max = th_swp;
                        th_swp = (th_swp - th_min)/2  + th_min;
                    else
                        cploop = 0;
                    end

                end
                th_wtg(idx,1) = th_swp;
                Kpwtg(idx) = Pmechwtg(idx)./(cpwtg * vw_wtg_0(idx)^3); % Fudging Kp
%                 Pwind = Kpwtg(idx)* cpwtg * vw_wtg_0(idx)^3;
%                 Pwind - Pmechwtg(idx)             
            end
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
            
            %*** Type 3  ***%
            Isrewtg  = x1_wtg(:,1).*Vtrewtg./Vtmagwtg + (Vtimwtg./Lppwtg).*x0_wtg(:,1)./Vtmagwtg;
            Isimwtg  = x1_wtg(:,1).*Vtimwtg./Vtmagwtg - (Vtrewtg./Lppwtg).*x0_wtg(:,1)./Vtmagwtg;
            %*** Type 4  ***% 
            % correcting for Type 4            
            Isrewtg(ixwtg4) = x1_wtg(ixwtg4,1).*Vtrewtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1) + Vtimwtg(ixwtg4,1).*x0_wtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1);
            Isimwtg(ixwtg4) = x1_wtg(ixwtg4,1).*Vtimwtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1) - Vtrewtg(ixwtg4,1).*x0_wtg(ixwtg4,1)./Vtmagwtg(ixwtg4,1);
            %*** ------ ***%
            
            Iswtg(:,1) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva); % CONFIRM
            
            windINERTIAf(flag,k, wtg_ix, wtg_idx2);
            
            Pgv_wtg(:,1) = Pg_wtg; Qgv_wtg(:,1) = Qg_wtg;
            Ipcmd_wtg = Pord_wtg(:,1).*(wtgbase./genbasmva_wtg)./Vtmagwtg;
            Ipcmdv_wtg(:,1) = Ipcmd_wtg; Pmechv_wtg(:,1) = Pmechwtg;
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
            genbasmva_wtg = wtg_con(wtg_ix,5);
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
            PFArefwtg = wtg_con(wtg_ix,66); % OJO ver que si es consistente
%             wINIflagwtg = wtg_con(wtg_ix,67);
%             Kwiwtg = wtg_con(wtg_ix,68);
%             dbwiwtg = wtg_con(wtg_ix,69);
%             Tlpwiwtg = wtg_con(wtg_ix,70);
%             Twowiwtg = wtg_con(wtg_ix,71);
            
            

            
            vw_wtgk = vw_wtg(:,k);
            % sensing voltage
            % Vtwtg = bus_v(wtg_idx,k);
            Vtwtg = bus_v(wtg_idx2,k);
            Vtmagwtg = abs(Vtwtg);
            Vtangwtg = angle(Vtwtg);
            Vtrewtg = real(Vtwtg);
            Vtimwtg = imag(Vtwtg);
            
            Iswtgk = Iswtg(:,k);
            % Itwtgk = Itwtg(:,k);
            
            Swtg = Vtwtg.*conj(Iswtgk); % CONFIRMAR CONSTANTE
            % Swtg = Vtwtg.*conj(Itwtgk);
               
            rpp = 0; %por el momento
            xpp = Lppwtg*basmva./genbasmva_wtg;
            zpp = rpp +1i*xpp;
            Izpp = Vtwtg./zpp;
            Szpp = Vtmagwtg.^2./conj(zpp);
            
            %*** Type 3 ***%         
            Pg_wtg = (real(Swtg) - real(Szpp)).*(basmva./wtgbase);
            Qg_wtg = (imag(Swtg) - imag(Szpp)).*(basmva./genbasmva_wtg);            
            %*** Type 4 ***%
            Pg_wtg(ixwtg4) = real(Swtg(ixwtg4)).*(basmva./wtgbase(ixwtg4));
            Qg_wtg(ixwtg4) = imag(Swtg(ixwtg4)).*(basmva./genbasmva_wtg(ixwtg4));
            %*** ------ ***%
            
            Pelecwtg = Pg_wtg; % ACA HAY UNA CONSTANTE POR DEFINIR
            
            % Verify Efd_wtg - from 'lim_exc_s1.m' in GE model
            ixdEfmx = (Efd_wtg(:,k) > (Vtmagwtg + xiqmaxwtg));
            Efd_wtg(ixdEfmx,k) = Vtmagwtg(ixdEfmx,1) + xiqmaxwtg(ixdEfmx,1);
            ixdEfmn = (Efd_wtg(:,k) < (Vtmagwtg + xiqminwtg));
            Efd_wtg(ixdEfmn,k) = Vtmagwtg(ixdEfmn,1) + xiqminwtg(ixdEfmn,1);           

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
            
            %*** LPVL level limit ***%
            lvplmax = 1.22;
            lvpl = lvplmax./(brkptwtg -zeroxwtg).*Vlvpl_wtg(:,k) + lvplmax.*zeroxwtg./(zeroxwtg - brkptwtg);
            lvpl(lvpl<=0) = 0;
            lvpl(lvpl>=lvplmax) = lvplmax;
            
            ixlvpl = ( (lvplflgwtg == 1) & (x1_wtg(:,k) > lvpl) );
            x1_wtg(ixlvpl,k) = lvpl(ixlvpl,1);
            %*** -------------- ***%
            
            %*** Frequency control ***%
            Pordext_wtg = windINERTIAf(flag,k, wtg_ix, wtg_idx2);
            %*** ----------------- ***% 

            %*** Reactive Power Control ***%
            % if varflag == -1 % case when Qord is held constant
            ixvarglaf_m1 = varflag == -1;
            dQset_wtg(ixvarglaf_m1,k) = 0;
            % if varflag == 0 % case when it follows PF control           
            ixvarglaf_0 = varflag == 0;
            ds6_wtg(ixvarglaf_0,k) = (1./Tpwrwtg(ixvarglaf_0,1)).*(Pg_wtg(ixvarglaf_0,1) - s6_wtg(ixvarglaf_0,k)); 
            Qset_wtg(ixvarglaf_0,k) = s6_wtg(ixvarglaf_0,k).*tan(PFArefwtg(ixvarglaf_0,1)); % SEE IT IS NOT OVERRIDED BY s_simu
            % if varflag == 1 % case when it follows Voltage regulation
            ixvarglaf_p1 = varflag == 1;
            Vrfq = abs( bus_v(bus_int(Vregbuswtg),1) ); % reference voltage - checked in xxx--
            Vrfq = Vrfq(ixvarglaf_p1,1); % reference voltage taken from the load flow
            Vqd = Kqdwtg(ixvarglaf_p1,1).*s7_wtg(ixvarglaf_p1,k); % Figure 4-5 GE report v4.5
            Vreg = abs( bus_v(bus_int(Vregbuswtg),k) ); % Voltage to regulate is defined by user
            Vreg = Vreg(ixvarglaf_p1,1);
            ds3_wtg(ixvarglaf_p1,k) = (1./Trwtg(ixvarglaf_p1,1)).*(Vreg - s3_wtg(ixvarglaf_p1,k));
            
            % Limit the signal to be less than Vermx and more than Vermn:
            saux_rpc = Vrfq - s3_wtg(ixvarglaf_p1,k) - Vqd;
            ixsaux = saux_rpc <= Vermnwtg(ixvarglaf_p1,1);
            saux_rpc(ixsaux) = Vermnwtg(ixsaux);
            ixsaux = saux_rpc >= Vermxwtg(ixvarglaf_p1,1);
            saux_rpc(ixsaux) = Vermxwtg(ixsaux);
            ds2_wtg(ixvarglaf_p1,k) = (1./Tvwtg(ixvarglaf_p1,1)).*( (1./fNwtg(ixvarglaf_p1,1)).*saux_rpc - s2_wtg(ixvarglaf_p1,k) );
            ds4_wtg(ixvarglaf_p1,k) = (1./fNwtg(ixvarglaf_p1,1)).*saux_rpc;
            
            % Freeze 2 integrators if  <Vfrz
            ixVfrz = Vreg < Vfrzwtg(ixvarglaf_p1,1);
            ds2_wtg(ixVfrz,k) = 0; ds4_wtg(ixVfrz,k) = 0;
            
            % dQset - verifing limits of the reference signal
            saux2_rpc = Kivwtg(ixvarglaf_p1,1).*s4_wtg(ixvarglaf_p1,k) + Kpvwtg(ixvarglaf_p1,1).*s2_wtg(ixvarglaf_p1,k);
            ixsaux2 = saux2_rpc >= Qmaxwtg(ixvarglaf_p1,1);
            saux2_rpc(ixsaux2) = Qmaxwtg(ixsaux2);
            ixsaux2 = saux2_rpc <= Qminwtg(ixvarglaf_p1,1);
            saux2_rpc(ixsaux2) = Qminwtg(ixsaux2);
            dQset_wtg(ixvarglaf_p1,k) = (1./Tcwtg(ixvarglaf_p1,1)).*(saux2_rpc  - Qset_wtg(ixvarglaf_p1,k) );
            
            Qinput = 0; % FIGURE OUT what is this (page 4.9 GE report v4.5)
            ds7_wtg(ixvarglaf_p1,k) = (1./Tlpqdwtg(ixvarglaf_p1,1)).*(s7_wtg(ixvarglaf_p1,k) - Qinput);
            %*** ---------------------- ***%

            %*** Verify limits for Qset ***%
            % To do list
            Qset_wtg(Qset_wtg(:,k) >= Qmaxwtg,k) = Qmaxwtg(Qset_wtg(:,k) >= Qmaxwtg);
            Qset_wtg(Qset_wtg(:,k) <= Qminwtg,k) = Qminwtg(Qset_wtg(:,k) <= Qminwtg);
            %*** ---------------------- ***%
            
%**************************** -Two mass model- ***************************%            
            wg_wtg = w0_wtg + wgSV_wtg(:,k); % DUDA en la linealizacion y obtencion de w0
            wt_wtg = w0_wtg + wtSV_wtg(:,k); % DUDA en la linealizacion y obtencion de w0
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
            end
            
            for ix = 1:n_wtg
                cpwtg(ix) = cp_det(lam_wtg(ix),th_wtg(ix,k));
            end
            
            Pmechwtg = Kpwtg.* cpwtg .* vw_wtgk.^3; % remember Kpwtg was fudged at initialization
            % verify limits of Pmech - later
            
%             Ipcmd_wtg = Pord_wtg(:,k).*(wtgbase./genbasmva_wtg)./Vtmagwtg; %confirmar el orden de esta ecuacion       
            Ipcmd_wtg = Pordext_wtg.*(wtgbase./genbasmva_wtg)./Vtmagwtg; %confirmar el orden de esta ecuacion
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


            
            
            %*** Type 4 ***%
            Eerrdbr_wtg = Edbr_wtg(:,k) - EBSTwtg;
            Eerrdbr_wtg(Eerrdbr_wtg < 0) = 0;
            dEdbr_wtg(:,k) = Pordext_wtg - Pelecwtg - Kdbrwtg.*Eerrdbr_wtg;
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

            ddelerr1_wtg(:,k) = Kipwtg.*(wg_wtg - wref_wtg(:,k)); % DUDA 
            ddelerr2_wtg(:,k) = Kitrqwtg.*(wg_wtg - wref_wtg(:,k)); % DUDA
            dEerr_wtg(:,k) = Kicwtg.*(Pord_wtg(:,k) - Pset_wtg);
            
            dth_wtg(:,k) = (1./Tpwtg).*(-th_wtg(:,k) + Kppwtg.*(wg_wtg - wref_wtg(:,k)) + delerr1_wtg(:,k) + Kpcwtg.*(Pord_wtg(:,k) - Pset_wtg) + Eerr_wtg(:,k));
            dPord_wtg(:,k) = (1./Tpcwtg).*( -Pord_wtg(:,k) + wg_wtg.*( Kptrqwtg.*(wg_wtg - wref_wtg(:,k)) + delerr2_wtg(:,k) ) );
            
            dwref_wtg(:,k) = (1/5).*(1.2 - wref_wtg(:,k));
            ixaux = find( (Pg_wtg + Pdbr) <= 0.75);
            dwrefx = (1/5).*((-0.67*(Pg_wtg + Pdbr) + 1.42 ).*(Pg_wtg + Pdbr) + 0.51 - wref_wtg(:,k));
            dwref_wtg(ixaux,k) = dwrefx(ixaux); %CHECK FOR SYNTAX
            
            % dx0_wtg(:,k) = (1./Tddelwtg).*(Efd_wtg(:,k) - x0_wtg(:,k)); % duda type 4
            %*** Type 3 ***%
            dx0_wtg(ixwtg3,k) = (1./Tddelwtg(ixwtg3,1)).*(Efd_wtg(ixwtg3,k) - x0_wtg(ixwtg3,k));
            %*** Type 4 ***%
            dx0_wtg(ixwtg4,k) = (1./Tddelwtg(ixwtg4,1)).*(IQcmd_wtg(ixwtg4,k) - x0_wtg(ixwtg4,k));
            %*** ------ ***%
            
            dx1_wtg(:,k) = (1./Tddelwtg).*(Ipcmd_wtg - x1_wtg(:,k));
            %*** LPVL ramp rate ***%
            ixlvplr = ( (lvplflgwtg == 1) & (dx1_wtg(:,k)) > rrpwrwtg );
            dx1_wtg(ixlvplr,k) = rrpwrwtg(ixlvplr,1);
            %*** -------------- ***%
            
            dVlvpl_wtg(:,k)  = (1./Tddelwtg).*(Vtmagwtg - Vlvpl_wtg(:,k));
            
            
            dgam_wtg(:,k) = Kpllpwtg.*( Vtimwtg.*cos(gam_wtg(:,k)) - Vtrewtg.*sin(gam_wtg(:,k)) );
            dgam_wtg(:,k) = dgam_wtg(:,k)/377;
            dgam_wtglim = 0.1;
            ixdgam = dgam_wtg(:,k) >= dgam_wtglim;
            dgam_wtg(ixdgam,k) = dgam_wtglim;
            ixdgam = dgam_wtg(:,k) <= -dgam_wtglim;
            dgam_wtg(ixdgam,k) = -dgam_wtglim;
            dgam_wtg(:,k) = dgam_wtg(:,k)*377;

            dRerr_wtg(:,k) = kQiwtg.*( Qset_wtg(:,k) - Qg_wtg );
%             Rerr_wtg( Rerr_wtg >= Vmaxcwtg ) = Vmaxcwtg( Rerr_wtg >= Vmaxcwtg ); % not in simulink model
%             Rerr_wtg( Rerr_wtg <= Vmincwtg ) = Vmincwtg( Rerr_wtg <= Vmincwtg ); % not in simulink model
            
            %*** Type 3 ***%
            dEfd_wtg(ixwtg3,k) =  kViwtg(ixwtg3,1).*( Rerr_wtg(ixwtg3,k) - Vtmagwtg(ixwtg3,1) );
            %*** ------ ***%
            %*** Type 4 ***%
            dIQcmd_wtg(ixwtg4,k) = kViwtg(ixwtg4,1).*( Rerr_wtg(ixwtg4,k) - Vtmagwtg(ixwtg4,1) );
            %*** ------ ***%

            %*** Type 3 ***%
            Iinj = x0_wtg(:,k)./Lppwtg;
            %*** Type 4 ***%
            % correcting for type 4
            Iinj(ixwtg4) = x0_wtg(ixwtg4,k);
            
            Isrewtg = x1_wtg(:,k).*cos(gam_wtg(:,k)) + Iinj.*(sin(gam_wtg(:,k)));
            Isimwtg = -Iinj.*cos(gam_wtg(:,k)) + x1_wtg(:,k).*(sin(gam_wtg(:,k)));
            Iswtg(:,k+1) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva); % CONFIRM k+1

            % Verify limits of dtheta/dt (pitch angle)
            %thrate = 10;  %line 205 asyst5_init (maximum pitch rate) 
            ixdth = dth_wtg(:,k)>=thratemx;
            dth_wtg(ixdth,k) = thratemx(ixdth);
            ixdth = dth_wtg(:,k)<thratemn;
            dth_wtg(ixdth,k) = thratemn(ixdth);
            
            % Verify limits of theta (pitch angle) - when it hits the lower
            % bound
            ixthmn = th_wtg(:,k)<=(thminwtg+eps);
            th_wtg(ixthmn,k) = thminwtg(ixthmn);
            ix_dth = (dth_wtg(ixthmn,k)<0);
            %dth_wtg(ix_dth,k) = zeros(length(ix_dth),1);
            zaux = zeros(length(ix_dth),1);
            ddelerr1_wtg(ix_dth,k) = zaux(ix_dth);
            dEerr_wtg(ix_dth,k) = zaux(ix_dth);;
            % Verify limits of theta (pitch angle) - when it hits the upper
            % bound
            ixthmx = th_wtg(:,k)>=thmaxwtg;
            th_wtg(ixthmx,k) = thmaxwtg(ixthmx);
            % ix_dth = (dth_wtg(ixthmx,k)>=0); % ??
            % dth_wtg(ix_dth,k) = zeros(length(ix_dth),1); % ??
            
            % Verify limits of dPord/dt
            % Pordrate = 0.45;  %line 205 asyst5_init (maximum pitch rate) 
            ixdPord =  dPord_wtg(:,k)>Pordratemx;
            dPord_wtg(ixdPord,k) = Pordratemx(ixdPord);
            ixdPord  = dPord_wtg(:,k)<Pordratemn;
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
            ix_dPord = (dPord_wtg(ixPordmx,k)>0);
            %dPord_wtg(ix_dPord,k) = zeros(length(ix_dPord),1);
            zaux = zeros(length(ix_dPord),1);
            ddelerr2_wtg(ix_dPord,k) = zaux(ix_dPord);
            
            % Verify dEfd_wtg % % Verify Efd_wtg - from 'lim_exc_s1.m' in GE model
            ixdEfdmx = ((Efd_wtg(:,k) >= (Vtmagwtg + xiqmaxwtg)) & (dEfd_wtg(:,k) >= 0));
            dEfd_wtg(ixdEfdmx,k) = 0;
            ixdEfdmn = ((Efd_wtg(:,k) <= (Vtmagwtg + xiqminwtg)) & (dEfd_wtg(:,k) <= 0));
            dEfd_wtg(ixdEfdmn,k) = 0;     
            
% Back up:
%             ixdEfdmx = ((Efd_wtg(:,k) >= Vtmagwtg + xiqmaxwtg) & (dEfd_wtg(:,k) >= 0));
%             dEfd_wtg(ixdEfdmx,k) = 0;
%             ixdEfdmn = ((Efd_wtg(:,k) <= Vtmagwtg + xiqminwtg) & (dEfd_wtg(:,k) <= 0));
%             dEfd_wtg(ixdEfdmn,k) = 0;            
            
            bus_new = bus;
            
            Pgv_wtg(:,k) = Pg_wtg; Qgv_wtg(:,k) = Qg_wtg;
            Ipcmdv_wtg(:,k) = Ipcmd_wtg; Pmechv_wtg(:,k) = Pmechwtg;
            Ipmxv_wtg(:,k) = Ipmx; Iqmxv_wtg(:,k) = IQmx; Iqxv_wtg(:,k) = Iqmxv;
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


function Pordext_wtg = windINERTIAf(flag,k, wtg_ix, wtg_idx2);
    %** frequency control (windINERTIA)************************************    
    global wtg_con Pord_wtg  bus_freq
    global s1wini_wtg s2wini_wtg 
    global ds1wini_wtg ds2wini_wtg dpwi_wtg

    wINIflagwtg = wtg_con(wtg_ix,67);
    Kwiwtg = wtg_con(wtg_ix,68);
    dbwiwtg = wtg_con(wtg_ix,69);
    Tlpwiwtg = wtg_con(wtg_ix,70);
    Twowiwtg = wtg_con(wtg_ix,71);
    Urlwiwtg = wtg_con(wtg_ix,72);
    Drlwiwtg = wtg_con(wtg_ix,73);
    Pmaxwiwtg = wtg_con(wtg_ix,74);
    Pminwiwtg = wtg_con(wtg_ix,75);
    
    if flag==0
    auxsigwini_wtg = 0; 
    freqrefwtg = bus_freq(wtg_idx2,1); % initial frequency - reference
    busfreq_wtg = bus_freq(wtg_idx2,k);% calculated through freqcalc
    busferr_wtg = freqrefwtg - (busfreq_wtg + auxsigwini_wtg);
    ixwINIfl_1 = wINIflagwtg == 1;
    s1wini_wtg(ixwINIfl_1,1) = busferr_wtg(ixwINIfl_1,1);
    s2wini_wtg(ixwINIfl_1,1) = Twowiwtg(ixwINIfl_1,1).*Kwiwtg(ixwINIfl_1,1).*s1wini_wtg(ixwINIfl_1,k);   
    end
    
    if flag==2
    % auxiliary signal normally set to 0 except for test. As stated
    % in the report (v4.5) page 4.26
    auxsigwini_wtg = 0; 
    freqrefwtg = bus_freq(wtg_idx2,1); % verificar que es la system freq
    busfreq_wtg = bus_freq(wtg_idx2,k);% calculated through freqcalc **CONFIRM
  
    % if wINIflagwtg == 0 - windINERTIA disabled
    ixwINIfl_0 = wINIflagwtg == 0;
    dpwiwtg = zeros(length(wINIflagwtg),1);
    dpwiwtg(ixwINIfl_0) = 0;

    % if wINIflagwtg == 1 - windINERTIA enabled
    ixwINIfl_1 = wINIflagwtg == 1;
    busferr_wtg = freqrefwtg - (busfreq_wtg + auxsigwini_wtg);
    ixwINI_ch = (busferr_wtg > dbwiwtg) & ixwINIfl_1;
    Kitrqwtg = 0.05; % pag. 4.26 GE WTG Modeling-V4.5
    Kptrqwtg = 0.5; % pag. 4.26 GE WTG Modeling-V4.5
    Tpcwtg = 4; % pag. 4.26 GE WTG Modeling-V4.5
    
    wtg_con(ixwINI_ch,22) = Kitrqwtg(ixwINI_ch); % PERMANENT Modification
    wtg_con(ixwINI_ch,23) = Kptrqwtg(ixwINI_ch); % PERMANENT Modification
    wtg_con(ixwINI_ch,25) = Tpcwtg(ixwINI_ch); % PERMANENT Modification
    
    ixwINI_ch_e = (busferr_wtg < dbwiwtg) & ixwINIfl_1;
    busferr_wtg(ixwINI_ch_e) = 0;
    
    ds1wini_wtg(ixwINIfl_1,k) = (1./Tlpwiwtg(ixwINIfl_1,1)).*(busferr_wtg(ixwINIfl_1,1) - s1wini_wtg(ixwINIfl_1,k));
    ds2wini_wtg(ixwINIfl_1,k) = Kwiwtg(ixwINIfl_1,1).*s1wini_wtg(ixwINIfl_1,k) - (1./Twowiwtg(ixwINIfl_1,1)).*(s2wini_wtg(ixwINIfl_1,k));
    dpwiwtg(ixwINIfl_1) = ds2wini_wtg(ixwINIfl_1,k);

    
%     Pmaxwiwtg = 0.10; % Table 4-13 Pag.4.27 GE report v4.5
%     Pminwiwtg = 0.0;  % Table 4-13 Pag.4.27 GE report v4.5
    % Verify limits of dpwiwtg - when it hits the lower bound
    ixdpwiwtgmn = dpwiwtg<=Pminwiwtg;
    dpwiwtg(ixdpwiwtgmn) = Pminwiwtg(ixdpwiwtgmn);

    % Verify limits of dpwiwtg - when it hits the upper bound
    ixdpwiwtgmx = dpwiwtg>=Pmaxwiwtg;
    dpwiwtg(ixdpwiwtgmx) = Pmaxwiwtg(ixdpwiwtgmx);

    Pordext_wtg = Pord_wtg(:,k) + dpwiwtg;
    end

    %** end- frequency control (windINERTIA)*******************************
    
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
