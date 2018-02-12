function bads = MGF_megdenoise(sqdfile, emptyfile, knownbads)
% MGF_megdenoise, cleans MEG data by using Adeen's LSdenoise function
    
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

