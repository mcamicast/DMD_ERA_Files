function f = mpm_sig(t,k)
% Syntax: f = mpm_sig(t,k)
% 1:19 PM 15/08/97
% defines modulation signal for generator mechanical power
global pm_sig n_pm mac_spd lwnri pnts_lwnr 
f=0; %dummy variable
if n_pm~=0
   pm_sig(:,k) = zeros(n_pm,1);
% f1C=0.1;f2C=3;tfC=56;tiC=2;
% teZ=round(2*tfC*(f2C-f1C)/log(f2C/f1C))/2*log(f2C/f1C)/(f2C-f1C);
if   t<=2.0 %(t<=tiC)||(t>=tiC+teZ) 
    pm_sig(:,k) = zeros(n_pm,1);
else
    pm_sig(:,k) = zeros(n_pm,1);
% pm_sig(1,k)=0.001*sin(2*pi*f1C*((f2C/f1C)^(1/teZ).^(t-tiC)-1)./log((f2C/f1C)^(1/teZ)));
%     pnts_lwnr(lwnri)
%     0.001*sin(2*pi*pnts_lwnr(lwnri)*t)
%     pm_sig(8,k) = 0.001*sin(2*pi*pnts_lwnr(lwnri)*t);
   %pm_sig(1,k) = 0.01;
   %pm_sig(2,k) = -0.01;
  end
end
return
