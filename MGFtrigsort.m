function [ trl, event ] = MGFtrigsort( cfg )
% MGFtrigsort takes in cfg with prestim, poststim and trig fields
%   Takes in sqdfile and generates events based on trigger info.
%   THIS FUNCTION IS NOT MEANT FOR EXTERNAL USE.
%
% Created by Keith Doelling, New York University, 2/7/18


% get header
hdr = ft_read_header(cfg.dataset);
% extract trigger groups
trig = cfg.trialdef.trig;

% get triggers from each grouping
trigger = cell(1,length(trig));
for tr = 1:length(cfg.trialdef.trig)
    % look for each trigger grouping
    trigger{tr} = ft_read_event(cfg.dataset,'trigindx',trig{tr}, 'threshold',2.5);
    if tr == 1
        % If this is the first group, put all triggers into events and
        % update some formatting
        event = trigger{1};
        type = cellfun(@str2double,{event.type},'UniformOutput',false);
        [event.type] = deal(type{:});
    elseif tr > 1
        % for second group, find which events in this group line up with
        % events in second group with tolerance for a few samples in either
        % direction
        [ind,loc] = ismembertol([event(:).sample],[trigger{tr}(:).sample],1e-5);
        lind = loc(ind);
        Iind = find(ind);
        typecon = cell(length(Iind),1);

        for i = 1:length(Iind)
            typecon{i} = [event(Iind(i)).type str2double({trigger{tr}(lind(i)).type})];
        end
        % consolidate those events using the earliest sample found and
        % concatenating both trigger types
        sampcon = num2cell(min([[event(ind).sample]',[trigger{tr}(lind).sample]'],[],2));
        % put consolidated info into event structure
        [event(ind).sample] = deal(sampcon{:});
        [event(ind).type] = deal(typecon{:});
        % add any new events in second group not previously in first group
        % and sort
        event = [event trigger{tr}(setxor(1:length(trigger{tr}),lind))];
        [~,sortind] = sort([event.sample],'ascend');
        event = event(sortind);
    end
end

trigtype = zeros(length(event), length(trig));
for tr = 1:length(trig)
    for e = 1:length(event)
        num = find(ismember(trig{tr},event(e).type),1);
        if isempty(num)
            num = 0;
        end
        trigtype(e,tr) = num;
    end
end

pretrig  = -cfg.trialdef.prestim  * hdr.Fs;
posttrig =  cfg.trialdef.poststim * hdr.Fs;

trl = zeros(length(event),3+size(trigtype,2));


for j = 1:length(event);
    trlbegin = event(j).sample + pretrig ;
    offset   = pretrig;

    if trlbegin<1
        trlbegin = 1;
        offset = -(event(j).sample-1);
    end
    trlend   = event(j).sample + posttrig ;
    
    % the function returns a matrix with each row as a different trial, the
    % first three columns I think must be the trial window start place (in
    % samples), the trial window end place and then the offset from the
    % trigger to the start window. After that you can add as
    % many columns as you like with whatever information (I have included
    % the trigger line the trial came from as it is relevant to me) You
    % could also put in behavioral responses for the trial or reaction
    % times or whatever.
    trl(j,:)   = [trlbegin trlend offset trigtype(j,:)];
end
end


