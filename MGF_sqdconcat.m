function MGF_sqdconcat( sqdnames, outputname, rmflag )
% MGF_sqdconcat Concatenate sqd files in order.
%   sqdnames = {'block1.sqd','block2.sqd','block3.sqd'}
%   outputname = 'wholesession.sqd'
%   rmflag = delete original files? (1 or 0)

    if nargin == 3
        rmflag = 0;
    end

    copyfile(sqdnames{1},outputname);
    
    for s = 2:length(sqdnames)
        [data, ~] = sqdread(sqdnames{s});
        
        sqdwrite(outputname,outputname,'Action','Append','Data',data);
        
    end
    if rmflag
        cellfun(@delete,sqdnames)
    end
end


