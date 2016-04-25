% First level GLM for modality x response side (more vs. less) analysis 
clear all; clc;
 
spm('defaults', 'eeg')
       global defaults
       global UFp
       UFp=0.001;

input_mask = 'sqrt_tf_fraeMMMf.mat'; % ANPASSEN ob mit oder ohne baseline
BL_correct=0; % ANPASSEN ob mit oder ohne baseline

subjects = {'02','03','04','05','06','07','08','09','10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21'};
% subjects = {'09'};
project_dir = 'C:\Sebastian\xdisc\';

analysis_dir =  [project_dir 'analysis\' 'epoch2deci_mod_x_resp'];

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
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'mod';
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 3;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
            
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'resp';
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
    
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).name = 'perf';
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).levels = 2;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).dept = 1;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).variance = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).gmsca = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).ancova = 0;        

%             for k=1:length(subjects)
                sub_dir=fullfile(analysis_dir, [file_mask subjects{k}], '\');
                dirlist=dir(sub_dir);
                for i=3:length(dirlist);
                    dirs(i-2,:)=dirlist(i,1).name;
                end         
                actdirs=dirs(str2num(dirs(:,1:3))==100+el,:);

                zelle=0; n1s = []; n2s = []; mods = [];
                perfs = []; resps=[];

                for r=1:2
                    for m=1:3 %modalities: VisAud = 1; VisTac = 2; AudTac = 3
                        for p=1:2
                            zelle=zelle+1;
                            modality=str2num(actdirs(:,end-3:end-2)); %modality !!!! CHECK!!!! -> VisAud = 1; VisTac = 2; AudTac = 3
                            fps=abs(str2num(actdirs(:,end-1))); %perf !!!! CHECK!!!!
                            resp=str2num(actdirs(:,end));
                            for q=1:length(modality)
                                switch modality(q)
                                    case {12 21}
                                        modality(q)=1;
                                    case {13 31}
                                        modality(q)=2;
                                    case {23 32}
                                        modality(q)=3;
                                end
                            end
                            thisdirs=actdirs(modality==m & resp==p & fps==r-1,:); 
                            selimg=[]; 
                            for l=1:size(thisdirs,1) %modality
                                cond_dir=[sub_dir char(thisdirs(l,:))];
                                prelist=spm_select('FPList',cond_dir, '^strial.*img');
                                selimg=[selimg;prelist];
                            end

                            mod=zeros(size(selimg,1),1); perf=zeros(size(selimg,1),1);
                            response=zeros(size(selimg,1),1);
                            for q=1:size(selimg,1)
                                trig=selimg(q,regexp(selimg(q,:),'type_')+5:regexp(selimg(q,:),'type_')+8);
                                mod(q)=str2double(trig(1:2));
                                response(q)=str2double(trig(end));
                                perf(q)=str2double(trig(end-1));
                            end
                            matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).levels = [r m p];
                            matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).scans = cellstr(selimg);
                            mods = [mods; mod(:)];
                            perfs = [perfs; perf(:)];
                            resps = [resps; resp(:)];
                        end
                    end
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

            cname       = 'more_vs_less';
            c           =[ 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 ];
            SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'more_vs_less_corr';
            c           =[ 0 0 0 0 0 0 1 -1 1 -1 1 -1 ];
            SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'more_vs_less_incorr';
            c           =[ 1 -1 1 -1 1 -1 0 0 0 0 0 0 ];
            SPM.xCon(3) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'incorr_vs_corr';
            c           =[ -1 -1 -1 -1 -1 -1 1 1 1 1 1 1 ];
            SPM.xCon(4) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
           

            spm_contrasts(SPM);

            clear matlabbatch SPM 
        end
        clear dirs
end