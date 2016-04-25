subs=[02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21];
thre=[25 35 18 35 12 15 38 14 35 14 30 20 11 30 13 14 30 13 12 7];

for i=1:length(subs)
    if i<9
        D=spm_eeg_load(strcat('C:\Sebastian\xdisc\processed_data\subj0',num2str(subs(i)),'\fxdisc0',num2str(subs(i))));
    else 
        D=spm_eeg_load(strcat('C:\Sebastian\xdisc\processed_data\subj',num2str(subs(i)),'\fxdisc',num2str(subs(i))));
    end
    D_ebf=detect_eye_blinks(D, thre(i), 'EXG5')
    compute_eye_blink_components(D_ebf, 1)
end