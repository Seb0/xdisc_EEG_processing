%% alpha topography power graph producer for mod_x_n1 analysis

clear all; clc; 

project_dir = 'C:\Sebastian\xdisc';
ref_dir = project_dir;

file_ID = 'rtf_frae*'; % change file ID for different images
% img_ID = {'beta_0001.img', 'beta_0002.img' 'beta_0003.img'}; %vis_aud,vis_tac,aud_tac
img_ID = {'con_0007.img'};
foi = [8 13];

black = [0 0 0];
blue = [0 0 1];
green = [0 1 0];
red = [1 0 0];
% roi = {'C3','C4'};
% roi={'Pz'};
% roi={'T7', 'T8'};


dir_img =  fullfile(project_dir, 'analysis', 'mod_x_n1', 'BC', 'correct_trials');
subj = {'02', '03', '04', '05', '06', '08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'}; % 17 subjects
% subj = {'02'};
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
t = D_init.time(12:103);
corr_table=zeros(N, length(t), length(img_ID));

for vol=1:N % cycle thru volunteers (subs)
    sub_dir=fullfile(dir_img, strcat('subj', subj{vol}), 'stats');
    cd(sub_dir);
    disp(['#### Accessing data of subject ' num2str(subj{vol}) ' ####']);
    data = zeros(D_init.nsamples, length(roi));
    for im=1:length(img_ID)
        for el=1:length(roi)
            cd(roi{el});
            beta_img = ft_read_mri(img_ID{im});
            % data is timecourse, electrodes, beta_img
            data(:,el,im) = squeeze(mean(beta_img.anatomy(passband_idx,:)));
            cd ..
        end
    end
    avg_time_courses = squeeze(mean(data,2));
    short_time_courses=avg_time_courses(12:103,:);
    mycolor_order = [red; green; blue; black];

    
    corr_table(vol,:,:)=short_time_courses;
end
% 
courses=squeeze(mean(corr_table,1)); %avg over subjects
course_sem=squeeze(std(corr_table,1)/sqrt(17));

if strcmp(dir_img(end-15:end), 'C\correct_trials')
    corr_courses=courses;
elseif strcmp(dir_img(end-15:end), 'incorrect_trials')
    incorr_courses=courses;
else 
    error('Time courses couldnt be assigned to correct or incorrect trials. Likely, a path problem with dir_img.');
end
figure;
axes('position', [0.1 0.2 0.8 0.6])
xlabel('time (s)');
ylabel('alpha amplitude change relative to baseline (%)');
% title(['alpha amplitude change by modality pairs at electrode ',[roi{:}]]);
set(gca, 'FontSize', 10)
% set(gca, 'ColorOrder', mycolor_order)
if size(corr_courses,1)==1
    plot(t, corr_courses, '-r', 'linewidth', 2);
    legend(img_ID{1});
else
    hold on;
    plot(t, corr_courses(:,1), '-r', 'linewidth', 2);
    plot(t, corr_courses(:,2), '-b', 'linewidth', 2);
    plot(t, corr_courses(:,3), '-g', 'linewidth', 2);
    if exist('incorr_courses','var')
        plot(t, incorr_courses(:,1), '--r', 'linewidth', 2);
        plot(t, incorr_courses(:,2), '--b', 'linewidth', 2);
        plot(t, incorr_courses(:,3), '--g', 'linewidth', 2);
    end
    hold off;
    legend('Vis & Aud','Vis & Tac','Aud & Tac');
    title('alpha amplitude change by modality pairs at all electrodes');
% shadedErrorBar(t,course,course_sem,'-k',1)
end