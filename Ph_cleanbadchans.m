function [ cleandata ] = Ph_cleanbadchans( data,layout,neighbours,seglength )
%Ph_cleanbadchans Repair bad channels
%   This uses a modified version of ft_rejectvisual which can be found
%   here: https://github.com/kdoelling1919/fieldtrip/blob/rejectviz/ft_rejectvisual.m
%   
%   
    
    % chop raw signal into reasonably sized parts    
    cfg = [];
    cfg.length = seglength;
    split = ft_redefinetrial(cfg,data);
    % run reject visual to identify bad channels
    cfg = [];
    cfg.grad = data.grad;
    cfg.layout = layout;
    cfg.neighbours = neighbours;
    cfg.keepchannel = 'neighbours';
    cfg.keeptrial = 'nan';
    cfg.method = 'summary';
    cfg.metric = '1/var';
    cleandata = ft_rejectvisual(cfg,split);
    
    % Put the split back together again
    buf = data;
    buf.trial = {cell2mat(cleandata.trial)};
    cleandata = buf;


end

