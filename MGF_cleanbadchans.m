function [ cleandata ] = MGF_cleanbadchans( data,layout,neighbours,seglength, chans )
%Ph_cleanbadchans Repair bad channels
%   This uses a modified version of ft_rejectvisual which can be found
%   here: https://github.com/kdoelling1919/fieldtrip/blob/rejectviz/ft_rejectvisual.m
%   it has since been incorporated to fieldtrip
%   
%       data = fieldtrip data struct
%       grad = grad for channel positions
%       layout = layout struct as outputted by ft_prepare_layout
%       neighbours = neighbours struct as outputted by ft_prepare_neighbours
%       seglength = the length of each segment to consider as a "trial" for
%           reject visual
    
    if ischar(data)
        cfg = [];
        cfg.dataset = data;
        data = ft_preprocessing(cfg);
    elseif ~isstruct(data)
        error('data variable is of wrong type');
    end
    
    if isempty(chans)
        chans = 'visual';
    end
    
    if strcmp(chans, 'visual')
        if isempty(seglength)
            seglength = 20;
        end
        % chop raw signal into reasonably sized parts    
        cfg = [];
        cfg.length = seglength;
        split = ft_redefinetrial(cfg,data);
        % run reject visual to identify bad channels
        cfg = [];
        cfg.checksize = Inf;
        cfg.grad = data.grad;
        cfg.layout = layout;
        cfg.neighbours = neighbours;
        cfg.keepchannel = 'repair';
        cfg.keeptrial = 'nan';
        cfg.method = 'summary';
        cfg.metric = '1/var';
        cleandata = ft_rejectvisual(cfg,split);
    elseif isnumeric(chans)
        cfg = [];
        cfg.checksize = Inf;
        cfg.neighbours = neighbours;
        cfg.method = 'spline';
        cfg.badchannel = data.label(chans);
        cleandata = ft_channelrepair(cfg,data);
    else
        error('chans variable of wrong type')
    end
    
    % Put the split back together again
    buf = data;
    buf.trial = {cell2mat(cleandata.trial)};
    cleandata = buf;
    
    % put back trigger channels if they were there before
    if size(data.trial{1},1) > size(cleandata.trial{1},1)
        miss = size(cleandata.trial{1},1)+1:size(data.trial{1},1);
        cleandata.trial{1} = [cleandata.trial{1}; data.trial{1}(miss,:)];
    end

end

