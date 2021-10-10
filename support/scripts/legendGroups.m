function legendGroups(axh, names, nChannels)
% LEGENDGROUPS creates a legend for groups of lines and deactivates all
% others
%
% INPUT:
%       axh:        axes handle where the legend should be created
%       names:      Cell list of names that are shown in the legend
%       nChannels:  array of number of lines in a group
%   
%       e.g. legendGroups(axh, {'bla','blubb','kladeratsch'}, [5,2,10])
%
% Example:
%     % create data
%     L = 100;
%     names = {'bla','blubb','kladeratsch'};
%     nChannels = [5,20,7];
%     group1 = 2*randn(L,nCh(1));
%     group2 = 0.1*randn(L,nCh(2));
%     group3 = randn(L,nCh(3));
%     % plot data
%     figure;
%     plot(group1,'r');
%     hold all;
%     plot(group2,'b');
%     plot(group3,'k');
%     % group legend
%     legendGroups(gca, names, nChannels)

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Created:  27-Mar-2019


% get lines
allLines = findobj(axh,'Type','line');
% lines are invertedly sorted

startId = cumsum(nChannels) - (nChannels);
endId = cumsum(nChannels)-1;

% iterate over all line groups
for idLine = 1:length(names)
    curLines = allLines(end-endId(idLine):end-startId(idLine));
    
    % set name for first line
    set(curLines(end),'DisplayName',names{idLine}); 
    
    % deactivate legend for all other lines
    for idRestLine = 1:length(curLines)-1
        set(get(get(curLines(idRestLine),'Annotation'),'LegendInformation'),...
            'IconDisplayStyle','off'); % Exclude line from legend
    end
end

% show legend
legend('show')