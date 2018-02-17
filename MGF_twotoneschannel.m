function [ bestchannels ] = MGF_twotoneschannel( filename, triggers, nchans, plotflag)
%MGF_twotonechannels reads in denoised MEG data and outputs best channels
%for two tone data by finding the peak M100 respond and 
%   Inputs:
%       filename = filepath to two tone sqd fata
%       triggers = the trigger channels used in experiment (default is
%           {161:162}). Must be in cell format
%       nchans = the number of channels to return in each hemisphere.
%       plotflag = logical number, if 1, plot topography and butterfly plot
%
%   Outputs:
%       bestchannels = nchans x 2 array with first column giving best
%       channels for left hemisphere and second column for right hemisphere

    if ~exist(filename, 'file')
        error('File does not exist')
    end
    if nargin < 2
        triggers = {161:162};
    end
    if nargin < 3
        nchans = 10;
    end
    if nargin < 4
        plotflag = 0
    end
    if ~iscell(triggers)
        triggers = {triggers};
    end
    
    trlinfo = MGF_triggerread(filename,triggers,1,1);
    [data, layout, neighbours, trlinfo] = MGF_meganalysis(filename, [], 100, 20, 1, trlinfo);
    
    [ica,pca,weights,sphere] = MGF_megica(data, layout, 32, [], 0);
    % remove ica components you don't like
    cleandata = MGF_cleanica(ica,pca,weights,sphere,layout);
    % remove any other clearly unruly channels this should be limited to a
    % few and mostly to recovering dead channels. The next step will fix
    % jumps over thresholds and the like
    cleandata = MGF_cleanbadchans(cleandata, layout, neighbours, [], 'visual'); % sometimes generates issues with data.grad not having the right size
    cleandata = MGF_overclean(cleandata, neighbours, 3e-12, 10, .05, 50);
    
    % epoch data;
    cfg = [];
    cfg.trl = trlinfo.trl;
    cleandata = ft_redefinetrial(cfg, cleandata);
    
    bestchannels = MGFchannelselect(cleandata, layout, [.07 .14], nchans, 0, plotflag, [-.1 .3]);
end

