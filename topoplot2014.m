project_dir='/Users/Sebastian/Desktop/xdisc';
fullfile_ref='/Users/Sebastian/Desktop/xdisc/processed_data/subj02/tf_fraeMMMfxdisc02.mat'
    D = spm_eeg_load(fullfile_ref);

    dat = D.fttimelock();
    
    Elecs = D.chanlabels; 
    dat.powspctrm = zeros(D.nchannels, D.nfrequencies, D.nsamples);

    allconds=squeeze(mean(imgs,3));
    zs=squeeze(mean(allconds(:,:,:,1:2:12),4));
    os=squeeze(mean(allconds(:,:,:,2:2:12),4));

    dat.powspctrm(:,:,:)=permute(zs,[3 1 2]);

    dat.dimord='chan_freq_time';

        
    [X,Y]=getcoords(dat.label);
   
    cfg.layout='ordered';
    lay = ft_prepare_layout(cfg, dat);
    lay.pos(1:64,:)=[X;Y]';
    scaler=0.6; %workaround for a nicely scaled topoplot
    lay.pos(1:length(dat.label),:)=[X;Y]'.*scaler;
    lay.width=lay.width*scaler;
    lay.height=lay.height*scaler;
    cfg.layout= lay;
    cfg.interactive='yes';
    cfg.colorbar='yes';
%   cfg.showlabels    = 'yes';
%   cfg.colormap='jet';

%     if strcmp(plt_type,'spmT')
        cfg.zlim = [-4 4];
%     end
%   
    timeframe = [0 2];
    cfg.xlim = timeframe; % explicit windowing in time
    cfg.ylim = [8 13]; % explicit windowing in freq.  % only for topoplot
%     cfg.ylim = [20 30];
%     if strcmp(plt_type,'con')
        cfg.zlim = [-20 20]; % s.o.
%     end
%     if strcmp(plt_type,'spmF')
%         cfg.zlim = [0 10];
%     end
    
   
    cfg.style='straight';
%     h=figure;
%     timeframe=num2str(timeframe);
%     timeframe(ismember(timeframe,' ,.:;!')) = [];
    name=strcat('alpha_con_', num2str(con_ID),'_frame_',timeframe);
%     ft_multiplotTFR(cfg, dat); % multiplot
    ft_topoplotTFR(cfg, dat); % topoplot
%     ft_singleplotTFR(cfg, dat); % single plot
%     title([plt_type ' - contrast:' num2str(con_ID) BL_style]);
%     curdir=pwd;
%     cd('C:\Users\LabWorker\Desktop');
%     saveas(h,name,'png')
%     cd(curdir);
