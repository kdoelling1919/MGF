function [ TFR ] = MGF_tfanalysis(data,freqoi,toi, m )
% MGF_tfanalysis time frequency analysis for wavelet MEG data, depends on fieldtrip
%   Detailed explanation goes here
    if nargin < 4
        m = 7;
    end
    cfg = [];
    cfg.channel = 'all';
    cfg.method = 'wavelet';
    cfg.foi = freqoi;
    cfg.toi = toi;
    cfg.width = m;
    cfg.keeptrials = 'yes';
    cfg.output = 'fourier';
    cfg.polyremoval = -1;
    TFR = ft_freqanalysis(cfg,data);

end

