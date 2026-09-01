function [] = wpprbuslf()



Pbus = ;
Vbusmag = ;
Vbusang = ;
Qwpp = ;
% Pwpp = ;

xpp = ;
rpp = 0;

Vwppmag = 1.0;
Vwppang = Vbusang;

zpp = rpp + 1i*xpp;
Vb = Vbusmag*exp(1i*Vbusang);
Vwpp = Vwppmag*exp(1i*Vwppang);

It = (vw - vb)/(zpp);
Itmag = abs(It);
Itang = angle(It);

Pbusc = Itmag^2*abs(zpp)*cos(angle(zpp)) + Vbmag*Itmag*cos(Vbusang - Itang) - Itmag^2*rpp;
Qwppc = Itmag^2*abs(zpp)*sin(angle(zpp)) + Vbmag*Itmag*sin(Vbusang - Itang);


dPb_dd = Vbmag*Itmag*sin(Vbusang - Itang);
dPb_dIt = 2*Itmag*abs(zpp)*cos(angle(zpp)) + Vbmag*cos(Vbusang - Itang) - 2*Itmag*rpp;

dQw_dd = -Vbmag*Itmag*cos(Vbusang - Itang);
dQw_dIt = 2*Itmag*abs(zpp)*sin(angle(zpp)) + Vbmag*sin(Vbusang - Itang);



