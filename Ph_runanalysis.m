subdir = '/Volumes/Vault/Data/Phonetica/R0013/';

sqdfile = [subdir 'R0013_Phonetica1-LSdenoised_NR.sqd'];
trialdef = struct('trig',164:167,'prestim',0,'poststim',5,'offset',-1);
trialfun = 'alltrialfun';

[data,trlinfo,layout,neighbours] = Ph_meganalysis(sqdfile,trialdef,trialfun);
ica = Ph_megica(data,layout,ncomps);

mkdir([subdir 'Processed']);
savefile = [subdir 'Processed/variables.mat'];
save(savefile,'data','trialinfo','layout','neighbours','ica','-v7.3');


