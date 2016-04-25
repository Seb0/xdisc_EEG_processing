% First level GLM for power graph, correct vs incorrect
clear all; clc;
 
spm('defaults', 'eeg')
       global defaults
       global UFp
       UFp=0.001;

input_mask = 'rtf_fraeMMMf.mat'; % ANPASSEN ob mit oder ohne baseline
BL_correct=0; % ANPASSEN ob mit oder ohne baseline

% subjects = {'02','03','04','05','06','08','09','10', '11', '12', '13', '15', '17', '18', '19', '20', '21'};
subjects = {'21'};
project_dir = 'C:\Sebastian\xdisc\';

analysis_dir =  [project_dir 'analysis\' 'pwr_graph_corr_vs_incorr\' 'BC'];
cd(fullfile(project_dir,'analysis'));
if ~exist('pwr_graph_corr_vs_incorr', 'dir')
    mkdir('pwr_graph_corr_vs_incorr');
end
D=spm_eeg_load(fullfile(project_dir, 'processed_data', 'subj02',['rtf_fraeMMMfxdisc02'  '.mat'])); %just load the chanlabels once
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
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'perf';
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

            zelle=0; perfs = []; 
            for p=1:2
                zelle=zelle+1;
                fps=abs(str2num(actdirs(:,end-1))); %perf !!!! CHECK!!!!
                thisdirs=actdirs(fps==p-1,:); 
                selimg=[]; 
                for l=1:size(thisdirs,1) 
                    cond_dir=[sub_dir char(thisdirs(l,:))];
                    prelist=spm_select('FPList',cond_dir, '^strial.*img');
                    selimg=[selimg;prelist];
                end
                for q=1:size(selimg,1)
                    trig=selimg(q,regexp(selimg(q,:),'type_')+5:regexp(selimg(q,:),'type_')+11);
                    perf(q)=str2double(trig(end-1));
                end
                perfs = [perfs; perf(:)]; 
                if p==1
                    num_incorr_imgs=length(perfs(perfs==0));
                else 
                    num_correct_imgs=length(perfs(perfs==1));
                    selimg=datasample(selimg,num_incorr_imgs,'Replace',false);
                end         
                
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).levels = p;
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

            cname       = 'all';
            c           =[ 1 1 ];
            SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
 
            cname       = 'incorr_vs_corr';
            c           =[ -1 1 ];
            SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);            
            
            cname       = 'corr';
            c           =[ 0 1 ];
            SPM.xCon(3) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'incor';
            c           =[ 1 0 ];
            SPM.xCon(4) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);            
           
            spm_contrasts(SPM);

            clear matlabbatch SPM 
        end
        clear dirs
end