function [tmp, evtlog, nevt, lapse]=recode_xdisc_paramstd(tmp, sub)

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
    laps=0;
    if ismember(evt(i),modtrigs) % if its a modality cue trigger: 
        param=zeros(1,3);
        for nj=1:15
            if evt(i+nj) == 1 & ismember(evt(i+nj+1),[2 3]) & ismember(evt(i+nj+2),[fbtrigs fbtrigs+1])
                break 
            end
        end
        if ~ismember(evt(i+nj+2),[fbtrigs fbtrigs+1])
            continue
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
                button=2;
            elseif evt(i+nj+1)==3
                button=1;
            else button=0;
            end
        end
        %% 
        chk=param(param~=0);
        if diff(chk)==0 | laps==1
            lapse=lapse+1;
            continue
        end
        %% 
        perf= rem(evt(i+nj+2),10);
        % recode to all params
%         tmp(i).value=tmp(i).value.*100000+param(1)*10000+param(2)*1000+param(3)*100+perf*10+button;
%         tmp(i).value=tmp(i).value.*100+perf*10+button; %recode to mod x perf x button
        tmp(i+nj-1).value=tmp(i).value.*10000+param(1)*1000+param(2)*100+param(3)*10+perf; %recode to mod x numerosity

        nevt(i+nj-1)=tmp(i).value;
        evtlog=[evtlog; tmp(i+nj-1).value];
    end        
end
  

                
    
    
    
    
 
