%% find bad channels and denoise these suckers.

homedir = '/Volumes/Vault/Data/Phonetica';
% find subjects
subjects = dir([homedir '/R*']);
srch = '*Phonetica*1.sqd';

% identify channels that are known to be wonky
knownbads = [41 116 113 153];
for sub = 1:length(subjects)
   % find sqdfiles to denoise and remove those that have already been denoised 
   subdir = [homedir '/' subjects(sub).name];
   sqdfiles = dir([subdir '/' srch]);
   nr = ~cellfun(@isempty,strfind({sqdfiles.name},'NR.sqd'));
   if nr == length(sqdfiles)/2
       continue
   elseif any(nr)
       sqdfiles(nr) = [];
   end
   
   % look for empty room file
   emptyfile = dir([subdir '/*EmptyRoom*.sqd']); 
   % find bad channels and denoise
   for sqd = 1:length(sqdfiles);
       sqdfile = [subdir '/' sqdfiles(sqd).name];
       % if not empty roomfile use the data
       if isempty(emptyfile)
           empfile = sqdfile;
       else
           empfile = [subdir '/' emptyfile.name];
       end
       % find the bad channels
       bads = mark_bad_channels(sqdfile,knownbads);
       % run Adeen's denoising script
       LSdenoise(empfile,sqdfile,[],[],bads,[],1);
   end  
    delete('*LSdenoised.sqd')
end

