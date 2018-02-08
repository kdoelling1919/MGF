function [ trlinfo ] = MGF_triggerread( sqdfile, trigstruct )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    cfg = [];
    cfg.dataset = sqdfile;
    cfg.continuous = 'yes';

    % create new config for current preprocessing
    cfgP = cfg;

    % get trialinfo 
    cfg.trialdef.prestim = 5;
    cfg.trialdef.poststim = 17;
    cfg.trialdef.trig = trigstruct;

    % MPtrialsort is a function I wrote to collect my trials based on
    % triggers and collect other information about them as needed.
    % You'll need to write your own function which is tailored to your
    % experiment
    cfg.trialfun = 'MGFtrigsort';
    cfg = ft_definetrial(cfg);

    % collect trialinfo
    trlinfo.trl = cfg.trl;
    trlinfo.event = cfg.event;

end

