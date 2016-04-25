%% script to create and smooth images

clear all;

spm('defaults', 'eeg')
spm_jobman('initcfg')

% input_mask = 'sqrt_tf_fraeMMMf*.mat'; % ANPASSEN ob mit oder ohne baseline
input_mask = 'sqrt_mtf_fraeMMMf*.mat';
% img_ID = 'trial'; %trial vs average
img_ID = 'average'; %trial vs average
smoothfwhm =[3 400 0]; % Hz x ms

% subjects = {'05', '06', '08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'};
% subjects = {'02','03','04',};
subjects = {'06'};
%% Some organizational stuff

% select folder which contains the raw EEG data
project_dir = 'C:\Sebastian\xdisc\';

smoothdir = fullfile(project_dir, 'smoother');
analysisdir = fullfile(project_dir, 'analysis','mod','noBC','mod_x_perf');


for n=1:length(subjects)
    disp(['======================= Subject ' subjects{n} '(' num2str(n) '/' num2str(length(subjects)) ') =================']);
    
    cd(fullfile(project_dir, 'processed_data',['subj' subjects{n}]));
    
    mask_match = dir(input_mask);
    
    D = spm_eeg_load(mask_match(1).name);
    
    S = [];
    S.D = D.fname;
    for el=1:length(chanlabels(D))
        S.images.fmt='channels';
        S.images.elecs=el;
        S.images.region_no=100+el;
        %S.n=32;            
        S.interpolate_bad=1;
        [Dout, Sout] = spm_eeg_convert2images(S);
    end

    % move images to different directory
    movename=D.fname;
    movefile(fullfile(D.path, movename(1:end-4)), smoothdir);


    matlabbatch{1}.spm.spatial.smooth.data = spm_select('FPListRec',smoothdir, [img_ID '.*.img']);
    matlabbatch{1}.spm.spatial.smooth.fwhm = smoothfwhm;
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    output_list = spm_jobman('run',matlabbatch);


    % move smoothed images
    dirlist=dir(smoothdir);
    for i=3:length(dirlist)
%         el_dir = dir(fullfile(smoothdir, dirlist(i).name, '1*'));
%         disp('>>>> Deleting unsmoothed images')
%         for j=1:length(el_dir)
%             delete(smoothdir, fullfile(el_dir(j).name, 'trial*'))
% %             dir(fullfile(el_dir(j).name, 'trial*'))
%         end
        
        disp(['>>>> Moving: ' dirlist(i).name])
        movefile(fullfile(smoothdir, dirlist(i).name), analysisdir);
    end
    
%     log_txt = fullfile(analysisdir, movename(1:end-4), 'preprocessing_log.txt');
end

