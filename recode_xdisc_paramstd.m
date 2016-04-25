function [tmp, evtlog, nevts, nevtlog]=recode_xdisc_paramstd(tmp, sub)

    modtrigs=[12 21 13 31 23 32];  %vis aud tac X  vis aud tac (1st attended)
    fbtrigs=[70 100 60 80 110 90];  %+1 for correct 
    basevec=  [40 50 130];  %vis aud tac

    for i=1:length(tmp)
        if isempty(tmp(i).value) 
            evt(i)=0;
        else
            evt(i)=tmp(i).value;
        end
    end

    evtlog=[]; nevt=zeros(1,length(evt)); lapse=0;
    for i=1:length(tmp)
        laps=0; miss=0;
        if ismember(evt(i),modtrigs) % if its a modality cue trigger: 
            param=zeros(1,3);
            for nj=1:15
                if evt(i+nj) == 1 & ismember(evt(i+nj+1),[2 3]) & ismember(evt(i+nj+2),[fbtrigs fbtrigs+1])
                    break 
                end
            end
            if ~ismember(evt(i+nj+2),[fbtrigs fbtrigs+1])
                % continue % when a participant missed a trial
                perf=0;
                miss=1;
            end
            for n=1:nj
                for mod=1:3
                    if ismember(evt(i+n),[basevec(mod)+1:basevec(mod)+7])
                        param(mod)=param(mod)+1;
                        if evt(i+n)~=basevec(mod)+param(mod)
                            laps=1;
                        end
                    end
                end
            end
            if ismember(evt(i+nj+1),[2 3])
                if evt(i+nj+1)==2
                    button=2; %left
                elseif evt(i+nj+1)==3
                    button=1; %right
                else button=0;
                end
            end
            %% 
    %         chk=param(param~=0);
    %         if diff(chk)==0 | laps==1
    %             lapse=lapse+1;
    %             continue
    %         end

            %%
            if miss==0
                perf= rem(evt(i+nj+2),10);
            end
            % recode to all params
    %         tmp(i).value=tmp(i).value.*100000+param(1)*10000+param(2)*1000+param(3)*100+perf*10+button;
            if ismember(perf, [0 1])
                tmp(i).value=tmp(i).value.*100+perf; %recode to mod x perf
            else error('Perf was found not to be neither 0 nor 1. ABORTED')
            end
    %         tmp(i).value=tmp(i).value.*10000+param(1)*1000+param(2)*100+param(3)*10+perf; %recode to mod x numerosity

            nevt(i)=tmp(i).value;
                        
            positions=find(nevt~=0);
            values=nevt(positions);
            corrects=find(rem(values,2)==1);
            incorrects=find(rem(values,2)==0);
            vector_c=positions(corrects);
            vector_ic=positions(incorrects);
            evtlog=[evtlog; tmp(i).value];
            nevts=[tmp.value];
            if length(vector_ic)==min(length(vector_c),length(vector_ic))
                msize=numel(vector_c);
                new_vc=vector_c(randperm(msize, min(length(vector_c),length(vector_ic))));
                nevts([new_vc vector_ic])=nevts([new_vc vector_ic])*10;
            elseif length(vector_c)==min(length(vector_c),length(vector_ic))
                msize=numel(vector_ic);
                new_vic=vector_ic(randperm(msize, min(length(vector_c),length(vector_ic))));
                nevts([new_vic vector_c])=nevts([new_vic vector_c])*10;
            else
                error('Something went wrong when making the sizes of corrects and incorrects equal.');
            end

            
            
            nevtlog=nevts(nevts/10000>1);
            
         end        

    end   


