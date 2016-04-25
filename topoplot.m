function topoplot(con_ID, BL_style, plt_type, fullfile_ref, project_dir)  

    if nargin < 5
        project_dir = '/Users/Sebastian/Desktop/xdisc';
    end

    if nargin < 4
%          fullfile_ref = fullfile(project_dir, 'processed_data\subj02\sqrt_tf_fraeMMMfxdisc02.mat');
         fullfile_ref = fullfile(project_dir, '/Users/Sebastian/Desktop/xdisc/processed_data/subj02/tf_fraeMMMfxdisc02.mat');
    end
    
    if nargin < 3
        plt_type = 'spmT'
    end
    
    D = spm_eeg_load(fullfile_ref);
%     dir_krzl = 'C:\Sebastian\xdisc\analysis\mod\noBC\stats_noBC\'; %baseline
    dir_krzl = 'C:\Sebastian\xdisc\analysis\mod_x_n1\noBC\correct_trials\group_sel_17\con0005\'; %baseline
%     dir_krzl = 'C:\Sebastian\xdisc\analysis\left_right\noBC\group_sel_17\con0002\'
    cd(dir_krzl);
    
    dat = D.fttimelock();
    
    Elecs = D.chanlabels; %{'Fp1';'AF7';'AF3';'F1';'F3';'F5';'F7';'FT7';'FC5';'FC3';'FC1';'C1';'C3';'C5';'T7';'TP7';'CP5';'CP3';'CP1';'P1';'P3';'P5';'P7';'P9';'PO7';'PO3';'O1';'Iz';'Oz';'POz';'Pz';'CPz';'Fpz';'Fp2';'AF8';'AF4';'AFz';'Fz';'F2';'F4';'F6';'F8';'FT8';'FC6';'FC4';'FC2';'FCz';'Cz';'C2';'C4';'C6';'T8';'TP8';'CP6';'CP4';'CP2';'P2';'P4';'P6';'P8';'P10';'PO8';'PO4';'O2'};
    dat.powspctrm = zeros(D.nchannels, D.nfrequencies, D.nsamples);
    
    for el=1:length(Elecs)
        el
        
        if con_ID<10
            actdir = fullfile(dir_krzl, Elecs{el}, [plt_type '_000' num2str(con_ID) '.img']);
        else
            actdir = fullfile(dir_krzl, Elecs{el}, [plt_type '_00' num2str(con_ID) '.img']);
        end
        actimg = ft_read_mri(actdir);
        
        dat.powspctrm(el,:,:)=actimg.anatomy;

        dat.dimord='chan_freq_time';
    end
        
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

    if strcmp(plt_type,'spmT')
        cfg.zlim = [-4 4];
    end
%   
    timeframe = [0 2];
    cfg.xlim = timeframe; % explicit windowing in time
    cfg.ylim = [8 13]; % explicit windowing in freq.  % only for topoplot
%     cfg.ylim = [20 30];
    if strcmp(plt_type,'con')
        cfg.zlim = [-20 20]; % s.o.
    end
%     if strcmp(plt_type,'spmF')
%         cfg.zlim = [0 10];
%     end
    
   
    cfg.style='straight';
    h=figure;
    timeframe=num2str(timeframe);
    timeframe(ismember(timeframe,' ,.:;!')) = [];
    name=strcat('alpha_con_', num2str(con_ID),'_frame_',timeframe);
%     ft_multiplotTFR(cfg, dat); % multiplot
    ft_topoplotTFR(cfg, dat); % topoplot
%     ft_singleplotTFR(cfg, dat); % single plot
    title([plt_type ' - contrast:' num2str(con_ID) BL_style]);
    curdir=pwd;
    cd('C:\Users\LabWorker\Desktop');
    saveas(h,name,'png')
    cd(curdir);
end