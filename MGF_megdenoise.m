function bads = MGF_megdenoise(sqdfile, emptyfile, knownbads)
% MGF_megdenoise, cleans MEG data by using Adeen's LSdenoise function
    
    % if no empty room file use the data
    if isempty(emptyfile)
       empfile = sqdfile;
    else
       empfile = [subdir '/' emptyfile.name];
    end
    % find the bad channels
    bads = MGFmark_bad_channels(sqdfile,knownbads);
    % run Adeen's denoising script
    LSdenoise(empfile,sqdfile,[],[],bads,[],1);
    delete('*LSdenoised.sqd')
end

