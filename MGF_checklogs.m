function [ trlinfo, checks ] = MGF_checklogs( trlinfo, behdata, chkfields, addfields )
% MGF_checklogs compares trlinfo with behavioral data and incorporates beh
% into trl
%   Inputs
%       trlinfo = a struct received from MGF_triggerread which outputs
%           trigger orders and trialinformation
%       behdata = a struct containing behavioral data and information about
%           condition order from the behavioral perspective
%       chkfields = a cell with strings specifying the fields in behdata to
%           compare against trlinfo.
%       addfields = a cell with strings specifying the fields in behdata to
%           be added to trlinfo.trl.
%
%   Outputs
%       trlinfo = a new trlinfo struct with behavioral data incorporated
%       checks = a vector the same length as chkfields. Returns 1s if
%           chkfields data matches trigger data.
%           
    
    % Make sure there are enough columns in trlinfo.trl to compare against
    % chkfields
    if length(trlinfo.trl(1,4:end)) ~= length(chkfields)
        error('Incorrect number of fields.')
    end
    % make sure chkfields are in fact fields in behdata
    if ~all(isfield(behdata,chkfields))
        error('fields must refer to fields in behdata struct');
    end
    % compare fields in behdata against trigger info
    checks = zeros(size(chkfields));
    for chk = 1:length(chkfields)
        % behavioral data
        beh = behdata.(chkfields{chk});
        % trigger data
        trg = trlinfo.trl(:,chk+3);
        
        % get the unique pattern in a stable way for each of these. Doing
        % it this way, we don't need to ensure that the specific numbers
        % are the same only that the number pattern is the same.
        [~,~,behpattern] = unique(beh,'stable');
        [~,~,trgpattern] = unique(trg,'stable');
        % make sure patterns are equal.
        checks(chk) = isequal(behpattern,trgpattern);   
    end
    % if everything checks out, add the specified fields to trlinfo.trl
    if all(checks)
        for ad = 1:length(addfields)
            beh = behdata.(addfields{ad});
            % make sure vector data is in column format
            if isvector(beh)
                if isrow(beh)
                    beh = beh';
                end
            end
            % make sure it is the correct size
            if size(beh,1) == size(trlinfo.trl,1)
                % append
                trlinfo.trl = [trlinfo.trl beh];
            else
                error([addfields{ad} ' field is not of correct size'])
            end
        end
    else
        % if not everything checks out, put up a warning and quit.
        disp('Warning: not all of the triggers checked out with behavioral data');
    end
end

