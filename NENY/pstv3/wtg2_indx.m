function [bus_new] = wtg2_indx(bus,line)

global wtg2_con load_con n_wtg2 wtg2_idx wtg2_idx2 basmva
global sl_wtg2 ws_wtg2 bus_int

n_wtg2 = size(wtg2_con,1);
if ~isempty(wtg2_con)
% Note that WTG Type 2 is modeled as a PV bus for the loadflow. As such P
% and V are suposed to remain constant for that Bus under the loadflow
% (unless limits are hit). So here, before the loadflow we assume P and V
% are given and from it the Rrtot can be calculated, since the initial slip
% is given in the WTG parameter data.

    tol = 1e-8;   % tolerance for convergence
    iter_max = 30; % maximum number of iterations
    acc = 1.0;   % acceleration factor
    [bus_sol,line,line_flw] = ...
    loadflow(bus,line,tol,iter_max,acc,'n',2);
    bus_or = bus;
    bus = bus_sol;  % solved loadflow to find out how much Q the WTG should produce
    bus_new = bus_or;
  

    wtg2_ix = 1:n_wtg2; % OJO CONFIRMAR
    % wtg2_idx2 = bus_int(wtg2_con(:,2)); % OJO CONFIRMAR
    
    wtg2_idx2 = zeros(n_wtg2,1);
    for ix = 1:n_wtg2
        index2 = find(bus(:,1) == wtg2_con(ix,2));
        if ~isempty(index2)
            wtg2_idx2(ix) = index2; % index relative to bus_v
        end
    end
%     
%     if any(wtg2_idx2 - wtg2_idx2_C)
%         error('Indexing error WTG Type 2')
%     end

%     wtg2base = wtg2_con(wtg2_ix,3);
%     genbasmva_wtg2 = 10/9*wtg2base;
%     Rswtg2 = wtg2_con(wtg2_ix,4);
%     XAwtg2 = wtg2_con(wtg2_ix,5);
%     XMwtg2 = wtg2_con(wtg2_ix,6);
%     Xrwtg2 = wtg2_con(wtg2_ix,7);
%     Rrwtg2 = wtg2_con(wtg2_ix,8);
%     spdrotwtg2 = wtg2_con(wtg2_ix,9);
%     
%     ws_wtg2 = 1.0;
%     Vtwtg2 = bus(wtg2_idx2,2).*exp(1i*bus(wtg2_idx2,3)*pi/180); %Cambioindx
%     Vtmagwtg2 = abs(Vtwtg2);
%     
%     
%     Plf_wtg2 = -bus(wtg2_idx2,6); 
%     Qlf_wtg2 = -bus(wtg2_idx2,7);
% 
% %     Pg_wtg2 = Plf_wtg2.*(basmva./wtg2base);
% %     Qg_wtg2 = Qlf_wtg2.*(basmva./wtg2base);
%             
%     Pgint_wtg2 = Plf_wtg2.*(basmva./genbasmva_wtg2);
%     
%     for idx = 1:n_wtg2
%             
%         sl_wtg2(idx,1)= -(ws_wtg2 - spdrotwtg2(idx))/ws_wtg2;
%         spdrotwtg2 = wtg2_con(wtg2_ix,9);
%         Ra = Rswtg2(idx);
%         Xm = XMwtg2(idx);
%         Xa = XAwtg2(idx);
%         Xr = Xrwtg2(idx);
%         
%             Rrl = linspace(0,0.25,10000);
%             Zeq = Ra + 1i.*Xa + (1i.*Xm.*(1i.*Xr + Rrl./sl_wtg2(idx,1)))./(1i.*Xm + (1i.*Xr + Rrl./sl_wtg2(idx,1)));
%             It = Vtmagwtg2(idx)./Zeq;
%             St = Vtmagwtg2(idx).*(It');
%             Pt = real(St);
%             [~, ixRPtmax] = max(Pt);
%             
%             Rr_min = Rrl(ixRPtmax);
%             Rr_max = 0.25;
%             Rr_swp = Rr_min; % = (Rr_max - Rr_min)/2;
%             Rr_loop = 1;
%             tol_rrot = 1e-10;
%             while Rr_loop
%                 Rr = Rr_swp;
%                 Zeq = Ra + 1i.*Xa + (1i.*Xm.*(1i.*Xr + Rr./sl_wtg2(idx,1)))./(1i.*Xm + (1i.*Xr + Rr./sl_wtg2(idx,1)));
%                 Zeq_r = real(Zeq);
%                 Zeq_mag = abs(Zeq);
% 
%                 Pgit = (Zeq_r./(Zeq_mag.^2)).*Vtmagwtg2(idx)^2;
% 
%                 errP = Pgit - Pgint_wtg2(idx);
% 
%                 if errP > tol_rrot
%                     Rr_min = Rr_swp;
%                     Rr_swp = (Rr_max - Rr_swp)/2 + Rr_swp;
%                 elseif errP < -tol_rrot
%                     Rr_max = Rr_swp;
%                     Rr_swp = (Rr_swp - Rr_min)/2  + Rr_min;
%                 else
%                     Rr_loop = 0;
%                 end
%             end
% 
% %         Rr_min = 0.0001;
% %         Rr_max = 0.01640164;
% % 
% %         Rr_loop = 1;
% %         tol_rrot = 1e-8;
% % 
% %         Rr_swp = Rr_min; % = (Rr_max - Rr_min)/2;
% % 
% % 
% %         while Rr_loop
% %             Rr = Rr_swp;
% %             Zeq = Ra + 1i.*Xa + (1i.*Xm.*(1i.*Xr + Rr./sl_wtg2(idx,1)))./(1i.*Xm + (1i.*Xr + Rr./sl_wtg2(idx,1)));
% %             Zeq_r = real(Zeq);
% %             Zeq_mag = abs(Zeq);
% % 
% %             Vit = sqrt(Pgint_wtg2(idx).*Zeq_mag.^2./Zeq_r);
% % 
% %             errV = Vit - Vtmagwtg2(idx);
% % 
% %             if errV > tol_rrot
% %                 Rr_min = Rr_swp;
% %                 Rr_swp = (Rr_max - Rr_swp)/2 + Rr_swp;
% %             elseif errV < -tol_rrot
% %                 Rr_max = Rr_swp;
% %                 Rr_swp = (Rr_swp - Rr_min)/2  + Rr_min;
% %             else
% %                 Rr_loop = 0;
% %             end
% %         end
% 
%         Rrtotwtg2(idx,1) = Rr_swp;
% 
% %         slipdet = abs(sl_wtg2(idx,k));
% %         Psig_wtg2(idx,1) = fixpt_interp1(...
% %                        Slipdatwtg2(idx,:),Powrdatwtg2(idx,:),slipdet,...
% %                        sfix(16),2^-16,sfix(16), 2^-14,'Nearest');
% 
%     end
%     
%     Zeq = Ra + 1i.*Xa + (1i.*Xm.*(1i.*Xr + Rrtotwtg2./sl_wtg2(idx,1)))./(1i.*Xm + (1i.*Xr + Rrtotwtg2./sl_wtg2(idx,1)));
%     Iwtg2 = Vtwtg2./Zeq;
%     
%     %- Swtg2 = Vtwtg2.*conj(Iwtg2);
%     %- Swtg2 = Swtg2.*genbasmva_wtg2./basmva;
%     % Include capacitor
%     %- Qact_wtg2 = imag(Swtg2);
%     %- Qinj_Bc = Qlf_wtg2 + Qact_wtg2;
%     %- Bc = Qinj_Bc./(Vtmagwtg2.^2);
%     bus_new = bus_or;
% %     bus_new(wtg2_idx2,7) = -Qinj_Bc;
% %     bus_new(wtg2_idx2,9) = -Bc + bus(wtg2_idx2,9);
else
    bus_new = bus;
    
end