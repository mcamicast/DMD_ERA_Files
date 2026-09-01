function [senstr] = standa_wtg_sens(dfile,pathname,sys_freq_i,basmva_i,parsens_wtg)
% Inputs:
% dfile -file name
% pathname -path where the file is
% The file to read should contain the following variables:
%  t - a time profile
%  vtwtg_pr - a voltage profile of the same size as time profile
% S0 -initial active and reactive power
% wtg_con - matrix of parameters of WTG

caspar = [34 40 41 55 56 57 58 60 61];
 [Lia,~] = ismember(parsens_wtg,caspar);
if any(~Lia)
    error('NOT a valid parameter specified')
end

lfile = length(dfile); curpath = cd; cd(pathname);
% check either a mat file or a m file
switch dfile(find(dfile=='.'):end)
    case '.mat'
        load(dfile)
    case '.m'
        % strip off .m and convert to lower case %msgbox('case .m')
        dfile = dfile(1:lfile-2); % dfile = lower(dfile(1:lfile-2));
        run(dfile)% eval(dfile);
    otherwise
        error('file extension not supported')
end
cd(curpath);

if (wtg_con(52)==2) && (any(parsens_wtg == 41))
    error('Parameter KVi-41- cannot be identified with Q control set = 2')
end

fpath = pathname;
nSENSfile = 'nSENStanda_sid';
save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','Swtg_pr');
sstr = standa_wtg([nSENSfile,'.mat'], fpath, 60, 100,[],[]);
It_wtg_or = sstr.It_wtg;
% Itre_wtg_or = real(It_wtg_or);
% Itim_wtg_or = imag(It_wtg_or);
dIt_dkpllp_wtg = [];
dIt_dkQi_wtg = [];
dIt_dkVi_wtg = [];
dIt_dTv_wtg = [];
dIt_dkpv_wtg = [];
dIt_dkiv_wtg = [];
dIt_dTc_wtg = [];
dIt_dTlpd_wtg = [];
dIt_dkqd_wtg = [];
SmatC = [];

p_ratio = 1e-5;
for hx = 1:length(parsens_wtg)
    
    p_ids = parsens_wtg(hx);
    
    pert = p_ratio*abs(wtg_con(p_ids));
    aux = wtg_con(p_ids);
    wtg_con(p_ids) = wtg_con(p_ids) + pert;
    save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','Swtg_pr');
    sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i,[],[]);
    wtg_con(p_ids) = aux;
    
    switch parsens_wtg(hx)
        
        case 34 % Kpllp
%             pert = p_ratio*abs(wtg_con(34));
%             aux = wtg_con(34);
%             wtg_con(34) = wtg_con(34) + pert;
%             save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','Swtg_pr');
%             sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i,[],[]);
%             wtg_con(34) = aux;
            
            It_wtg_dkpllp = sstr.It_wtg;
            dIt_dkpllp_wtg = (It_wtg_dkpllp - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dkpllp_wtg.'];
        case 40 % kQi
%             pert = p_ratio*abs(wtg_con(40));
%             aux = wtg_con(40);
%             wtg_con(40) = wtg_con(40) + pert;
%             save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','Swtg_pr');
%             sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i,[],[]);
%             wtg_con(40) = aux;
            
            It_wtg_dkQi = sstr.It_wtg;
            dIt_dkQi_wtg = (It_wtg_dkQi - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dkQi_wtg.'];
        case 41 % kVi
            It_wtg_dkVi = sstr.It_wtg;
            dIt_dkVi_wtg = (It_wtg_dkVi - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dkVi_wtg.'];
        case 55 % Tv
            It_wtg_dTv = sstr.It_wtg;
            dIt_dTv_wtg = (It_wtg_dTv - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dTv_wtg.'];
        case 56 % Kpv
            It_wtg_dkpv = sstr.It_wtg;
            dIt_dkpv_wtg = (It_wtg_dkpv - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dkpv_wtg.'];
        case 57 %Kiv
            It_wtg_dkiv = sstr.It_wtg;
            dIt_dkiv_wtg = (It_wtg_dkiv - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dkiv_wtg.'];
        case 58 % Tc
            It_wtg_dTc = sstr.It_wtg;
            dIt_dTc_wtg = (It_wtg_dTc - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dTc_wtg.'];
        case 60 % Tlpd
            It_wtg_dTlpd = sstr.It_wtg;
            dIt_dTlpd_wtg = (It_wtg_dTlpd - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dTlpd_wtg.'];
        case 61 % Kqd
            It_wtg_dkqd = sstr.It_wtg;
            dIt_dkqd_wtg = (It_wtg_dkqd - It_wtg_or)/pert;
            SmatC = [SmatC dIt_dkqd_wtg.'];
        otherwise
            error('NOT a valid parameter')
    end 
    
end

% senstr. = ;
senstr.t = t;
senstr.It_wtg_or = It_wtg_or;
senstr.dIt_dkpllp_wtg = dIt_dkpllp_wtg;
senstr.dIt_dkQi_wtg = dIt_dkQi_wtg;
senstr.dIt_dkVi_wtg = dIt_dkVi_wtg;
senstr.dIt_dTv_wtg = dIt_dTv_wtg;
senstr.dIt_dkpv_wtg = dIt_dkpv_wtg;
senstr.dIt_dkiv_wtg = dIt_dkiv_wtg;
senstr.dIt_dTc_wtg = dIt_dTc_wtg;
senstr.dIt_dTlpd_wtg = dIt_dTlpd_wtg;
senstr.dIt_dkqd_wtg = dIt_dkqd_wtg;

senstr.SmatC = SmatC;