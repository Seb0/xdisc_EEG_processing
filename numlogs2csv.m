function numlogs2csv(xdisc_num)
% num logs to CSV
    for subject=2:21
        trial_no=(1:90)';

        modal1=xdisc_num(subject).run.mylog.modality(1,:)';
        retrocue1=xdisc_num(subject).run.mylog.retrocue(1,:)';
        n11=xdisc_num(subject).run.mylog.numerosity(1,:,1)';
        n21=xdisc_num(subject).run.mylog.numerosity(1,:,2)';
        resp1=xdisc_num(subject).run.mylog.resp(1,:)';
        perf1=xdisc_num(subject).run.mylog.perform(1,:)';
        RT1=xdisc_num(subject).run.mylog.resptime(1,:)';
        miss1=xdisc_num(subject).run.mylog.missing(1,:)';

        modal2=xdisc_num(subject).run.mylog.modality(2,:)';
        retrocue2=xdisc_num(subject).run.mylog.retrocue(2,:)';
        n12=xdisc_num(subject).run.mylog.numerosity(2,:,1)';
        n22=xdisc_num(subject).run.mylog.numerosity(2,:,2)';
        resp2=xdisc_num(subject).run.mylog.resp(2,:)';
        perf2=xdisc_num(subject).run.mylog.perform(2,:)';
        RT2=xdisc_num(subject).run.mylog.resptime(2,:)';
        miss2=xdisc_num(subject).run.mylog.missing(2,:)';

        modal3=xdisc_num(subject).run.mylog.modality(3,:)';
        retrocue3=xdisc_num(subject).run.mylog.retrocue(3,:)';
        n13=xdisc_num(subject).run.mylog.numerosity(3,:,1)';
        n23=xdisc_num(subject).run.mylog.numerosity(3,:,2)';
        resp3=xdisc_num(subject).run.mylog.resp(3,:)';
        perf3=xdisc_num(subject).run.mylog.perform(3,:)';
        RT3=xdisc_num(subject).run.mylog.resptime(3,:)';
        miss3=xdisc_num(subject).run.mylog.missing(3,:)';

        modal=[modal1;modal2;modal3];
        retrocue=[retrocue1;retrocue2;retrocue3];
        n1=[n11;n12;n13];
        n2=[n21;n22;n23];
        resp=[resp1;resp2;resp3];
        perf=[perf1;perf2;perf3];
        RT=[RT1;RT2;RT3];
        miss=[miss1;miss2;miss3];

        clearvars -except subject xdisc_num trial_no modal retrocue n1 n2 resp perf RT miss

        subj_ID=num2str(subject);
        if length(subj_ID)<2
            subj_ID=['0' subj_ID];
        end
        file=strcat(subj_ID, 'numbering_perf.csv');
        cd 'C:\Sebastian\xdisc\CSVfiles';
        h=fopen(file,'wt');
        fprintf(h,'Subj_ID;Trial;Condition;Cue;N1;N2;Response;Performance;ReactionTime;MISSED \n');
        for i=1:90
            fprintf(h,'%s;%i;%i;%i;%i;%i;%i;%i;%6.6f;%i \n',subj_ID,trial_no(i),modal(i),retrocue(i),n1(i),n2(i),resp(i),perf(i),RT(i),miss(i));
        end
        fclose(h);

        clearvars -except xdisc_num

    end
end