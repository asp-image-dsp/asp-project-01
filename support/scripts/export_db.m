clc

%% path to database
database_folder = '../../PANDAR_database_1.0'; 

%% load acoustic booth dataset
dataset_folder          = fullfile(database_folder,'BoseQC20\acoustic_booth\');
[ itaPersons ]          = ita_read_ita_folder( fullfile(dataset_folder,'persons') );
[ itaHandling ]         = ita_read_ita_folder( fullfile(dataset_folder,'handling') );
itaBooth                = [itaPersons,itaHandling];

% separate in primary/secondary/feedback path left and right
[ itaBoothPaths, ~ ]    = ita_separateByChannelNames( ita_merge(itaBooth), 3 );

%% load electronic back-end
dataset_folder          = fullfile(database_folder,'BoseQC20\electronic_backend\');
[ itaBackend ]          = ita_read_ita_folder( dataset_folder );

%% extract certain paths
% extract from booth measurements
itaPrimPathBooth        = ita_merge(itaBoothPaths(3:4)); % Merges P(z) L and R
itaSecPathBooth         = ita_merge(itaBoothPaths(5:6)); % Merges G(z) L and R
itaAFBPathBooth         = ita_merge(itaBoothPaths(1:2)); % Merges F(z) L and R

% average paths
%itaPrimPathBoothMean    = mean(itaPrimPathBooth);
%itaSecPathBoothMean     = mean(itaSecPathBooth);
%itaAFBPathBoothMean     = mean(itaAFBPathBooth);

% separate into different fits
% use cases:        normal-fit / slightly-loose-fit / loose-fit / open-fit 
% handling cases:   open and closed
%[ itaPrimPathsFit, ~ ]  = ita_separateByChannelUserData( itaPrimPathBooth, 4 );
%[ itaSecPathsFit, ~ ]   = ita_separateByChannelUserData( itaSecPathBooth, 4 );
%[ itaAFBPathsFit, ~ ]   = ita_separateByChannelUserData( itaAFBPathBooth, 4 );


%% extract acoustic component G_A(z) and F_A(z) of secondary path G(z) and feedback path F(z)
% this component compensates for the influence of the electronic backend
% for simulations of a realizable ANC system it is advisable to include an
% electronic backend
itaSecPathAcousticBooth = itaSecPathBooth / itaBackend.ch(4);
itaAFBPathAcousticBooth = itaAFBPathBooth / itaBackend.ch(4);

%% save all measurements to a JSON file
json = '';
for i=1:itaBoothPaths(1).dimensions
    P = [itaBoothPaths(3).timeData(:,i) itaBoothPaths(4).timeData(:,i)]'; % [ L R ]
    G = [itaBoothPaths(5).timeData(:,i) itaBoothPaths(6).timeData(:,i)]'; % [ L R ]
    F = [itaBoothPaths(1).timeData(:,i) itaBoothPaths(2).timeData(:,i)]'; % [ L R ]
    if i > 1
        json = append(json,',');
    end
    json = append(json,jsonencode(struct('P',P,'G',G,'F',F)));
end

json = append('{"acoustic_booth":[',json,']}');
fileID = fopen('../../PANDAR_database_1.0/BoseQC20/processed_data.json','w');
fprintf(fileID, json);
fclose(fileID);
