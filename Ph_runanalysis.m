subdir = '/Volumes/Vault/Data/Phonetica/R0013/';

sqdfile = [subdir 'R0013_Phonetica1-LSdenoised_NR.sqd'];
trialdef = struct('trig',164:167,'prestim',0,'poststim',5,'offset',-1);
trialfun = 'alltrialfun';

[data,trlinfo,layout,neighbours] = Ph_meganalysis(sqdfile,trialdef,trialfun);
pcaname=regexp(sqdfile,'R\d{3,4}_(?<name>[a-zA-Z0-9]+)','names');

pcafile = [subdir pcaname.name '_PCA.jpg'];
ica = Ph_megica(data,layout,ncomps,pcafile,[]);

mkdir([subdir 'Processed']);
savefile = [subdir 'Processed/variables.mat'];
save(savefile,'data','trlinfo','layout','neighbours','ica','-v7.3');


