% First level GLM for modality x numerosity analysis 
spm('defaults', 'eeg')
       global defaults
       global UFp
       UFp=0.001;

input_mask = 'sqrt_tf_fraeMMMf.mat'; % ANPASSEN ob mit oder ohne baseline
BL_correct=0; % ANPASSEN ob mit oder ohne baseline

% subjects = {'02', '03', '04', '05', '06','07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21'};
subjects = {'02'};
project_dir = 'C:\Sebastian\xdisc\';

analysis_dir =  [project_dir 'analysis\' 'mod_x_n1'];

D=spm_eeg_load(fullfile(project_dir, 'processed_data', 'subj02',['sqrt_tf_fraeMMMfxdisc' subjects{1} '.mat'])); %just load the chanlabels once
% Elecs = D.chanlabels;
Elecs = D.chanlabels(1);

file_mask=D.fname;
file_mask=file_mask(1:end-6); 



for el = 1:length(Elecs);
        stats_dir=fullfile(analysis_dir, 'stats',Elecs{el}, filesep);
        mkdir(stats_dir)
        matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};

        %-----------------------------------------------------------------------
        % Job configuration created by cfg_util (rev $Rev: 3130 $)
        %------------------------------------------------------------------
        %-----
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'mod';
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
        
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'n1_num';
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
        
%         matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'mod';
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 3;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
        
%         matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'n1';
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 6;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
%         matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
        
        for k=1:length(subjects)
            sub_dir=fullfile(analysis_dir, [file_mask subjects{k}], '\');
            dirlist=dir(sub_dir);
            for i=3:length(dirlist);
                dirs(i-2,:)=dirlist(i,1).name;
            end         
            actdirs=dirs(str2num(dirs(:,1:3))==100+el,:);
            mod=str2num(actdirs(:,end-5:end-4)); %modality !!!! CHECK!!!! -> VisAud = 1; VisTac = 2; AudTac = 3
            fps=abs(str2num(actdirs(:,end))); %perf !!!! CHECK!!!!
            n1str=actdirs(:,end-3:end-1); %n1 !!!! CHECK!!!!
            n1s=zeros(length(mod),1);
            for q=1:length(mod)
                switch mod(q)
                    case 12
                        n1=str2double(n1str(q,1));
                        mod(q)=1;
                    case 13
                        n1=str2double(n1str(q,1));
                        mod(q)=2;
                    case 21
                        n1=str2double(n1str(q,2));
                        mod(q)=1;
                    case 23
                        n1=str2double(n1str(q,2));
                        mod(q)=3;
                    case 31
                        n1=str2double(n1str(q,3));
                        mod(q)=2;
                    case 32
                        n1=str2double(n1str(q,3));
                        mod(q)=3;
                end
                n1s(q)=n1;
            end
            
            zelle=0;
            for m=1:3 %modalities: VisAud = 1; VisTac = 2; AudTac = 3
%                 for n=2:7 %numerosity
%                     zelle=zelle+1;
                    
                    thisdirs=actdirs(mod==m & fps==1,:); % only correct trials? insert: & fps==1

%                     thisdirs=actdirs(mod==m & n1s==n & fps==1,:); % only correct trials? insert: & fps==1
                    selimg=[];
                    for l=1:size(thisdirs,1) %modality
                        cond_dir=[sub_dir char(thisdirs(l,:))];
                        prelist=spm_select('FPList',cond_dir, '^strial.*img');
                        selimg=[selimg;prelist];
                    end
                      matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(m).conds = [repmat(m,size(selimg,1),1) [2:7]'];
                      matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(m).scans = cellstr(selimg);    
%                     matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).levels = m;
%                     matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(zelle).scans = cellstr(selimg);
%                 end
            end
            
        end  
              
       
    
%         matlabbatch{1}.spm.stats.factorial_design.cov(1).c = n1;
%         matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'n1';
%         matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI =1;
%         matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
%         
%         matlabbatch{1}.spm.stats.factorial_design.cov(2).c = abs(f1-4.5)-1.5;
%         matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'xtr';
%         matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI =2;
%         matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;

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
     
%         cname       = 'visaudparam';
%         c           =[ -5 -3 -1  1 3 5 zeros(1,12)];
%         SPM.xCon(1) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);

%         cname       = 'audparam';
%         c           =[  zeros(1,6) -5 -3 -1  1 3 5 zeros(1,6)];
%         SPM.xCon(2) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'tacparam';
%         c           =[ zeros(1,12) -5 -3 -1  1 3 5 ];
%         SPM.xCon(3) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'allparam';
%         c           =[ -5 -3 -1  1 3 5  -5 -3 -1  1 3 5  -5 -3 -1  1 3 5];
%         SPM.xCon(4) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%       
%         cname       = 'visVSall';
%         c           =[2 2 2 2 2 2 -ones(1,12)];
%         SPM.xCon(5) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
% 
%         cname       = 'audVSall';
%         c           =[-ones(1,6) 2 2 2 2 2 2 -ones(1,6)];
%         SPM.xCon(6) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%         
%         cname       = 'tacVSall';
%         c           =[-ones(1,12) 2 2 2 2 2 2];
%         SPM.xCon(7) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);
%         
%         cname       = 'All';
%         c           =[ones(1,18)./18];
%         SPM.xCon(8) = spm_FcUtil('Set',cname,'T','c',c',SPM.xX.xKXs);

         
        spm_contrasts(SPM);

        clear matlabbatch SPM 
    end
    clear dirs
    