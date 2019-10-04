function [ cleandata ] = MGF_cleanbadchans( data, layout, neighbours, chans)
%MGF_cleanbadchans Repairs bad channels as specified or through visual
%inspection
%   Inputs
%       data = fieldtrip data struct or filepath to sqd data to be read in
%           with default preprocessing
%       layout = layout struct as outputted by ft_prepare_layout
%       neighbours = neighbours struct as outputted by ft_prepare_neighbours
%       seglength = the length of each segment (in seconds) to consider as a "trial".
%           (default = 20). Ensure that this value is a divisor of the total session length.
%           If not, it will cut out any remainder sections. 
%       chans = a vector of numbers or 'visual'. If 'visual', function
%       will call ft_rejectvisual with summary method to allow you to
%       select channels to repair based on visual inspection. If a vector
%       of numbers, function will repair channels specified by those
%       numbers. (default is 'visual')
%   Outputs
%       cleandata = fieldtrip data struct with repaired channels

% If data is a filepath read in the data
    if ischar(data)
        cfg = [];
        cfg.dataset = data;
        cfg.channel = 'meg';
        data = ft_preprocessing(cfg);
    elseif ~isstruct(data)
        error('data variable is of wrong type');
    end
% If no channels specified lets go visual
    if isempty(chans)
        chans = 'visual';
    end

    if strcmp(chans, 'visual')
        % set to to automatically pick seglength
        len = length(data.time{1});
        seglen = autolen(len);
        seglength = seglen./data.fsample;
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
        % fix bad channels as specified
        cfg = [];
        cfg.checksize = Inf;
        cfg.neighbours = neighbours;
        cfg.method = 'spline';
        cfg.badchannel = data.label(chans);
        cleandata = ft_channelrepair(cfg,data);
    else
        % you did something wrong
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

function seglen = autolen(len)
    f = 1:floor(len./2);
    m = len./f;
    integ = m == floor(m);
    f = f(integ);
    m = m(integ);
    [~,sel] = min(abs(f-m));
    seglen = m(sel);
end
