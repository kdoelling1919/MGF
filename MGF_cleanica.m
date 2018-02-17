function [ cleandata ] = MGF_cleanica( ft_ICA,ft_PCA,weights,sphere,layout )
%MGF_cleanica remove components based on visual inspections
%   Inputs:
%       ft_ICA = ica struct as outputted by Ph_megica.m or ft_componentanalysis
%       ft_PCA = pca struct for weights and formatting
%       weights = weights variable outputted by Ph_megica.m
%       sphere = sphere variable outputted by Ph_megica.m
%       layout = layout struct as outputted by ft_prepare_layout.m
%
%   Outputs:
%       cleandata = fieldtrip data struct with ICA components removed.
%   Adapted from code written by Adden Flinker: Keith Doelling, 2/18/2016

    % visualize the ICA components
    cfg = [];
    cfg.layout = layout; % specify the layout file that should be used for plotting
    cfg.viewmode = 'component';
    cfg.continous = 'yes';
    cfg.compscale = 'local';
    cfg.blocksize = 20;
    cfg.ylim = [-4 4].*std(ft_ICA.trial{1}(:));
    ft_databrowser(cfg, ft_ICA);
    waitfor(gcf);
    % when your done input components to be removed to the prompt
    badco = inputdlg({'Bad Components:'});
    % split the input by commas
    badIcomps = str2double(regexp(badco{1},',','split'));
    activations = ft_ICA.trial{1};
    % if there is anything to remove
    if ~isempty(badco{1})
        disp(['Removing ICA components ' num2str(badIcomps)])
        activations(badIcomps,:) = 0;  % zero out the bad components
    else
        disp('No ICA components being removed')
    end
    % put everything back together again
    ICA_postreject = (weights*sphere)\activations;
    ft_PCA_ICA =ft_PCA;
    ft_PCA_ICA.trial{1}(1:size(activations,1),:) = ICA_postreject;
    % get components back
    cleandata = ft_rejectcomponent(struct('component',[],'demean','no'),ft_PCA_ICA);
end

