clc; clear all; close all; clear memory; close all;


ftsize = 30;
lwi = 2;



dfile = 'data16m_4o2_hvdc_wind_lqg.m'; %generadores e??licos y HVDC


fpath= 'C:\Users\maria\Dropbox\Work_Cami\For_Amrit\HVDC_Wind\NENY';
%fpath= '/Users/zamora/Dropbox/Camila_Castrillon/Work_damping_control/PST_WT';
cd(fpath);
dfilex = dfile(1:end-2);
run(dfilex)
namTfile = 'd164om2_DMD.mat'; 


%save([fpath, namTfile],'bus','line','load_con','mac_con','sw_con','vw_wtg','wtg_con');
save([fpath, namTfile],'bus','line','mac_con','sw_con');


global wadc 
wadc = 1; %1 for activate LQG control 0 for deactivate

sstr_12 = s_simuf(dfile, fpath, 60, 100);
%sstr_1 = svm_mgenf(dfile, fpath, 60, 100); 

% loadflow(bus,line, 1e-9, 30, 1.0, 'y', 1);
% tMAP=sstr.t;
% spdMAP=sstr.mac_spd;
% plot(tMAP,spdMAP,'DisplayName','tMAP')

