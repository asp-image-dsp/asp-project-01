clc

disp('###########################################################')
disp('### Welcome to the iks|PANDAR database (v1.0)')
disp('### Paths for Active Noise Cancellation Development And Research')
disp('### Published by Institut of Communication Systems (IKS) ')
disp('### RWTH Aachen University')
disp('### - transfer function loading and example plotting -')
disp('###########################################################')

% Note: the measurements have been regularized for frequencies below 20 and above 20000 Hz
% Note2: The transfer functions have only been truncated but not smoothed
% For further smoothing utilize the raw measurements, where in the
% "PANDAR_load_and_process_raw.m" script a smoothing is included

%% path to database
database_folder = '../'; 

%% load acoustic booth dataset
dataset_folder          = fullfile(database_folder,'BoseQC20\acoustic_booth\');
[ itaPersons ]          = ita_read_ita_folder( fullfile(dataset_folder,'persons') );
[ itaHandling ]         = ita_read_ita_folder( fullfile(dataset_folder,'handling') );
itaBooth                = [itaPersons,itaHandling];

% separate in primary/secondary/feedback path left and right
[ itaBoothPaths, ~ ]    = ita_separateByChannelNames( ita_merge(itaBooth), 3 );

%% load anechoic chamber dataset
dataset_folder          = fullfile(database_folder,'BoseQC20\anechoic_chamber\');
[ itaChamberPrimary ]   = ita_read_ita_folder( fullfile(dataset_folder,'primary') );
[ itaChamberSecAFB ]    = ita_read_ita_folder( fullfile(dataset_folder,'secondary+afb') );

% separate in primary path left and right
[ itaChamberPaths, ~ ]  = ita_separateByChannelNames( ita_merge(itaChamberPrimary), 3 );

%% load electronic back-end
dataset_folder          = fullfile(database_folder,'BoseQC20\electronic_backend\');
[ itaBackend ]          = ita_read_ita_folder( dataset_folder );

%% extract certain paths
% extract from booth measurements
itaPrimPathBooth        = ita_merge(itaBoothPaths(3:4)); % Merges P(z) L and R
itaPrimPathLateral      = itaBoothPaths(3); % Left
itaPrimPathOpposite     = itaBoothPaths(4); % Right
itaSecPathBooth         = ita_merge(itaBoothPaths(5:6)); % Merges G(z) L and R
itaAFBPathBooth         = ita_merge(itaBoothPaths(1:2)); % Merges F(z) L and R

% average paths
itaPrimPathBoothMean    = mean(itaPrimPathBooth);
itaSecPathBoothMean     = mean(itaSecPathBooth);
itaAFBPathBoothMean     = mean(itaAFBPathBooth);

% separate into different fits
% use cases:        normal-fit / slightly-loose-fit / loose-fit / open-fit 
% handling cases:   open and closed
[ itaSecPathsFit, ~ ]   = ita_separateByChannelUserData( itaSecPathBooth, 4 );
[ itaAFBPathsFit, ~ ]   = ita_separateByChannelUserData( itaAFBPathBooth, 4 );
[ itaPrimPathsFit, ~ ]  = ita_separateByChannelUserData( itaPrimPathBooth, 4 );

% extract from anechoic chamber measurements
itaPrimPathChamber      = ita_merge(itaChamberPaths);
itaSecPathChamber       = itaChamberSecAFB.ch(1:2);
itaAFBPathChamber       = itaChamberSecAFB.ch(3:4);

%% extract acoustic component G_A(z) and F_A(z) of secondary path G(z) and feedback path F(z)
% this component compensates for the influence of the electronic backend
% for simulations of a realizable ANC system it is advisable to include an
% electronic backend
itaSecPathAcousticBooth = itaSecPathBooth / itaBackend.ch(4);
itaAFBPathAcousticBooth = itaAFBPathBooth / itaBackend.ch(4);

itaSecPathAcousticChamber = itaSecPathChamber / itaBackend.ch(4);
itaAFBPathAcousticChamber = itaAFBPathChamber / itaBackend.ch(4);

%% example for extracting the impulse response of one channel
IR_SecPathExample       = itaSecPathBooth.ch(1).timeData;
IR_SecPathMean          = itaSecPathBoothMean.timeData;

%% example for plotting
% impulse response
ita_plot_time(itaSecPathBooth);

% magnitude and phase
ita_plot_freq_phase(itaSecPathBooth);

% groupdelay (might require additional smoothing, e.g. by ita_smooth)
ita_plot_groupdelay(itaSecPathBooth);


%% ************************************************
% *************** Extended Plotting ***************
% *************************************************

%% Electronic backend
co = winter(6);
% [~, axh] = ita_plot_freq_phase(itaBackend);
% xlim(axh(1),[20,20000]);
% xlim(axh(2),[20,20000]);


%% SecPath - calculate means and plot
itaSecPaths_mean = mean(itaSecPathBooth);
itaSecPath_closed = itaSecPathsFit(1);
itaSecPath_open = itaSecPathsFit(4);
itaSecPath_persons = ita_merge(itaSecPathsFit([2,3,5]));


co = winter(6);
hFig = figure('Name','Secondary Path');
% ita_preferences('colortablename','winter');
[~, axh] = ita_plot_freq_phase(itaSecPath_persons,'figure_handle',hFig,'hold','on','colormap',co(6,:));
ita_plot_freq_phase(itaSecPath_open,'figure_handle',hFig,'hold','on','colormap',co(5,:));
ita_plot_freq_phase(itaSecPath_closed,'figure_handle',hFig,'hold','on','colormap',co(4,:));
ita_plot_freq_phase(itaSecPathChamber,'figure_handle',hFig,'hold','on','colormap',co(3,:));
ita_plot_freq_phase(itaSecPaths_mean,'figure_handle',hFig,'hold','on','colormap',co(1,:));
nChannelsFit = [itaSecPath_persons.nChannels, itaSecPath_open.nChannels, itaSecPath_closed.nChannels, itaSecPathChamber.nChannels, itaSecPaths_mean.nChannels];
legendText = {'persons','open','closed','dummy','mean'};
legendGroups(axh(1), legendText, nChannelsFit);
xlim(axh(1),[20,20000]);
xlim(axh(2),[20,20000]);



%% SecPath - calculate means and plot

% calculate individual mean
for idx = 1:length(itaSecPathsFit)
    itaSecPathsFit_mean(idx) = mean(itaSecPathsFit(idx));
end

co = winter(length(itaSecPathsFit_mean)+2);
hFig = figure('Name','Secondary Path');
for idx = 1:length(itaSecPathsFit_mean)
    [~, axh] = ita_plot_freq_phase(itaSecPathsFit_mean(idx),'figure_handle',hFig,'hold','on','colormap',co(idx,:));
    nChannelsFit(idx) = itaSecPathsFit_mean(idx).nChannels;
    legendText{idx} = itaSecPathsFit_mean(idx).comment;
end
legendGroups(axh(1), legendText, nChannelsFit);
xlim(axh(1),[20,20000]);
xlim(axh(2),[20,20000]);



%% AFBPath - calculate means and plot
itaAFBPaths_mean = mean(itaAFBPathBooth);
itaAFBPaths_closed = itaAFBPathsFit(1);
itaAFBPaths_open = itaAFBPathsFit(4);
itaAFBPaths_persons = ita_merge(itaAFBPathsFit([2,3,5]));

co = winter(6);
hFig = figure('Name','Acoustic Feedback Path');
[~, axh] = ita_plot_freq_phase(itaAFBPaths_persons,'figure_handle',hFig,'hold','on','colormap',co(6,:));
ita_plot_freq_phase(itaAFBPaths_open,'figure_handle',hFig,'hold','on','colormap',co(5,:));
ita_plot_freq_phase(itaAFBPaths_closed,'figure_handle',hFig,'hold','on','colormap',co(4,:));
ita_plot_freq_phase(itaAFBPathChamber,'figure_handle',hFig,'hold','on','colormap',co(3,:));
ita_plot_freq_phase(itaAFBPaths_mean,'figure_handle',hFig,'hold','on','colormap',co(1,:));
nChannelsFit = [itaAFBPaths_persons.nChannels, itaAFBPaths_open.nChannels, itaAFBPaths_closed.nChannels, itaSecPathChamber.nChannels, itaAFBPaths_mean.nChannels];
legendText = {'persons','open','closed','dummy', 'mean'};
legendGroups(axh(1), legendText, nChannelsFit);
xlim(axh(1),[20,20000]);
xlim(axh(2),[20,20000]);




%% AFB - calculate means and plot
% calculate individual means
for idx = 1:length(itaAFBPathsFit)
    itaAFBPathsFit_mean(idx) = mean(itaAFBPathsFit(idx));
end

co = winter(length(itaAFBPathsFit_mean)+2);
hFig = figure('Name','Secondary Path');
for idx = 1:length(itaAFBPathsFit_mean)
    [~, axh] = ita_plot_freq_phase(itaAFBPathsFit_mean(idx),'figure_handle',hFig,'hold','on','colormap',co(idx,:));
    nChannelsFit(idx) = itaAFBPathsFit_mean(idx).nChannels;
    legendText{idx} = itaAFBPathsFit_mean(idx).comment;
end
legendGroups(axh(1), legendText, nChannelsFit);
xlim(axh(1),[20,20000]);
xlim(axh(2),[20,20000]);


%% PrimPath - calculate means and plot
itaPrimPaths_mean = mean(itaPrimPathLateral);
itaPrimPaths_closed = itaPrimPathsFit(1);
itaPrimPaths_open = itaPrimPathsFit(4);
itaPrimPaths_persons = ita_merge(itaPrimPathsFit([2,3,5]));

co = winter(6);
hFig = figure('Name','Primary Path');
[~, axh] = ita_plot_freq_phase(itaPrimPaths_persons,'figure_handle',hFig,'hold','on','colormap',co(6,:));
ita_plot_freq_phase(itaPrimPaths_open,'figure_handle',hFig,'hold','on','colormap',co(5,:));
ita_plot_freq_phase(itaPrimPaths_closed,'figure_handle',hFig,'hold','on','colormap',co(4,:));
ita_plot_freq_phase(itaPrimPaths_mean,'figure_handle',hFig,'hold','on','colormap',co(1,:));
nChannelsFit = [itaPrimPaths_persons.nChannels, itaPrimPaths_open.nChannels, itaPrimPaths_closed.nChannels,  itaPrimPaths_mean.nChannels];
legendText = {'persons','open','closed','mean'};
legendGroups(axh(1), legendText, nChannelsFit);
xlim(axh(1),[20,20000]);
xlim(axh(2),[20,20000]);
ylim(axh(1),[-70,20]);

%% Primary - calculate means and plot
% calculate individual means
for idx = 1:length(itaPrimPathsFit)
    itaPrimPathsFit_mean(idx) = mean(itaPrimPathsFit(idx));
end

co = winter(length(itaPrimPathsFit_mean)+2);
hFig = figure('Name','Secondary Path');
for idx = 1:length(itaPrimPathsFit_mean)
    [~, axh] = ita_plot_freq_phase(itaPrimPathsFit_mean(idx),'figure_handle',hFig,'hold','on','colormap',co(idx,:));
    nChannelsFit(idx) = itaPrimPathsFit_mean(idx).nChannels;
    legendText{idx} = itaPrimPathsFit_mean(idx).comment;
end
legendGroups(axh(1), legendText, nChannelsFit);
xlim(axh(1),[20,20000]);
xlim(axh(2),[20,20000]);

%% PrimPath Chamber - calculate means and plot
itaPrimPaths_mean = mean(itaPrimPathChamber);

map = bone(itaPrimPathChamber.nChannels);
coMean = [1,0,0; 0,1,0];
hFig = figure('Name','Primary Path');
[~, axh] = ita_plot_freq_phase(itaPrimPathChamber,'figure_handle',hFig,'hold','on','colormap',map);
ita_plot_freq_phase(itaPrimPaths_mean,'figure_handle',hFig,'hold','on','colormap',coMean(1,:));
nChannelsFit = [itaPrimPathChamber.nChannels, itaPrimPaths_mean.nChannels];
legendText = {'directions','mean'};
legendGroups(axh(1), legendText, nChannelsFit);
xlim(axh(1),[20,20000]);
xlim(axh(2),[20,20000]);
