function [] = tcsr_indx(bus,line)
% syntax: f = tcsr_indx(tcsr_dc)
% January 31, 2014
% determines the relationship between TCSR and nc loads
% checks for TCSR
% determines number of TCSR


global tcsr_con n_tcsr %tcsvf_idx tcsct_idx 

global load_con Xtcsr_or tcsrf_idx tcsrt_idx tcsrf_idx2 tcsrt_idx2
global tap_tcsr phasesh_tcsr tcsrlin_idx % tcsr_idx % tcsr 

if ~isempty(tcsr_con)
    n_tcsr = size(tcsr_con,1);
    % tcsr_idx = zeros(n_tcsr,1);
    for ix = 1:n_tcsr
        index = find(tcsr_con(ix,2)==load_con(:,1));
        if ~isempty(index)
         tcsrf_idx(ix) = index;
        else
         error('you must have the tcsr buses declared as a non-conforming load')
        end
        index = find(tcsr_con(ix,3)==load_con(:,1));
        if ~isempty(index)
         tcsrt_idx(ix) = index;
        else
         error('you must have the tcsr buses declared as a non-conforming load')
        end
        idx_Xtcsr = ( ((tcsr_con(ix,2) == line(:,1)) & (tcsr_con(ix,3) == line(:,2))) |...
           ((tcsr_con(ix,3) == line(:,1)) & (tcsr_con(ix,2) == line(:,2))) );

        if size(line(idx_Xtcsr,4),1)~=1
            error('TCSR buses should not have any other element attached between them')
        end
        Xtcsr_or(ix,1) = line(idx_Xtcsr,4);
        if abs(line(idx_Xtcsr,3))>1e-8
           error('TCSR is only reactive')
        end
        tap_tcsr(ix,1) = line(idx_Xtcsr,6);
        phasesh_tcsr(ix,1) = line(idx_Xtcsr,7);
        tcsrlin_idx(ix) = find(idx_Xtcsr);
        
        indexf2 = find(bus(:,1) == tcsr_con(ix,2));
        if ~isempty(indexf2)
            tcsrf_idx2(ix) = indexf2; % index -from bus- relative to bus_v
        end
        indext2 = find(bus(:,1) == tcsr_con(ix,3));
        if ~isempty(indext2)
            tcsrt_idx2(ix) = indext2; % index -to bus- relative to bus_v
        end
        
    end

end




% f = 0;
% global tcsc_con load_con  n_tcsc  tcscf_idx tcsct_idx tcsc_idx % tcsc 
% global n_tcscud dtcscud_idx  %user defined damping controls
% if ~isempty(tcsc_con)
%    n_tcsc = size(tcsc_con,1);
%    tcsc_idx = zeros(n_tcsc,1);
%    for j = 1:n_tcsc
%       index = find(tcsc_con(j,2)==load_con(:,1));
%       if ~isempty(index)
%          tcscf_idx(j) = index;
%       else
%          error('you must have the tcsc buses declared as a non-conforming load')
%       end
%       index = find(tcsc_con(j,3)==load_con(:,1));
%       if ~isempty(index)
%          tcsct_idx(j) = index;
%       else
%          error('you must have the tcsc buses declared as a non-conforming load')
%       end
%    end
%    %check for user defined controls
%    if ~isempty(tcsc_dc)
%       n_tcscud = size(tcsc_dc,1);
%       for j = 1:n_tcscud
%          dtcscud_idx(j) = tcsc_dc{j,2};
%       end
%    end      
% end
