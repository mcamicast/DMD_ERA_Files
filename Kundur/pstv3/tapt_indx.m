function [] = tapt_indx(bus,line)
% syntax: tapt_indx(tcsr_dc)
% February 5, 2014
% determines the relationship Tap changing transformer and the bus indexes
% checks for Tap changing transformers
% determines number of Tapchanging transformers



global tapt_con n_tapt %tcsvf_idx tcsct_idx 
global tapt_sig tapt_sig_ch taptf_idx2 taptt_idx2 dfrfilt_tapt frfilt_tapt

if ~isempty(tapt_con)
    n_tapt = size(tapt_con,1);
    if length( unique(tapt_con(:,1)) ) ~= n_tapt
        error('CHECK the numbering of the Tap Changing Transformers')
    end
    for ix = 1:n_tapt
        
        
        tindexf2 = find(bus(:,1) == tapt_con(ix,2));
        if ~isempty(tindexf2)
            taptf_idx2(ix) = tindexf2; % index -from bus- relative to bus_v
        end
        tindext2 = find(bus(:,1) == tapt_con(ix,3));
        if ~isempty(tindext2)
            taptt_idx2(ix) = tindext2; % index -to bus- relative to bus_v
        end
        
    end
    tapt_sig = zeros(n_tapt,1);
    tapt_sig_ch = ones(n_tapt,1);
end