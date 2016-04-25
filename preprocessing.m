fprintf('\nSPECIFICATIONS:\n-------\nFilter: %3.1f - %dHz\nEpoching: %s\nEpoch Interval: %d to %dms\nArtefact Threshold: %dmV\nTF baseline: %d to %d sec\n\n', ...
    hpf_cutoff, lpf_cutoff, epoching_labels{epoching}, epoch_interval(1), epoch_interval(2), artefact_threshold, TF_baseline(1), TF_baseline(2))
fprintf('SELECTED OPERATIONS:\n------\n%d - Import Data\n%d - Downsample\n%d - HP Filter\n%d - Coregister\n%d - Rereference\n%d - Cut Data (epoching)\n%d - Remove Artefacts\n%d - LP Filter\n%d - TF transform\n%d - SQRT transform\n%d - TF Baseline Average\n%d - TF Baseline Correction\n%d - Single Trial Baseline Correction\n%d - Create CONTRASTS for first look\n%d - Remove excessive files\n%d - Grandmean of contrasts\n\n', ...
    IMPORT_DATA,DOWNSAMPLE,HP_FILTER,COREGISTER,REREFERENCE,EPOCHS,ARTEFACTS,LP_FILTER,TIME_FREQUENCY,SQRT,TF_AVERAGE,TF_BASELINE,AVERAGE_AFTER_BC,CONTRASTS,CLEAN_UP,GRANDMEAN);
% reply = input('CONTINUE??? y/n [y]: ', 's');
% if isempty(reply)
%     reply = 'y';
% end
% 
% if strcmp(reply, 'n'), error('Aborted!'), end

disp('>>>>>>>>>>>>>>> Start!!!! <<<<<<<<<<<<<<<<<<<<<')

for i=2:length(filenames)

    [path, fname, ext] = fileparts(filenames(i).name);
    
    subj_ID = char(regexp(fname, '\d+', 'match')); % a string
    n = str2double(subj_ID); % an integer
     % only process bdf files
    if ~strcmpi(ext,'.bdf') || (ismember(n, reject_list)) || ~strfind(fname,input_filename)
        continue;
    end
    
    disp(['========================== subject ' subj_ID ' ========================='])
    
    subj_dir = ['subj',subj_ID];

    if exist(subj_dir,'dir')~=7
        mkdir(res_dir, subj_dir)
    end
    
    cd(fullfile(res_dir, subj_dir))
    try
        load(log_filename)
    catch e_catch
        disp('Cannot load log file. Will create one.')
    end
    
     %% convert the data to SPM format
    if IMPORT_DATA
        S = [];
        S.dataset = fullfile(eeg_dir, [fname ext]);
        S.outfile = [output_filename subj_ID];
        S.channels = 'all';
        S.checkboundary = 1;
        S.usetrials = 0; 
        S.datatype = 'float32-le';
        S.eventpadding = 0;
        S.saveorigheader = 0;
        S.conditionlabel = {'Undefined'};
        S.inputformat = [];
        S.continuous = true;
        D = spm_eeg_convert(S);
% %         badind = find(ismember(D.chanlabels, bad_channels{str2double(subjects{n}),:}));
        badind = D.indchannel(bad_channels{n});
        if ~isempty(badind)
            D = D.badchannels(badind, 1);
        end
        save(D);
    end
    
    if DOWNSAMPLE
        target_file = dir(file_mask);
        if isempty(target_file), disp(['No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        S = [];
        S.D = D;
        S.fsample_new = 512;
        S.prefix = '';
        D = spm_eeg_downsample(S);
        save(D);
    end
    %% high-pass filter
    if HP_FILTER
        target_file = dir(file_mask);
        if isempty(target_file)
            base_target_file = dir('xdisc*.mat');
            if isempty(base_target_file), disp(['No matching file found for subject ' subj_ID]), continue, end
            D_orig = spm_eeg_load(base_target_file(1).name);
        
            D = clone(D_orig, [output_filename subj_ID '.dat'], size(D_orig));
            D(:,:,:) = D_orig(:,:,:);
            save(D);
            clear D_orig;
        else
            D = spm_eeg_load(target_file(1).name);
        end
        
        S = [];
        S.D = D;
        S.filter.band = 'high';
        S.filter.PHz = hpf_cutoff;
        D = spm_eeg_filter(S);
        
        preprocess_log.filter.high_pass_cutoff = hpf_cutoff;
        
    end
    
    %% co-register the channel positions with recorded positions
    if COREGISTER
        target_file = dir(['f' file_mask]);
        if isempty(target_file), disp(['No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        
        % if correct positions were measured, use them ...
        loc_files = dir(fullfile(elpos, 'mat'));
        if ismember([output_filename subj_ID 'pos.mat'], {loc_files.name}) && ...
           ismember([output_filename subj_ID 'fid.mat'], {loc_files.name}) && ...
           ~ismember(n,default_locs)
            S = [];
            S.D = D;
            S.sensfile = fullfile(elpos, 'mat', [output_filename subj_ID 'pos.mat']);
            S.source = 'mat';
            S.headshapefile = fullfile(elpos, 'mat', [output_filename subj_ID 'fid.mat']);
            S.fidlabel = 'lpa nas rpa';
            S.task = 'loadeegsens';
            S.save = 1;
            D = spm_eeg_prep(S);
            preprocess_log.sensor_locs = 'measured';
        % ... otherwise use default locations
        else
            S = [];
            S.D = D;
            S.task = 'defaulteegsens';
            S.save = 1;
            D = spm_eeg_prep(S);
            preprocess_log.sensor_locs = 'default';
        end 

        S = [];
        S.D = D;
        S.task = 'coregister';
        S.save = 1;
        S.useheadshape=0;
        D = spm_eeg_prep(S);
    end
    
    %% re-reference to global average & remove eye-blink artefacts according to ebf-file
    %  Make sure that you have created an ebf-file named according to
    %  variable 'ebfname'. This file must hold PCs of eye-blinks.
    if REREFERENCE
        target_file = dir(['f' file_mask]);
        if isempty(target_file)
            base_target_file = dir('xdisc*.mat');
            if isempty(base_target_file), disp(['No matching file found for subject ' subj_ID]), continue, end
            D_orig = spm_eeg_load(base_target_file(1).name);
        
            D = clone(D_orig, [output_filename subj_ID '.dat'], size(D_orig));
            D(:,:,:) = D_orig(:,:,:);
            save(D);
            clear D_orig;
        else
            D = spm_eeg_load(target_file(1).name);
        end
          S=[];
        S.D=D;
        S.refchan='average';
        D= spm_eeg_reref_eeg(S);

        if ismember(n, dontcorrect)
            S = [];
            S.D = D;
            S.newname = ['MM' D.fname];
            D = spm_eeg_copy(S);
        else
            S = [];
            S.D = D;
            S.method = 'SPMEEG';
            S.conffile = ebfname;
            D = spm_eeg_spatial_confounds(S);

            S = [];
            S.D = D;
            S.correction = 'Berg';
            D = spm_eeg_correct_sensor_data(S);
        end
        % delete file with only one M
        target_file = dir(['Mf' file_mask]);
        if isempty(target_file), disp(['No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        D.delete();
    end
    
    
    %% define conditions & cut data into epochs around the trigger

    if EPOCHS
        target_file = dir(['MMMf' file_mask]);
        if isempty(target_file), disp(['Epoching: No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        
        tmp=D.events;
        for j=1:length(tmp)
            if isempty(tmp(j).value)
                tmp(j).value=999;
            end
        end
        evt=[tmp.value];
        
        preprocess_log.strange_trigger = sum(evt == 255);

        types = {tmp.type};
        time_stamps = [tmp.time];
        block_onsets = time_stamps(strcmp(types,'Epoch'));
        preprocess_log.block_onsets = block_onsets/60.0; % block onsets in minutes
%% RECODE TRIGGERS 
% the idea now is to do a prerecoding depending on analysis type (dont have
% to do anything for modality). Then do real recoding after epoching.

        if epoching == 1
            [tmp, evtlog, nevts, nevtlog]=recode_xdisc_paramstd(tmp, n);
        elseif epoching == 2
            [tmp, evtlog]=recode_xdisc_to_deci(tmp,n);
        elseif epoching == 3
            [tmp, evtlog]=recode_xdisc_to_last_pulse(tmp,n);
        end
        
        for i=1:length(tmp)
            tmp(i).value=nevts(i);
        end
        D=events(D, [], tmp); % store recoded trigger in events
        save(D);
        nevtlog=unique(nevtlog);

%         evtlog=[12; 13; 21; 23; 31; 32]; % no recoding, just epoch on these triggers
        S = [];
        S.D = D;
        S.bc = 1; % baseline correction

        % define trials 
        S.pretrig = epoch_interval(1);
        S.posttrig = epoch_interval(2);
       
        for j=1:length(nevtlog)
            S.trialdef(j).conditionlabel=num2str(nevtlog(j));
            S.trialdef(j).eventtype='STATUS';
            S.trialdef(j).eventvalue=nevtlog(j);
        end
        S.reviewtrials = 0;
        S.save = 0;
        D = spm_eeg_epochs(S);
%                        
        % mark all trials that happened in an aborted block as bad
        if ~isempty(bad_blocks)
            subj_bad_blocks = str2double(bad_blocks{n});
                for bb=1:length(subj_bad_blocks)
                    if isnan(subj_bad_blocks(bb)), break, end
                        D = reject(D, find(block_onsets(subj_bad_blocks(bb)) < D.trialonset & D.trialonset < block_onsets(subj_bad_blocks(bb)+1)), 1);
                end
        end
        save(D); % save bad trials from bad block
        
        preprocess_log.trials_in_bad_block = sum(D.reject);
        preprocess_log.epoching.label = epoching_labels{epoching};
%         preprocess_log.epoching.trial_type = trial_labels{trial_type};
        preprocess_log.epoching.interval = epoch_interval;
    end
    
    %% remove bad trials
    if ARTEFACTS
        target_file = dir(['eMMMf' file_mask]);
        if isempty(target_file), disp(['No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        
%         preprocess_log.empirical_artefact_threshold = mean(mean(std(D(D.meegchannels,:,:),0,2),3))*10.0;
        
        S = [];
        S.D = D;
        S.badchanthresh = 0.2;
        S.methods.channels = 'EEG';
        S.methods.fun = 'threshchan';
        S.methods.settings.threshold = artefact_threshold; % µV
%         S.methods.settings.threshold = preprocess_log.empirical_artefact_threshold; % µV
        D = spm_eeg_artefact(S);

        preprocess_log.total_rejected_trials = sum(D.reject);
        preprocess_log.bad_channels = D.badchannels;

        S=[];
        S.D=D;
        D = spm_eeg_remove_bad_trials(S);
        
    end
    
    %% low-pass filter
    if LP_FILTER
        target_file = dir(['raeMMMf' file_mask]);
        if isempty(target_file), disp(['No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        
        S = [];
        S.D = D;
        S.filter.band = 'low';
        S.filter.PHz = lpf_cutoff;
        D = spm_eeg_filter(S);
        
        preprocess_log.filter.low_pass_cutoff = lpf_cutoff;
    end
    %% compute time-frequency responses
    if TIME_FREQUENCY
        target_file = dir(['fraeMMMf' file_mask]);
        if isempty(target_file), disp(['TF: No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
    
        % compute time frequency response
        if strcmpi(TF_method, 'multitaper')
            % multitaper approach
            S = [];
            S.D=D;
            S.channels = D.chanlabels(D.meegchannels);
            S.pretrig  = epoch_interval(1);
            S.posttrig = epoch_interval(2);
            S.timewin  = TF_timewin;
            S.timestep = TF_timestep; 
            S.freqwin  = TF_freqwin; 
            D = spm_eeg_ft_multitaper_tf(S);
        elseif strcmpi(TF_method, 'morlet');
            % Morlet Wavelets
            S = [];
            S.D = D;
            S.channels = {'EEG'};
            S.frequencies = TF_frequencies;
            S.timewin = epoch_interval;
            S.phase = 0;
            S.method = TF_method;
            S.settings.ncycles = 7;
            S.settings.subsample = 25; % round(TF_timestep / (1000./D.fs)) in ms;
            [D Dph] = spm_eeg_tf(S);
        else
            error('Unknown TF_method')
        end
    
        % average over induced power
        if TF_AVERAGE
            % average TF results
            S = [];
            S.D=D;
            S.robust = 0;
            D = spm_eeg_average_TF(S);
        end
        
        preprocess_log.TF.timewin = TF_timewin;
        preprocess_log.TF.timestep = TF_timestep;
        preprocess_log.TF.freqwin = TF_freqwin;
        preprocess_log.TF.method = TF_method;
    end
    
    %% square-root transform
    if SQRT
%         if TF_AVERAGE
%             target_file = dir(['mtf_fraeMMMf' file_mask]);
%         else
%             target_file = dir(['tf_fraeMMMf' file_mask]);
%         end
        target_file = dir(['mtf_fraeMMMf' file_mask]);  
        D=spm_eeg_load(target_file(1).name);
        sqrtD = clone(D, ['sqrt_' D.fnamedat], size(D));
        sqrtD(:,:,:,:) = sqrt(D(:,:,:,:));
        save(sqrtD);
        clear D;
    end
    
    if SQRT
%         if TF_AVERAGE
%             target_file = dir(['mtf_fraeMMMf' file_mask]);
%         else
%             target_file = dir(['tf_fraeMMMf' file_mask]);
%         end
        target_file = dir(['tf_fraeMMMf' file_mask]);  
        D=spm_eeg_load(target_file(1).name);
        sqrtD = clone(D, ['sqrt_' D.fnamedat], size(D));
        sqrtD(:,:,:,:) = sqrt(D(:,:,:,:));
        save(sqrtD);
        clear D;
    end
    
    if TF_BASELINE
        if TF_AVERAGE
            target_file = dir(['mtf_fraeMMMf' file_mask]);
            if isempty(target_file), disp(['Rescaling: No matching file found for subject ' subj_ID]), continue, end
            D = spm_eeg_load(target_file(1).name);
%         elseif SQRT
%             target_file = dir(['sqrt_mtf_fraeMMMf' file_mask]);
%             if isempty(target_file), disp(['Rescaling: No matching file found for subject ' subj_ID]), continue, end
%             D = spm_eeg_load(target_file(1).name);
        else
            target_file = dir(['tf_fraeMMMf' file_mask]);
            if isempty(target_file), disp(['Rescaling: No matching file found for subject ' subj_ID]), continue, end
            D = spm_eeg_load(target_file(1).name);
        end            
        
        % rescale the TF results in relation to the average power in percent 
        S = [];
        S.D = D;
%         if SQRT
%             S.tf.method = 'Sqrt';
%         else
        S.tf.method = 'Rel';
%         end
        S.tf.Db = [];
        S.tf.Sbaseline = TF_baseline; % in seconds 0 = epoching point
        D = spm_eeg_tf_rescale(S);
        
        preprocess_log.TF.baseline = TF_baseline;
    end
    
    if TF_BASELINE
        target_file = dir(['tf_fraeMMMf' file_mask]);
        if isempty(target_file), disp(['Rescaling: No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
                    
        
        % rescale the TF results in relation to the average power in percent 
        S = [];
        S.D = D;
%         if SQRT
%             S.tf.method = 'Sqrt';
%         else
        S.tf.method = 'Rel';
%         end
        S.tf.Db = [];
        S.tf.Sbaseline = TF_baseline; % in seconds 0 = epoching point
        D = spm_eeg_tf_rescale(S);
        
        preprocess_log.TF.baseline = TF_baseline;
    end
    
    if AVERAGE_AFTER_BC   
        target_file = dir(['rtf_fraeMMMf' file_mask]);
        if isempty(target_file), disp(['TF: No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        S = [];
        S.D=D;
        S.robust = 0;
        D = spm_eeg_average_TF(S);
    end
    
    if CONTRASTS
%         target_file = dir(['sqrt_mtf_fraeMMMf' file_mask]);
        target_file = dir(['sqrt_mtf_fraeMMMf' file_mask]);
        if isempty(target_file), disp(['Contrasts: No matching file found for subject ' subj_ID]), continue, end
        D = spm_eeg_load(target_file(1).name);
        
        S = [];
        S.D = D;
        S.c = [1/4 1/4 0 0 1/4 1/4 0 0 0 0 0 0; % specify contrasts here
               0 0 1/4 1/4 0 0 0 0 1/4 1/4 0 0;
               0 0 0 0 0 0 1/4 1/4 0 0 1/4 1/4;
               1 1 -1 -1 1 1 0 0 -1 -1 0 0;
               1 1 0 0 1 1 -1 -1 0 0 -1 -1;
               0 0 1 1 0 0 -1 -1 1 1 -1 -1;
               1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12;
               0 1/6 0 1/6 0 1/6 0 1/6 0 1/6 0 1/6;
               1/6 0 1/6 0 1/6 0 1/6 0 1/6 0 1/6 0;
               -1 1 -1 1 -1 1 -1 1 -1 1 -1 1;
               1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 ]; 
        S.label = {'AV' 'TV' 'TA' 'A-T' 'V-T' 'V-A' 'grandmean' 'corrects' 'false' 'correct-false' 'false-correct'}; % specify labels here. #elem.=#rows in S.c
        S.WeightAve = 0;
        D = spm_eeg_weight_epochs(S);
    end
    
    if CLEAN_UP
%         delete('xdisc*')
        delete('aeMebf*')
        delete('aeMMMf*')
        delete('eMMMf*')
        delete('aefMMM*')
        delete('raeMMMf*')
    end
    if GRANDMEAN
        target_file = dir(['rmtf_fraeMMMf' file_mask]);
        gm_list{i,:}=target_file.name; 
        if exist(strcat('..\grandmean\',target_file.name),'file')~=2
            copyfile('rmtf_*','..\grandmean\');
        end
    end
    if exist('preprocess_log', 'var')
        save(fullfile(res_dir, subj_dir, log_filename), 'preprocess_log');
    end
end
%% spm_eeg_grandmean
if GRANDMEAN
        cd 'C:\Sebastian\xdisc\processed_data\grandmean\'
        target_file = dir(['rmtf_fraeMMMf' file_mask]);
        if isempty(target_file), disp(['Grandmean: No matching file found for subject ' subj_ID]), end
        gm_list(2)=[]; gm_list(2)=[]; % this needs to be here
        gm_list(6)=[]; gm_list(12)=[]; gm_list(13)=[]; 
        gm_mat=cell2mat(gm_list);
        S = [];
        S.D = gm_mat;
        S.weighted = 0;
        S.Dout = 'C:\Sebastian\xdisc\processed_data\grandmean\grandmean';
        D = spm_eeg_grandmean(S);
end
