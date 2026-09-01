function [bus_new] = wtg2(i,k,bus,flag,busi_v)
% Syntax: [bus_new] = wtg(i,k,bus,flag,busi_v)
% 07/08/2012
% Purpose: Wind Turbine Generator Type 2.
% 
% 
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
global  basmva basrad bus_int bus_freq

% Type 2 - Wind Power Plant (wtg) Variables
global wtg2_con n_wtg2 wtg2_idx wtg2_idx2

global vdp_wtg2 vqp_wtg2 wgSV_wtg2 wtSV_wtg2 delgt_wtg2 Wdel_wtg2
global Pdel_wtg2 Rint_wtg2 Pgd_wtg2 Ri_wtg2 Pom_wtg2 Pmech_wtg2

global dvdp_wtg2 dvqp_wtg2 dwgSV_wtg2 dwtSV_wtg2 ddelgt_wtg2 dWdel_wtg2
global dPdel_wtg2 dRint_wtg2 dPgd_wtg2 dRi_wtg2 dPom_wtg2 dPmech_wtg2

global id_wtg2 iq_wtg2 sl_wtg2 ws_wtg2

global w0_wtg2 delg0_wtg2 Pref_wtg2 wref_wtg2

global P_wtg2 Q_wtg2

bus_new = bus;
if ~isempty(wtg2_con)
    if flag == 0 % initialization
        if i~=0
            %later
        else
            
            n_wtg2 = length(wtg2_con(:,1));
            wtg2_ix = 1:n_wtg2; % OJO CONFIRMAR
            wtg2_idx2 = bus_int(wtg2_con(:,2)); % OJO CONFIRMAR
            
            wtg2base = wtg2_con(wtg2_ix,3); 
            Rswtg2 = wtg2_con(wtg2_ix,4);
            XAwtg2 = wtg2_con(wtg2_ix,5);
            XMwtg2 = wtg2_con(wtg2_ix,6);
            Xrwtg2 = wtg2_con(wtg2_ix,7);
            Rrwtg2 = wtg2_con(wtg2_ix,8);
            spdrotwtg2 = wtg2_con(wtg2_ix,9);
            
            Se1wtg2 = wtg2_con(wtg2_ix,10);
            Se2wtg2 = wtg2_con(wtg2_ix,11);
            
            nmasswtg2 = wtg2_con(wtg2_ix,12); % define one or two mass model
            Dtgwtg2 = wtg2_con(wtg2_ix,13);
            Htwtg2 = wtg2_con(wtg2_ix,14);
            Hgwtg2 = wtg2_con(wtg2_ix,15);           
            Freq1wtg2 = wtg2_con(wtg2_ix,16);
%             Wbase2 = wtg2_con(wtg2_ix,17);

%             kwwtg2 = wtg2_con(wtg2_ix,17);
%             Tpewtg2 = wtg2_con(wtg2_ix,18);
%             kdroopwtg2 = wtg2_con(wtg2_ix,19);
%             kpwtg2 = wtg2_con(wtg2_ix,20);
%             kiwtg2 = wtg2_con(wtg2_ix,21);
%             pimaxwtg2 = wtg2_con(wtg2_ix,22);
%             piminwtg2 = wtg2_con(wtg2_ix,23);
%             T1wtg2 = wtg2_con(wtg2_ix,24);
%             T2wtg2 = wtg2_con(wtg2_ix,25);
%             
%             Twrrwtg2 = wtg2_con(wtg2_ix,26);
%             kwrrwtg2 = wtg2_con(wtg2_ix,27);
%             Tprrwtg2 = wtg2_con(wtg2_ix,28);
            kprrwtg2 = wtg2_con(wtg2_ix,29);
%             kpprrwtg2 = wtg2_con(wtg2_ix,30);
%             kiprrwtg2 = wtg2_con(wtg2_ix,31);
%             Rextmaxwtg2 = wtg2_con(wtg2_ix,32);
%             Rextminwtg2 = wtg2_con(wtg2_ix,33);
            
%             Slip1rrwtg2 = wtg2_con(wtg2_ix,34);
%             Slip2rrwtg2 = wtg2_con(wtg2_ix,35);
%             Slip3rrwtg2 = wtg2_con(wtg2_ix,36);
%             Slip4rrwtg2 = wtg2_con(wtg2_ix,37);
%             Slip5rrwtg2 = wtg2_con(wtg2_ix,38);
%             Powr1rrwtg2 = wtg2_con(wtg2_ix,39);
%             Powr2rrwtg2 = wtg2_con(wtg2_ix,40);
%             Powr3rrwtg2 = wtg2_con(wtg2_ix,41);
%             Powr4rrwtg2 = wtg2_con(wtg2_ix,42);
%             Powr5rrwtg2 = wtg2_con(wtg2_ix,43);
            
            Slipdatwtg2 = wtg2_con(wtg2_ix,34:38);
            Powrdatwtg2 = wtg2_con(wtg2_ix,39:43);
            
            genbasmva_wtg2 = 10/9*wtg2base;
            
            w0_wtg2 = spdrotwtg2;
            ws_wtg2 = 1.0;
            

            
            % WTG Type 2 treated as a PV bus
            % => Reactive power (Qlf_wtg2) calculated from loadflod
            % => Reactive power (Qfor_wtg2) also calculated from induction
            % generator specifics
            % Shunt capacitors put to supply the difference
            Vtwtg2 = bus(wtg2_idx2,2).*exp(1i*bus(wtg2_idx2,3)*pi/180); %Cambioindx
            Vtmagwtg2 = abs(Vtwtg2);
            Vtangwtg2 = angle(Vtwtg2);
            Vtrewtg2 = real(Vtwtg2);
            Vtimwtg2 = imag(Vtwtg2);
            
            Plf_wtg2 = -bus(wtg2_idx2,6); 
            Qlf_wtg2 = -bus(wtg2_idx2,7);
%             Plf_wtg2 = bus(wtg2_idx2,4); 
%             Qlf_wtg2 = bus(wtg2_idx2,5);
            
            Pg_wtg2 = Plf_wtg2.*(basmva./wtg2base);
            Qg_wtg2 = Qlf_wtg2.*(basmva./wtg2base);
            
            Pgbasi_wtg2 = Plf_wtg2.*(basmva./genbasmva_wtg2);
            
            Htotwtg2 = Htwtg2 + Hgwtg2;
            Ktgwtg2 = 2*((2*pi*Freq1wtg2).^2).*Htwtg2.*Hgwtg2./Htotwtg2;
            

%***************************** Initialization ****************************%   
% WTG Type 2 treated as a PV bus, then from loadflow obtain P, V (also
% temporarily Q) with P, V, iterate to obtain Rrtot and the actual Q
% Recall that the rotor speed is an INPUT parameter so the slip is already
% defined (since stator frequency is the grid frequency and can be assumed
% to be 1.0) and the iteration is done to find the total Rotor resistance.
% As the rotor resistance is given the external rotor resistance can be
% calculated
% Calculate and place a capacitor in that bus to improve the power factor
% this is done in function wtg2_indx
            
            Pgite_wtg2 = -Pgbasi_wtg2;
            for idx = 1:n_wtg2
            
            sl_wtg2(idx,k)= (ws_wtg2 - spdrotwtg2(idx))/ws_wtg2; % -(ws_wtg2 - spdrotwtg2(idx))/ws_wtg2;
%             spdrotwtg2 = wtg2_con(wtg2_ix,9);
            Ra = Rswtg2(idx);
            Xm = XMwtg2(idx);
            Xa = XAwtg2(idx);
            Xr = Xrwtg2(idx);
            
            Rrl = linspace(0,0.25,10000);
            Zeq = Ra + 1i.*Xa + (1i.*Xm.*(1i.*Xr + Rrl./sl_wtg2(idx,1)))./(1i.*Xm + (1i.*Xr + Rrl./sl_wtg2(idx,1)));
            It = Vtmagwtg2(idx)./Zeq;
            St = Vtmagwtg2(idx).*(It');
            Pt = real(St);
            [~, ixPtmin] = min(Pt);

            Rr_min = Rrl(ixPtmin);
            Rr_max = 0.25;
            Rr_swp = Rr_min; % = (Rr_max - Rr_min)/2;
            Rr_loop = 1;
            tol_rrot = 1e-10;
            while Rr_loop
                Rr = Rr_swp;
                Zeq = Ra + 1i.*Xa + (1i.*Xm.*(1i.*Xr + Rr./sl_wtg2(idx,1)))./(1i.*Xm + (1i.*Xr + Rr./sl_wtg2(idx,1)));
                Zeq_r = real(Zeq);
                Zeq_mag = abs(Zeq);

                Pgit = (Zeq_r./(Zeq_mag.^2)).*Vtmagwtg2(idx)^2;

                errP = Pgit - Pgite_wtg2(idx);

                if errP > tol_rrot
                    Rr_max = Rr_swp;
                    Rr_swp = (Rr_swp - Rr_min)/2  + Rr_min;
                elseif errP < -tol_rrot
                    Rr_min = Rr_swp;
                    Rr_swp = (Rr_max - Rr_swp)/2 + Rr_swp;
                else
                    Rr_loop = 0;
                end
            end
            
            Rrtotwtg2(idx,1) = Rr_swp;
            
            slipdet = abs(sl_wtg2(idx,k));
            Psig_wtg2(idx,1) = fixpt_interp1(...
                           Slipdatwtg2(idx,:),Powrdatwtg2(idx,:),slipdet,...
                           sfix(32),2^-32,sfix(32), 2^-29,'Nearest');
%             Psig_wtg2(idx,1) = 0.9; % just test
            end
 
%************************* -Induction generator- *************************%
            Ra = Rswtg2;
            Xm = XMwtg2;
            Xa = XAwtg2;
            Xr = Xrwtg2;
            
            Xs_wtg2 = XAwtg2 + XMwtg2;
            Xsp_wtg2 = XAwtg2 + (XMwtg2.*Xrwtg2)./(XMwtg2 + Xrwtg2);
            Top_wtg2 = (XMwtg2 + Xrwtg2)./(basrad*Rrtotwtg2); % ?? IN SECONDS?

            Zeq = Ra + 1i.*Xa + (1i.*Xm.*(1i.*Xr + Rrtotwtg2./sl_wtg2(:,k)))./(1i.*Xm + (1i.*Xr + Rrtotwtg2./sl_wtg2(:,k)));
%             Zeq_r = real(Zeq);
%             Zeq_mag = abs(Zeq);
            
            Iwtg2 = Vtwtg2./Zeq;
            
            Swtg2 = Vtwtg2.*conj(Iwtg2); % Remember no rotation required
            % genbasmva_wtg2./basmva;
            % wtg2base./basmva
            id_wtg2(:,k) = real(Iwtg2).*genbasmva_wtg2./basmva;
            iq_wtg2(:,k) = imag(Iwtg2).*genbasmva_wtg2./basmva;
            idm_wtg2 = real(Iwtg2);
            iqm_wtg2 = imag(Iwtg2);% % % .*basmva./wtg2base;
            
%             vdp_wtg2(:,k) = (idm_wtg2.*sl_wtg2(:,k)*basrad.*Top_wtg2 - iqm_wtg2).*(Xs_wtg2 - Xsp_wtg2)./(1 + (sl_wtg2(:,k).*basrad.*Top_wtg2).^2);
%             vqp_wtg2(:,k) = (iqm_wtg2.*sl_wtg2(:,k)*basrad.*Top_wtg2 + idm_wtg2).*(Xs_wtg2 - Xsp_wtg2)./(1 + (sl_wtg2(:,k).*basrad.*Top_wtg2).^2);
            Vp_wtg2 = Vtwtg2 - (Rswtg2 + 1i*Xsp_wtg2).*Iwtg2;
            vdp_wtg2(:,k) = real(Vp_wtg2);
            vqp_wtg2(:,k) = imag(Vp_wtg2);

            Swtg2 = Swtg2.*genbasmva_wtg2./basmva;
            
            % Modify bus load
            bus_new(wtg2_idx2,4) = 0;
            % Include capacitor
            Qact_wtg2 = imag(Swtg2);
%             Qinj_Bc = Qlf_wtg2 + Qact_wtg2;
%             Bc = Qinj_Bc./(Vtmagwtg2.^2);
            bus_new(wtg2_idx2,6) = 0.0;
            bus_new(wtg2_idx2,7) = bus(wtg2_idx2,7) - Qact_wtg2;
%             bus_new(wtg2_idx2,7) = bus(wtg2_idx2,7) - Qinj_Bc;
            
            Sint_wtg2 = (vdp_wtg2(:,k) + 1i*vqp_wtg2(:,k)).*conj(Iwtg2);
            Pgint_wtg2 = real(Sint_wtg2);
            
%**************************** ---------------- ***************************%        
            
%********************** -Rotor resistance controller- ********************%
% *** Input signals are the power in 0.9base and the rotor slip (*a*)
% (*a*) rotor slip is assumed since the data of the P vs slip curve fits
% with this input instead of any other
            Rint_wtg2(:,k) = Rrtotwtg2 - Rrwtg2;
            if any(Rint_wtg2(:,k)<0)
                error('negative resistance required NOT possible')
            end
            Pdel_wtg2(:,k) = Pgbasi_wtg2;
            Wdel_wtg2(:,k) = -(ws_wtg2 - spdrotwtg2)./ws_wtg2; % positive value
            
%             checking that psig and kp*Pdel are in fact 0
            aux_srrs = Psig_wtg2 - kprrwtg2.*Pdel_wtg2(:,k);
            if any( abs(aux_srrs)>0.5e-6 )
                error('Initialization of rotor resistance controller is not correct')
            else
            end
            
            % ***OJO toca poner los limites de Rextmax Rextmin
            
%**************************** ---------------- ***************************%
          
%**************************** -Two mass model- ***************************%            
            Pmech_wtg2(:,k) = Pgint_wtg2;% Pg_wtg2;
            wgSV_wtg2(:,k) = 0; % is the deviation with respect to w0
            wtSV_wtg2(:,k) = 0; % is the deviation with respect to w0
            
            wg_wtg2 = w0_wtg2 + wgSV_wtg2(:,k); 
            wt_wtg2 = w0_wtg2 + wtSV_wtg2(:,k); 
            
            delgt_wtg2(:,k) = 0;
            delg0_wtg2 = -Pmech_wtg2(:,k)./(Ktgwtg2.*wg_wtg2);
%             delg0_wtg2 = -Pg_wtg2./(Ktgwtg2.*wg_wtg2(:,1));
            
%*************************** -Pseudogovernor- ****************************%            
            
            Pom_wtg2(:,1) = Pmech_wtg2(:,1); % i.e. Pg_wtg2
            Ri_wtg2(:,1) = Pom_wtg2(:,1); % i.e. Pg_wtg2
            Pgd_wtg2(:,1) = Pgint_wtg2;
            
            Pref_wtg2 = Pgint_wtg2;
            wref_wtg2 = wg_wtg2; %
%**************************** ---------------- ***************************%


        end
    end
    
    if flag == 1
        %network interface
        %no interface required for induction generators
        
        
    end
    
    if flag == 2 % Dynamic model calculation
        if i~=0
            %later
        else %vectorized computation
            wtg2_ix = 1:n_wtg2; % OJO CONFIRMAR
            
            wtg2base = wtg2_con(wtg2_ix,3); 
            Rswtg2 = wtg2_con(wtg2_ix,4);
            XAwtg2 = wtg2_con(wtg2_ix,5);
            XMwtg2 = wtg2_con(wtg2_ix,6);
            Xrwtg2 = wtg2_con(wtg2_ix,7);
            Rrwtg2 = wtg2_con(wtg2_ix,8);
            spdrotwtg2 = wtg2_con(wtg2_ix,9);
            Se1wtg2 = wtg2_con(wtg2_ix,10);
            Se2wtg2 = wtg2_con(wtg2_ix,11);
            
            nmasswtg2 = wtg2_con(wtg2_ix,12); % define one or two mass model
            Dtgwtg2 = wtg2_con(wtg2_ix,13);
            Htwtg2 = wtg2_con(wtg2_ix,14);
            Hgwtg2 = wtg2_con(wtg2_ix,15);           
            Freq1wtg2 = wtg2_con(wtg2_ix,16);
%             Wbase2 = wtg2_con(wtg2_ix,17);

            kwwtg2 = wtg2_con(wtg2_ix,17);
            Tpewtg2 = wtg2_con(wtg2_ix,18);
            kdroopwtg2 = wtg2_con(wtg2_ix,19);
            kpwtg2 = wtg2_con(wtg2_ix,20);
            kiwtg2 = wtg2_con(wtg2_ix,21);
            pimaxwtg2 = wtg2_con(wtg2_ix,22);
            piminwtg2 = wtg2_con(wtg2_ix,23);
            T1wtg2 = wtg2_con(wtg2_ix,24);
            T2wtg2 = wtg2_con(wtg2_ix,25);
            
            Twrrwtg2 = wtg2_con(wtg2_ix,26);
            kwrrwtg2 = wtg2_con(wtg2_ix,27);
            Tprrwtg2 = wtg2_con(wtg2_ix,28);
            kprrwtg2 = wtg2_con(wtg2_ix,29);
            kpprrwtg2 = wtg2_con(wtg2_ix,30);
            kiprrwtg2 = wtg2_con(wtg2_ix,31);
            Rextmaxwtg2 = wtg2_con(wtg2_ix,32);
            Rextminwtg2 = wtg2_con(wtg2_ix,33);
            
            Slipdatwtg2 = wtg2_con(wtg2_ix,34:38);
            Powrdatwtg2 = wtg2_con(wtg2_ix,39:43);
            
            genbasmva_wtg2 = 10/9*wtg2base;
            
            Htotwtg2 = Htwtg2 + Hgwtg2;
            Ktgwtg2 = 2*((2*pi*Freq1wtg2).^2).*Htwtg2.*Hgwtg2./Htotwtg2;
            
            k2=1; if k~=1; k2=k-1; end; k2=k;
            Vtwtg2 = busi_v(wtg2_idx2,k2);
            Vtmagwtg2 = abs(Vtwtg2);
            Vtangwtg2 = angle(Vtwtg2);
            Vtrewtg2 = real(Vtwtg2);
            Vtimwtg2 = imag(Vtwtg2);
            
            Iwtg2k = (id_wtg2(:,k) + 1i*iq_wtg2(:,k)).*basmva./wtg2base;
            Swtg2 = Vtwtg2.*conj(-Iwtg2k);
            
            Pg_wtg2 = real(Swtg2);
            Qg_wtg2 = imag(Swtg2);
            
            Sint_wtg2 = (vdp_wtg2(:,k) + 1i*vqp_wtg2(:,k)).*conj(Iwtg2k).*...
                         wtg2base./genbasmva_wtg2;
            Pgint_wtg2 = real(Sint_wtg2);
            
            
%**************************** -Two mass model- ***************************%            
            % w0_wtg depends on the calculus of the slip
            wg_wtg2 = w0_wtg2 - wgSV_wtg2(:,k); %** PR
            wt_wtg2 = w0_wtg2 - wtSV_wtg2(:,k); %** PR
%**************************** -One mass model- ***************************%
            nmass1idx = nmasswtg2 == 1;
            wg_wtg2(nmass1idx,1) = wt_wtg2(nmass1idx,1);
%**************************** ---------------- ***************************%
            
            sl_wtg2(:,k) = (ws_wtg2 - wg_wtg2)/ws_wtg2; %-(ws_wtg2 - wg_wtg2)/ws_wtg2;
            
%********************** -Rotor resistance controller- ********************%
            Pgbasi_wtg2 = Pg_wtg2.*wtg2base./genbasmva_wtg2;
            dWdel_wtg2(:,k) = (1./Twrrwtg2).*( ( -sl_wtg2(:,k) ) - Wdel_wtg2(:,k)); % 
            dWdel_wtg2(:,k) = 0; %-                                          -%***
            dPdel_wtg2(:,k) = (1./Tprrwtg2).*(Pgbasi_wtg2 - Pdel_wtg2(:,k));
            dPdel_wtg2(:,k) = 0; %-                                          -%***
            
            Psig_wtg2 = zeros(n_wtg2,1);
            for idx = 1:n_wtg2
                Psig_wtg2(idx,1) = fixpt_interp1(...
                   Slipdatwtg2(idx,:),Powrdatwtg2(idx,:),kwrrwtg2(idx,1).*Wdel_wtg2(idx,k),...
                   sfix(32),2^-32,sfix(32), 2^-29,'Nearest');
%                Psig_wtg2(idx,1) = 0.9;
            end
            
            aux_srrs = Psig_wtg2 - kprrwtg2.*Pdel_wtg2(:,k);

            dRint_wtg2(:,k) = kiprrwtg2.*(aux_srrs); 
            dRint_wtg2(:,k) = 0; %-                                          -%***
            Rextwtg2 = kpprrwtg2.*aux_srrs + Rint_wtg2(:,k);
            % ***OJO toca poner los limites de Rextmax Rextmin
%**************************** ---------------- ***************************%

%*************************** -Pseudogovernor- ****************************%
            dPgd_wtg2(:,k) = (1./Tpewtg2).*(Pgint_wtg2 - Pgd_wtg2(:,k));
            dPgd_wtg2(:,k) = 0; %-                                          -%***
            aux_spgov1 = kdroopwtg2.*(Pref_wtg2 - Pgd_wtg2(:,k)) - ...
            kwwtg2.*(wg_wtg2 - wref_wtg2); 
            
            % ***OJO toca poner los limites a aux_spgov1
            
            dRi_wtg2(:,k) = kiwtg2.*aux_spgov1;
            dRi_wtg2(:,k) = 0; %-                                          -%***
            aux_spgov2 = kpwtg2.*aux_spgov1 + Ri_wtg2(:,k);
            dPom_wtg2(:,k) = (1./T1wtg2).*(aux_spgov2 - Pom_wtg2(:,k));
            dPom_wtg2(:,k) = 0; %-                                          -%***
            dPmech_wtg2(:,k) = (1./T2wtg2).*(Pom_wtg2(:,k) - Pmech_wtg2(:,k));
            dPmech_wtg2(:,k) = 0; %-                                          -%***
%********************** ---------------------------- ********************%

%**************************** -Two mass model- ***************************%
            dwgSV_wtg2(:,k) = (1./(2*Hgwtg2)).*(-(Pgint_wtg2)./wg_wtg2 - Dtgwtg2.*(wgSV_wtg2(:,k) - wtSV_wtg2(:,k)) - Ktgwtg2.*(delgt_wtg2(:,k) + delg0_wtg2)); % DUDA - changed for both type 3 and type 4
            dwtSV_wtg2(:,k) = (1./(2*Htwtg2)).*(Pmech_wtg2(:,k)./wt_wtg2 + Dtgwtg2.*(wgSV_wtg2(:,k) - wtSV_wtg2(:,k)) + Ktgwtg2.*(delgt_wtg2(:,k) + delg0_wtg2)); % DUDA
            % OJO CON los kw
%             ddelgt_wtg2(:,k) = Wbase.*(wgSV_wtg2(:,k) - wtSV_wtg2(:,k));
            ddelgt_wtg2(:,k) = wgSV_wtg2(:,k) - wtSV_wtg2(:,k);
%**************************** -One mass model- ***************************%
            nmass1idx = nmasswtg2 == 1;
            dwtSV_aux = (1./(2*Htwtg2.*wt_wtg2)).*(Pmech_wtg2(:,k) - (Pgint_wtg2)); % DUDA
            dwtSV_wtg2(nmass1idx,k) = dwtSV_aux(nmass1idx,1);
%**************************** ---------------- ***************************%

%********************** -Induction generator model- **********************%

            Rrtotwtg2 = Rrwtg2 + Rextwtg2;
            Xs_wtg2 = XAwtg2 + XMwtg2;
            Xsp_wtg2 = XAwtg2 + (XMwtg2.*Xrwtg2)./(XMwtg2 + Xrwtg2);
            Top_wtg2 = (XMwtg2 + Xrwtg2)./(basrad*Rrtotwtg2); % ?? IN SECONDS?
            
            %vector calculation    
%             idm_wtg2 = id_wtg2(:,k).*basmva./wtg2base;%convert to machine base
%             iqm_wtg2 = iq_wtg2(:,k).*basmva./wtg2base;

            idm_wtg2 = real(Iwtg2k).*wtg2base./genbasmva_wtg2; %convert to induction gen. base (0.9)
            iqm_wtg2 = imag(Iwtg2k).*wtg2base./genbasmva_wtg2;
            
            %Brereton, Lewis and Young motor model
%           dvdpig(:,k)=-(iqigm.*igen_pot(:,6)+vdpig(:,k)).*igen_pot(:,7)+vqpig(:,k).*slig(:,k)*basrad;
            dvdp_wtg2(:,k) = -(iqm_wtg2.*(Xs_wtg2 - Xsp_wtg2) + vdp_wtg2(:,k)).*(1./Top_wtg2) + vqp_wtg2(:,k).*sl_wtg2(:,k)*basrad;
%             dvqpig(:,k)=(idigm.*igen_pot(:,6)-vqpig(:,k)).*igen_pot(:,7)-vdpig(:,k).*slig(:,k)*basrad;	
            dvqp_wtg2(:,k) = (idm_wtg2.*(Xs_wtg2 - Xsp_wtg2) - vqp_wtg2(:,k)).*(1./Top_wtg2) - vdp_wtg2(:,k).*sl_wtg2(:,k)*basrad;	

%             equation not considered since there is an independent
%             turbine/generator model
%             dslig(:,k)=(tmig(:,k)-vdpig(:,k).*idigm-vqpig(:,k).*iqigm)/2./igen_con(:,9);
%**************************** ---------------- ***************************%            

            
        end
    end
    
end