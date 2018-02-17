function [ cleandata ] = MGF_overclean( data, neighbours, thresh, chan2repair, minsec, segwin )
%MFG_overclean Really gets in there and scrubs
%   Inputs:
%       data = fieldtrip data struct
%       neighbours = fieldtrip neighbours struct
%       thresh = a scalar value, a threshold to find aberrant data.
%       chan2repair = a scalar value, the number of aberrant channels to
%           tolerate before removing pca components to get rid of the
%           artifact. If the number of channels is less than chan2repair,
%           we will use ft_channelrepair to fix it.
%       minsec = add buffer (in seconds) around artifacts to make sure we get it all
%       segwin = a window around each artifact to search for other
%       artifacts. If a second artifact is within the window, treat them as
%       one.
%
%   Outputs:
%       cleandata = output data struct
    dat = data.trial{1};
        
        % thresh
        lastthresh = [];
        %find first segments that are out of the threshold
        outthresh = abs(dat) > thresh;
        counter = 0;
        % iterate process until no samples are out of threshold or if
        % script doesn't reduce the number of samples out of threshold
    while any(outthresh(:)) || sum(lastthresh(:)) < sum(outthresh(:))
        artsum = bwlabeln(logical(sum(outthresh)));

        % identify the number of segments
        artind = unique(artsum(:));
        artind(1) = []; % remove the zero
        neighborfix = zeros(size(artsum));
        pcafix = neighborfix;

        % for each bad segment
        for a = 1:length(artind)
            %find the segments
            [~,c] = find(artsum == a);

            % if nothing in the segment skip it (i don't think this
            % happens)
            if isempty(c)
                continue
            end
            % find other nearby artifacts
            begseg = c(1) - segwin;
            if begseg < 1
                begseg = 1;
            end
            endseg = c(end) + segwin;
            if endseg > length(artsum)
                endseg = length(artsum);
            end
            segment = artsum(begseg:endseg);
            [~,d] = find(segment);
            d = d + begseg-1;

            % see if there was anything there and identify
            left = setxor(d,c);
            if ~isempty(left)
                % if so, incorporate those artifacts in as well
                extra = artsum(left);
                begin = find(artsum == extra(1));
                endin = find(artsum == extra(end));
                samp2fix = (min([begin(1) c(1)])):(max([endin(end) c(end)]));
                artsum(ismember(artsum,extra)) = 0;
            else
                endsamp = c(end) + minsec*data.fsample;
                begsamp = c(1) - minsec*data.fsample;

                if endsamp > size(dat,2)
                    endsamp = size(dat,2);
                end
                if begsamp < 1
                    begsamp = 1;
                end
                % if not, samples to fix plus the minimum number of samples
                % on each side
                samp2fix = begsamp:endsamp;
            end
            % determine all channels in need of fixing within the sample
            chan2fix = find(any(outthresh(:,samp2fix),2));

            % pick out just this segment and put it into a fieldtrip struct
                segdata = data;
                segdata.trial{1} = dat(:,samp2fix);
                segdata.time{1} = segdata.time{1}(samp2fix);

                %if there are only a few channels, use ft_channelrepair
            if length(chan2fix) <= chan2repair && ~isempty(chan2fix)
                % small number of channels get repaired                
                cfg = [];
                cfg.badchannel = segdata.label(chan2fix);
                cfg.neighbours = neighbours;
                cfg.missingchannel = [];
                cfg.method = 'spline';
                fixdata = ft_channelrepair(cfg,segdata);
                dat(:,samp2fix) = fixdata.trial{1};

                neighborfix(samp2fix) = 1;
            elseif length(chan2fix) > chan2repair
                % if there are a large number of channels, remove first
                % component of pca
                [EigenVectors,EigenValues]=pcsquash(segdata.trial{1});

                PCA_seg = ft_componentanalysis(struct('demean','no','unmixing',EigenVectors','topolabel',{segdata.label}),segdata);

                fixdata = ft_rejectcomponent(struct('component',1),PCA_seg);
                % input PCA cleaned data into dat matrix
                dat(:,samp2fix) = fixdata.trial{1};

                if samp2fix(1) > 10
                    % smooth out the discontinuities with conv2
                    % beginning
                    smoother = conv2(dat(:,samp2fix(1)-10:samp2fix(1)+10),ones(1,5)./5,'same');
                    dat(:,samp2fix(1)-5:samp2fix(1)+5) = smoother(:,6:16);
                end

                if samp2fix(end) < size(dat,2) - 10
                % ending
                smoother = conv2(dat(:,samp2fix(end)-10:samp2fix(end)+10),ones(1,5)./5,'same');
                dat(:,samp2fix(end)-5:samp2fix(end)+5) = smoother(:,6:16); 
                pcafix(samp2fix) = 1;
                end
            end    
        end
        % check old and new as to samples out of threshold
        lastthresh = outthresh;
        outthresh = abs(dat) > thresh;
        counter = counter + 1;
    end
    cleandata = data;
    cleandata.trial{1} = dat;
    fprintf('%d iterations ran\n', counter);
end

