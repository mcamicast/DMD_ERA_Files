function [senstr] = standa_wtg_sens(dfile,pathname,sys_freq_i,basmva_i,parsens_wtg)
% Inputs:
% dfile -file name
% pathname -path where the file is
% The file to read should contain the following variables:
%  t - a time profile
%  vtwtg_pr - a voltage profile of the same size as time profile
% S0 -initial active and reactive power
% wtg_con - matrix of parameters of WTG


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

fpath = pathname;
nSENSfile = 'nSENStanda_sid';
save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
sstr = standa_wtg([nSENSfile,'.mat'], fpath, 60, 100);
Is_wtg_or = sstr.Is_wtg;
% Isre_wtg_or = real(Is_wtg_or);
% Isim_wtg_or = imag(Is_wtg_or);
dIs_dkpllp_wtg = [];
dIs_dkQi_wtg = [];
dIs_dkVi_wtg = [];
dIs_dkpv_wtg = [];
dIs_dkiv_wtg = [];

p_ratio = 1e-5;
for hx = 1:length(parsens_wtg)
    
    switch parsens_wtg(hx)
        case 34 % Kpllp
            pert = p_ratio*abs(wtg_con(34));
            aux = wtg_con(34);
            wtg_con(34) = wtg_con(34) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(34) = aux;
            
            Is_wtg_dkpllp = sstr.Is_wtg;
            dIs_dkpllp_wtg = (Is_wtg_dkpllp - Is_wtg_or)/pert;
        case 40 % kQi
            pert = p_ratio*abs(wtg_con(40));
            aux = wtg_con(40);
            wtg_con(40) = wtg_con(40) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(40) = aux;
            
            Is_wtg_dkQi = sstr.Is_wtg;
            dIs_dkQi_wtg = (Is_wtg_dkQi - Is_wtg_or)/pert;
        case 41 % kVi
            pert = p_ratio*abs(wtg_con(41));
            aux = wtg_con(41);
            wtg_con(41) = wtg_con(41) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(41) = aux;
            
            Is_wtg_dkVi = sstr.Is_wtg;
            dIs_dkVi_wtg = (Is_wtg_dkVi - Is_wtg_or)/pert;
        case 56 % kpv
            pert = p_ratio*abs(wtg_con(56));
            aux = wtg_con(56);
            wtg_con(56) = wtg_con(56) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(56) = aux;
            
            Is_wtg_dkpv = sstr.Is_wtg;
            dIs_dkpv_wtg = (Is_wtg_dkpv - Is_wtg_or)/pert;
        case 57 %kiv
            pert = p_ratio*abs(wtg_con(57));
            aux = wtg_con(57);
            wtg_con(57) = wtg_con(57) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(57) = aux;
            
            Is_wtg_dkiv = sstr.Is_wtg;
            dIs_dkiv_wtg = (Is_wtg_dkiv - Is_wtg_or)/pert;
        otherwise
            error('NOT a valid parameter')
    end 
    
end

% senstr. = ;
senstr.t = t;
senstr.Is_wtg_or = Is_wtg_or;
senstr.dIs_dkpllp_wtg = dIs_dkpllp_wtg;
senstr.dIs_dkQi_wtg = dIs_dkQi_wtg;
senstr.dIs_dkVi_wtg = dIs_dkVi_wtg;
senstr.dIs_dkpv_wtg = dIs_dkpv_wtg;
senstr.dIs_dkiv_wtg = dIs_dkiv_wtg;
