%% EEG PROCESSING FOR XDISC

% main script, controls other subscripts
% @author: s.fleck@fu-berlin.de , adapted from J.Herding & B.Spitzer

clear all; clc;
% addpath(genpath('C:\Users\LabWorker\Documents\MATLAB\spm8'));
spm('defaults', 'eeg');
output_filename = 'xdisc';
input_filename = 'xdisc';
log_filename = ['log_' output_filename];

%% define work steps - make sure that the file_mask matches the right conditions!!!
file_mask = 'xdisc*.mat';
IMPORT_DATA      = 0;
DOWNSAMPLE       = 0; 
HP_FILTER        = 0; 
COREGISTER       = 1;
REREFERENCE      = 1;
EPOCHS           = 0;
ARTEFACTS        = 0;
LP_FILTER        = 0;
TIME_FREQUENCY   = 0;
SQRT             = 0; % if 1, rescaling = 0
TF_AVERAGE       = 0;
TF_BASELINE      = 0; % Berni rescaling - sqrt=0
AVERAGE_AFTER_BC = 0; % dont need this yet
CONTRASTS        = 1;
CLEAN_UP         = 0;
GRANDMEAN        = 0;

settings; % subscript that defines settings for EEG analysis
preprocessing;
% create_smooth_imgV2;
% cd 'C:\Sebastian\xdisc\analysis\'
% GLM2_1;
% clear all; clc;
% GLM2_2_wBC;
% clear all; clc;
% GLM2_2_2_wBC;





