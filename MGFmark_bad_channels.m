function [ bads ] = MGFmark_bad_channels( varargin )
% mark_bad_channels Identifies bad channels for removal from sqd Denoise
%   sqdfile = filename of sqd
%   knownbads = channels that should be removed automatically for whatever
%   reason
%
%   Created by Keith Doelling, 2/12/2016
    if nargin == 2
        sqdfile = varargin{1};
        knownbads = varargin{2};
    elseif nargin == 1
        sqdfile = varargin{1};
        knownbads = [];
    else
        error('Need inputs!')
    end
    
    badchannels = [];
    info = sqdread(sqdfile, 'Info');
    sampnum = get(info,'ActSamplesAcquired');

    for t = 1:19800:sampnum
        finish = min(20000+t,sampnum);
        data = sqdread(sqdfile, 'Channels',[0 156],'Samples',[t finish]);

        change = diff(data);
        sat = change == 0;
        sat = mean(sat);
        badchannels = [badchannels find(sat > .5)];
    end
    [badchannels] = unique(badchannels);
    bads = unique([badchannels knownbads]);
end