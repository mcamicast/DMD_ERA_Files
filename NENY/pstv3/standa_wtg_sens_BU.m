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
It_wtg_or = sstr.It_wtg;
% Itre_wtg_or = real(It_wtg_or);
% Itim_wtg_or = imag(It_wtg_or);
dIt_dkpllp_wtg = [];
dIt_dkQi_wtg = [];
dIt_dkVi_wtg = [];
dIt_dkpv_wtg = [];
dIt_dkiv_wtg = [];

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
            
            It_wtg_dkpllp = sstr.It_wtg;
            dIt_dkpllp_wtg = (It_wtg_dkpllp - It_wtg_or)/pert;
        case 40 % kQi
            pert = p_ratio*abs(wtg_con(40));
            aux = wtg_con(40);
            wtg_con(40) = wtg_con(40) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(40) = aux;
            
            It_wtg_dkQi = sstr.It_wtg;
            dIt_dkQi_wtg = (It_wtg_dkQi - It_wtg_or)/pert;
        case 41 % kVi
            pert = p_ratio*abs(wtg_con(41));
            aux = wtg_con(41);
            wtg_con(41) = wtg_con(41) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(41) = aux;
            
            It_wtg_dkVi = sstr.It_wtg;
            dIt_dkVi_wtg = (It_wtg_dkVi - It_wtg_or)/pert;
        case 56 % kpv
            pert = p_ratio*abs(wtg_con(56));
            aux = wtg_con(56);
            wtg_con(56) = wtg_con(56) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(56) = aux;
            
            It_wtg_dkpv = sstr.It_wtg;
            dIt_dkpv_wtg = (It_wtg_dkpv - It_wtg_or)/pert;
        case 57 %kiv
            pert = p_ratio*abs(wtg_con(57));
            aux = wtg_con(57);
            wtg_con(57) = wtg_con(57) + pert;
            save([fpath, nSENSfile],'t','vtwtg_pr','wtg_con','S0');
            sstr = standa_wtg([nSENSfile,'.mat'], fpath, sys_freq_i, basmva_i);
            wtg_con(57) = aux;
            
            It_wtg_dkiv = sstr.It_wtg;
            dIt_dkiv_wtg = (It_wtg_dkiv - It_wtg_or)/pert;
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
senstr.dIt_dkpv_wtg = dIt_dkpv_wtg;
senstr.dIt_dkiv_wtg = dIt_dkiv_wtg;
