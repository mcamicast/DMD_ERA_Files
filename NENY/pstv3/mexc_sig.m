function f = mexc_sig(t,k)
% Syntax: f = mexc_sig(t,k)
% 1:20 PM 15/08/97
% defines modulation signal for exciter control
global exc_sig mac_spd n_exc frec maqui_num...
    Alqg Blqg Clqg Dlqg Klqg Glqg xlqg Kopt ...
    pnts_lwnr lwnri


f=0; %dummy variable
if n_exc~=0
%  exc_sig(:,k)=zeros(n_exc,1);
%  exc_sig(1,k)=0.1;
%end
if t<=0.20
% if t<=0.0
     exc_sig(:,k) = zeros(n_exc,1);
 else
%     exc_sig(:,k) = zeros(n_exc,1);
    %exc_sig(maqui_num,k) = 0.001*sin(2*pi*frec*t);
%% Control LQG --------------------------------- Activar
    prueba = 10203;
    xlqg = Alqg*xlqg+Blqg*(1-mac_spd(:,k));
    exc_sig(:,k) = Clqg*xlqg+Dlqg*(1-mac_spd(:,k));
%     exc_sig([4 12 14 15 16],k) = Clqg*xlqg+Dlqg*(1-mac_spd(:,k));
 end
end
return