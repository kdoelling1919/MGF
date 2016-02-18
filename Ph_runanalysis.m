subdir = '/Volumes/Vault/Data/Phonetica/R0013/';

sqdfile = [subdir 'R0013_Phonetica1-LSdenoised_NR.sqd'];
trialdef = struct('trig',164:167,'prestim',0,'poststim',5,'offset',-1);
trialfun = 'alltrialfun';
samplefs = 500;
ncomps = 32;

[data,trlinfo,layout,neighbours] = Ph_meganalysis(sqdfile,trialdef,trialfun,samplefs);

seglength = numSubPlot(length(data.trial{1})./data.fsample);
data = Ph_cleanbadchans(data,layout,neighbours,seglength);

pcaname=regexp(sqdfile,'R\d{3,4}_(?<name>[a-zA-Z0-9]+)','names');
pcafile = [subdir pcaname.name '_PCA.jpg'];
[ft_ica,ft_pca,weights,sphere] = Ph_megica(data,layout,ncomps,pcafile,false);

cleanchdata = Ph_cleanica(ft_ica,ft_pca,weights,sphere,layout);

mkdir([subdir 'Processed']);
savefile = [subdir 'Processed/variables.mat'];
save(savefile,'cleanchdata','data','trlinfo','layout','neighbours','ft_ica','ft_pca','weights','sphere','-v7.3');

%% remove ica components and clear





