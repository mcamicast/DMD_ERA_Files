function f = mexc_sig_lqg(t,k)
% Syntax: f = mexc_sig(t,k)
% 1:20 PM 15/08/97
% defines modulation signal for exciter control
global exc_sig mac_spd n_exc frec maqui_num ...
    Alqg Blqg Clqg Dlqg Kq Gq xlqg Kopt ...
    pnts_lwnr lwnri wadc dif_mac_spd1 xlqg1 
% amp = 0.1;
% fs = 0.1; %Frecuency start
% fe = 1; %Frecuency end
% T = 20; %final time
% rf = (fe/fs)^(1/T);
f=0; %dummy variable
if n_exc~=0
    %  exc_sig(:,k)=zeros(n_exc,1);
    %  exc_sig(1,k)=0.1;
    %end
    if t<=0.1
        % if t<=0.0
        %%exc_sig(:,k) = amp*sin((2*pi*fs*((rf^t)-1))/log(rf)); %%%Activar
        %%chirp
        exc_sig(:,k) = zeros(n_exc,1);
    elseif wadc == 1
        %exc_sig(:,k) = zeros(n_exc,1);
        %% Control LQG --------------------------------- Activar
        dif_mac_spd = (1-mac_spd(:,k));
        dif_mac_spd1(:,k) = dif_mac_spd;
        xlqg = Alqg*xlqg + Blqg*dif_mac_spd;
        % xlqg = (Alqg-Blqg*Kq)*xlqg-Gq'*(Clqg*xlqg+(1-mac_spd(:,k)));
        xlqg1(:,k) = xlqg;
        exc_sig(:,k) = 1*Clqg*xlqg;% + Dlqg*dif_mac_spd;
        % exc_sig(:,k) = -Kq*xlqg;
           % % % exc_sig(maqui_num,k) = 0.001*sin(2*pi*frec*t);
            % exc_sig(1,k) = 0.01*sin(2*pi*0.1*t);
            % exc_sig(1,k) = 0.05;
            % exc_sig(1,k)= 0.023*sin(2*pi*0.01*t+((3*pi)/2));
    else
        exc_sig(:,k) = zeros(n_exc,1);
    end
end
return