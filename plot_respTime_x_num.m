clear all; clc;

cd 'C:\Sebastian\xdisc\behaviorals and graphs'
load linTrends

perf=2; rt=3;
for cond=1:3
    for num=2:7
        mp(cond,num)=mean(M((M(:,4)==cond & M(:,1)==num)==1, perf));
        semp(cond,num)=std(M((M(:,4)==cond & M(:,1)==num)==1, perf))/sqrt(20);
        mrt(cond,num)=mean(M((M(:,4)==cond & M(:,1)==num)==1, rt));
        semrt(cond,num)=std(M((M(:,4)==cond & M(:,1)==num)==1, rt))/sqrt(20);
    end
end
%% RT %%
mrt(:,1)=[];
semrt(:,1)=[];

    
e=figure; 
errorbar(mrt(1,:), semrt(1,:), 'r');
hold on
errorbar(mrt(2,:), semrt(2,:), 'g');
errorbar(mrt(3,:), semrt(3,:), 'b');
hold off

curdir=pwd;
cd('C:\Users\LabWorker\Desktop');
name='rt_x_num';
saveas(e,name,'png')
cd(curdir);

x=2:7;

f=figure;
hold on
param=polyfit(x,mrt(1,:),1);
A=plot(param(1)*x+param(2));
param=polyfit(x,mrt(2,:),1);
B=plot(param(1)*x+param(2));
param=polyfit(x,mrt(3,:),1);
C=plot(param(1)*x+param(2));
set(A, 'Color', [1 0 0]);
set(B, 'Color', [0 1 0]);
set(C, 'Color', [0 0 1]);

set(gca, 'xlim', [0 7], 'xtick',1:6, 'XTickLabel', {'2','3','4','5','6','7'})
xlabel('# pulses');
ylabel('response time (s)');

for ii=1:6
    D=plot([ii,ii], mrt(1,ii), 'ro');
    set(D, 'MarkerFaceColor', [1 0 0]);
    E=plot([ii,ii], mrt(2,ii), 'go');
    set(E, 'MarkerFaceColor', [0 1 0]);
    F=plot([ii,ii], mrt(3,ii), 'bo');
    set(F, 'MarkerFaceColor', [0 0 1]);
    plot([ii,ii],[mrt(1,ii)-semrt(1,ii),mrt(1,ii)+semrt(1,ii)],'-r','LineWidth',1)
    plot([ii,ii],[mrt(2,ii)-semrt(2,ii),mrt(2,ii)+semrt(2,ii)],'-g','LineWidth',1)
    plot([ii,ii],[mrt(3,ii)-semrt(3,ii),mrt(3,ii)+semrt(3,ii)],'-b','LineWidth',1)
end
hold off
curdir=pwd;
cd('C:\Users\LabWorker\Desktop');
name='rt_x_num_linTrend';
saveas(f,name,'png')
cd(curdir);
%% PERFORMANCE %%

mp(:,1)=[];
semp(:,1)=[];

    
g=figure; 
errorbar(mp(1,:), semp(1,:), 'r');
hold on
errorbar(mp(2,:), semp(2,:), 'g');
errorbar(mp(3,:), semp(3,:), 'b');
hold off
curdir=pwd;
cd('C:\Users\LabWorker\Desktop');
name='perf_x_num';
saveas(g,name,'png')
cd(curdir);

x=2:7;

h=figure;
hold on
param=polyfit(x,mp(1,:),1);
A=plot(param(1)*x+param(2));
param=polyfit(x,mp(2,:),1);
B=plot(param(1)*x+param(2));
param=polyfit(x,mp(3,:),1);
C=plot(param(1)*x+param(2));
set(A, 'Color', [1 0 0]);
set(B, 'Color', [0 1 0]);
set(C, 'Color', [0 0 1]);

set(gca, 'xlim', [0 7], 'xtick',1:6, 'XTickLabel', {'2','3','4','5','6','7'})
xlabel('# pulses');
ylabel('proportion correct');

for ii=1:6
    D=plot([ii,ii], mp(1,ii), 'ro');
    set(D, 'MarkerFaceColor', [1 0 0]);
    E=plot([ii,ii], mp(2,ii), 'go');
    set(E, 'MarkerFaceColor', [0 1 0]);
    F=plot([ii,ii], mp(3,ii), 'bo');
    set(F, 'MarkerFaceColor', [0 0 1]);
    plot([ii,ii],[mp(1,ii)-semp(1,ii),mp(1,ii)+semp(1,ii)],'-r','LineWidth',1)
    plot([ii,ii],[mp(2,ii)-semp(2,ii),mp(2,ii)+semp(2,ii)],'-g','LineWidth',1)
    plot([ii,ii],[mp(3,ii)-semp(3,ii),mp(3,ii)+semp(3,ii)],'-b','LineWidth',1)
end
hold off
curdir=pwd;
cd('C:\Users\LabWorker\Desktop');
name='perf_x_num_linTrend';
saveas(h,name,'png')
cd(curdir);
close all;