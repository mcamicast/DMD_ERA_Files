function f = mexc_sig_ne_lqg(t,k,flag)
% Syntax: f = mexc_sig(t,k)
% 1:20 PM 15/08/97
% defines modulation signal for exciter control
global exc_sig mac_spd n_exc frec maqui_num pnts_lwnr lwnri ...
       Alqg Blqg Clqg Dlqg Klqg Glqg xlqg Kopt gengen
f=0; %dummy variable
if n_exc~=0
if t<=0.01 % (t<=tiC)||(t>=tiC+teZ) %
     exc_sig(:,k) = zeros(n_exc,1);
 else
%     exc_sig(:,k) = zeros(n_exc,1);
%     exc_sig(47,k) = 0.001*sin(2*pi*pnts_lwnr(lwnri)*t);

%% Control LQG --------------------------------- Activar
    % xlqg = Alqg*xlqg+Blqg*(1-mac_spd(:,k));
    % exc_sig(:,k) = Clqg*xlqg+Dlqg*(1-mac_spd(:,k));
    % exc_sig([4 12 14 15 16],k) = Clqg*xlqg+Dlqg*(1-mac_spd(:,k));
%% Control LQG (Estimator and Regulator)
    if flag ~= 2
        xlqg = (Alqg-Blqg*Klqg)*xlqg - Glqg'*(Clqg*xlqg+(1-mac_spd(:,k)));
        exc_sig(gengen,k) = -Klqg*xlqg;
    elseif flag == 2
        mac_spd_1 = mac_spd(:,(k-60));
        xlqg = (Alqg-Blqg*Klqg)*xlqg - Glqg'*(Clqg*xlqg+(1-mac_spd_1));
        exc_sig(gengen,k) = -Klqg*xlqg;
    end

%% Control OPT (Optimal Regulator - 0.05 week gain in to discrete time)  
%     exc_sig(:,k) = 0.05*Kopt*(1-mac_spd(:,k));

 end
end
return