function [ cleandata ] = Ph_cleanica( ft_ICA,ft_PCA,weights,sphere,layout )
%Ph_cleanica remove components based on visual inspections
%   ft_ICA = ica struct as outputted by Ph_megica.m or ft_componentanalysis
%   ft_PCA = pca struct for weights and formatting
%   weights = weights variable outputted by Ph_megica.m
%   sphere = sphere variable outputted by Ph_megica.m
%   layout = layout struct as outputted by ft_prepare_layout.m
%
%   Adapted from code written by Adden Flinker: Keith Doelling, 2/18/2016

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
    ICA_postreject = (weights*sphere)\activations;
    
    ft_PCA_ICA =ft_PCA;
    ft_PCA_ICA.trial{1}(1:size(activations,1),:) = ICA_postreject;
    cleandata = ft_rejectcomponent(struct('component',[],'demean','no'),ft_PCA_ICA);
end

