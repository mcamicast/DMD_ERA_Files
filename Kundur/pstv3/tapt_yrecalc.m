% change in line matrix to include the tap change
% Tap transformer specified in tapt_con

% SEE if the order of -from and -to buses is important 
% Transformer with variable tap - data format
%	        1. Xfrm tap number 
%           2. From bus number
%           3. To bus number
%           4. Xfrm step
%           5. Dead band width -if reached the tap should change
%           6. Bus frequency signal
%                        1 - Frequency of From bus 
%                        2 - Frequency of To bus
%                        3 - average frequency of to and from buses
%           7. Time constant of low pass filter for frequency input

% dbpartt = .3*60/100; % ma
%          1     2     3     4      5       6      7       8       9       10 
% tapt_con = [...
%            1     9     19    0.05   dbpartt 1];

line_aux = line;
if ~isempty(tapt_con)

steptapt = tapt_con(:,4);
dbtapt = tapt_con(:,5);
Tflpf_tapt = tapt_con(:,7);

busfr_ttix = tapt_con(:,6);
busfr_ttix_2 = busfr_ttix == 2;
busfr_ttix_3 = busfr_ttix == 3;

% freqref_tapt - is a global variable
if ktapt==1
    freqref_tapt = bus_freqf(taptf_idx2,1); % initial frequency - reference
    freqref_tapt(busfr_ttix_2) = bus_freqf(taptt_idx2(busfr_ttix_2),1);
    auxbusfr = (bus_freqf(taptf_idx2,1) + bus_freqf(taptt_idx2,1))/2;
    freqref_tapt(busfr_ttix_3) = auxbusfr(busfr_ttix_3);
    frfilt_tapt(:,ktapt) = freqref_tapt;
end

busfreq_tapt = bus_freqf(taptf_idx2,ktapt); % calculated through freqcalc
busfreq_tapt(busfr_ttix_2) = bus_freqf(taptt_idx2(busfr_ttix_2),ktapt);
auxbusfr = (bus_freqf(taptf_idx2,ktapt) + bus_freqf(taptt_idx2,ktapt))/2;
busfreq_tapt(busfr_ttix_3) = auxbusfr(busfr_ttix_3);

dfrfilt_tapt(:,ktapt) = 1./Tflpf_tapt.*(busfreq_tapt - frfilt_tapt(:,ktapt));

tapt_sig = abs(freqref_tapt - frfilt_tapt(:,ktapt)) > dbtapt;

% spript to activate tap changing transformers
% February 5, 2014

% tapt_sig - flag raised when tap change is needed
% initialized at zeros

% tapt_sig_ch - if once is changed it can be changed again
% initialized at ones

tapt_fl = tapt_sig & tapt_sig_ch;


if any(tapt_fl)

    for ixtt = 1:n_tapt
        if tapt_fl(ixtt)
            idx_tapt = ( ((tapt_con(ixtt,2) == line(:,1)) & (tapt_con(ixtt,3) == line(:,2))) |...
                   ((tapt_con(ixtt,3) == line(:,1)) & (tapt_con(ixtt,2) == line(:,2))) );

            % change 'line' matrix accordingly
    
            % LINE tap related fields
            % col6 tap ratio
            % col7 phase shifter angle
            % col8 tapmax (optional)
            % col9 tapmin (optional)
            % col10 tapsize (optional)

            % Changes the tap ratio
            stepttch = sign(freqref_tapt - busfreq_tapt).*steptapt;
            line(idx_tapt,6) = line(idx_tapt,6) + stepttch(ixtt);
            tapt_sig_ch(ixtt) = 0; % ensures the tap changes occurs only once per transformer
            % % line_aux2 = line_aux; % i.e. the original line
            line_aux = line;
            % % line = line_aux;
        end
    end

    % Recalculates all the Y matrices
    y_switch; % should rewrite all the matrices
   
end

end

% if k >= sum(k_inc(1:3))+1
%     % fault cleared
% elseif k >=sum(k_inc(1:2))+1
%     % near bus cleared
% elseif k>=k_inc(1)+1
%     % fault applied
% elseif k<k_inc(1)+1
%     % pre fault
% end

        