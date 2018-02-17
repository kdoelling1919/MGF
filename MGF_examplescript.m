%% set parameters and locations
% these reguire human input
% subject info
subno = 'R0053';
root = '/Volumes/Vault/Data/NewMusicPhase/';
knownbads = [21 53 88 153];
protocol = 'twotones';
% trigger info
% trigger = {161:166, 168, 167}; % for newmusicphase
trigger = {161:162}; % for twotones
% trial info
prestim = 1;
poststim = 1;
samplefs = 100;

%These are set by subject folder tree structure!
megdir = [root 'meg/'];
logdir = [root 'logs/'];
figdir = [root 'figs/'];
submeg = [megdir subno '/'];
sublog = [logdir subno '/'];
subfig = [figdir subno '/'];
sqdfiles = dir([submeg '*' protocol '*.sqd']);
%%
% remove sqdfiles that have already been denoised (in case you are running
% this script multiple times

% find original files which end in numbers
NR = regexp({sqdfiles.name}, '\d\d\.sqd', 'once');
% grab ones that do not end in numbers
NR = cellfun(@isempty, NR);
% remove them
sqdfiles(NR) = [];

% if there is more than one, then the data was split into blocks. Make sure you
% have only files with the word block in it
if length(sqdfiles) > 1
    blockfiles = regexp({sqdfiles.name},'block','once');
    sqdfiles = sqdfiles(~cellfun('isempty',blockfiles));
end

% find the emptyroom file
allsqds = dir([submeg '*.sqd']);
% contains the words emptyroom
emptyroom = ~cellfun('isempty',regexpi({allsqds.name},'emptyroom'));
emptyfile = allsqds(emptyroom);

% make sure there is only one file
if length(emptyfile) ~= 1
    error('Should only be one empty room file here.');
else
    % add the path to the file.
    emptyfile = [submeg emptyfile.name];
end
%% DENOISE THE DATA
% collect denoised and channel repair data
data2 = cell(1,length(sqdfiles));
% denoise on the individual blocks repair bad channels and concatenate
for f = 1:length(sqdfiles)
    % denoise the blocked data
    sqdfiles(f).name = [submeg sqdfiles(f).name];
    bads = MGF_megdenoise(sqdfiles(f).name, emptyfile, knownbads);
    sqdfiles_clean = strrep(sqdfiles(f).name,'.sqd','-LSdenoised_NR.sqd');    
    % extract data from files
    [data, layout, neighbours] = MGF_meganalysis(sqdfiles_clean, 1:192, 1000);
    % repair dead channels using spline based on channel locations
    data = MGF_cleanbadchans(data, layout, neighbours, [], bads);
    data2{f} = data.trial{1};
%     delete(sqdfiles_clean);
end
% % concatenate blocks
wholesesh = regexprep(sqdfiles_clean,'block\d\_','');
if exist(wholesesh,'file')
    delete(wholesesh)
end
datachans = regexp(data.label,'^[A-Z]+\d+$');
datachans = ~cellfun('isempty',datachans);
fulldata = cell2mat(data2)'; 
% conversion issues!)
fulldata(:,datachans) = fulldata(:,datachans).*1e15;
fulldata(:,~datachans) = fulldata(:,~datachans).*7.9067*1e3;
% write the the newly denoised data to a file.
sqdwrite(sqdfiles(f).name, wholesesh, fulldata); 

%% PREPROCESS THE DATA
% preprocess info
lpf = 30;
hpf = .1;
icacomps = 32;

% make figure file
if ~exist(subfig,'dir')
    mkdir(subfig);
end
pcafig = [subfig subno '_pca'];
prepfig = [subfig subno '_cleancomp'];

% get trlinfo from file
trlinfo = MGF_triggerread(wholesesh, trigger, prestim, poststim);
% pull out data from file
[data, layout, neighbours, trlinfo] = MGF_meganalysis(wholesesh, 1:157, samplefs, lpf, hpf, trlinfo);
% run ica analysis
[ica,pca,weights,sphere] = MGF_megica(data, layout, 32, pcafig, 0);
% remove ica components you don't like
cleandata = MGF_cleanica(ica,pca,weights,sphere,layout);
[~,lngth] = numSubPlot(round(cleandata.time{1}(end)));
% remove any other clearly unruly channels
cleandata = MGF_cleanbadchans(cleandata, layout, neighbours, lngth, 'visual'); % sometimes generates issues with data.grad not having the right size
overcleandata = MGF_overclean(cleandata, neighbours, 3e-12, 10, .05, 50);

figure;
subplot(2,1,1);
plot(data.time{1}, data.trial{1});
subplot(2,1,2);
plot(data.time{1}, overcleandata.trial{1});
setLims(gcf,'ylim')
saveas(gcf,prepfig,'jpg');
%% Plot the ERP
figure;
cfg = [];
cfg.trl = trlinfo.trl;
epochclean = ft_redefinetrial(cfg, overcleandata);
epoch = ft_redefinetrial(cfg,data);
cfg = [];
avgclean = ft_timelockanalysis(cfg, epochclean);
avg = ft_timelockanalysis(cfg, epoch);
cfg = [];
cfg.baseline = [-1 0];
avgclean = ft_timelockbaseline(cfg,avgclean);
avg = ft_timelockbaseline(cfg,avg);
subplot(2,1,1);
plot(avg.time,avg.avg);
title('Original data');
subplot(2,1,2);
plot(avgclean.time,avgclean.avg);
title('Cleaned data');
figname 
ttfig = [subfig subno '_erp'];
saveas(gcf,ttfig,'jpg');


figure;
plot(avg.time, rms(avg.avg)); hold on;
plot(avgclean.time, rms(avgclean.avg));
legend({'Original','Clean'})
%% TF ANALYSIS and EPOCH OF THE DATA
% select frequencies of interest
% freqoi = [.3:.2:.7 1:.25:2 2.5:.5:10];
freqoi = 1:20;
toi = data.time{1};
% do a time frequency analysis
TF = MGF_tfanalysis(overcleandata,freqoi,toi,4);
TF.powspctrm = abs(TF.fourierspctrm).^2;
TF.dimord = 'rpt_chan_freq_time';
TF = rmfield(TF,'fourierspctrm');
epochTF = MGF_epochfreq(TF,trlinfo,'powspctrm');
epochTFbsl = ft_freqbaseline(struct('baseline',[-1 0],'baselinetype','relative'),epochTF);
avg = ft_freqdescriptives([],epochTFbsl);
figure; uimagesc(avg.time(50:150),avg.freq, squeeze(mean(avg.powspctrm(:,:,50:150)))); axis xy;
