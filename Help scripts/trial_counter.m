%record me the amount of trials.
project_dir='C:\Sebastian\xdisc\';
subjects = {'02', '03', '04', '05', '06','07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21'};
xTrials=zeros(20,1);
for i=1:20
    sub=strcat('subj', subjects{i});
    temp=fullfile(project_dir, 'processed_data', sub, filesep);
    cd(temp);
    tmp=dir('frae*.mat');
    D=spm_eeg_load(tmp.name);
    no_of_trials=length(D.events);
    xTrials(i)=no_of_trials;
end


