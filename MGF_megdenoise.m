function bads = MGF_megdenoise(sqdfile, emptyfile, knownbads)
% MGF_megdenoise, cleans MEG data by using Adeen's LSdenoise function
%   Inputs:
%       sqdfile = filepath to sqd file.
%       emptyfile = filepath to emptyroom data (if empty use the sqdfile
%           again
%       knownbads = channels that we know for sure are bad
%
%   Outputs:
%       bads = a number vector of found bad channels including knownbads
%
%   Denoised is written to a new sqdfile in the same folder as sqdfile
%   with -LSdenoised_NR suffixed to the name 
    
    % if no empty room file use the data
    if isempty(emptyfile)
       emptyfile = sqdfile;
    end
    % find the bad channels
    bads = MGFmark_bad_channels(sqdfile,knownbads);
    % run Adeen's denoising script
    LSdenoise(emptyfile,sqdfile,[],[],bads,[],1);
    delete(strrep(sqdfile,'.sqd','-LSdenoised.sqd'))
end

