% Script for calculating loadflows:
% need as input:
% - line_flw
% - ixlin -the line number in a vector according to line_flw

% - busfl - see loads
% - line
% - V1, V2
% - line_compl
% - 

if exist('ixlin') && ~isempty(ixlin)
if any( ixlin > max(line_flw(:,1)) )
    error('Not a valid line number')
end
    
Sfrom = [];
Sto = [];
Ifrom = [];
Ito = [];
for ixC = 1:length(ixlin)
    idx_flin = ixlin(ixC);
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
    Sfrom(ixC,:) = Sf_fl;
    Sto(ixC,:) = St_fl;
    
    [Il_f,Il_t] = line_curf(V1_fl,V2_fl,R_fl,X_fl,B_fl,tap_fl,phi_fl);
    Ifrom(ixC,:) = Il_f;
    Ito(ixC,:) = Il_t;
    
end
end