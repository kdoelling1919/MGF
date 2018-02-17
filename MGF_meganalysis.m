function [data, layout, neighbours, trlinfo] = MGF_meganalysis(sqdfile, channels, samplefs, lpf, hpf, trlinfo)
%MGF_meganalysis reads in sqdfile data, filters and resamples
%   Inputs:
%       sqdfile = filepath to the sqd file to be read in
%       channels = the channels to be selected (default is MEG channels
%           (i.e. not triggers or noise channels)
%       samplefs = new sampling rate to resample the data to.
%       lpf = low pass filter cutoff
%       hpf = high pass filter cutoff
%       trlinfo = trial struct as output from MGF_TRIGGERREAD to be edited
%           to accommodate resample
%
%   Outputs
%       data = fieldtrip data struct as output from ft_preprocessing
%       layout = fieldtrip layout struct for data channel positions
%       neighbours = fieldtrip neighbours struct to identify nearby
%           channels
%       trlinfo = updated trlinfo given new resampling


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
        if isempty(channels)
            cfg.channel = 'meg';
        else
            cfg.channel = channels;
        end
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
        
        if ~isempty(samplefs) && samplefs~=data.fsample
            resamp = 1;
            cfg=[];
            cfg.resamplefs = samplefs;
            cfg.detrend = 'no';
            data = ft_resampledata(cfg,data);
        else
            resamp = 0;
        end
        
        if ~isempty(trlinfo) && nargout == 4 && trlinfo.fsample ~= samplefs && resamp
            trlinfo.trl(:,1:3) = round(trlinfo.trl(:,1:3).*samplefs/trlinfo.fsample);
            samples = cellfun(@(x) round(x.*samplefs/trlinfo.fsample),...
                {trlinfo.event.sample},'UniformOutput',false);
            [trlinfo.event.sample] = deal(samples{:});
            trlinfo.fsample = samplefs;
        end
end
