% function [vw,t] = windprofset(modvw,vwini,tini,tgini,vgamp,tgdur,tfin,tstep)
function [vw,t] = windprofset(modvw,vwini,tini,tgini,vgamp,tgdur,tsdur,vgamp2,tgdur2,tfin,tstep)

% ramp
% sin

% tini = 0;
% tfin = 12;
% tgini = 5;
% tgdur=3;
% 
% tstep = 0.001;
% vwini = 14;
% vgamp = -5;
% 
% %modvw = 'sin';
% modvw = 'ramp';

if (vwini<0)||((vwini + vgamp)<0)
    error('ERROR -  wind speed cannot be negative')
%     return;
end
if (tini + tgdur > tfin)
    error('ERROR -  Final time is less than initial time plus the duration of the wind gust')
%     return;
end

if strcmp(modvw,'sin')
    
    
    t_aux = (0:tstep:tgdur);
    % vwgust = vgamp*sin(pi/tgdur*t_aux) + vwini;
    vwgust = vgamp*((1 - cos(2*pi/tgdur*t_aux))/2) + vwini;
    t_aux = t_aux + tgini;
    t = (tini:tstep:tini+tgini);
    t(end) = [];
    vw = vwini*ones(size(t));
    vw = [vw vwgust];
    t = [t t_aux];
    
    t_aux = (tgini+tgdur:tstep:tfin);
    t_aux(1) = [];
    vwf = vwini*ones(size(t_aux));
    
    vw = [vw vwf];
    t = [t t_aux];
    
    %figure, plot(t,vw), ylim([0 20])
    
    
elseif strcmp(modvw,'ramp')
    
    t_aux = (0:tstep:tgdur);
    vwramp = vgamp*t_aux/tgdur + vwini;
    t_aux = t_aux + tgini;
    t = (tini:tstep:tini+tgini);
    t(end) = [];
    vw = vwini*ones(size(t));
    vw = [vw vwramp];
    t = [t t_aux];
    
    t_aux = (tgini+tgdur:tstep:tgini+tgdur+tsdur);
    t_aux(1) = [];
    vwf = (vwini+vgamp)*ones(size(t_aux));
    
    vw = [vw vwf];
    t = [t t_aux];
        
%     t_aux = (tgini+tgdur+tsdur:tstep:tgini+tgdur+tsdur+tgdur2);
    t_aux = (0:tstep:tgdur2);
    t_aux(1) = [];
    vwramp2 = vgamp2*t_aux/tgdur2 + (vgamp +vwini);
    t_aux = t_aux + tgini + tgdur + tsdur;
    vw = [vw vwramp2];
    t = [t t_aux];
    
    
    t_aux = (tgini+tgdur+tsdur+tgdur2:tstep:tfin);
    t_aux(1) = [];
    vwf = ((vgamp +vwini) + vgamp2)*ones(size(t_aux));
    
    vw = [vw vwf];
    t = [t t_aux];

    if any(vw<0)
       error('Wind speed cannot be negative!. Check matrix: vw_wtg') 
    end
    
%     t_aux = (tgini+tgdur:tstep:tfin);
%     t_aux(1) = [];
%     vwf = (vwini+vgamp)*ones(size(t_aux));
%     
%     vw = [vw vwf];
%     t = [t t_aux];
%     
    %figure, plot(t,vw), ylim([0 20])
    
end



