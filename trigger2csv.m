function trigger2csv(project_dir,subj_ID,q_val,q_rt)
    current_dir=pwd;
    cd(project_dir);
    file=strcat(subj_ID, 'trig_perf.csv');
    h=fopen(file,'wt');
    fprintf(h,'Trial;Condition;N1;N2;Performance;RespButton;ReactionTime \n');
    for i=1:length(q_val)
        trig=num2str(q_val(i));
        mod=trig(1:2);
        n1=str2double(trig(str2double(mod(1))+2));
        n2=str2double(trig(str2double(mod(2))+2));
        perf=str2double(trig(6));
        button=str2double(trig(7));
        
        switch mod
            case '12'
                cond='VA';
            case '13'
                cond='VT';
            case '21'
                cond='AV';
            case '23'
                cond='AT';
            case '31'
                cond='TV';
            case '32'
                cond='TA';
            otherwise
                cond='fail';
        end
        fprintf(h,'%i;%s;%i;%i;%i;%i;%6.6f \n',i,cond,n1,n2,perf,button,q_rt(i));
    end
    fclose(h);
    cd(current_dir);
end