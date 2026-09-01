function f = tcsr(i,k,bus,flag)
% Syntax: f = tcsr(i,k,bus,flag)
% 29/12/98
% Purpose: Thyristor controlled series reactor, 
%          with vectorized computation option
%          NOTE - TCSC buses must be declared as 
%                 non-conforming load buses
%                 The initial capacitance must be inserted as a loss free negative reactance 
%                 between the two tcsc buses.
%                 These buses are inserted in the compensated line 
% Input: i - tcsc number: if i= 0, vectorized computation
%        	  k - integer time
%        	  bus - solved loadflow bus data
%             flag - 0 - initialization
%                    1 - network interface computation
%                    2 - generator dynamics computation
%       
%
% Output: f - a dummy variable
%                    

% (c) Copyright 1998 Joe H. Chow/Cherry Tree Scientific Software
%     All Rights Reserved

% History (in reverse chronological order)
%
% Version 1
% Date: December 1998
% Author: Graham Rogers
% system variables
global  basmva bus_int bus_freqf

% TCSR variables
global tcsr_con n_tcsr tcsrf_idx2 tcsrt_idx2 
global X_tcsr frfilt_tcsr tcsr_sig
global dX_tcsr dfrfilt_tcsr dtcsr_sig thrshld_tcsr

if ~isempty(tcsr_con)
    if flag == 0 % initialization
        if i~=0
            %later
        else
            dbtcsr = tcsr_con(:,8);
            thrshld_tcsr = ones(n_tcsr,1)*[8e-5, -8e-5];
            X_tcsr(:,1) = zeros(n_tcsr,1);
            dX_tcsr(:,1) = zeros(n_tcsr,1);
            freqref_tcsr = bus_freqf(tcsrf_idx2,1); % initial frequency - reference
            frfilt_tcsr(:,1) = freqref_tcsr;
            dfrfilt_tcsr(:,1) = zeros(n_tcsr,1);
        end
    end
    if flag == 1 % network interface computation
        % no interface calculation required - done in nc_load
    end
    if flag == 2 % Dynamic model calculation
        if i~=0
            %later
        else %vectorized computation
            % TCSR (variable reactor) data format
%	        1. TSCR number 
%           2. From bus number
%           3. To bus number
%           4. Xtcsr_max
%           5. Xtcsr_min
%           6. Ktcsr Regulator gain
%           7. Ttcsr Device (TCSR) time constant
%           8. Dead band width 
%           9. Bus frequency signal
%                        1 - Frequency of From bus 
%                        2 - Frequency of To bus
%                        3 - average frequency of to and from buses
%           10. Time constant of low pass filter for frequency signal
%           11. Rate of change of Xtcsr


            Xtcsr_max = tcsr_con(:,4);
            Xtcsr_min = tcsr_con(:,5);
            Ktcsr = tcsr_con(:,6);
            Ttcsr = tcsr_con(:,7);
            dbtcsr = tcsr_con(:,8);
            busfrix = tcsr_con(:,9);
            Tflpf_tcsr = tcsr_con(:,10);
            rate_tcsr_lim = tcsr_con(:,11);
            
%             ixfrc = tcsvf_idx2.*(busfrix == 1) + tcsvt_idx2.*(busfrix == 2);
            busfrix_1 = busfrix == 1;
            busfrix_2 = busfrix == 2;
            busfrix_3 = busfrix == 3;
            
            freqref_tcsr = bus_freqf(tcsrf_idx2,1); % initial frequency - reference
            freqref_tcsr(busfrix_2) = bus_freqf(tcsrt_idx2(busfrix_2),1);
            auxbusfr = (bus_freqf(tcsrf_idx2,1) + bus_freqf(tcsrt_idx2,1))/2;
            freqref_tcsr(busfrix_3) = auxbusfr(busfrix_3);
            
            busfreq_tcsr = bus_freqf(tcsrf_idx2,k); % calculated through freqcalc
            busfreq_tcsr(busfrix_2) = bus_freqf(tcsrt_idx2(busfrix_2),k);
            auxbusfr = (bus_freqf(tcsrf_idx2,k) + bus_freqf(tcsrt_idx2,k))/2;
            busfreq_tcsr(busfrix_3) = auxbusfr(busfrix_3);
            
            dfrfilt_tcsr(:,k) = 1./Tflpf_tcsr.*(busfreq_tcsr - frfilt_tcsr(:,k));
            
%             Xtdes = freqref_tcsr - busfreq_tcsr;
            Xtdes = freqref_tcsr - frfilt_tcsr(:,k);
            frq_err_ix = abs(freqref_tcsr - busfreq_tcsr)<(dbtcsr + thrshld_tcsr(:,1));
            thrshldaux = thrshld_tcsr(frq_err_ix,1);
            thrshld_tcsr(frq_err_ix,1) = thrshld_tcsr(frq_err_ix,2);
            thrshld_tcsr(frq_err_ix,2) = thrshldaux;
            Xtdes(frq_err_ix) = 0;
            
            dX_tcsr(:,k) = (1./Ttcsr).*(tcsr_sig(:,k) + Ktcsr.*Xtdes - X_tcsr(:,k));
            
            % rate limit check
            ix_dX_max = dX_tcsr(:,k) > rate_tcsr_lim;
            dX_tcsr(ix_dX_max,k) = rate_tcsr_lim(ix_dX_max);
            ix_dX_min = dX_tcsr(:,k) < -rate_tcsr_lim;
            dX_tcsr(ix_dX_min,k) = -rate_tcsr_lim(ix_dX_min);
            
            % anti-windup reset
            % CHECK wind up limits
            % CHECK max limit
            ix_X_max = X_tcsr(:,k) > Xtcsr_max;
%             if any(ix_X_max)
%                 disp('X reached')
%             end
            
            X_tcsr(ix_X_max,k) = Xtcsr_max(ix_X_max);
            % CHECK min limit
            ix_X_min = X_tcsr(:,k) < Xtcsr_min;
            X_tcsr(ix_X_min,k) = Xtcsr_max(ix_X_min);           
            % set rate to zero
            dX_tcsr(ix_X_max | ix_X_min,k) = 0;
            
%             freqrefwtg = bus_freqf(wtg_idx2,1); % initial frequency - reference
%             busfreq_wtg = bus_freqf(wtg_idx2,k);% calculated through freqcalc
            
        end
    end
    
end