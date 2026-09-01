function [bus_new] = ccinj_indx(bus,line)
% determines the relationship between wtg and nc loads
% checks for wtg
% determines number of wtgs
% % f is a dummy variable
% % f = 0;

global ccinj_con load_con n_ccinj ccinj_idx ccinj_idx2

n_ccinj = size(ccinj_con,1);
if ~isempty(ccinj_con)
    for ix = 1:n_ccinj
        index = find(ccinj_con(ix,2)==load_con(:,1));
        if ~isempty(index)
            ccinj_idx(ix) = index; % relative index to load_con
        else
            error('you must have the Constant Current Injection declared as a non-conforming load')
            return;
        end
        index2 = find(bus(:,1) == ccinj_con(ix,2));
        if ~isempty(index2)
            ccinj_idx2(ix) = index2; % index relative to bus_v
        end
        
%         ixccibus = bus(:,1) == ccinj_con(ix,2);
%         if (bus(ixccibus,10) ~= 2)
%             error('CCInj should be defined as a PV (gen) bus')
%         end
    end
end
bus_new = bus;
