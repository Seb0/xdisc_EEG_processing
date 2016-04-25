project_dir='C:\Sebastian\xdisc';
%  
subjects = {'02', '03', '04', '05', '06', '08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'};
% edit analysis you want to do in the line below
temp=fullfile(project_dir, 'processed_data','mod_sqrt_backup120614', filesep);
cd(temp);
for i=1:length(subjects)
    sub=strcat('subj', subjects{i});
    mkdir(temp, sub);
    cd ..
    cd(sub);
%     copyfile('rmtf_frae*mat',strcat(temp, sub)); % edit datafile you want copied here
%     copyfile('rtf_frae*mat',strcat(temp, sub));
    copyfile('sqrt_mtf_frae*mat',strcat(temp, sub));
    copyfile('sqrt_tf_frae*mat',strcat(temp, sub));
    cd(temp);
end