cd /Volumes/Vault/Data/Phonetica

Origdir = '/Volumes/Vault/Data/Phonetica/';
cd(Origdir);
Subjects = dir('R*');
for sub = 1:length(Subjects)
cd(Subjects(sub).name)

protocol = 'Phonetica';
sqdfiles=dir(['*' protocol '*11.sqd']);

thresh= 3e4;
channels=160:167;
eventnums=zeros(length(channels),length(sqdfiles));
figure('Name',Subjects(sub).name);
ordax=gca;
color={'r','g','b','k','c','m','y',};
order = cell(size(sqdfiles));
load ../Phonetica_stimuli/Exp/list
for s = 1:length(sqdfiles)
    sqdfile = sqdfiles(s);
    %read in triggers
    [data,info] = sqdread(sqdfile.name,'Channels',channels);
    
    events=data >thresh;
    
    strts=diff(events);
    strts=strts>0;
    eventnums(:,s)=sum(strts);
    
    [samp,cond] = find(strts);
    
    [~,indx] = sort(samp,'ascend');
    
    order{s}=cond(indx);
    plot(ordax,1:length(order{s}),order{s},['.-' color{s}],'MarkerSize',20)
    hold on;
end
% set(gca,'xlim',get(gca,'xlim'))

plot(log2(triggers),'.-','MarkerSize',20)
cd ../
end
