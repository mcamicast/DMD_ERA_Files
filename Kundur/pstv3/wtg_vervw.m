function [] = wtg_vervw(t)
% md defines whether to interpolate or not
% Wind profile construction for wind power plants.
% It also interpolates and matches the wind profile vector with the time
% vector of the simulation (specified in sw_con).
global wtg_con n_wtg wtg_idx vw_wtg wprof_wtg

if ~isempty(wtg_con)
    [n_wtg ~] = size(wtg_con);
    %=====================================================================%
    %                   Part used for svm_mgen
    %=====================================================================%
    if isempty(t) % case when it is called for svm_mgen
        [fvw cvw] = size(vw_wtg);
        if (cvw == 1)&&(fvw == 1)

            vw_wtg = vw_wtg*ones(n_wtg,2);

        elseif(cvw == 1)&&(fvw == n_wtg)

            vw_wtg = vw_wtg*ones(1,2);

        elseif  (cvw == 12)&&(fvw == n_wtg)
            vwini = vw_wtg(:,3);
            vw_wtg = vwini*ones(1,2);
        elseif (cvw == 12)&&(fvw == 1)
            vwini = vw_wtg(1,3);
            vw_wtg = epmat(vwini,n_wtg,2);
        else
            error('Error specifying wind profiles')        
        end
        
        return
    end
    %=====================================================================%
    %=====================================================================%
    
    tsini = t(1);
    tsfin = t(end);
        
    l_t = length(t);
    [fvw cvw] = size(vw_wtg);
    
    if (cvw == 12)
        if any(tsini~=vw_wtg(:,4))
            error('Error -  no correspondence in time secuences at the beginning')
            return;
        end

        if any(tsfin~=vw_wtg(:,11))
            error('Error -  no correspondence in time secuences at the end')
            return;
        end
    end
    
    if ~isempty(wprof_wtg)
%         msgPdf = ['Wind Profile as Input File!!!'];
%         uiwait(msgbox(msgPdf,'Caution','warn'));
        for ix = 1:1:n_wtg
            tvw = linspace(tsini,tsfin,length(wprof_wtg(ix,:)));
            vw_a(ix,:) = interp1(tvw,wprof_wtg(ix,:),t);
        end
        vw_wtg = vw_a;
        return;
    end
    if (cvw == 1)&&(fvw == 1)
        
        vw_wtg = vw_wtg*ones(n_wtg,1);
        vw_wtg = repmat(vw_wtg,1,l_t);
        
    elseif(cvw == 1)&&(fvw ==n_wtg)
        
        vw_wtg = repmat(vw_wtg,1,l_t);
        
    elseif  (cvw == 12)&&(fvw == n_wtg)
        
        % making correspondence according to the wtg number
        wtg_idx_vw = [];
        for ix = 1:1:n_wtg
            index = find(wtg_con(ix,1) == vw_wtg(:,1));
            wtg_idx_vw = [wtg_idx_vw index];
        end
        
        if ~( ( length(wtg_con(:,1)) == length(vw_wtg(:,1)) ) && ( length(wtg_idx_vw) == length(vw_wtg(:,1)) ) )
            error('Verify the way wind profiles are assigned to WTG')
        end
        
        vw_wtg = vw_wtg(wtg_idx_vw,:);
        vw_a = zeros(n_wtg,l_t);
        for ix = 1:1:n_wtg
            tini = vw_wtg(ix,4);
            tgini = vw_wtg(ix,5);
            tfin = vw_wtg(ix,11);
            tgdur = vw_wtg(ix,7);
            tstep = vw_wtg(ix,12);
            vwini = vw_wtg(ix,3);
            vgamp = vw_wtg(ix,6);

            tsdur = vw_wtg(ix,8);
            vgamp2 = vw_wtg(ix,9);
            tgdur2 = vw_wtg(ix,10);
            if vw_wtg(ix,2) == -1
                modvw = 'sin';
            elseif vw_wtg(ix,2) == -2
                modvw = 'ramp';
            end
            
            [vw,tvw] = windprofset(modvw,vwini,tini,tgini,vgamp,tgdur,tsdur,vgamp2,tgdur2,tfin,tstep);
            
            vw_a(ix,:) = interp1(tvw,vw,t);

            %figure, plot(t,vw_a(ix,:))
        end
        vw_wtg = vw_a;
    elseif (cvw == 12)&&(fvw == 1)

        tini = vw_wtg(1,4);
        tgini = vw_wtg(1,5);
        tfin = vw_wtg(1,11);
        tgdur = vw_wtg(1,7);
        tstep = vw_wtg(1,12);
        vwini = vw_wtg(1,3);
        vgamp = vw_wtg(1,6);

        tsdur = vw_wtg(1,8);
        vgamp2 = vw_wtg(1,9);
        tgdur2 = vw_wtg(1,10);
        if vw_wtg(1,2) == -1
            modvw = 'sin';
        elseif vw_wtg(1,2) == -2
            modvw = 'ramp';
        end
%         tini = vw_wtg(1,2);
%         tgini = vw_wtg(1,3);
%         tfin = vw_wtg(1,4);
%         tgdur = vw_wtg(1,5);
%         tstep = vw_wtg(1,6);
%         vwini = vw_wtg(1,7);
%         vgamp = vw_wtg(1,8);
%         if vw_wtg(1,9) == -1
%                 modvw = 'sin';
%         elseif vw_wtg(1,9) == -2
%                 modvw = 'ramp';
%         end
            
        [vw,tvw] = windprofset(modvw,vwini,tini,tgini,vgamp,tgdur,tsdur,vgamp2,tgdur2,tfin,tstep);
            
        vw_a = interp1(tvw,vw,t);
        vw_wtg = repmat(vw_a,n_wtg,1);
        
    else
        error('Error - Number of wind inputs is different of number of wind power plants')
    end    
    
end