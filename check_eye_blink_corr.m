function check_eye_blink_corr(D, E, n_comps, new_fname)
% function that computes the priciple components in sensor space that
% correspond to eye-blinks
% D       - MEEG object which must hold information on eye-blinks (i.e. result of function detect_eye_blinks)
% n_comps - nr of principal components that should be calculated

if nargin < 4
    new_fname = 'ebf_check';
end

% refeed the triggers into the corrected file
S = [];
S.triggertime = E.time; % dies sollte das aeMebf_fxdisc*.mat sein
% I CANT SEEM TO FEED THE EYEBLINK TRIGGERS INTO THE ALREADY CORRECTED FILE

% create epochs around all detected eye-blink events
S = [];
S.D = D; % dies sollte das MMMfxdisc*.mat sein
S.pretrig = -200;
S.posttrig = 400;
S.trialdef.conditionlabel = 'blink';
S.trialdef.eventtype = 'artefact';
S.trialdef.eventvalue = {'eyeblink'};
S.reviewtrials = 0;
S.save = 0;
S.epochinfo.padding = 0;
D_ebf2 = spm_eeg_epochs(S);


% mark bad trials as they might screw up the PCA
S = [];
S.D = D_ebf2;
S.badchanthresh = 0.2;
S.methods.channels = 'EEG';
S.methods.fun = 'threshchan';
S.methods.settings.threshold = 500; % mV
D_ebf3 = spm_eeg_artefact(S);


% compute the average of all eye-blink events
S = [];
S.D = D_ebf3;
S.robust=0;
S.review=0;
D_ebf4 = spm_eeg_average(S);  


% compute SVD to find first two principal components of avg. eye-blink in
% channel space
S = [];
S.D = D_ebf4;
S.method = 'SVD';
S.timewin = [-0.2 0.4]; % in seconds?
S.ncomp = n_comps;
D_ebf5 = spm_eeg_spatial_confounds(S);

% copy data to simple file name
S = [];
S.D = D_ebf5;
S.newname = new_fname;
spm_eeg_copy(S);

D_ebf1.delete(); % re-referanced
D_ebf2.delete(); % epoched
D_ebf3.delete(); % badtrials marked (artefact rej.)
D_ebf4.delete(); % average of all blink events