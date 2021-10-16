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


%% load anechoic chamber dataset
anechoic_folder         = fullfile(database_folder,'BoseQC20\anechoic_chamber\');
[ itaChamberPrimary ]   = ita_read_ita_folder( fullfile(anechoic_folder,'primary') );
[ itaChamberSecAFB ]    = ita_read_ita_folder( fullfile(anechoic_folder,'secondary+afb') );
itaBooth                = [itaPersons,itaHandling];

% separate in primary path left and right
[ itaChamberPaths, ~ ]  = ita_separateByChannelNames( ita_merge(itaChamberPrimary), 3 );

%% load electronic back-end
dataset_folder          = fullfile(database_folder,'BoseQC20\electronic_backend\');
[ itaBackend ]          = ita_read_ita_folder( dataset_folder );

%% extract certain paths
% extract from booth measurements
itaPrimPathBooth        = ita_merge(itaBoothPaths(3:4)); % Merges P(z) L and R
itaSecPathBooth         = ita_merge(itaBoothPaths(5:6)); % Merges G(z) L and R
itaAFBPathBooth         = ita_merge(itaBoothPaths(1:2)); % Merges F(z) L and R

% extract from anechoic chamber measurements
itaPrimPathChamber      = ita_merge(itaChamberPaths);          % Merges P(z) L and R
itaSecPathChamber       = ita_merge(itaChamberSecAFB.ch(1:2)); % Merges G(z) L and R
itaAFBPathChamber       = ita_merge(itaChamberSecAFB.ch(3:4)); % Merges F(z) L and R

%% extract acoustic component G_A(z) and F_A(z) of secondary path G(z) and feedback path F(z)
% this component compensates for the influence of the electronic backend
% for simulations of a realizable ANC system it is advisable to include an
% electronic backend
itaSecPathAcousticBooth = itaSecPathBooth / itaBackend.ch(4);
itaAFBPathAcousticBooth = itaAFBPathBooth / itaBackend.ch(4);

itaSecPathAcousticChamber = itaSecPathChamber / itaBackend.ch(4);
itaAFBPathAcousticChamber = itaAFBPathChamber / itaBackend.ch(4);

%% save all acoustic booth measurements to a JSON file
json = '';
N = itaBoothPaths(1).dimensions;
for i=1:N
    P = [itaPrimPathBooth.timeData(:,i) itaPrimPathBooth.timeData(:,N+i)]';               % [ L R ]
    G = [itaSecPathAcousticBooth.timeData(:,i) itaSecPathAcousticBooth.timeData(:,N+i)]'; % [ L R ]
    F = [itaAFBPathAcousticBooth.timeData(:,i) itaAFBPathAcousticBooth.timeData(:,N+i)]'; % [ L R ]
    if i > 1
        json = append(json,',');
    end
    json = append(json,jsonencode(struct('P',P,'G',G,'F',F)));
end

json = append('{"acoustic_booth":[',json,']');

%% save all anechoic chamber measurements to a JSON file

json = append(json,',"anechoic_chamber":{"primary":[');
N = itaChamberPaths(1).dimensions;
for i=1:N
    P = [itaPrimPathChamber.timeData(:,i) itaPrimPathChamber.timeData(:,N+i)]';               % [ L R ]
    if i > 1
        json = append(json,',');
    end    
    json = append(json,jsonencode(P));
end
json = append(json,'],"secondary":');
G = [itaSecPathAcousticChamber.timeData(:,1) itaSecPathAcousticChamber.timeData(:,2)]'; % [ L R ]
json = append(json,jsonencode(G),',"feedback":');
F = [itaAFBPathAcousticChamber.timeData(:,1) itaAFBPathAcousticChamber.timeData(:,2)]'; % [ L R ]
json = append(json,jsonencode(F),'}}');

%% Save file

fileID = fopen('../../PANDAR_database_1.0/BoseQC20/processed_data.json','w');
fprintf(fileID, json);
fclose(fileID);
