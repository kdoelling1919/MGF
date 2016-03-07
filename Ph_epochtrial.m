function [ data ] = Ph_epochtrial( data,trlinfo,field )
%Ph_epochtrial epoch the raw data files into the trial.
%   Detailed explanation goes here

if iscell(data.time)
    time = data.time{1};
else
    time = data.time;
end

if isfield(data,'freq')
    freq = data.freq;
else
    freq = 1;
end

Fs = 1./diff(time(1:2));
trl = round(trlinfo.trl(:,1:3).*Fs./trlinfo.fsample);
samps = trl(:,1:2);

epochdata = zeros(size(samps,1),length(data.label),length(freq),diff(samps(1,:))+1);
trnum = size(samps,1);
dig = length(num2str(trnum));
fprintf(['Trial %' num2str(dig) 'd'],1);
for e = 1:trnum
    epochdata(e,:,:,:) = data.(field)(1,:,:,samps(e,1):samps(e,2));
    if e == size(samps,1)
        fprintf('\nDone!\n')
    else
        fprintf([repmat('\b',1,dig) '%' num2str(dig) 'd'],e+1)
    end
end
data.trialinfo = trlinfo.trl(:,4:end);

zerspot = trl(1,1) -trl(1,3);
trlbnds = trl(1,1:2) - zerspot;
time = (trlbnds(1):trlbnds(2))./Fs;

data.time = time;
data.(field) = epochdata;
data.trialinfo = trlinfo.trl(:,4:end);
end