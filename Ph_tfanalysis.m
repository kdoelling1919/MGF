function [ TFR ] = Ph_tfanalysis(data,freqoi,toi)
%Ph_tfanalysis time frequency analysis for wavelet MEG data, depends on fieldtrip
%   Detailed explanation goes here
    cfg = [];
    cfg.channel = 'all';
    cfg.method = 'wavelet';
    cfg.foi = freqoi;
    cfg.toi = toi;
    cfg.width = 7;
    cfg.keeptrials = 'yes';
    cfg.output = 'fourier';
    cfg.polyremoval = -1;
    TFR = ft_freqanalysis(cfg,data);

end

