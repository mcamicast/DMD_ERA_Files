function f = shtr(i,k,bus,flag)
% Syntax: f = tcsr(i,k,bus,flag)
% 29/12/98
% Purpose: Shunt reactor 
%          with vectorized computation option
%          NOTE - Shunt reactor must be declared as nonconforming load
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

% tcsc variables
global shtr_con n_shtr shtr_idx shtr_idx2
global Yshtr frfilt_shtr shtr_sig
global dYshtr dfrfilt_shtr dshtr_sig thrshld_shtr

if ~isempty(shtr_con)
    if flag == 0 % initialization
        if i~=0
            %later
        else
            dbshtr = shtr_con(:,6);
            thrshld_shtr = ones(n_shtr,1)*[8e-5, -8e-5];
            Yshtr(:,1) = zeros(n_shtr,1);
            dYshtr(:,1) = zeros(n_shtr,1);
            freqref_shtr = bus_freqf(shtr_idx2,1); % initial frequency - reference
            frfilt_shtr(:,1) = freqref_shtr;
            dfrfilt_shtr(:,1) = zeros(n_shtr,1);
        end
    end
    if flag == 1 % network interface computation
        % no interface calculation required - done in nc_load
    end
    if flag == 2 % Dynamic model calculation
        if i~=0
            %later
        else %vectorized computation
            
            % ShuntReactor data format
%	        1. ShuntReactor number 
%           2. bus number
%           3. Yshtr_max
%           4. Kshtr Regulator gain
%           5. Tshtr device (SVR) time constant
%           6. Deadband width (%) % only responsive to frequency reduction
%           7. Time constant of low pass filter for frequency signal
%           8. Rate of change of Yshtr

            Yshtr_max = shtr_con(:,3);
            Kshtr = shtr_con(:,4);
            Tshtr = shtr_con(:,5);
            dbshtr = shtr_con(:,6);
            Tflpf_shtr = shtr_con(:,7);
            rate_shtr_lim = shtr_con(:,8);
            
            freqref_shtr = bus_freqf(shtr_idx2,1); % initial frequency - reference
            busfreq_shtr = bus_freqf(shtr_idx2,k); % calculated through freqcalc
            
            dfrfilt_shtr(:,k) = 1./Tflpf_shtr.*(busfreq_shtr - frfilt_shtr(:,k));
            
            Yshdes = freqref_shtr - frfilt_shtr(:,k);
            frq_err_ix = (freqref_shtr - frfilt_shtr(:,k))<(dbshtr + thrshld_shtr(:,1)); % only consider dips in freq
            thrshldaux = thrshld_shtr(frq_err_ix,1);
            thrshld_shtr(frq_err_ix,1) = thrshld_shtr(frq_err_ix,2);
            thrshld_shtr(frq_err_ix,2) = thrshldaux;
%             if any(frq_err_ix)
%                 disp('e')
%             end
            Yshdes(frq_err_ix) = 0;
            
            dYshtr(:,k) = (1./Tshtr).*(shtr_sig(:,k) + Kshtr.*Yshdes - Yshtr(:,k));
            
            % rate limit check
            ix_dY_max = dYshtr(:,k) > rate_shtr_lim;
            dYshtr(ix_dY_max,k) = rate_shtr_lim(ix_dY_max);
            ix_dY_min = dYshtr(:,k) < -rate_shtr_lim;
            dYshtr(ix_dY_min,k) = -rate_shtr_lim(ix_dY_min);
            
            % anti-windup reset
            % CHECK wind up limits
            % CHECK max limit
            ix_Ymax = Yshtr(:,k) > Yshtr_max;
            Yshtr(ix_Ymax,k) = Yshtr_max(ix_Ymax);
            % No CHECK min because it's not suppose to act due to -frq_err_ix
           
            % set rate to zero
            dYshtr(ix_Ymax) = 0;
           
        end
    end
    
end