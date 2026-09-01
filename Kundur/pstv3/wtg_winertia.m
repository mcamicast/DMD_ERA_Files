 %** frequency control (windINERTIA)************************************    

% global wtg_con Pord_wtg bus_freqf
% global s1wini_wtg s2wini_wtg 
% global ds1wini_wtg ds2wini_wtg dpwi_wtg
% global swinif_wtg
% global dpwi_wtg

thminwtg = wtg_con(wtg_ix,27);

wINIflagwtg = wtg_con(wtg_ix,67);
Kwiwtg = wtg_con(wtg_ix,68);
dbwiwtg = wtg_con(wtg_ix,69);
Tlpwiwtg = wtg_con(wtg_ix,70);
Twowiwtg = wtg_con(wtg_ix,71);
Urlwiwtg = wtg_con(wtg_ix,72);
Drlwiwtg = wtg_con(wtg_ix,73);
Pmaxwiwtg = wtg_con(wtg_ix,74);
Pminwiwtg = wtg_con(wtg_ix,75);

if flag==0 % initialization
    auxsigwini_wtg = 0; 
    freqrefwtg = bus_freqf(wtg_idx2,1); % initial frequency - reference
    busferr_wtg = freqrefwtg - (swinif_wtg(:,1) + auxsigwini_wtg);
    
    ixwINIfl_1 = wINIflagwtg == 1;
    ixwINIfl_2 = wINIflagwtg == 2;
    ixwINIfl_t = ixwINIfl_1 | ixwINIfl_2;
    
    s1wini_wtg(ixwINIfl_t,1) = busferr_wtg(ixwINIfl_t,1);
    s2wini_wtg(ixwINIfl_t,1) = Twowiwtg(ixwINIfl_t,1).*Kwiwtg(ixwINIfl_t,1).*s1wini_wtg(ixwINIfl_t,k);   
    
    ixthmn2 = th_wtg(:,k)<=(thminwtg+0.03);
    wtg_con(ixwINIfl_2&ixthmn2,67) = 0;% deactivate WindINERTIA2 mod if no headroom for it
    
    thrshldwini = ones(n_wtg,1)*[-0.02, 0.02];
end

if flag==2
    % auxiliary signal normally set to 0 except for test. As stated
    % in the report (v4.5) page 4.26
    auxsigwini_wtg = 0; 
    freqrefwtg = bus_freqf(wtg_idx2,1); %  calculated through freqcalc

    dpwiwtg = zeros(n_wtg,1);
    % if wINIflagwtg == 0 - windINERTIA disabled
    ixwINIfl_0 = wINIflagwtg == 0;
    dpwiwtg(ixwINIfl_0) = 0;

    % if wINIflagwtg == 1 - windINERTIA enabled
    % if wINIflagwtg == 2 - windINERTIA OWN
    % same working it only does not change the constants and
    % it does not work when the pitch angle is below certain level
    
    ixthmn2 = th_wtg(:,k)<=(thminwtg+0.03+thrshldwini(:,1));
    thrshldaux = thrshldwini(ixthmn2,1);
    thrshldwini(ixthmn2,1) = thrshldwini(ixthmn2,2);
    thrshldwini(ixthmn2,2) = thrshldaux;
    
    ixwINIfl_1 = wINIflagwtg == 1;
    % ixwINIfl_2 = (wINIflagwtg == 2)&(~ixthmn2);
    ixwINIfl_2 = wINIflagwtg == 2;
    ixwINIfl_t = ixwINIfl_1 | ixwINIfl_2;
    
    
    busferr_wtg = freqrefwtg - (swinif_wtg(:,k) + auxsigwini_wtg);
    ixwINI_ch = (busferr_wtg >= dbwiwtg) & ixwINIfl_1;
    Kitrqwtgn = 0.05; % pag. 4.26 GE WTG Modeling-V4.5
    Kptrqwtgn = 0.5; % pag. 4.26 GE WTG Modeling-V4.5
    Tpcwtgn = 4; % pag. 4.26 GE WTG Modeling-V4.5

    wtg_con(ixwINI_ch,22) = Kitrqwtgn; % PERMANENT Modification
    wtg_con(ixwINI_ch,23) = Kptrqwtgn; % PERMANENT Modification
    wtg_con(ixwINI_ch,25) = Tpcwtgn; % PERMANENT Modification
    
    Kppwtgn = 450;
    %Kppaux = wtg_con(ixwINI_ch2,19);
    ixwINI_ch2 = (busferr_wtg >= dbwiwtg) & ixwINIfl_2;
    %wtg_con(ixwINI_ch2,19) = Kppwtgn;
    Kppwtg(ixwINI_ch2) = Kppwtgn;
    ixwINI_db_e = (busferr_wtg < dbwiwtg) & ixwINIfl_t;
    busferr_wtg(ixwINI_db_e) = 0;

    ds1wini_wtg(ixwINIfl_t,k) = (1./Tlpwiwtg(ixwINIfl_t,1)).*(busferr_wtg(ixwINIfl_t,1) - s1wini_wtg(ixwINIfl_t,k));
    ds2wini_wtg(ixwINIfl_t,k) = Kwiwtg(ixwINIfl_t,1).*s1wini_wtg(ixwINIfl_t,k) - (1./Twowiwtg(ixwINIfl_t,1)).*(s2wini_wtg(ixwINIfl_t,k));
    
    %     Pmaxwiwtg = 0.10; % Table 4-13 Pag.4.27 GE report v4.5
    %     Pminwiwtg = 0.0;  % Table 4-13 Pag.4.27 GE report v4.5
    % Verify limits of dpwiwtg - when it hits the lower bound
    ixdpwiwtgmn = (ds2wini_wtg(:,k) <= Pminwiwtg)&ixwINIfl_t;
    ds2wini_wtg(ixdpwiwtgmn,k) = Pminwiwtg(ixdpwiwtgmn,1);

    % Verify limits of dpwiwtg - when it hits the upper bound
    ixdpwiwtgmx = (ds2wini_wtg(:,k) >= Pmaxwiwtg)&ixwINIfl_t;
    ds2wini_wtg(ixdpwiwtgmx,k) = Pmaxwiwtg(ixdpwiwtgmx,1);
    
    dpwiwtg(ixwINIfl_t) = ds2wini_wtg(ixwINIfl_t,k);
    
%     Pordext_wtg = Pord_wtg(:,k) + dpwiwtg;
end

%** end- frequency control (windINERTIA)*******************************
 