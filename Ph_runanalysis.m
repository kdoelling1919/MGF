homedir = '/Volumes/Vault/Data/Phonetica';
% find subjects
subjects = dir([homedir '/R*']);
srch = '*Phonetica*NR.sqd';
global ft_default
ft_default.checksize = Inf;
trialstrt = ones(length(subjects),1);
trialstrt(2) = 2;
for sub = 2:length(subjects)
    subdir = [homedir '/' subjects(sub).name];
    sqdfiles = dir([subdir '/' srch]);
    
    for sqd = trialstrt(sub):length(sqdfiles)
        sqdfile = [subdir '/' sqdfiles(sqd).name];
        trialdef = struct('trig',164:167,'prestim',0,'poststim',5,'offset',-1);
        trialfun = 'alltrialfun';
        samplefs = 500;
        ncomps = 32;

        [data,trlinfo,layout,neighbours] = Ph_meganalysis(sqdfile,trialdef,trialfun,samplefs);

        seglength = numSubPlot(length(data.trial{1})./data.fsample);
        data = Ph_cleanbadchans(data,layout,neighbours,seglength);

        pcaname=regexp(sqdfile,'R\d{3,4}_(?<name>[a-zA-Z0-9]+)','names');
        pcafile = [subdir '/' pcaname.name '_PCA.jpg'];
        [ft_ica,ft_pca,weights,sphere] = Ph_megica(data,layout,ncomps,pcafile,[]);

        cleanchdata = Ph_cleanica(ft_ica,ft_pca,weights,sphere,layout);

        mkdir([subdir '/Processed']);
        savefile = [subdir '/Processed/' pcaname.name '.mat'];
        save(savefile,'cleanchdata','data','trlinfo','layout','neighbours','ft_ica','ft_pca','weights','sphere','-v7.3');
    end
end
%% remove ica components and clear





