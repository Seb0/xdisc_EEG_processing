% First level GLM for left vs right, all trials
clear all; clc;
 
spm('defaults', 'eeg')
       global defaults
       global UFp
       UFp=0.001;

input_mask = 'sqrt_tf_fraeMMMf.mat'; % ANPASSEN ob mit oder ohne baseline
BL_correct=0; % ANPASSEN ob mit oder ohne baseline

subjects = {'09','10', '11', '12', '13', '15', '17', '18', '19', '20', '21'};
% subjects = {'02'};
project_dir = 'C:\Sebastian\xdisc\';

analysis_dir =  [project_dir 'analysis\' 'left_right\' 'noBC'];
cd(fullfile(project_dir,'analysis'));
if ~exist('left_right', 'dir')
    mkdir('left_right');
end
D=spm_eeg_load(fullfile(project_dir, 'processed_data', 'subj02',['sqrt_tf_fraeMMMfxdisc02'  '.mat'])); %just load the chanlabels once
Elecs = D.chanlabels;
% Elecs = D.chanlabels(1);

file_mask=D.fname;
file_mask=file_mask(1:end-6); 

for k=1:length(subjects)

    for el = 1:length(Elecs);
            stats_dir=fullfile(analysis_dir, ['subj' subjects{k}],'stats',Elecs{el}, filesep);
            mkdir(stats_dir)
            matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};

            %-----------------------------------------------------------------------
            % Job configuration created by cfg_util (rev $Rev: 3130 $)
            %------------------------------------------------------------------
            %-----

            matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'button';
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;

            sub_dir=fullfile(analysis_dir, [file_mask subjects{k}], '\');
            dirlist=dir(sub_dir);
            for i=3:length(dirlist);
                dirs(i-2,:)=dirlist(i,1).name;
            end         
            actdirs=dirs(str2num(dirs(:,1:3))==100+el,:);

            zelle=0; buttons = []; 
            for b=1:2
                zelle=zelle+1;
                knopf=abs(str2num(actdirs(:,end))); %buttons !!!! CHECK!!!! 2 is left, 1 is right
                thisdirs=actdirs(knopf==b,:); 
                selimg=[]; 
                for l=1:size(thisdirs,1) 
                    cond_dir=[sub_dir char(thisdirs(l,:))];
                    prelist=spm_select('FPList',cond_dir, '^strial.*img');
                    selimg=[selimg;prelist];
                end
                for q=1:size(selimg,1)
                    trig=selimg(q,regexp(selimg(q,:),'type_')+5:regexp(selimg(q,:),'type_')+11);
                    button(q)=str2double(trig(end));
                end
                buttons = [buttons; button(:)]; 
                               
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).levels = b;
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).scans = cellstr(selimg);              
            end              
            matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


            %% CONTINUE BELOW HERE !
            output_list = spm_jobman('run',matlabbatch);
            cd(stats_dir);
            load('SPM.mat');

            spm_spm(SPM);

            load('SPM.mat');

            if isfield(SPM,'xCon')
                SPM = rmfield(SPM,'xCon');
            end

            cname       = 'both';
            c           =[ 1 1 ];
            SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
 
            cname       = 'right_minus_left';
            c           =[ 1 -1 ];
            SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);            
            
            cname       = 'left';
            c           =[ 0 1 ];
            SPM.xCon(3) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'right';
            c           =[ 1 0 ];
            SPM.xCon(4) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);            
           
            spm_contrasts(SPM);

            clear matlabbatch SPM 
        end
        clear dirs
end