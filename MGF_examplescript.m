subno = 'R1095';
root = '/Volumes/Vault/Data/NewMusicPhase/';
knownbads = [21 53 88 153];

megdir = [root 'meg/'];
logdir = [root 'logs/'];
submeg = [megdir subno '/'];
sublog = [logdir subno '/'];
protocol = 'nmp';

sqdfiles = dir([submeg '*' protocol '*.sqd']);
% remove sqdfiles that have already been denoised
NR = regexp({sqdfiles.name}, '\d\d\.sqd', 'once');
NR = cellfun(@isempty, NR);
sqdfiles(NR) = [];

% if there is more than one, the data was split into blocks. Make sure you
% have only files with the word block in it
if length(sqdfiles) > 1
    blockfiles = regexp({sqdfiles.name},'block','once');
    sqdfiles = sqdfiles(~cellfun('isempty',blockfiles));
end

allsqds = dir([submeg '*.sqd']);
emptyroom = ~cellfun('isempty',regexpi({allsqds.name},'emptyroom'));
emptyfile = allsqds(emptyroom);

if length(emptyfile) ~= 1
    error('Should only be one empty room file here.');
else
    emptyfile = [submeg emptyfile.name];
end
% denoise on the individual blocks
for f = 1:length(sqdfiles)
    sqdfiles(f).name = [submeg sqdfiles(f).name];
    bads = MGF_megdenoise(sqdfiles(f).name, emptyfile, knownbads);
    sqdfiles(f).name = strrep(sqdfiles(f).name,'.sqd','-LSdenoised_NR.sqd');
    
    % repair those bad channels
    cfg = [];
    cfg.dataset = sqdfiles(f).name;
    data = ft_preprocessing(cfg);
    
    layout = ft_prepare_layout(data.cfg,data); 
    cfg=[];
    cfg.method='distance';
    cfg.neighbourdist=4;
    cfg.layout = layout;
    neighbours = ft_prepare_neighbours(cfg,data);
    
    cfg = [];
    cfg.neighbours = neighbours;
    cfg.method = 'spline';
    cfg.badchannel = data.label(bads);
    data2 = ft_channelrepair(cfg,data);
end
% % concatenate blocks
wholesesh = regexprep(sqdfiles(f).name,'block\d\_','');
MGF_sqdconcat({sqdfiles.name},wholesesh,1);
 
