
% Controller implementation for WTG

if k==1 % initialization
    
    if size(wtg_con,2)>75
        thrshldnfc = ones(n_wtg,1)*[-0.015, 0.015];
        fcflagwtg = wtg_con(wtg_ix,76);
        dbfcwtg = wtg_con(wtg_ix,77);
        p1fcwtg = wtg_con(wtg_ix,78);
        p2fcwtg = wtg_con(wtg_ix,79);
        p3fcwtg = wtg_con(wtg_ix,80);
        p4fcwtg = wtg_con(wtg_ix,81);
        p5fcwtg = wtg_con(wtg_ix,82);
        p6fcwtg = wtg_con(wtg_ix,83);
        p7fcwtg = wtg_con(wtg_ix,84);

        ixfcwtg1 = fcflagwtg == 1;
        ixfcwtg2 = fcflagwtg == 2;
        ixfcwtg3 = fcflagwtg == 3;
        ixfcwtg4 = fcflagwtg == 4;
%         thrshldnfc(ixfcwtg2,:) = 1; % switching control variable for sw = 1

        if any(p3fcwtg(ixfcwtg4,1) ==0)
            error('Cant divide by zero')% prevents dividing by zero afterwards
        end
        
            p2_0 = (p2fcwtg ==0)&ixfcwtg2;
            p4_0 = (p4fcwtg ==0)&ixfcwtg2;
            p6_0 = (p6fcwtg ==0)&ixfcwtg2;
            
            if any(p1fcwtg(p2_0)~=0)
                error('system non causal')
            end
            if any(p3fcwtg(p4_0)~=0)
                error('system non causal')
            end
            if any(p5fcwtg(p6_0)~=0)
                error('system non causal')
            end
        
        % Frequency signals
%         ixbferr_wtg = (freqrefwtg - swinif_wtg(:,k))<dbfcwtg; % only consider dips in freq
        
        ixbferr_wtg = abs(freqrefwtg - swinif_wtg(:,k))<dbfcwtg; % CHANGE: Consider all freq variations 3/30/2015
        busferr_wtg = (freqrefwtg - swinif_wtg(:,k));
        busferr_wtg(ixbferr_wtg) = 0;

        fst1_wtg(ixfcwtg1,k) = 0;

        fst1_wtg(ixfcwtg3,k) = 0;
    end
    
    
else % dynamic computation
    
    if size(wtg_con,2)>75
        fcflagwtg = wtg_con(wtg_ix,76);
        dbfcwtg = wtg_con(wtg_ix,77);
        p1fcwtg = wtg_con(wtg_ix,78);
        p2fcwtg = wtg_con(wtg_ix,79);
        p3fcwtg = wtg_con(wtg_ix,80);
        p4fcwtg = wtg_con(wtg_ix,81);
        p5fcwtg = wtg_con(wtg_ix,82);
        p6fcwtg = wtg_con(wtg_ix,83);
        p7fcwtg = wtg_con(wtg_ix,84);
        p8fcwtg = wtg_con(wtg_ix,85);
        p9fcwtg = wtg_con(wtg_ix,86);
        
        if size(wtg_con,2)>86
            Kipwtgn = wtg_con(wtg_ix,87);
            Kppwtgn = wtg_con(wtg_ix,88);
            Kicwtgn = wtg_con(wtg_ix,89);
            Kpcwtgn = wtg_con(wtg_ix,90);
            Kitrqwtgn = wtg_con(wtg_ix,91);
            Kptrqwtgn = wtg_con(wtg_ix,92);
        end
        
        
        
%===================== Freq control Diff Approaches ======================%
        ixfcwtg1 = fcflagwtg == 1;
        ixfcwtg2 = fcflagwtg == 2;
        ixfcwtg3 = fcflagwtg == 3;
        ixfcwtg4 = fcflagwtg == 4;

%         ixbferr_wtg = (freqrefwtg - swinif_wtg(:,k))<dbfcwtg; % only consider dips in freq
        ixbferr_wtg = abs(freqrefwtg - swinif_wtg(:,k))<dbfcwtg; % CHANGE: Consider all freq variations 3/30/2015
        busferr_wtg = (freqrefwtg - swinif_wtg(:,k));
        busferr_wtg(ixbferr_wtg) = 0;
            
%===================== Freq control PI cont over Pset ====================%
% Method #1
% PI controller
% Kp + Ki/s

            dfst1_wtg(ixfcwtg1,k) = p2fcwtg(ixfcwtg1,1).*busferr_wtg(ixfcwtg1,1);
            sigpru1_wtg(ixfcwtg1,k) = p1fcwtg(ixfcwtg1,1).*busferr_wtg(ixfcwtg1,1) + fst1_wtg(ixfcwtg1,k);
            % NFCs1lim = p3fcwtg.*(freqrefwtg - swinif_wtg(:,k));
           
            % max state fst1
%             fstlimlim =  1.5 - Pset_wtg; % adaptative dependend on Pset
%             ixmst1 = fst1_wtg(:,k)>fst1lim;
%             ixmst1 = ixmst1 & ixfcwtg1;
%             fst1_wtg(ixmst1,k) = fst1lim;
%             ixmdst1 = ixmst1 & (dfst1_wtg(:,k)>0);
%             dfst1_wtg(ixmdst1,k) = 0;
%             ixliml = sigpru1_wtg(:,k)>fstlimlim;
%             ixliml = ixliml & ixfcwtg1;
%             sigpru1_wtg(ixliml,k) = fstlimlim(ixliml);
%             ixdliml = ixliml & (dfst1_wtg(:,k)>0);
%             dfst1_wtg(ixdliml,k) = 0;
            
% %             ixlNFC = sigpru1_wtg(:,k)>NFCs1lim;
% %             ixlNFC = ixlNFC & ixfcwtg1;
% %             sigpru1_wtg(ixlNFC,k) = NFCs1lim(ixlNFC);
% %             ixdNFC = ixlNFC & (dfst1_wtg(:,k)>0);
% %             dfst1_wtg(ixdNFC,k) = 0;
            


% ixbferr2_wtg = (freqrefwtg - swinif_wtg(:,k)) > (60-59.99)/60;
ixbferr2_wtg = abs(freqrefwtg - swinif_wtg(:,k)) > dbfcwtg; % CHANGE: Consider all freq variations 3/30/2015
%======================== Freq control 3 stages ==========================%
% Method #2
% K (1+T1s)/(1+T2s) * (1+T3s)/(1+T4s) * 
% T1 - p1fcwtg
% T2 - p2fcwtg
% T3 - p3fcwtg
% T4 - p4fcwtg
% T5 - p5fcwtg
% T6 - p6fcwtg
% K  - p7fcwtg
% input u - busferr_wtg(:,1)
% Output y - sigpru1_wtg(ixfcwtg3,k)
            p2_0 = (p2fcwtg ==0)&ixfcwtg2;
            p4_0 = (p4fcwtg ==0)&ixfcwtg2;
            p6_0 = (p6fcwtg ==0)&ixfcwtg2;
            
            % no need to check again since it's done once in the init
%             if any(p1fcwtg(p2_0)~=0)
%                 error('system non causal')
%             end
               
            rsigint = (fst1_wtg(:,k) + p1fcwtg(:,1).*busferr_wtg(:,1))./p2fcwtg(:,1);
            dfst1_wtg(ixfcwtg2,k) = ( busferr_wtg(ixfcwtg2,1) - rsigint(ixfcwtg2,1) );
            rsigint(p2_0,1) = busferr_wtg(p2_0,1);

            %yfc_2s = (fst2_wtg(:,k) + p3fcwtg(:,1).*rsigint)./p4fcwtg(:,1); %borrar
            rsigint2 = (fst2_wtg(:,k) + p3fcwtg(:,1).*rsigint)./p4fcwtg(:,1);
            dfst2_wtg(ixfcwtg2,k) = ( rsigint(ixfcwtg2,1) - rsigint2(ixfcwtg2,1) );
            rsigint2(p4_0,1) = rsigint(p4_0,1);
            
            yfc_3s = (fst3_wtg(:,k) + p5fcwtg(:,1).*rsigint2)./p6fcwtg(:,1);
            dfst3_wtg(ixfcwtg2,k) = ( rsigint2(ixfcwtg2,1) - yfc_3s(ixfcwtg2,1) );
            yfc_3s(p6_0,1) = rsigint2(p6_0,1);
            
            sigpru1_wtg(ixfcwtg2,k) = p7fcwtg(ixfcwtg2,1).*yfc_3s(ixfcwtg2,1);
            

            if size(wtg_con,2)>86
                Kipwtgn = wtg_con(wtg_ix,87);
                Kppwtgn = wtg_con(wtg_ix,88);
                Kicwtgn = wtg_con(wtg_ix,89);
                Kpcwtgn = wtg_con(wtg_ix,90);
                Kitrqwtgn = wtg_con(wtg_ix,91);
                Kptrqwtgn = wtg_con(wtg_ix,92);
                
                ixthmn2 = (th_wtg(:,k)<=(thminwtg+0.03+thrshldnfc(:,1))) & (ixfcwtg2|ixfcwtg3);
                thrshldaux = thrshldnfc(ixthmn2,1);
                thrshldnfc(ixthmn2,1) = thrshldnfc(ixthmn2,2);
                thrshldnfc(ixthmn2,2) = thrshldaux;
                
                ixch_nfch = (ixfcwtg2|ixfcwtg3) & ixbferr2_wtg &(~ixthmn2);    % 
                Kipwtg(ixch_nfch) = Kipwtgn(ixch_nfch); % 18
                Kppwtg(ixch_nfch) = Kppwtgn(ixch_nfch); % 19
                Kicwtg(ixch_nfch) = Kicwtgn(ixch_nfch); % 20
                Kpcwtg(ixch_nfch) = Kpcwtgn(ixch_nfch); % 21
                Kitrqwtg(ixch_nfch) = Kitrqwtgn(ixch_nfch); % 22
                Kptrqwtg(ixch_nfch) = Kptrqwtgn(ixch_nfch); % 23
                
%                 ixch_nfc2 = ixfcwtg2 & ixbferr2_wtg;    % 
%                 Kipwtg(ixch_nfc2) = Kipwtgn(ixch_nfc2); % 18
%                 Kppwtg(ixch_nfc2) = Kppwtgn(ixch_nfc2); % 19
%                 Kicwtg(ixch_nfc2) = Kicwtgn(ixch_nfc2); % 20
%                 Kpcwtg(ixch_nfc2) = Kpcwtgn(ixch_nfc2); % 21
%                 Kitrqwtg(ixch_nfc2) = Kitrqwtgn(ixch_nfc2); % 22
%                 Kptrqwtg(ixch_nfc2) = Kptrqwtgn(ixch_nfc2); % 23
                
            end
            


%====================== Freq control Transient Gain ======================%
% Method #3
% Proportional constant plus transient gain
% Kp + Kptr (s*Tr)/(1 + s*Tr)
% Kp   - p1fcwtg
% Kptr - p2fcwtg
% Tr   - p3fcwtg
            dfst1_wtg(ixfcwtg3,k) = p2fcwtg(ixfcwtg3,1).*busferr_wtg(ixfcwtg3,1) - fst1_wtg(ixfcwtg3,k)./p3fcwtg(ixfcwtg3,1);
            sigpru1_wtg(ixfcwtg3,k) = p1fcwtg(ixfcwtg3,1).*busferr_wtg(ixfcwtg3,1) +  dfst1_wtg(ixfcwtg3,k);
                        
%             if size(wtg_con,2)>86
%                 Kipwtgn = wtg_con(wtg_ix,87);
%                 Kppwtgn = wtg_con(wtg_ix,88);
%                 Kicwtgn = wtg_con(wtg_ix,89);
%                 Kpcwtgn = wtg_con(wtg_ix,90);
%                 Kitrqwtgn = wtg_con(wtg_ix,91);
%                 Kptrqwtgn = wtg_con(wtg_ix,92);
%                 
%                 ixch_nfc3 = ixfcwtg3 & ixbferr2_wtg;    % 
%                 Kipwtg(ixch_nfc3) = Kipwtgn(ixch_nfc3); % 18
%                 Kppwtg(ixch_nfc3) = Kppwtgn(ixch_nfc3); % 19
%                 Kicwtg(ixch_nfc3) = Kicwtgn(ixch_nfc3); % 20
%                 Kpcwtg(ixch_nfc3) = Kpcwtgn(ixch_nfc3); % 21
%                 Kitrqwtg(ixch_nfc3) = Kitrqwtgn(ixch_nfc3); % 22
%                 Kptrqwtg(ixch_nfc3) = Kptrqwtgn(ixch_nfc3); % 23
%             end
            
%             Kppwtgn = p4fcwtg;
%             Kpcwtgn = p5fcwtg;
%             Kicwtgn = p6fcwtg;
%             Kptrqwtgn = p7fcwtg;
%             Kitrqwtgn = p8fcwtg;
%             Tpcwtgn = p9fcwtg;
            
%             if t(k)>0.6
%                 disp('solpru')
%             end            
            % thrshldnfc = [0.025 -0.25];
%             ixthmn2 = th_wtg(:,k)<=(thminwtg+eps+0.1+thrshldnfc(:,1)) & ixfcwtg3;
%             thrshldaux = thrshldnfc(ixthmn2,1);
%             thrshldnfc(ixthmn2,1) = thrshldnfc(ixthmn2,2);
%             thrshldnfc(ixthmn2,2) = thrshldaux;
%             
%             ixch_nfc3 = ixfcwtg3 & ixbferr2_wtg & ~ixthmn2;%~(ix_dth & ixthmn);
%             Kppwtg(ixch_nfc3) = Kppwtgn(ixch_nfc3); % 19
%             Kicwtg(ixch_nfc3) = Kicwtgn(ixch_nfc3); % 20
%             Kpcwtg(ixch_nfc3) = Kpcwtgn(ixch_nfc3); % 21
%             Kitrqwtg(ixch_nfc3) = Kitrqwtgn(ixch_nfc3); % 22
%             Kptrqwtg(ixch_nfc3) = Kptrqwtgn(ixch_nfc3); % 23
%             %Tpwtg % 24
%             Tpcwtg(ixch_nfc3) = Tpcwtgn(ixch_nfc3); % 25
            
            
            
            
%=================== Freq control P Control, Include zero =================%
%             if t(k)>0.5
%                 disp('dbugg')
%             end
%             if t(k)>1.5
%                 disp('dbugg')
%             end
%             if t(k)>2.5
%                 disp('dbugg')
%             end
%             yfc_zp = ( busferr_wtg(:,1) + fst1_wtg(:,k) ); % not indexed, cos' done it afterwards
%             dfst1_wtg(ixfcwtg4,k) = p3fcwtg(ixfcwtg4,1).*(busferr_wtg(ixfcwtg4,1)) - yfc_zp(ixfcwtg4,1).*p2fcwtg(ixfcwtg4,1);
%             % sigpru1_wtg(ixfcwtg4,k) = p1fcwtg(ixfcwtg4,1).*yfc_zp(ixfcwtg4,1).*p2fcwtg(ixfcwtg4,1)./p3fcwtg(ixfcwtg4,1);
%             % sigpru1_wtg(ixfcwtg4,k) = p1fcwtg(ixfcwtg4,1).*yfc_zp(ixfcwtg4,1);
%             sigpru1_wtg(ixfcwtg4,k) = p1fcwtg(ixfcwtg4,1).*yfc_zp(ixfcwtg4,1).*p2fcwtg(ixfcwtg4,1)./p3fcwtg(ixfcwtg4,1);
%             
% 
%             % ixch_nfc4 = ixfcwtg4 & ixbferr2_wtg & ~ixthmn2;
%             ixch_nfc4 = ixfcwtg4 & ixbferr2_wtg;
%             Kppwtg(ixch_nfc4) = Kppwtgn(ixch_nfc4); % 19
%             Kicwtg(ixch_nfc4) = Kicwtgn(ixch_nfc4); % 20
%             Kpcwtg(ixch_nfc4) = Kpcwtgn(ixch_nfc4); % 21
%             Kitrqwtg(ixch_nfc4) = Kitrqwtgn(ixch_nfc4); % 22
%             Kptrqwtg(ixch_nfc4) = Kptrqwtgn(ixch_nfc4); % 23
%             %Tpwtg % 24
%             Tpcwtg(ixch_nfc4) = Tpcwtgn(ixch_nfc4); % 25
            
%=================== assign on variable =================%

            Pth_sig_wtg(:,k) = -sigpru1_wtg(:,k);
        
    end
    
    
end