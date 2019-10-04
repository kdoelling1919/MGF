function W=LSdenoise(reference_sqd,data_sqd,new_sqd,badchans_ref,badchans_data,time_samples,TSPCA)
%
%   This function will denoise the new_sqd datafile using a least squares estimator on
%   the reference_sqd datafile. The reference_sqd is ideally empty room noise but can be any
%   dataset including the new_sqd dataset itself. 
%
%   LSdenoise(reference_sqd,data_sqd,new_sqd <,badchans_ref,badchans,time_samples,TSPCA>)
%
%       reference_sqd       - reference dataset with noise
%       data_sqd                - dataset to denoise
%       new_sqd                 - destination name of the denoised dataset  (defaults to an added -LSdenoised suffix)
%       badchans_ref        - bad channels to ignore in the reference data  (defaults to [])
%       badchans_data     - bad channels to ignore in the data  (defaults to [])
%       time_samples        - time samples from reference_sqd to use for least squares estimation (defaults to all time samples)
%       TSPCA                    - flag to run TSPCA (sqdDenoise) after LSdenoise (default is 0, use 1 to run sqdDenoise)
%
%
%   Usage:
%
%   % run denoise using room noise as referece
%   LSdenoise('~/Desktop/Adeen_test_room_rest.sqd','dataset.sqd','dataset-LSdenoised.sqd',[],badchans);
%
%   % run denoise using the dataset as referece
%   LSdenoise('dataset.sqd','dataset.sqd','dataset-LSdenoised.sqd',badchans,badchans);
%
%   % run denoise using room noise as referece and then run sqdDenoise
%   LSdenoise('~/Desktop/Adeen_test_room_rest.sqd','dataset.sqd','dataset-LSdenoised.sqd',[],badchans,[],1);
%
%   Adeen Flinker 6/2013 (adeen.f@gmail.com)
%
%

% argument check
if nargin<1
	if exist('uigetfile')
		[fn, pn] = uigetfile('*.sqd','Select an SQD reference file');
		reference_sqd = fullfile(pn,fn);
	else
		error('Please enter at least 2 arguments');
	end
end
if nargin<2
	if exist('uigetfile')
		[fn, pn] = uigetfile('*.sqd','Select an SQD data file');
		data_sqd = fullfile(pn,fn);
	else
		error('Please enter at least 2 arguments');
	end
end
if nargin<3 | isempty(new_sqd)
	[pathstr,name,ext] = fileparts(data_sqd);
	new_sqd = fullfile(pathstr,[name '-LSdenoised' ext ]);
end
if nargin<4
	badchans_ref = [];
end
if nargin<5
	badchans_data = [];
end

if nargin<6 
	time_samples = [];
end

% make sure sqd files exist and prompt for new ones if they are invalid
while ~exist(reference_sqd)
    warning('Reference file does not exist, please pick a vaild file');
    [fn, pn] = uigetfile('*.sqd','Select a valid SQD reference file');
    reference_sqd = fullfile(pn,fn);
end
ref_data   = sqdread(reference_sqd);

while ~exist(data_sqd)
    warning('Data file does not exist, please pick a vaild file');
    [fn, pn] = uigetfile('*.sqd','Select a valid SQD data file');
    data_sqd = fullfile(pn,fn);
end

if isempty(time_samples)
	time_samples = 1:length(ref_data);
end

% define sensors and references for reference dataset
sensors = ref_data(time_samples,1:157);
sensors = sensors - repmat(mean(sensors),size(sensors,1),1);

sensors(:,badchans_ref)=0;

ref = ref_data(time_samples,158:160);
ref = ref-repmat(mean(ref),size(ref,1),1);

%
% optional normalization of reference channels, disabled
%
%ref = ref./repmat(std(ref).*mean(std(sensors)),size(ref,1),1);
%ref(:,1) =ref(:,1)./std(ref(:,1))*mean(std(ref(:,2:3)));


% learn the least squares weights
fprintf('Calculating least squares weights from %s\n',reference_sqd);
W = pinv(ref)*sensors;

% apply W matrix on to new dataset
fprintf('Applying least squares weights to %s\n',data_sqd);
dat_apply = sqdread(data_sqd);

% define sensors and references for new dataset
ref = dat_apply(:,158:160);
ref = ref-repmat(mean(ref),size(ref,1),1);

new_sensors = dat_apply(:,1:157);
new_sensors = new_sensors - repmat(mean(new_sensors),size(new_sensors,1),1);
new_sensors = new_sensors-ref*W;
new_sensors(:,badchans_data)=0;

% creating new reference channels from the deniosed sensors
new_ref = new_sensors*pinv(W);

% creating cleaned dataset and saving file
dat_apply(:,1:157) = new_sensors;
dat_apply(:,158:160) = new_ref;

fprintf('Saving denoised data to %s\n',new_sqd);
if exist(new_sqd)
    warning('File %s already exists, overwriting.',new_sqd);
    delete(new_sqd);
end
sqdwrite(data_sqd,new_sqd,dat_apply);

% run sqdDenoise if TSPCA is 1
if ~exist('TSPCA'), TSPCA = 0; end
if TSPCA
    fprintf('Running sqdDenoise\n');
    sqdDenoise(20000,-100:100,0,new_sqd, badchans_data-1,'no',168,'no',[new_sqd(1:end-4) '_NR.sqd']);
    
end