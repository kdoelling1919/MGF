function [ output_args ] = Ph_cleanica( ft_ICA,weights,sphere,layout )
%Ph_cleanica remove components e
%   Detailed explanation goes here

    cfg = [];
    cfg.layout = layout; % specify the layout file that should be used for plotting
    cfg.viewmode = 'component';
    cfg.continous = 'yes';
    cfg.compscale = 'local';
    cfg.blocksize = 20;
    cfg.ylim = [-4 4].*std(ft_ICA.trial{1}(:));

    ft_databrowser(cfg, ft_ICA);
    waitfor(gcf);

    badco = inputdlg({'Bad Components:'});
    badIcomps = str2double(regexp(badco{1},',','split'));
    activations = ft_ICA.trial{1};
    if ~isempty(badco{1})
        disp(['Removing ICA components ' num2str(badIcomps)])
        activations(badIcomps,:) = 0;  % remove components
    else
        disp('No ICA components being removed')
    end
    ICA_postreject = inv(weights*sphere)*activations;
end

