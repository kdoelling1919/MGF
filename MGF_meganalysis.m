function [data,trlinfo,layout,neighbours] = MGF_meganalysis(sqdfile,trialdef,trialfun,samplefs)

        cfg = [];
        cfg.dataset = sqdfile;
        cfg.continuous = 'yes';
        cfgP = cfg;
        cfg.trialdef = trialdef;
        cfg.trialfun = trialfun;
        cfg = ft_definetrial(cfg);
        trlinfo.trl = cfg.trl;
        trlinfo.event = cfg.event;
    
        cfgP.channel = [1:157];
        cfgP.detrend = 'yes';
        cfgP.demean = 'no';
        
        data = ft_preprocessing(cfgP);
        trlinfo.fsample = data.fsample;
        layout = ft_prepare_layout(data.cfg,data); 
        cfg=[];
        cfg.method='distance';
        cfg.neighbourdist=4;
        cfg.layout = layout;
        neighbours = ft_prepare_neighbours(cfg,data);
        
        cfg=[];
        cfg.resamplefs = samplefs;
        cfg.detrend = 'no';
        data = ft_resampledata(cfg,data);
        
        trlinfo.trl(:,1:3) = round(trlinfo.trl(:,1:3).*cfg.resamplefs/1000);
        samples = cellfun(@(x) round(x.*cfg.resamplefs/1000),{trlinfo.event.sample},'UniformOutput',false);
        [trlinfo.event.sample] = deal(samples{:});
        trlinfo.fsample = cfg.resamplefs;
%       
        knownbads = [41 116 113 153];
        bads = mark_bad_channels(sqdfile,knownbads);
        
        cfgcr= [];
        cfgcr.neighbours = neighbours;
        cfgcr.badchannel = data.label(bads);
        cfgcr.trials = 'all';
        data = ft_channelrepair(cfgcr,data);      
end
