%% alpha topography power graph producer for mod_x_n1 analysis

clear all; clc; 

project_dir = 'C:\Sebastian\xdisc';
ref_dir = project_dir;

file_ID = 'rtf_frae*'; % change file ID for different images
img_ID = {'beta_0001.img', 'beta_0002.img'}; % incorrect , correct
% img_ID = {'beta_0001.img'}
foi = [8 13];

black = [0 0 0];
blue = [0 0 1];
green = [0 1 0];
red = [1 0 0];
% roi = {'C3','C4'};
% roi={'Pz'};
% roi={'T7', 'T8'};


dir_img =  fullfile(project_dir, 'analysis', 'pwr_graph_corr_vs_incorr', 'BC');
subj = {'02', '03', '04', '05', '06', '08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'}; % 17 subjects
N = length(subj);

x_lim = [-1.5 4.5];
y_lim = [-10 50];
match = dir(fullfile(ref_dir, 'processed_data', 'subj02', [file_ID '*.mat']));
D_init = spm_eeg_load(fullfile(ref_dir, 'processed_data', 'subj02', match(1).name)); % simply load a spm-data file from the same study to get channel labels
elecs = D_init.chanlabels;
roi = elecs; % if you want all elecs, do that here, otherwise above
passband_idx = unique(D_init.indfrequency(foi(1):foi(2)));
passband_idx = passband_idx(~isnan(passband_idx));
% t = D_init.time;
t = D_init.time(22:103);


for vol=1:N % cycle thru volunteers (subs)
    sub_dir=fullfile(dir_img, strcat('subj', subj{vol}), 'stats');
    cd(sub_dir);
    data = zeros(D_init.nsamples, length(img_ID), length(roi));
    for im=1:length(img_ID)
        for el=1:length(roi)
            cd(roi{el});
            beta_img = ft_read_mri(img_ID{im});
            data(:,im,el) = squeeze(mean(beta_img.anatomy(passband_idx,:)));
            cd ..
        end
    end
    avg_time_courses = squeeze(mean(data,3));
    shorten=avg_time_courses(22:103,:);
    mycolor_order = [red; green; blue; black];

    
%     
%     plot(t, avg_time_courses, '-', 'linewidth', 2)
%     plot(t, stim_time_only, '-', 'linewidth', 2)
    corr_table(vol,1,:) = subj{vol};    
    corr_table(vol,2:83,:)=shorten;
end

courses=mean(corr_table(:,2:83,:),1);
course_sem=squeeze(std(corr_table(:,2:83,:),1)/sqrt(17));

courses=squeeze(courses);

figure;
axes('position', [0.1 0.2 0.8 0.6])
xlabel('time (s)');
ylabel('alpha amplitude change relative to baseline (%)');
% title(['alpha amplitude change by modality pairs at electrode ',[roi{:}]]);
title('alpha amplitude change by modality pairs at all electrodes');
set(gca, 'FontSize', 10)
% set(gca, 'ColorOrder', mycolor_order)
hold on;
plot(t, courses(:,1), '-r', 'linewidth', 2);
plot(t, courses(:,2), '-b', 'linewidth', 2);
% shadedErrorBar(t,courses(:,1),course_sem(:,1),'-b',1);
% shadedErrorBar(t,courses(:,2),course_sem(:,2),'-r',1);
hold off;
legend('Correct','Incorrect');
