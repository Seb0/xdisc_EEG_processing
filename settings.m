%% SETTINGS

project_dir = 'C:\Sebastian\xdisc\';
% eeg_dir = fullfile(project_dir, 'RAW', 'xdisc');
eeg_dir = 'D:\SEBASTIAN Backup RAW DATA\xdisc';
filenames = dir(eeg_dir);

% create a folder for resulting data & ebf files
% mkdir(project_dir, 'processed_data');
res_dir = fullfile(project_dir, 'processed_data', filesep);
% res_dir = fullfile(project_dir, 'processed_data', 'no_baseline_correction', filesep);

cd(res_dir); % work in result directory

sfppath='C:\Sebastian\xdisc\sfpmat\';
fname={'dspm8', 'xdisc'};
ebfname='ebf_conf'; % name of file that holds all information on detected eye-blinks

elpos = [project_dir 'elpos'];

% list of rejected subjects
reject_list = [7 14 16];
% list of subjects that don't need to be corrected for eye-blink data
dontcorrect = [];
% use default electrode locations for ...
default_locs = [];


% name of file that holds bad channels
bad_ch_file = fullfile(project_dir, 'bad_channels.csv');
bad_channels = csv2cell(bad_ch_file);

% name of file that holds bad blocks
bad_block_file = fullfile(project_dir, 'bad_blocks.csv');
bad_blocks = csv2cell(bad_block_file);

% name of file that holds the thresholds for eye-blinks
blink_thresh_file = [project_dir 'blink_thresh.csv'];
blink_thresh = csv2cell(blink_thresh_file);


%% parameter settings
lpf_cutoff   = 48;  % Hz
hpf_cutoff   = 0.5; % Hz
epoching     = 1; % where to center epoch: 1=cond_cue_locked, 2=resp_locked, 3=last_pulse_locked
epoching_labels = {'cond_cue_locked', 'resp_locked', 'last_pulse_locked'};
erp_reference = 1; % compute ERP with respect to cond_cue = 1 or resp = 2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< WICHTIG!!!!!

epoch_interval = [-1500 4500]; % ms for normal analysis
% epoch_interval = [-4500 1500]; % ms for resp locked analysis
artefact_threshold = 80; %µV

TF_method = 'morlet'; % currently: 'multitaper' or 'morlet'
TF_timewin = 400; %ms
TF_timestep = 50; %ms
TF_freqwin = [4 48]; %Hz
TF_frequencies = 2:2:48; %Hz
TF_baseline = [-1 -0.25]; % xdisc values
