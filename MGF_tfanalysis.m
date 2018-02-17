function [ TFR ] = MGF_tfanalysis(data,freqoi,toi, m )
% MGF_tfanalysis time frequency analysis for wavelet MEG data, depends on fieldtrip
%   Inputs:
%       data = fieldtrip data struct
%       freqoi = frequencies of interest (numeric vector)
%       toi = times of interest
%       m = window length (in cycles) for wavelet analysis (default = 7)
    % set default for m to 7
    if nargin < 4 || isempty(m)
        m = 7;
    end
    % run TF analysis
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

