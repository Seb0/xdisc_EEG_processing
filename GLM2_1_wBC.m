% First level GLM for modality x numerosity analysis 
clear all; clc;
 
spm('defaults', 'eeg')
       global defaults
       global UFp
       UFp=0.001;

input_mask = 'rmtf_fraeMMMf.mat'; % ANPASSEN ob mit oder ohne baseline
% BL_correct=1; % ANPASSEN ob mit oder ohne baseline

subjects = {'03', '04', '05', '06', '08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'};
% subjects = {'02'};
project_dir = 'C:\Sebastian\xdisc\';

analysis_dir =  [project_dir 'analysis\' 'mod\' 'BC'];

D=spm_eeg_load(fullfile(project_dir, 'processed_data', 'subj03',['rmtf_fraeMMMfxdisc' subjects{1} '.mat'])); %just load the chanlabels once
Elecs = D.chanlabels;


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
            
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'modxperf';
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 6;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
            
            %             for k=1:length(subjects)
                sub_dir=fullfile(analysis_dir, [file_mask subjects{k}], '\');
                dirlist=dir(sub_dir);
                for i=3:length(dirlist);
                    dirs(i-2,:)=dirlist(i,1).name;
                end         
                actdirs=dirs(str2num(dirs(:,1:3))==100+el,:);

                zelle=0; 
%                 n1s = [];
%                 n2s = [];
                mods = [];
                perfs = [];
                    
                for m=1:3 %modalities: VisAud = 1; VisTac = 2; AudTac = 3      
                    for f=0:1
                        zelle=zelle+1;
                        modality=str2num(actdirs(:,end-2:end-1)); %modality !!!! CHECK!!!! -> VisAud = 1; VisTac = 2; AudTac = 3
                        fps=abs(str2num(actdirs(:,end))); %perf !!!! CHECK!!!!
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
                        thisdirs=actdirs(modality==m & fps==f,:); % ; % only correct trials? insert: & fps==1
                        selimg=[]; 
                        for l=1:size(thisdirs,1) %modality
                            cond_dir=[sub_dir char(thisdirs(l,:))];
                            prelist=spm_select('FPList',cond_dir, '^saverage.*img');
                            selimg=[selimg;prelist];
                        end
%                         n1=zeros(size(selimg,1),1); n2=zeros(size(selimg,1),1); 
%                             mod=zeros(size(selimg,1),1); %perf=zeros(size(selimg,1),1);
%                             for q=1:size(selimg,1)
%                                 trig=selimg(q,regexp(selimg(q,:),'type_')+5:regexp(selimg(q,:),'type_')+6);
%                                 mod(q)=str2double(trig(1:2));
%                             switch mod(q)
%                                 case 12
%                                     n1(q)=str2double(trig(3));
%                                     n2(q)=str2double(trig(4));
%                                 case 13
%                                     n1(q)=str2double(trig(3));
%                                     n2(q)=str2double(trig(5));
%                                 case 21
%                                     n1(q)=str2double(trig(4));
%                                     n2(q)=str2double(trig(3));
%                                 case 23
%                                     n1(q)=str2double(trig(4));
%                                     n2(q)=str2double(trig(5));
%                                 case 31
%                                     n1(q)=str2double(trig(5));
%                                     n2(q)=str2double(trig(3));
%                                 case 32
%                                     n1(q)=str2double(trig(5));
%                                     n2(q)=str2double(trig(4));
%                             end
%                             perf(q)=str2double(trig(6));
%                             end
                    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).levels = zelle;
                    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).scans = cellstr(selimg);
%                         n1s = [n1s; n1(:)];
%                         n2s = [n2s; n2(:)];
%                         mods = [mods; mod(:)];
%                         perfs = [perfs; perf(:)];
%                 end



                    end
                end


% 
%             matlabbatch{1}.spm.stats.factorial_design.cov(1).c = n1s;
%             matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'n1';
%             matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI =2;
%             matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
% 
%             matlabbatch{1}.spm.stats.factorial_design.cov(2).c = n2s;
%             matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'n2';
%             matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI =2;
%             matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;

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
                   
            cname       = 'all-mods';
            c           =[ 1/6 1/6 1/6 1/6 1/6 1/6 ];
            SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'all-mods-corr';
            c           =[ 0 1/3 0 1/3 0 1/3 ];
            SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'all-mods-incorr';
            c           =[ 1/3 0 1/3 0 1/3 0 ];
            SPM.xCon(3) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'V-T-allTrials';
            c           =[ 1 1 0 0 -1 -1 ];
            SPM.xCon(4) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'V-T-corrTrials';
            c           =[ 0 1 0 0 0 -1 ];
            SPM.xCon(5) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);

            cname       = 'V-T-incorrTrials';
            c           =[ 1 0 0 0 -1 0 ];
            SPM.xCon(6) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'V-A-all';
            c           =[ 0 0 1 1 -1 -1 ];
            SPM.xCon(7) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'V-A-corrTrials';
            c           =[ 0 0 0 1 0 -1 ];
            SPM.xCon(8) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'V-A-incorrTrials';
            c           =[ 0 0 1 0 -1 0 ];
            SPM.xCon(9) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'A-T-all';
            c           =[ 1 1 -1 -1 0 0 ];
            SPM.xCon(10) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'A-T-corrTrials';
            c           =[ 0 1 0 -1 0 0 ];
            SPM.xCon(11) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'A-T-incorrTrials';
            c           =[ 1 0 -1 0 0 0 ];
            SPM.xCon(12) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'T-V-all';
            c           =[ -1 -1 0 0 1 1 ];
            SPM.xCon(13) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'T-V-corrTrials';
            c           =[ 0 -1 0 0 0 1 ];
            SPM.xCon(14) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'T-V-incorrTrials';
            c           =[ -1 0 0 0 1 0 ];
            SPM.xCon(15) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'A-V-all';
            c           =[ 0 0 -1 -1 1 1 ];
            SPM.xCon(16) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'A-V-corrTrials';
            c           =[ 0 0 0 -1 0 1 ];
            SPM.xCon(17) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'A-V-incorrTrials';
            c           =[ 0 0 -1 0 1 0 ];
            SPM.xCon(18) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'T-A-all';
            c           =[ -1 -1 1 1 0 0 ];
            SPM.xCon(19) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'T-A-corrTrials';
            c           =[ 0 -1 0 1 0 0 ];
            SPM.xCon(20) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'T-A-incorrTrials';
            c           =[ -1 0 1 0 0 0 ];
            SPM.xCon(21) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VA-AV-all';
            c           =[ 1 1 0 0 0 0 ];
            SPM.xCon(22) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VA-AV-corrTrials';
            c           =[ 0 1 0 0 0 0 ];
            SPM.xCon(23) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VA-AV-incorrTrials';
            c           =[ 1 0 0 0 0 0 ];
            SPM.xCon(24) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VT-TV-all';
            c           =[ 0 0 1 1 0 0 ];
            SPM.xCon(25) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VT-TV-corrTrials';
            c           =[ 0 0 0 1 0 0 ];
            SPM.xCon(26) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VT-TV-incorrTrials';
            c           =[ 0 0 1 0 0 0 ];
            SPM.xCon(27) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'AT-TA-all';
            c           =[ 0 0 0 0 1 1 ];
            SPM.xCon(28) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'AT-TA-corrTrials';
            c           =[ 0 0 0 0 0 1 ];
            SPM.xCon(29) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'AT-TA-incorrTrials';
            c           =[ 0 0 0 0 1 0 ];
            SPM.xCon(30) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VA-AV-all-half';
            c           =[ 1/2 1/2 0 0 0 0 ];
            SPM.xCon(31) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'VT-TV-all-half';
            c           =[ 0 0 1/2 1/2 0 0 ];
            SPM.xCon(32) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
            
            cname       = 'AT-TA-all-half';
            c           =[ 0 0 0 0 1/2 1/2 ];
            SPM.xCon(33) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
                 
            
%             cname       = 'all_mod';
%             c           =[ 1/3 1/3 1/3 0 0 0 0 0 0 ];
%             SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'visaud';
%             c           =[ 1 0 0 0 0 0 0 0 0 ];
%             SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'vistac';
%             c           =[ 0 1 0 0 0 0 0 0 0 ];
%             SPM.xCon(3) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'audtac';
%             c           =[ 0 0 1 0 0 0 0 0 0 ];
%             SPM.xCon(4) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'V-T';
%             c           =[ 1 0 -1 0 0 0 0 0 0 ];
%             SPM.xCon(5) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'T-V';
%             c           =[ -1 0 1 0 0 0 0 0 0 ];
%             SPM.xCon(6) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'V-A';
%             c           =[ 0 1 -1 0 0 0 0 0 0 ];
%             SPM.xCon(7) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'A-V';
%             c           =[ 0 -1 1 0 0 0 0 0 0 ];
%             SPM.xCon(8) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'A-T';
%             c           =[ 1 -1 0 0 0 0 0 0 0 ];
%             SPM.xCon(9) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'T-A';
%             c           =[ -1 1 0 0 0 0 0 0 0 ];
%             SPM.xCon(10) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'all_n1_param';
%             c           =[ 0 0 0 1 1 1 0 0 0 ];
%             SPM.xCon(11) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'all_n1_param_by_3';
%             c           =[ 0 0 0 1/3 1/3 1/3 0 0 0 ];
%             SPM.xCon(12) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'all_n2param';
%             c           =[ 0 0 0 0 0 0 1 1 1 ];
%             SPM.xCon(13) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%              cname       = 'all_n2param_by3';
%             c           =[ 0 0 0 0 0 0 1/3 1/3 1/3 ];
%             SPM.xCon(14) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%             cname       = 'all_n1n2param';
%             c           =[ 0 0 0 1 1 1 1 1 1 ];
%             SPM.xCon(15) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'all_n1n2param_by6';
%             c           =[ 0 0 0 1/6 1/6 1/6 1/6 1/6 1/6 ];
%             SPM.xCon(16) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%             cname       = 'n1param_n2param';
%             c           =[ 0 0 0 1 1 1 -1 -1 -1 ];
%             SPM.xCon(17) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%              cname       = 'n2param_n1param';
%             c           =[ 0 0 0 -1 -1 -1 1 1 1 ];
%             SPM.xCon(18) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             %einzel param per mod pair
%             cname       = 'visaud_n1param';
%             c           =[ 0 0 0 1 0 0 0 0 0 ];
%             SPM.xCon(19) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%             cname       = 'vistac_n1param';
%             c           =[ 0 0 0 0 1 0 0 0 0 ];
%             SPM.xCon(20) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%              cname       = 'audtac_n1param';
%             c           =[ 0 0 0 0 0 1 0 0 0 ];
%             SPM.xCon(21) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%             cname       = 'visaud_n2param';
%             c           =[ 0 0 0 0 0 0 1 0 0 ];
%             SPM.xCon(22) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%             cname       = 'vistac_n2param';
%             c           =[ 0 0 0 0 0 0 0 1 0 ];
%             SPM.xCon(23) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%             
%             cname       = 'audtac_n2param';
%             c           =[ 0 0 0 0 0 0 0 0 1 ];
%             SPM.xCon(24) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%    


            spm_contrasts(SPM);

            clear matlabbatch SPM 
        end
        clear dirs
end