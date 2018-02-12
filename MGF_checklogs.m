function [ trlinfo, checks ] = MGF_checklogs( trlinfo, behdata, chkfields, addfields )
% MGF_readlogs read out behavioral files from subject
%   Detailed explanation goes here
    if length(trlinfo.trl(1,4:end)) ~= length(chkfields)
        error('Incorrect number of fields.')
    end
    
    if ~all(isfield(behdata,chkfields))
        error('fields must refer to fields in behdata struct');
    end
    
    checks = zeros(size(chkfields));
    for chk = 1:length(chkfields)
        beh = behdata.(chkfields{chk});
        trg = trlinfo.trl(:,chk+3);
        
        % This almost does it, but doesn't account for different ordering
        % of numbers. 
        [~,~,behpattern] = unique(beh,'stable');
        [~,~,trgpattern] = unique(trg,'stable');
        
        checks(chk) = isequal(behpattern,trgpattern);   
    end
    if all(checks)
        for ad = 1:length(addfields)
            beh = behdata.(addfields{ad});
            if isvector(beh)
                if isrow(beh)
                    beh = beh';
                end
            end
            if size(beh,1) == size(trlinfo.trl,1)
                trlinfo.trl = [trlinfo.trl beh];
            else
                error([addfields{ad} ' field is not of correct size'])
            end
        end
    else
        disp('Warning: not all of the triggers checked out with behavioral data');
    end
end

