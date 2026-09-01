%governor indexes
function f = tg_indx % function f=gov_indx
%set global variables
global  tg_con  
global  tg_idx n_tg tgh_idx n_tgh tg_agg_f
f=0;
n_tg=0; n_tgh=0;
if length(tg_con)~=0
   tg_idx = find(tg_con(:,1)==1);
   if ~isempty(tg_idx)
      n_tg = length(tg_idx);
      if size(tg_con,2)>10
          tg_agg_f = 1;
      else
          tg_agg_f = 0;
      end
   else
      n_tg = 0;
   end 
   tgh_idx = find(tg_con(:,1)==2);
   if ~isempty(tgh_idx)
      n_tgh = length(tgh_idx);
   else
      n_tgh=0;
   end
end