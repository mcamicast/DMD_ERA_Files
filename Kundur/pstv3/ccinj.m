function [bus_new] = ccinj(i,k,bus,flag,busi_v,t)

% Constant Current injection data format
%	        1. CC number 
%           2. Bus number
% ccinj_con = [ 1    1 ];

global Iccinj
global ccinj_con load_con n_ccinj ccinj_idx ccinj_idx2
global Pccinj Qccinj
% 

bus_new = bus;
if ~isempty(ccinj_con)
    if flag == 0 % initialization
        if i~=0
            %later
        else
            
            Vtccinj = bus(ccinj_idx2,2).*exp(1i*bus(ccinj_idx2,3)*pi/180); %Cambioindx
            Vtmagccinj = abs(Vtccinj);
            Vtangccinj = angle(Vtccinj);
            Vtreccinj = real(Vtccinj);
            Vtimccinj = imag(Vtccinj);
            
            ix_PV = (bus(ccinj_idx2,10) == 1) | (bus(ccinj_idx2,10) == 2);
            ix_PQ = bus(ccinj_idx2,10) == 3;
            
            
            Sccinj = zeros(n_ccinj,1);
            Sccinj(ix_PV,1) = bus(ccinj_idx2(ix_PV),4) + 1i*bus(ccinj_idx2(ix_PV),5);
            Sccinj(ix_PQ,1) = bus(ccinj_idx2(ix_PQ),6) + 1i*bus(ccinj_idx2(ix_PQ),7);
            
%             if (abs(bus(ccinj_idx2(ix_PQ),4) + 1i*bus(ccinj_idx2(ix_PQ),5))<tolS)||...
%                (abs(bus(ccinj_idx2(ix_PV),4) + 1i*bus(ccinj_idx2(ix_PV),5))<tolS)
%             end

            Iccinj(ix_PV,1) = -Sccinj(ix_PV)./abs(Vtccinj(ix_PV));
            Iccinj(ix_PQ,1) = Sccinj(ix_PQ)./abs(Vtccinj(ix_PQ));

%             Iccinj(ix_PV,1) = conj(Sccinj(ix_PV)./Vtccinj(ix_PV));
%             Iccinj(ix_PQ,1) = conj(-Sccinj(ix_PQ)./Vtccinj(ix_PQ));
%             Iccinj(ix_PQ,1) = -Sccinj./abs(Vtccinj);
            
        end
    end
    if flag == 1 % network interface computation
        % no interface calculation required - done in nc_load
    end
    if flag == 2 % Dynamic model calculation
        % NO dynamic calculation for current injection as it is
        Vtccinj = busi_v(ccinj_idx2,k);
        Sccinj = Vtccinj.*conj(Iccinj(:,k));
        Pccinj(:,k) = real(Sccinj); Qccinj(:,k) = imag(Sccinj);
    end
end



