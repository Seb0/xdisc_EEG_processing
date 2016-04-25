clear all; clc; 

project_dir = 'C:\Sebastian\xdisc';
ref_dir = project_dir;

file_ID = 'rtf_frae*'; % change file ID for different images
img_ID = {'con_0005.img'};
foi = [8 13];

black = [0 0 0];
blue = [0 0 1];
lblue = [0.7 .78 1];
lred  = [1 0.69 0.39];
red = [1 0 0];
% roi = {'C4', 'C3'};
roi = {'Pz'};
% roi = {'CP1', 'CPz', 'CP2', 'CP4', 'P1', 'Pz', 'P2', 'P4', 'POz', 'PO4'};

dir_img =  fullfile(project_dir, 'analysis', 'mod_x_n1', 'BC', 'incorrect_trials');
subj = {'02', '03', '04', '05', '06', '08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'}; % 17 subjects
load('C:\Sebastian\xdisc\behaviorals and graphs\xdisc_perf_RT_perModPair.mat');
%deleted kicked subj
xdisc_aggr2([6 13 15],:)=[];
norm2sub_mean_visaudP=xdisc_aggr2(:,4)-xdisc_aggr2(:,2);
norm2sub_mean_vistacP=xdisc_aggr2(:,5)-xdisc_aggr2(:,2);
norm2sub_mean_audtacP=xdisc_aggr2(:,6)-xdisc_aggr2(:,2);
norm2sub_mean_visaudRT=xdisc_aggr2(:,7)-xdisc_aggr2(:,3);
norm2sub_mean_vistacRT=xdisc_aggr2(:,8)-xdisc_aggr2(:,3);
norm2sub_mean_audtacRT=xdisc_aggr2(:,9)-xdisc_aggr2(:,3);
N = length(subj);

x_lim = [-1.5 4.5];
y_lim = [-10 50];
match = dir(fullfile(ref_dir, 'processed_data', 'subj02', [file_ID '*.mat']));
D_init = spm_eeg_load(fullfile(ref_dir, 'processed_data', 'subj02', match(1).name)); % simply load a spm-data file from the same study to get channel labels
elecs = D_init.chanlabels;
% roi = elecs; % if you want all elecs, do that here, otherwise above
passband_idx = unique(D_init.indfrequency(foi(1):foi(2)));
passband_idx = passband_idx(~isnan(passband_idx));
% t = D_init.time;
t = D_init.time(32:72);
corr_table=zeros(17,43);

for vol=1:N % cycle thru volunteers (subs)
    sub_dir=fullfile(dir_img, strcat('subj', subj{vol}), 'stats');
    cd(sub_dir);
    data = zeros(D_init.nsamples, length(roi));
    for el=1:length(roi)
        cd(roi{el});
        beta_img = ft_read_mri(img_ID{1});
        data(:,el) = squeeze(mean(beta_img.anatomy(passband_idx,:)));
        cd ..
    end

    avg_time_courses = squeeze(mean(data,2));
    stim_time_only=avg_time_courses(32:72);
    % mycolor_order = [red; lred; lblue; blue];
    mycolor_order=black;
%     
%     figure;
%     axes('position', [0.1 0.2 0.8 0.6])
%     set(gca, 'FontSize', 10)
%     set(gca, 'ColorOrder', mycolor_order)
%     
%     plot(t, avg_time_courses, '-', 'linewidth', 2)
%     plot(t, stim_time_only, '-', 'linewidth', 2)
    corr_table(vol,1)=str2double(subj{vol});
    corr_table(vol,2)=norm2sub_mean_visaudP(vol);
    corr_table(vol,3)=norm2sub_mean_vistacP(vol);
    corr_table(vol,4)=norm2sub_mean_audtacP(vol);
    corr_table(vol,5:45)=stim_time_only;
end
% 
course=mean(corr_table(:,5:45),1);
course_sem=std(corr_table(:,5:45),1)/sqrt(17);

incr_decr_index=mean(corr_table(:,5:45),2);
figure;
plot(t, course, '-', 'linewidth', 2);
% shadedErrorBar(t,course,course_sem,'-k',1)
disp(['#### Correlating VisAud with mean of ' roi{:} ' during stimulation ####']);
[r p]=corrcoef(incr_decr_index, corr_table(:,2))
disp(['#### Correlating VisTac with mean of ' roi{:} ' during stimulation ####']);
[r p]=corrcoef(incr_decr_index, corr_table(:,3))
disp(['#### Correlating AudTac with mean of ' roi{:} ' during stimulation ####']);
[r p]=corrcoef(incr_decr_index, corr_table(:,4))
