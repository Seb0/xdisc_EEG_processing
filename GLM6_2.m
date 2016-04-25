% GROUP STATS
clear all; clc;
 
spm('defaults', 'eeg')
       global defaults
       global UFp
       UFp=0.001;
gsubjects = {'02','03', '04', '05', '06','08', '09', '10', '11', '12', '13', '15','17', '18', '19', '20', '21'};
project_dir = 'C:\Sebastian\xdisc\';
analysis_dir =  [project_dir 'analysis\' 'left_right\' 'noBC'];  
grpdir=['group_sel_' num2str(length(gsubjects)) '\'];
contrasts={'01';'02';'03';'04'};

D=spm_eeg_load(fullfile(project_dir, 'processed_data', 'subj02',['sqrt_tf_fraeMMMfxdisc' gsubjects{1} '.mat'])); %just load the chanlabels once
Elecs = D.chanlabels;
indir=[analysis_dir,'\'];

    for k=1:length(contrasts)
        tmpspm=[indir,'subj', gsubjects{k},'\','stats\', Elecs{k},'\SPM.mat'];
        load(tmpspm);
        actname=SPM.xCon(1,k).name;
        clear tmpspm;

        for el=1:length(Elecs)

            targdir=char(strcat(indir,grpdir,'con00',contrasts(k),'\',Elecs(el)));
            mkdir(targdir);
            for n=1:length(gsubjects)
                imglist(n,:)=char(strcat(indir,'subj',gsubjects(n),'\','stats\', Elecs(el),'\con_00',contrasts(k),'.img,1'));
            end

            matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(targdir);
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(imglist);
            matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

            output_list = spm_jobman('run',matlabbatch);
            cd(targdir);
            load('SPM.mat');
            SPM = spm_spm(SPM);

            SPM = rmfield(SPM,'xCon');

            cname       = actname;
            c           =1;
            SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);

            cname       = char(strcat('n',actname));
            c           =-1;
            SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);

            spm_contrasts(SPM);
            clear imglist
        end
    end