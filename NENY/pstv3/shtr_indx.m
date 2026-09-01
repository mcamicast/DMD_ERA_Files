function [] = shtr_indx(bus,line)
% syntax: f = shtr_indx(tcsr_dc)
% January 31, 2014
% determines the relationship between TCSR and nc loads
% checks for Shunt reactors
% determines number of Shunt reactors
global load_con
global shtr_con n_shtr shtr_idx shtr_idx2

if ~isempty(shtr_con)
    n_shtr = size(shtr_con,1);
    for ix = 1:n_shtr
        index = find(shtr_con(ix,2)==load_con(:,1));
        if ~isempty(index)
         shtr_idx(ix) = index;
        else
         error('you must have the Shunt reactor Bus declared as a non-conforming load')
        end
        
        index2 = find(bus(:,1) == shtr_con(ix,2));
        if ~isempty(index2)
            shtr_idx2(ix) = index2; % index -from bus- relative to bus_v
        end
    end
end