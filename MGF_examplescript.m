%% set parameters and locations
% these reguire human input
subno = 'R1095';
root = '/Volumes/Vault/Data/NewMusicPhase/';
knownbads = [21 53 88 153];
protocol = 'twotones';

%These are set by subject folder tree structure!
megdir = [root 'meg/'];
logdir = [root 'logs/'];
submeg = [megdir subno '/'];
sublog = [logdir subno '/'];
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
%%
% collect denoised and channel repair data
data2 = cell(1,length(sqdfiles));
% denoise on the individual blocks repair bad channels and concatenate
for f = 1:length(sqdfiles)
    % denoise the blocked data
    sqdfiles(f).name = [submeg sqdfiles(f).name];
    bads = MGF_megdenoise(sqdfiles(f).name, emptyfile, knownbads);
    sqdfiles_clean = strrep(sqdfiles(f).name,'.sqd','-LSdenoised_NR.sqd');
    
    % repair those bad channels that were lost
    % extract data from files
    cfg = [];
    cfg.dataset = sqdfiles(f).name;
    cfg.channel = 1:192;
    data = ft_preprocessing(cfg);
    % get layout of channels and figure out which channels are neighboring
    layout = ft_prepare_layout(data.cfg,data); 
    cfg=[];
    cfg.method='distance';
    cfg.neighbourdist=4;
    cfg.layout = layout;
    cfg.channel = 1:192;
    neighbours = ft_prepare_neighbours(cfg,data);
    trigchans = data.trial{1}(158:end,:);
    % repair dead channels using spline based on channel locations
    cfg = [];
    cfg.neighbours = neighbours;
    cfg.method = 'spline';
    cfg.badchannel = data.label(bads);
    cfg.channel = 1:192;
    data = ft_channelrepair(cfg,data);
    delete(sqdfiles_clean);
    % save repaired data
    data2{f} = [data.trial{1}; trigchans];
end
% % concatenate blocks
wholesesh = regexprep(sqdfiles_clean,'block\d\_','');
if exist(wholesesh,'file')
    delete(wholesesh)
end
sqdwrite(sqdfiles(f).name, wholesesh, cell2mat(data2)'); 
