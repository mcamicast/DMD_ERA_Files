function [bus_new] = wtg_indx(bus,line)
% determines the relationship between wtg and nc loads
% checks for wtg
% determines number of wtgs
% % f is a dummy variable
% % f = 0;

global wtg_con load_con n_wtg wtg_idx wtg_idx2 basmva 
global vw_wtg Kpwtg wtg_con_ini % th_wtg wref_wtg 

[n_wtg ~] = size(wtg_con);
if ~isempty(wtg_con)
    
    Idwtg = wtg_con(:,3) == 3 | wtg_con(:,3) == 4;
    if any(~Idwtg);
        error('Error in wtg_con, wind turbines are either type 3 = 3 or type 4 = 4')
        return;
    end
    
    %[n_wtg npar] = size(wtg_con);
    
    for ix = 1:n_wtg
        index = find(wtg_con(ix,2)==load_con(:,1));
        if ~isempty(index)
            wtg_idx(ix) = index; % relative index to load con
        else
            error('you must have the wtg bus declared as a non-conforming load')
            return;
        end
        index2 = find(bus(:,1) == wtg_con(ix,2));
        if ~isempty(index2)
            wtg_idx2(ix) = index2; % index relative to bus_v
        end
        
        
        varflag = wtg_con(ix,52);
        if varflag == 1
            Vregbuswtg = wtg_con(ix,53);
            wtgbuscon = wtg_con(ix,2);
            vercon_busreg(Vregbuswtg,wtgbuscon,line);
        end
        
        switch wtg_con(ix,12)
            case 1
                if any(~isnan([wtg_con(ix,13) wtg_con(ix,15:17)]))
                    msgbox('Excess of parameters on one mass model - not used','Warning');
                end
            case 2
                if any(isnan(wtg_con(ix,13:17)))
                    error('Parameters missing for two mass model')
                end
                
            otherwise
                error('nmass should be either 1 or 2 (mass models)')
        end
        
        ixwtbus = bus(:,1) == wtg_con(ix,2);
        if (bus(ixwtbus,10) ~= 2)&&(bus(ixwtbus,10) ~= 1)
            error('WTG should be defined as a PV (gen) bus or swing bus')
        end
        
        if wtg_con(ix,3) == 3
            % To add the reactance of the WPP (wtg) in the system matrices:
            % just for Type 3
            wtgbase_i = wtg_con(ix,4); % Base MVA of the wtg. 162 for the GE model
            genbasmva_wtg_i = wtgbase_i*10/9;
            rpp = 0; %por el momento
%             xpp = wtg_con(ix,33)*basmva./wtg_con(ix,5);
            xpp = wtg_con(ix,33)*basmva./genbasmva_wtg_i;
            zpp = rpp +1i*xpp;
            if zpp~=0
                ixbus_wtg = find(bus(:,1)==wtg_con(ix,2));
                ypp = 1/zpp;
                Gpp = real(ypp);
                Bpp = imag(ypp);
                if bus(ixbus_wtg,8)~=0
                    error('The bus to which the WTG is connected should not have shunt conductance');
                end
                if bus(ixbus_wtg,9)~=0
                    error('The bus to which the WTG is connected should not have line charging');
                end

                bus(ixbus_wtg,8) = Gpp;
                bus(ixbus_wtg,9) = Bpp;
                
%                 bus(ixbus_wtg,11) = bus(ixbus_wtg,11) + 10.0*wtg_con(ix,5)/basmva;
%                 bus(ixbus_wtg,12) = bus(ixbus_wtg,12) - 10.0*wtg_con(ix,5)/basmva;
                bus(ixbus_wtg,11) = bus(ixbus_wtg,11) + 10.0*genbasmva_wtg_i/basmva;
                bus(ixbus_wtg,12) = bus(ixbus_wtg,12) - 10.0*genbasmva_wtg_i/basmva;
                
            end
        elseif wtg_con(ix,3) == 4
            ixbus_wtg = find(bus(:,1)==wtg_con(ix,2));
            wtgbase_i = wtg_con(ix,4); % Base MVA of the wtg. 162 for the GE model
            genbasmva_wtg_i = wtgbase_i*10/9;
            bus(ixbus_wtg,11) = bus(ixbus_wtg,11) + 10.0*genbasmva_wtg_i/basmva;
            bus(ixbus_wtg,12) = bus(ixbus_wtg,12) - 10.0*genbasmva_wtg_i/basmva;
        end
        
        % 3. vwini - initial wind velocity
%         ixvw = find(wtg_con(ix,1) == vw_wtg(:,1));
%         if isempty(ixvw)
%             error('Wind speed not properly assigned to a WTG')
%         end
%         [fvw cvw] = size(vw_wtg);
%         if (cvw == 1)&&(fvw == 1)
%             vw_wtg_0(ix,1) = vw_wtg;
%         elseif(cvw == 1)&&(fvw == n_wtg)
%             vw_wtg_0(ix,1) = vw_wtg(ix);
%         elseif  (cvw == 12)&&(fvw == n_wtg)
%             vw_wtg_0(ix,1) = vw_wtg(ixvw,3);
%         elseif (cvw == 12)&&(fvw == 1)
%             vw_wtg_0(ix,1) = vw_wtg(1,3);
%         else
%             error('Error specifying wind profiles')        
%         end   
        vw_wtg_0(ix,1) = vw_wtg(ix,1);
        % put the minimum wind
        fl_windadj = 0;
        if  vw_wtg_0(ix,1)<3
            fl_windadj = 1;
            vw_wtg_0(ix,1) = 3;
        end
        
        Pg_wtg_lf = bus(wtg_idx2(ix),4)*basmva/wtg_con(ix,4); % in pu WTG base
        if Pg_wtg_lf > 1
            msgerr = ['Power demanded to WTG #',num2str(wtg_con(ix,1)),...
                     'at Bus ',num2str(wtg_con(ix,2)),'cannot be met. Please check WTG base'];
            error(msgerr);
        end
        
        wrefmodwtg = wtg_con(ix,66);
        if (wrefmodwtg~=1)&&(wrefmodwtg~=2)
            error('Mode of Reference of WTG not rightly specified')
        end
        wref_wtg(ix,1)= 1.2;
        if (Pg_wtg_lf <=(0.46+1e-12))&&(wrefmodwtg==1)
            wref_wtg(ix,1) = -0.75*Pg_wtg_lf.^2 + 1.59*Pg_wtg_lf + 0.63;
        end
        if (Pg_wtg_lf <=(0.75+1e-12))&&(wrefmodwtg==2)
            wref_wtg(ix,1) = (-0.67*Pg_wtg_lf + 1.42 ).*Pg_wtg_lf + 0.51;
        end
        wt_c = wref_wtg(ix,1);
        
        Klwtg(ix,1) = wtg_con(ix,10); %****mirar donde lo voy a poner
        Kpwtg(ix,1) = wtg_con(ix,11);

        % Determine lambda given a wind speed
        
        lam_wtg = Klwtg(ix)*wt_c/vw_wtg_0(ix);
        % The two dimensional Cp approximation is only valid for lambda
        % between 3 and 15. Page 4.19 GE report.
        lam_max = 15;
        lam_min = 3;
        if lam_wtg>lam_max
            disp('Lambda above limits for a wtg')
            %error('Lambda above limits for a wtg')
            fl_windadj = 1;
            vw_wtg_0(ix,1) = Klwtg(ix)*wt_c/lam_max;
        end
        if lam_wtg<lam_min
            disp('Lambda below limits for a wtg')
            error('Lambda below limits for a wtg')
        end
        
%         if  fl_windadj == 1
%             if (cvw == 1)&&(fvw == 1)
%                 vw_wtg = vw_wtg_0(ix,1);
%             elseif(cvw == 1)&&(fvw == n_wtg)
%                 vw_wtg(ix) = vw_wtg_0(ix,1);
%             elseif  (cvw == 12)&&(fvw == n_wtg)
%                 vw_wtg(ixvw,3) = vw_wtg_0(ix,1);
%             elseif (cvw == 12)&&(fvw == 1)
%                 vw_wtg(1,3) = vw_wtg_0(ix,1);
%             else
%                 error('Error specifying wind profiles')        
%             end
% %             msgPdf = ['Wind speed below limits in WTG #'...
% %                       , num2str(wtg_con(ix,1)), ' at Bus ',num2str(wtg_con(ix,2)),'. WIND SPEED ADJUSTED!!!'];
% %             uiwait(msgbox(msgPdf,'Caution','warn'));
%         end
        if  fl_windadj == 1
            vw_wtg(ix,:) = vw_wtg(ix,:) + (vw_wtg_0(ix,1) - vw_wtg(ix,1));
%             msgPdf = ['Wind speed below limits in WTG #'...
%                       , num2str(wtg_con(ix,1)), ' at Bus ',num2str(wtg_con(ix,2)),'. WIND SPEED ADJUSTED!!!'];
%             uiwait(msgbox(msgPdf,'Caution','warn'));
        end

        th_min = wtg_con(ix,27);
        th_max = wtg_con(ix,26);

        if vw_wtg_0(ix) > 25.0
            error('Initial wind speed too high')
        end

        cpwtg = cp_det(lam_wtg,th_min);
        Pwindmax = Kpwtg(ix)* cpwtg * vw_wtg_0(ix)^3;
        
        if Pwindmax < Pg_wtg_lf
%             msgPdf = ['Wind speed insufficient to produce desired electric power in WTG #'...
%                       , num2str(wtg_con(ix,1)), ' at Bus ',num2str(wtg_con(ix,2)),'. WIND SPEED ADJUSTED!!!'];
%             uiwait(msgbox(msgPdf,'Caution','warn'));
            
            % Determine wind speed to produce Pg with pitch at minimum
            errL = 99999.;
            for lam_sw = 15.0: -0.0001 : 2.0

                cpwtg = cp_det(lam_sw,th_min);
                vw_sw = Klwtg(ix)*wt_c/lam_sw;                
                Pwind = Kpwtg(ix)* cpwtg * vw_sw^3;
                errP = Pwind - Pg_wtg_lf;
                
                if( abs(errP) <= .0005 )
                    break; 
                end

                if ((abs(errP - errL) < abs(errP + errL)) || (errL > 90000))
                    errL   = errP;
                    lam_L = lam_sw;
                else

                    %  Interpolate last two points  
                    lam_sw = lam_L - errL * (lam_sw - lam_L) / (errP - errL);
                    cpwtg = cp_det(lam_sw,th_min);
                    vw_sw = Klwtg(ix)*wt_c/lam_sw; 
                    break;
                end		
            end
            th_wtg(ix,1) = th_min;
            Kpwtg(ix,1) = Pg_wtg_lf./(cpwtg * vw_sw^3); % Fudging Kp
            
%             if (cvw == 1)&&(fvw == 1)
%                 vw_wtg = vw_sw;
%             elseif(cvw == 1)&&(fvw == n_wtg)
%                 vw_wtg(ix) = vw_sw;
%             elseif  (cvw == 12)&&(fvw == n_wtg)
%                 vw_wtg(ixvw,3) = vw_sw;
%             elseif (cvw == 12)&&(fvw == 1)
%                 vw_wtg(1,3) = vw_sw;
%             else
%                 error('Error specifying wind profiles')        
%             end  
            vw_wtg(ix,:) = vw_wtg(ix,:) + (vw_sw - vw_wtg(ix,1));
            
        else
            
            cploop = 1;
            th_swp = th_min; % th_swp = (th_max - th_min)/2;
            tol_pwind = 1e-5;                

            while cploop
                cpwtg = cp_det(lam_wtg,th_swp);
                Pwind = Kpwtg(ix)* cpwtg * vw_wtg_0(ix)^3;
                errP = Pwind - Pg_wtg_lf;

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
            th_wtg(ix,1) = th_swp;
            Kpwtg(ix,1) = Pg_wtg_lf./(cpwtg * vw_wtg_0(ix)^3); % Fudging Kp
            
%             if Pg_wtg_lf < 1
%                 msgPdf = ['Spilling power in WTG #'...
%                       , num2str(wtg_con(ix,1)), ' at Bus ',num2str(wtg_con(ix,2))];
%                 uiwait(msgbox(msgPdf,'Caution','warn'));
%             end
        end
        
    end
    wtg_con_ini(:,1) = th_wtg;
    wtg_con_ini(:,2) = wref_wtg;
    
end
bus_new = bus;

function [] = vercon_busreg(Vregbuswtg,wtgbuscon,line)
% LATER
indexl = line(:,1)==wtgbuscon;

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



