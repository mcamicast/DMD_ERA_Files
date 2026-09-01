function [bus_new] = wtg(i,k,bus,flag)
% Syntax: [bus_new] = svc(i,k,bus,flag)
% 07/08/2012
% Purpose: Wind Power Plant Model Type 3. Based on the GE report and the 
% WECC model.
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
global  basmva bus_int bus_v

% wtg variables
global wtg_con n_wtg wtg_idx vw_wtg
global w0_wtg Pset_wtg Iswtg delg0_wtg Kpwtg % since Kp is fudged

global wref_wtg wgSV_wtg wtSV_wtg delg_wtg delt_wtg delerr1_wtg delerr2_wtg
global dwref_wtg dwgSV_wtg dwtSV_wtg ddelg_wtg ddelt_wtg ddelerr1_wtg ddelerr2_wtg

global Eerr_wtg Pord_wtg th_wtg x0_wtg x1_wtg gam_wtg Efd_wtg Rerr_wtg
global dEerr_wtg dPord_wtg dth_wtg dx0_wtg dx1_wtg dgam_wtg dEfd_wtg dRerr_wtg

global Qset_wtg s2_wtg s3_wtg s4_wtg s6_wtg
global dQset_wtg ds2_wtg ds3_wtg ds4_wtg ds6_wtg

global s1wini_wtg s2wini_wtg 
global ds1wini_wtg ds2wini_wtg dpwi_wtg

global bus_freq

bus_new = bus;
if ~isempty(wtg_con)
    if flag == 0 % initialization
        if i~=0
            %later
        else
            wtg_ix = 1:n_wtg;
            wtg_ix2 = wtg_con(:,2); % bus number
            % wtgtype = wtg_con(wtg_ix,3); % confirmar indices con el
            % tipo si es 3 o 4
            wtgbase = wtg_con(wtg_ix,4); % Base MVA of the wtg. 162 for the GE model
            genbasmva_wtg = wtg_con(wtg_ix,5);
            Klwtg = wtg_con(wtg_ix,10); %****mirar donde lo voy a poner
            Kpwtg = wtg_con(wtg_ix,11);
            Dtgwtg = wtg_con(wtg_ix,12);
            Hwtg = wtg_con(wtg_ix,13);
            Ktgwtg = wtg_con(wtg_ix,15);
            Kipwtg = wtg_con(wtg_ix,17);
            Kppwtg = wtg_con(wtg_ix,18);
            Kicwtg = wtg_con(wtg_ix,19);
            Kpcwtg = wtg_con(wtg_ix,20);
            Kitrqwtg = wtg_con(wtg_ix,21);
            Kptrqwtg = wtg_con(wtg_ix,22);
            Lppwtg = wtg_con(wtg_ix,32);
            Kpllpwtg = wtg_con(wtg_ix,33);
            
            varflag = wtg_con(wtg_ix,46);
            
            vw_wtg_0 = vw_wtg(:,1); %%*** definir despues
            
            rpp = 0; %por el momento
            xpp = Lppwtg*basmva./genbasmva_wtg;
            zpp = rpp +1i*xpp;
            % From loadflow:
            Vtwtg = bus(wtg_ix2,2).*exp(1i*bus(wtg_ix2,3)*pi/180); %Cambioindx
            Vtmagwtg = abs(Vtwtg);
            Vtangwtg = angle(Vtwtg);
            Vtrewtg = real(Vtwtg);
            Vtimwtg = imag(Vtwtg);
            Izpp = Vtwtg./zpp;
            Szpp = Vtmagwtg.^2./conj(zpp);
            
            Pset_wtg  = (bus(wtg_ix2,4) - real(Szpp)).*(basmva./wtgbase);%Cambioindx
            % Pset_wtg  = bus(wtg_ix,4).*(basmva./wtgbase);
            
            if varflag == 0 % confirm position
                Qset_wtg(:,1)  = (bus(wtg_ix2,5) - imag(Szpp)).*(basmva./genbasmva_wtg);%Cambioindx
                % Qset_wtg(:,1)  = bus(wtg_ix2,5).*(basmva./genbasmva_wtg);
            elseif varflag == -1
                % later
            elseif varflag == 1
                % later
            else
                disp('Error in Varflag selection')
            end
            Pg_wtg = Pset_wtg;
            Qg_wtg = Qset_wtg(:,1); % PUEDE ESTAR MAL POR GEN_base hacer seguimiento a esas señales

            Pmechwtg = Pg_wtg;
            Pelecwtg = Pg_wtg; 
            Pord_wtg(:,1) = Pset_wtg; %OJO CON LA CONSTANTE DE ACA

            % Determine generator speed 
            wref_wtg(:,1) = 1.2 * ones(n_wtg,1);
            ixaux = find(Pmechwtg <= 0.75);
            wrefx = (-0.67*Pmechwtg + 1.42 ).*Pmechwtg + 0.51;
            wref_wtg(ixaux,1) = wrefx(ixaux);
            w0_wtg = wref_wtg(:,1); %****OJO PENSAR COMO CAMBIAR ESTO - DUDA!!! DUDA!!! en la linalizacion
            
            wgSV_wtg(:,1) = 0;
            wtSV_wtg(:,1) = 0;
            
            wg_wtg = w0_wtg + wgSV_wtg(:,k); % DUDA en la linealizacion y obtencion de w0
            wt_wtg = w0_wtg + wtSV_wtg(:,k); % DUDA en la linealizacion y obtencion de w0
            
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
                
                th_min = wtg_con(idx,26);
                th_max = wtg_con(idx,25);
                cploop = 1;
                th_swp = (th_max - th_min)/2;
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
            
            delerr2_wtg(:,1) = Pset_wtg(:,1)./wref_wtg(:,1);
            delerr1_wtg(:,1) = th_wtg(:,1); %simulink model
            
            Eerr_wtg(:,1) = th_wtg(:,1) - delerr1_wtg(:,1);
            Rerr_wtg(:,1) = Vtmagwtg;
            
            delg_wtg(:,1) = 0; % line 391 onwards asyst5_init
            delt_wtg(:,1) = 0; % line 391 onwards asyst5_init
            delg0_wtg = -Pg_wtg./(Ktgwtg.*w0_wtg(:,1)); % line 391 onwards asyst5_init
            
            x0_wtg(:,1) = Qset_wtg(:,1).*Lppwtg./Vtmagwtg + Vtmagwtg;
            x1_wtg(:,1) = Pord_wtg(:,1).*(wtgbase./genbasmva_wtg)./Vtmagwtg;
            Efd_wtg(:,1) = x0_wtg(:,1);
            gam_wtg(:,1) = Vtangwtg;
            
            Isrewtg  = x1_wtg(:,1).*Vtrewtg./Vtmagwtg + (Vtimwtg./Lppwtg).*x0_wtg(:,1)./Vtmagwtg;
            Isimwtg  = x1_wtg(:,1).*Vtimwtg./Vtmagwtg - (Vtrewtg./Lppwtg).*x0_wtg(:,1)./Vtmagwtg;
            
            Iswtg(:,1) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva); % CONFIRM
            
            % Itrewtg  = x1_wtg(:,1).*Vtrewtg./Vtmagwtg + (Vtimwtg./Lppwtg).*(x0_wtg(:,1) - Vtmagwtg)./Vtmagwtg;
            % Itimwtg  = x1_wtg(:,1).*Vtimwtg./Vtmagwtg + (Vtrewtg./Lppwtg).*(Vtmagwtg - x0_wtg(:,1))./Vtmagwtg;
            
            % Itwtg(:,1) = (Itrewtg + 1i*Itimwtg).*(genbasmva_wtg./basmva); % CONFIRM
            bus_new = bus;
            % bus_new(wtg_ix,5) = 0;
            
            % % Vtwtg.*conj(Itwtg(:,1))
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
            wtg_ix2 = wtg_con(:,2); % bus number
            % wtgtype = wtg_con(wtg_ix,3); % confirmar indices con el
            % tipo si es 3 o 4
            wtgbase = wtg_con(wtg_ix,4); % Base MVA of the wtg. 162 for the GE model
            genbasmva_wtg = wtg_con(wtg_ix,5);
            Pordmaxwtg = wtg_con(wtg_ix,6);
            Pordminwtg = wtg_con(wtg_ix,7);
            Qmaxwtg = wtg_con(wtg_ix,8);
            Qminwtg = wtg_con(wtg_ix,9);
            
            Klwtg = wtg_con(wtg_ix,10); %****mirar donde lo voy a poner
            % Kpwtg global variable
            Dtgwtg = wtg_con(wtg_ix,12);
            Hwtg = wtg_con(wtg_ix,13);
            Hgwtg = wtg_con(wtg_ix,14);           
            Ktgwtg = wtg_con(wtg_ix,15);
            Wbase = wtg_con(wtg_ix,16);
            Kipwtg = wtg_con(wtg_ix,17);
            Kppwtg = wtg_con(wtg_ix,18);
            Kicwtg = wtg_con(wtg_ix,19);
            Kpcwtg = wtg_con(wtg_ix,20);
            Kitrqwtg = wtg_con(wtg_ix,21);
            Kptrqwtg = wtg_con(wtg_ix,22);
            Tpwtg = wtg_con(wtg_ix,23);
            Tpcwtg = wtg_con(wtg_ix,24);
            thmaxwtg = wtg_con(wtg_ix,25);
            thminwtg = wtg_con(wtg_ix,26);
            thratemx = wtg_con(wtg_ix,27);
            thratemn = wtg_con(wtg_ix,28);
            Pordratemx = wtg_con(wtg_ix,29);
            Pordratemn = wtg_con(wtg_ix,30);
            wfflgwtg = wtg_con(wtg_ix,31);
            Lppwtg = wtg_con(wtg_ix,32);
            Kpllpwtg = wtg_con(wtg_ix,33);
            kQiwtg = wtg_con(wtg_ix,34);
            kViwtg = wtg_con(wtg_ix,35);
            Ipmaxwtg = wtg_con(wtg_ix,36);
            Vmaxcwtg = wtg_con(wtg_ix,37); % Verify limits Rerr
            Vmincwtg = wtg_con(wtg_ix,38); % Verify limits Rerr
%             xiqminwtg = wtg_con(wtg_ix,39);
%             xiqmaxwtg = wtg_con(wtg_ix,40);
            EBSTwtg = wtg_con(wtg_ix,41);
            Kdbrwtg = wtg_con(wtg_ix,42);
            Iphlwtg = wtg_con(wtg_ix,43);
            Iqhl = wtg_con(wtg_ix,44);
            pqflag = wtg_con(wtg_ix,45);
            varflag = wtg_con(wtg_ix,46);
            Trwtg = wtg_con(wtg_ix,47);
            Tvwtg = wtg_con(wtg_ix,48);
            Kpvwtg = wtg_con(wtg_ix,49);
            Kivwtg = wtg_con(wtg_ix,50);
            Tcwtg = wtg_con(wtg_ix,51);
            fNwtg = wtg_con(wtg_ix,52);
            Tpwrwtg = wtg_con(wtg_ix,53);
            PFArefwtg = wtg_con(wtg_ix,54);
            xiqminwtg = wtg_con(wtg_ix,55);
            xiqmaxwtg = wtg_con(wtg_ix,56);
            wINIflagwtg = wtg_con(wtg_ix,57);
            Kwiwtg = wtg_con(wtg_ix,58);
            dbwiwtg = wtg_con(wtg_ix,59);
            Tlpwiwtg = wtg_con(wtg_ix,60);
            Twowiwtg = wtg_con(wtg_ix,61);
            
            %thminwtg = 0; % Thmin  - line 204 asyst5_init (minimum pitch angle)
            %thmaxwtg = 27;% Thmax  - line 203 asyst5_init (maximum pitch angle)
            
            vw_wtgk = vw_wtg(:,k);
            % sensing voltage
            % Vtwtg = bus_v(wtg_idx,k);
            Vtwtg = bus_v(wtg_ix2,k);
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
         
            Pg_wtg = (real(Swtg) - real(Szpp)).*(basmva/wtgbase);
            Qg_wtg = (imag(Swtg) - imag(Szpp)).*(basmva./genbasmva_wtg);
            Pelecwtg = Pg_wtg; % ACA HAY UNA CONSTANTE POR DEFINIR
            
            % Verify Efd_wtg - from 'lim_exc_s1.m' in GE model
            ixdEfmx = (Efd_wtg(:,k) > Vtmagwtg + xiqmaxwtg);
            Efd_wtg(ixdEfmx,k) = Vtmagwtg + xiqmaxwtg;
            ixdEfmn = (Efd_wtg(:,k) < Vtmagwtg + xiqminwtg);
            Efd_wtg(ixdEfmn,k) = Vtmagwtg + xiqminwtg;           


%             Pordminwtg = 0.10; % line 207 asyst5_init (maximum power)
%             Pordmaxwtg = 1.12; % line 206 asyst5_init (maximum power)
            % Verify limits of Pord - when it hits the lower bound
            ixPordmn = Pord_wtg(:,k)<=Pordminwtg;
            Pord_wtg(ixPordmn,k) = Pordminwtg;
            %ix_dPord = (dPord_wtg(ixPordmn,k)<=0);
            %dPord_wtg(ix_dPord,k) = zeros(length(ix_dPord),1);
            
            % Verify limits of Pord - when it hits the upper bound
            ixPordmx = Pord_wtg(:,k)>=Pordmaxwtg;
            Pord_wtg(ixPordmx,k) = Pordmaxwtg;

            % Frequency control
            Pordext_wtg = windINERTIAf(wINIflagwtg, k, wtg_ix2, Kwiwtg, dbwiwtg, Tlpwiwtg, Twowiwtg);
            % 

            %** Reactive power control
            if varflag == 0 % verificar posicion
                dQset_wtg(:,k) = 0;
            elseif varflag == -1
                ds6_wtg(:,k) = (1./Tpwrwtg).*(Pg_wtg - s6_wtg(:,k)); 
                Qset_wtg(:,k) = s6_wtg(:,k).*tan(PFArefwtg); % verificar posicion
            elseif varflag == 1
                % Definir Vref, Vrfq y Vqd;
                ds3_wtg(:,k) = (1./Trwtg).*(Vreg - s3_wtg(:,k));
                ds2_wtg(:,k) = (1./Tvwtg).*( (1./fNwtg).*(Vrfq - s3_wtg(:,k) - Vqd) - s2_wtg(:,k) ); 
                ds4_wtg(:,k) = (1./fNwtg).*(Vrfq - s3_wtg(:,k) - Vqd);
                dQset_wtg(:,k) = (1./Tcwtg).*( Kivwtg.*s4_wtg(:,k) + Kpvwtg.*s2_wtg(:,k) );
            end
            %** end- Reactive power control
            
            wg_wtg = w0_wtg + wgSV_wtg(:,k); % DUDA en la linealizacion y obtencion de w0
            wt_wtg = w0_wtg + wtSV_wtg(:,k); % DUDA en la linealizacion y obtencion de w0
            
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
            % Verify limits of Ipcmd (no lower limit)
            Ipcmd_wtg(Ipcmd_wtg>=Ipmaxwtg) = Ipmaxwtg(Ipcmd_wtg>=Ipmaxwtg); %OJO indice
            
            dwgSV_wtg(:,k) = (1/(2*Hgwtg)).*(-Pelecwtg./wg_wtg - Dtgwtg.*(wgSV_wtg(:,k) - wtSV_wtg(:,k)) - Ktgwtg.*(delg_wtg(:,k) - delt_wtg(:,k) + delg0_wtg)); % DUDA
            dwtSV_wtg(:,k) = (1/(2*Hwtg)).*(Pmechwtg./wt_wtg + Dtgwtg.*(wgSV_wtg(:,k) - wtSV_wtg(:,k)) + Ktgwtg.*(delg_wtg(:,k) - delt_wtg(:,k) + delg0_wtg)); % DUDA
            
            ddelg_wtg(:,k) = Wbase.*wgSV_wtg(:,k);
            ddelt_wtg(:,k) = Wbase.*wtSV_wtg(:,k);
            
            ddelerr1_wtg(:,k) = Kipwtg.*(wg_wtg - wref_wtg(:,k)); % DUDA 
            ddelerr2_wtg(:,k) = Kitrqwtg.*(wg_wtg - wref_wtg(:,k)); % DUDA
            dEerr_wtg(:,k) = Kicwtg.*(Pord_wtg(:,k) - Pset_wtg);
            
            dth_wtg(:,k) = (1/Tpwtg).*(-th_wtg(:,k) + Kppwtg.*(wg_wtg - wref_wtg(:,k)) + delerr1_wtg(:,k) + Kpcwtg.*(Pord_wtg(:,k) - Pset_wtg) + Eerr_wtg(:,k));
            dPord_wtg(:,k) = (1/Tpcwtg).*( -Pord_wtg(:,k) + wg_wtg.*( Kptrqwtg.*(wg_wtg - wref_wtg(:,k)) + delerr2_wtg(:,k) ) );
            
            dwref_wtg(:,k) = (1/5).*(1.2 - wref_wtg(:,k));
            ixaux = find(Pg_wtg <= 0.75);
            dwrefx = (1/5).*((-0.67*Pg_wtg + 1.42 ).*Pg_wtg + 0.51 - wref_wtg(:,k));
            dwref_wtg(ixaux,k) = dwrefx(ixaux); %CHECK FOR SYNTAX
            
            dx0_wtg(:,k) = (1/0.01).*(Efd_wtg(:,k) - x0_wtg(:,k));
            dx1_wtg(:,k) = (1/0.01).*(Ipcmd_wtg - x1_wtg(:,k));
            
            dgam_wtg(:,k) = Kpllpwtg.*( Vtimwtg.*cos(gam_wtg(:,k)) - Vtrewtg.*sin(gam_wtg(:,k)) );
            dgam_wtg(:,k) = dgam_wtg(:,k)/377;
            dgam_wtglim = 0.1;
            ixdgam = dgam_wtg(:,k) >= dgam_wtglim;
            dgam_wtg(ixdgam,k) = dgam_wtglim;
            ixdgam = dgam_wtg(:,k) <= -dgam_wtglim;
            dgam_wtg(ixdgam,k) = -dgam_wtglim;
            dgam_wtg(:,k) = dgam_wtg(:,k)*377;
            
            dEfd_wtg(:,k) = kViwtg.*( Rerr_wtg(:,k) - Vtmagwtg );
            dRerr_wtg(:,k) = kQiwtg.*( Qset_wtg(:,k) - Qg_wtg );
            
            
            Isrewtg = x1_wtg(:,k).*cos(gam_wtg(:,k)) + (x0_wtg(:,k)./Lppwtg).*(sin(gam_wtg(:,k)));
            Isimwtg = -(x0_wtg(:,k)./Lppwtg).*cos(gam_wtg(:,k)) + x1_wtg(:,k).*(sin(gam_wtg(:,k)));
            Iswtg(:,k+1) = (Isrewtg + 1i*Isimwtg).*(genbasmva_wtg./basmva); % CONFIRM k+1
            
            % Verify limits of dtheta/dt (pitch angle)
            %thrate = 10;  %line 205 asyst5_init (maximum pitch rate) 
            ixdth = dth_wtg(:,k)>=thratemx;
            dth_wtg(ixdth,k) = thratemx;
            ixdth = dth_wtg(:,k)<thratemn;
            dth_wtg(ixdth,k) = thratemn;
            
            % Verify limits of theta (pitch angle) - when it hits the lower
            % bound
            ixthmn = th_wtg(:,k)<=(thminwtg+eps);
            th_wtg(ixthmn,k) = thminwtg;
            ix_dth = (dth_wtg(ixthmn,k)<0);
            %dth_wtg(ix_dth,k) = zeros(length(ix_dth),1);
            ddelerr1_wtg(ix_dth,k) = zeros(length(ix_dth),1);
            dEerr_wtg(ix_dth,k) = zeros(length(ix_dth),1);
            % Verify limits of theta (pitch angle) - when it hits the upper
            % bound
            ixthmx = th_wtg(:,k)>=thmaxwtg;
            th_wtg(ixthmx,k) = thmaxwtg;
            % ix_dth = (dth_wtg(ixthmx,k)>=0); % ??
            % dth_wtg(ix_dth,k) = zeros(length(ix_dth),1); % ??
            
            % Verify limits of dPord/dt
            % Pordrate = 0.45;  %line 205 asyst5_init (maximum pitch rate) 
            ixdPord =  dPord_wtg(:,k)>Pordratemx;
            dPord_wtg(ixdPord,k) = Pordratemx;
            ixdPord  = dPord_wtg(:,k)<Pordratemn;
            dPord_wtg(ixdPord,k) = Pordratemn;
            
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
            ddelerr2_wtg(ix_dPord,k) = zeros(length(ix_dPord),1);
            
            % Verify dEfd_wtg % % Verify Efd_wtg - from 'lim_exc_s1.m' in GE model
            ixdEfdmx = ((Efd_wtg(:,k) >= Vtmagwtg + xiqmaxwtg) & (dEfd_wtg(:,k) >= 0));
            dEfd_wtg(ixdEfdmx,k) = 0;
            ixdEfdmn = ((Efd_wtg(:,k) <= Vtmagwtg + xiqminwtg) & (dEfd_wtg(:,k) <= 0));
            dEfd_wtg(ixdEfdmn,k) = 0;            
            
            bus_new = bus;
            
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


function Pordext_wtg = windINERTIAf(wINIflagwtg, k, wtg_ix2, Kwiwtg, dbwiwtg, Tlpwiwtg, Twowiwtg);
    %** frequency control (windINERTIA)************************************    
    global wtg_con Pord_wtg  bus_freq
    global s1wini_wtg s2wini_wtg 
    global ds1wini_wtg ds2wini_wtg dpwi_wtg
    
            
    % auxiliary signal normally set to 0 except for test. As stated
    % in the report (v4.5) page 4.26
    auxsigwini_wtg = 0; 
    freqrefwtg = bus_freq(wtg_ix2,1); % verificar que es la system freq
    busfreq_wtg = bus_freq(wtg_ix2,k);% calculated through freqcalc **CONFIRM
            
    if wINIflagwtg == 0 %
        % windINERTIA disabled

        dpwiwtg = 0;

    elseif wINIflagwtg == 1

        % windINERTIA enabled
        busferr_wtg = freqrefwtg - (busfreq_wtg + auxsigwini_wtg);
        if busferr_wtg > dbwiwtg
            % extra power needed - there is a frequency drop
            Kitrqwtg = 0.05; % pag. 4.26 GE WTG Modeling-V4.5
            Kptrqwtg = 0.5; % pag. 4.26 GE WTG Modeling-V4.5
            Tpcwtg = 4; % pag. 4.26 GE WTG Modeling-V4.5
            wtg_con(wtg_ix,21) = Kitrqwtg; % PERMANENT Modification
            wtg_con(wtg_ix,22) = Kptrqwtg; % PERMANENT Modification
            wtg_con(wtg_ix,24) = Tpcwtg; % PERMANENT Modification
        else
            busferr_wtg = 0;
        end

        ds1wini_wtg(:,k) = (1./Tlpwiwtg).*(busferr_wtg - s1wini_wtg(:,k));
        ds2wini_wtg(:,k) = Kwiwtg*s1wini_wtg(:,k) - (1./Twowiwtg).*(s2wini_wtg(:,k));
        dpwiwtg = ds2wini_wtg(:,k);

    else % elseif - space por different frequency control approaches

        % *** OJO MIRAR COMO LLEGAR A Pord A PARTIR DE ESTE VALOR 
    end
    Pordext_wtg = Pord_wtg(:,k) + dpwiwtg;

    Pordminwtg_wINI = 0.10;     % TESTING
    Pordmaxwtg_wINI = 1.2; % TESTING
    % Verify limits of Pord - when it hits the lower bound
    ixPordextmn = Pordext_wtg<=Pordminwtg_wINI;
    Pordext_wtg(ixPordextmn) = Pordminwtg_wINI;

    % Verify limits of Pord - when it hits the upper bound
    ixPordextmx = Pordext_wtg>=Pordmaxwtg_wINI;
    Pordext_wtg(ixPordextmx) = Pordmaxwtg_wINI;
    %** end- frequency control (windINERTIA)*******************************
