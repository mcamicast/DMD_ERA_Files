% Script for calculating loadflows:
% need as input:
% - busfl - see loads
% - line
% - V1, V2
% - line_compl
% - 
% - ixlfl with buses to and from to see the flow between them
% - Example: - ixlfl = [9 19]; 
% Output:
% - Sflb
% - Sto
% - Sfrom

% % busfl = [17 19]; % 2 load buses of the two area system
if exist('busfl') & ~isempty(busfl)
Sflb = [];
for ixb = 1:length(busfl)
    % recall V1 and V2 are obtained by s_simu with V1 as from and V2 as to
    % bus
    % Recall use of function line_pqf
    vx1_bfr = line(:,1) == busfl(ixb);
    V1_bfr = V1(vx1_bfr,:);
    V2_bfr = V2(vx1_bfr,:);
    R_bfr = squeeze(line_compl(vx1_bfr,3,:));
    X_bfr = squeeze(line_compl(vx1_bfr,4,:));
    B_bfr = squeeze(line_compl(vx1_bfr,5,:));   
    tap_bfr = squeeze(line_compl(vx1_bfr,6,:));
    phi_bfr = squeeze(line_compl(vx1_bfr,7,:));
    [S1_bfr,S2_bfr] = line_pqf(V1_bfr,V2_bfr,R_bfr,X_bfr,B_bfr,tap_bfr,phi_bfr);
    S1f_bfr = sum(S1_bfr,1);
    
    vx1_bto = line(:,2) == busfl(ixb);
    V1_bto = V1(vx1_bto,:);
    V2_bto = V2(vx1_bto,:);
    R_bto = squeeze(line_compl(vx1_bto,3,:));
    X_bto = squeeze(line_compl(vx1_bto,4,:));
    B_bto = squeeze(line_compl(vx1_bto,5,:));  
    tap_bto = squeeze(line_compl(vx1_bto,6,:));
    phi_bto = squeeze(line_compl(vx1_bto,7,:));
    [S1_bto,S2_bto] = line_pqf(V1_bto,V2_bto,R_bto,X_bto,B_bto,tap_bto,phi_bto);
    S2f_bto = sum(S2_bto,1);

    Sfl = S1f_bfr + S2f_bto;
    Sflb(ixb,:) = Sfl;
    leg_Pb{ixb} = ['$P_{', num2str(busfl(ixb)),'}$'];
    leg_Qb{ixb} = ['$Q_{', num2str(busfl(ixb)),'}$'];
end
Sflb = -Sflb;
end
% Determining the flow of lines to be ploted, in this case line 9 - 19
% ixlfl = [9 19];

if exist('ixlfl') & ~isempty(ixlfl)
Sfrom = [];
Sto = [];
for ixfl = 1:size(ixlfl,1)
    idx_flin = ((ixlfl(ixfl,1) == line(:,1)) & (ixlfl(ixfl,2) == line(:,2)));
    if ~any(idx_flin)
        error('that kind of line does not exist between those buses - TRY inverting the to and from buses')
    end
    
    V1_fl = V1(idx_flin,:);
    V2_fl = V2(idx_flin,:);
    R_fl = squeeze(line_compl(idx_flin,3,:));
    X_fl = squeeze(line_compl(idx_flin,4,:));
    B_fl = squeeze(line_compl(idx_flin,5,:));
    tap_fl = squeeze(line_compl(idx_flin,6,:));
    phi_fl = squeeze(line_compl(idx_flin,7,:));
    [Sf_fl,St_fl] = line_pqf(V1_fl,V2_fl,R_fl,X_fl,B_fl,tap_fl,phi_fl);
    
%     Sfrom(ixfl,:) = Sf_fl;
%     Sto(ixfl,:) = St_fl;
    Sfrom{ixfl} = Sf_fl;
    Sto{ixfl} = St_fl;
end
end