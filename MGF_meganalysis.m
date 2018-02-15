function [data, layout, neighbours, trlinfo] = MGF_meganalysis(sqdfile, channels, samplefs, lpf, hpf, trlinfo)
        if nargin < 4
            lpf = [];
        end
        if nargin < 5
            hpf = [];
        end
        if nargin < 6
            trlinfo = [];
        end
        cfg = [];
        cfg.dataset = sqdfile;
        cfg.continuous = 'yes';    
        cfg.channel = channels;
        cfg.detrend = 'no';
        cfg.demean = 'no';
        if ~isempty(lpf)
            cfg.lpfilter = 'yes';
            cfg.lpfreq = lpf;
        end
        if ~isempty(hpf)
            cfg.hpfilter = 'yes';
            cfg.hpfreq = hpf;
            cfg.hpfiltord = 4;
        end
        data = ft_preprocessing(cfg);
        oldfs = data.fsample;
        if nargout > 1
            layout = ft_prepare_layout(data.cfg,data);
        end
        if nargout > 2
            cfg=[];
            cfg.method='distance';
            cfg.neighbourdist=4;
            cfg.layout = layout;
            neighbours = ft_prepare_neighbours(cfg,data);
        end
        
        if samplefs~=data.fsample
            cfg=[];
            cfg.resamplefs = samplefs;
            cfg.detrend = 'no';
            data = ft_resampledata(cfg,data);
        end
        
        if ~isempty(trlinfo) && nargout == 4
            trlinfo.trl(:,1:3) = round(trlinfo.trl(:,1:3).*samplefs/oldfs);
            samples = cellfun(@(x) round(x.*samplefs/oldfs),...
                {trlinfo.event.sample},'UniformOutput',false);
            [trlinfo.event.sample] = deal(samples{:});
            trlinfo.fsample = samplefs;
        end
end
