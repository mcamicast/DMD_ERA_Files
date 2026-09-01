function f = mexc_sig(t,k)
% Syntax: f = mexc_sig(t,k)
% 1:20 PM 15/08/97
% defines modulation signal for exciter control
global exc_sig mac_spd n_exc frec maqui_num pnts_lwnr lwnri ...
       Alqg Blqg Clqg Dlqg Klqg Glqg xlqg Kopt
f=0; %dummy variable
if n_exc~=0
if t<=2.0 % (t<=tiC)||(t>=tiC+teZ) %
    exc_sig(:,k) = zeros(n_exc,1);
 else
%     exc_sig(:,k) = zeros(n_exc,1);
    exc_sig(1,k) = 0.2000*sin(2*pi*pnts_lwnr(lwnri)*t);

%% Control LQG (Estimator and Regulator)
%     xlqg = (Alqg-Blqg*Klqg)*xlqg-Glqg'*(Clqg*xlqg+(1-mac_spd(:,k)));
%     exc_sig(:,k) = -Klqg*xlqg;
%% Control OPT (Optimal Regulator - 0.05 week gain in to discrete time)  
%     exc_sig(:,k) = 0.05*Kopt*(1-mac_spd(:,k));

 end
end
return