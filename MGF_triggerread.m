function [ trlinfo ] = MGF_triggerread( sqdfile, trigstruct, prestim, poststim )
% MGF_triggerread Output trial information in fieldtrip format
%   sqdfile = file name of sqd file meant to be read in
%   trigstruct = Trigger channel numbers. This should be in cell format.
%       and be grouped by condition information
%       For example, if my MEG experiment has a 3x2 factor design, I may have
%       channels 161:163 code for the first factor and channels 164:165 (or
%       just 164) code for the second factor. Trigstruct in this case should be
%       {161:163,164:165} (or {161:163,164}). If there is an occasional aberration to keep the
%       subject focused I can add this in as well with {161:163,164:165,167};
%
%       For simpler experiments you can just use {161:168} as your
%       trigstruct.  It will extract all trigger events and make trials
%       frome ach one
%   prestim = number of seconds before trigger to include
%   poststim = number of seconds after trigger to include
% 
%   Output trlinfo is a struct containing fields:
%       trl
%       event
%
%   trl = a matrix with a row for each trigger and at least 4 columns. The 
%       first three are specified by fieldtrip. Col 1: beginning of trial. 
%       Col 2: end of a trial. Col 3: Offset from trigger to trial start.
%       The remaining number of columns is the number of cells in
%       trigstruct. If the event contains an item in a cell that column
%       will contain the number of that item. If the event (from above
%       example) contained triggers of 162 and 164 then the 4th and 5th
%       column will be 2 and 1 respectively. If the event contains nothing
%       in the cell, it will return 0. 
%   event = is the struct read out from ft_read_event containing trigger
%       sample and the triggers that were found on this event.
%
%   Created Keith Doelling, New York University, 2/7/18

    cfg = [];
    cfg.dataset = sqdfile;
    cfg.continuous = 'yes';
    % get trialinfo 
    cfg.trialdef.prestim = prestim;
    cfg.trialdef.poststim = poststim;
    cfg.trialdef.trig = trigstruct;

    % MGFtrigsort is a function I wrote to collect my trials based on
    % triggers and collect other information about them as needed.
    % You'll need to write your own function which is tailored to your
    % experiment
    cfg.trialfun = 'MGFtrigsort';
    [trlinfo.trl, trlinfo.event] = MGFtrigsort(cfg);

end

