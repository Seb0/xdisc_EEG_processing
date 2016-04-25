clear all; clc;
spm('defaults', 'eeg')
       global defaults
       global UFp
       UFp=0.001;

input_mask = 'rmtf_fraeMMMf*.mat'; % ANPASSEN ob mit oder ohne baseline
subjects = {'02', '03', '04', '05', '06','08', '09', '10', '11', '12', '13', '15', '17', '18', '19', '20', '21'};
% subjects ={'02'};
project_dir = '/Users/Sebastian/Desktop/datasafe/';

analysis_dir =  [project_dir 'analysis/' 'mod/' 'BC'];

D=spm_eeg_load(fullfile(project_dir, 'processed_data', 'subj02',['rmtf_fraeMMMfxdisc' subjects{1} '.mat'])); %just load the chanlabels once
Elecs = D.chanlabels;

file_mask=D.fname;
file_mask=file_mask(1:end-6); 


%% GLM 1
for n=1:length(Elecs)
        stats_dir=fullfile(analysis_dir, 'stats_BC',Elecs{n}, filesep);
        mkdir(stats_dir)
        matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};
        
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subjects';
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
        
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'mod';
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
        
                
        for k=1:length(subjects)
            sub_dir=fullfile(analysis_dir, [file_mask subjects{k}], '/');
            dirlist=dir(sub_dir);
            for i=3:length(dirlist)
                if strcmp(dirlist(i,1).name,'DS_Store')
                    dirs(i-2,:)=dirlist(i+1,1).name;
                else
                    dirs(i-2,:)=dirlist(i,1).name;
                end
            end         
            actdirs=dirs(str2num(dirs(:,1:3))==100+n,:);
            mod=str2num(actdirs(:,end-4:end-3)); %modality !!!! CHECK!!!!
            
               
            selimg=[];
            for l=1:length(mod) %modality
                cond_dir=[sub_dir char(actdirs(l,:))];
                prelist=spm_select('FPList',cond_dir, 'saverage.img');
                selimg=[selimg;prelist];
            end

                matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(k).conds = [repmat(k,6*2,1) str2num(actdirs(:,end-4:end))];
                matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(k).scans = cellstr(selimg);    
        end              
        
        
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 2;
        
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});

        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
%     
        output_list = spm_jobman('run',matlabbatch);
        cd(stats_dir);
        load('SPM.mat');
%         
        spm_spm(SPM);
        
        load('SPM.mat');
        
        if isfield(SPM,'xCon')
            SPM = rmfield(SPM,'xCon');
        end
     
        cname       = 'AT';
        c           =[zeros(1,length(subjects)) 0 0 0 0 0 0 1 1 0 0 1 1];
        SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);

%         cname       = 'TV';
%         c           =[zeros(1,length(subjects)) 0 0 1 1 0 0 0 0 1 1 0 0];
%         SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'VA';
%         c           =[zeros(1,length(subjects)) 1 1 0 0 1 1 0 0 0 0 0 0];
%         SPM.xCon(3) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%        
%         cname       = 'V-A';
%         c           =[zeros(1,length(subjects)) 0 0 1 1 0 0 -1 -1 1 1 -1 -1];
%         SPM.xCon(4) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%       
%         cname       = 'V-T';
%         c           =[zeros(1,length(subjects)) 1 1 0 0 1 1 -1 -1 0 0 -1 -1];
%         SPM.xCon(5) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'A-T';
%         c           =[zeros(1,length(subjects)) 1 1 -1 -1 1 1 0 0 -1 -1 0 0];
%         SPM.xCon(6) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%               
%         cname       = 'All';
%         c           =[ones(1,length(subjects))./length(subjects) ones(1,12)./12];
%         SPM.xCon(7) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%         
%         cname       = 'V-A-CorrOnly';
%         c           =[zeros(1,length(subjects)) 0 0 0 1 0 0 0 -1 0 1 0 -1];
%         SPM.xCon(8) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%       
%         cname       = 'V-T-CorrOnly';
%         c           =[zeros(1,length(subjects)) 0 1 0 0 0 1 0 -1 0 0 0 -1];
%         SPM.xCon(9) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'A-T-CorrOnly';
%         c           =[zeros(1,length(subjects)) 0 1 0 -1 0 1 0 0 0 -1 0 0];
%         SPM.xCon(10) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%         
%         cname       = 'V-A-IncorrOnly';
%         c           =[zeros(1,length(subjects)) 0 0 1 0 0 0 -1 0 1 0 -1 0];
%         SPM.xCon(11) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%       
%         cname       = 'V-T-IncorrOnly';
%         c           =[zeros(1,length(subjects)) 1 0 0 0 1 0 -1 0 0 0 -1 0];
%         SPM.xCon(12) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'A-T-IncorrOnly';
%         c           =[zeros(1,length(subjects)) 1 0 -1 0 1 0 0 0 -1 0 0 0];
%         SPM.xCon(13) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%         
%         cname       = 'IncorrMinCorrAll';
%         c           =[zeros(1,length(subjects)) 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1];
%         SPM.xCon(14) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%         
%         cname       = 'V-A-IncorrMinCorr';
%         c           =[zeros(1,length(subjects)) 0 0 1 -1 0 0 -1 1 1 -1 -1 1];
%         SPM.xCon(15) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%       
%         cname       = 'V-T-IncorrMinCorr';
%         c           =[zeros(1,length(subjects)) 1 -1 0 0 1 -1 -1 1 0 0 -1 1];
%         SPM.xCon(16) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'A-T-IncorrMinCorr';
%         c           =[zeros(1,length(subjects)) 1 -1 -1 1 1 -1 0 0 -1 1 0 0];
%         SPM.xCon(17) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
         
        spm_contrasts(SPM);

        clear matlabbatch SPM 
    
    clear dirs
           
 end
 