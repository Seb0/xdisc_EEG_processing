project_dir = 'C:\Sebastian\xdisc';
ref_dir = project_dir;

% dir_img =  fullfile(project_dir, 'analysis', 'mod', 'stats');
dir_img=fullfile(project_dir, 'processed_data', 'grandmean');
cd(dir_img);

subj = {'02', '03', '04', '05', '06', '08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'}; % 17 subjects

N = length(subj);




foi = [8 13];

black = [0 0 0];
blue = [0 0 1];
lblue = [0.7 .78 1];
lred  = [1 0.69 0.39];
red = [1 0 0];

% change file ID for different images
file_ID = 'sqrt_tf_frae*';
x_lim = [-1.5 4.5];
y_lim = [-10 50];
match = dir(fullfile(ref_dir, 'processed_data', 'subj02', [file_ID '*.mat']));
D_init = spm_eeg_load(fullfile(ref_dir, 'processed_data', 'subj02', match(1).name)); % simply load a spm-data file from the same study to get channel labels
elecs = D_init.chanlabels;
roi = elecs;
% roi = {'CP1', 'CPz', 'CP2', 'CP4', 'P1', 'Pz', 'P2', 'P4', 'POz', 'PO4'};
passband_idx = unique(D_init.indfrequency(foi(1):foi(2)));
passband_idx = passband_idx(~isnan(passband_idx));
t = D_init.time;

img_ID = {'grandmean.mat'};

data = zeros(D_init.nsamples, length(roi));
for el=1:length(roi)
    cd(roi{el});
    beta_img = ft_read_mri(img_ID{1});
    data(:,el) = squeeze(mean(beta_img.anatomy(passband_idx,:)));
    cd ..
end

avg_time_courses = squeeze(mean(data,2));

% mycolor_order = [red; lred; lblue; blue];
mycolor_order=black;

figure;
axes('position', [0.1 0.2 0.8 0.6])
set(gca, 'FontSize', 10)
set(gca, 'ColorOrder', mycolor_order)

plot(t, avg_time_courses, '-', 'linewidth', 2)


