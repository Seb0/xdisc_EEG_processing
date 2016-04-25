cd 'C:\Sebastian\xdisc\processed_data\'
dirlist=dir('subj*');

total_rejects=zeros(length(dirlist),3);

for i=1:length(dirlist)
    cd(dirlist(i).name)
    load('log_xdisc.mat')
    total_rejects(i,1)=i+1;
    total_rejects(i,2)=preprocess_log.total_rejected_trials;
    total_rejects(i,3)=length(preprocess_log.bad_channels);
    total_rejects(i,4)=length(preprocess_log.block_onsets);
    cd ..
end
