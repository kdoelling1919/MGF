function [ bestchannels ] = MGFchannelselect( data, layout, timewin, nchans, findtime, plotflag, plotwin)
%MGFchannelselect Select best channels based on peak response in a
%timewindow
%   Inputs:
%       data = fieldtrip data struct
%       layout = fieldtrip layout struct
%       timewin = time window to search for peak responses, [minwin maxwin]
%       nchans = the number of best channels to give per hemisphere
%       findtime = logical, whether to find the peak moment within timewin
%           (findtime = 1) or to use max of each channel in the whole 
%           window (findtime = 0). 1 is best if you are more unsure of your
%           time window 
%       plotflag = logical, whether to plot the topography and butterfly
%           plot
%       plotwin = timewindow for butterfly plot
%
%   Outputs:
%       bestchannels = nchans x 2 array with first column giving best
%           channels for left hemisphere and second column for right hemisphere

    cfg = [];
    cfg.covariance = 'no';
    cfg.keeptrials = 'no';
    avg = ft_timelockanalysis(cfg,data);
    
    minlim = timewin(1);
    minind = nearest(avg.time,minlim);
    maxlim = timewin(2);
    maxind = nearest(avg.time,maxlim);
    
    % find average peak moment and select channels sorted at this timepoint
    if findtime
        avg.rms = rms(avg.avg);
        [~,j] = max(avg.rms(minind:maxind));
        j = j + minind - 1;
        fprintf('Peak of data found at %f s.', avg.time(j));    
        [~,chans] = sort(mean(abs(avg.avg(:,j-1:j+1)),2),'descend');
    else
        % sort channels based on each channels maximum in the timewindow 
        % better for smaller time windows
        mxchan = max(abs(avg.avg(:,minind:maxind)),[],2);
        [~, chans] = sort(mxchan,'descend');
    end
    Lchans = chans(layout.pos(chans,1) < 0);  
    Rchans = chans(layout.pos(chans,1) > 0);
    
    bestchannels(:,1) = Lchans(1:nchans);
    bestchannels(:,2) = Rchans(1:nchans);
    
    if plotflag
        cfg = [];
        cfg.layout = layout;
        cfg.baseline = [-.3 0];
        cfg.xlim = avg.time([minind maxind]);
        cfg.interactive = 'yes';
        cfg.marker = 'off';
        cfg.style = 'fill';
        figure;
        subplot(211);
        ft_topoplotER(cfg,avg);
        hold on; scatter(layout.pos(bestchannels(:,1),1),layout.pos(bestchannels(:,1),2),'w');
        scatter(layout.pos(bestchannels(:,2),1),layout.pos(bestchannels(:,2),2),'g');
        subplot(2,1,2);
        plot(avg.time,avg.avg); hold on;
        ylim = get(gca,'ylim');
        tindx = patch([timewin(1).*[1; 1]; timewin(2).*[1;1]], [ylim';flipud(ylim')], 'k');
        set(tindx, 'FaceAlpha', 0.1);
        set(gca,'ylim',ylim)
        set(gca,'xlim',plotwin);
    end
end

