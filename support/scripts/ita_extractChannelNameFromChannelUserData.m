function [ out ] = ita_extractChannelNameFromChannelUserData( in, ids )
% Extracts channelName from channelUserData
% ita_merge
% INPUT:
%   - in: itaObj
%   - ids: denote the ids of the data in the channelUserData
%
% OUTPUT:
%   - out: selected channels
%

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Date:  21-Jan-2019
out = in;
for idx = 1:numel(out) % multi instance
    for idCh = 1:out(idx).nChannels % multiple channels
        % extract channelName from channelUserData
        tmp = [];
        for idNum = 1:length(ids)
            tmp = [tmp,'_',out(idx).ch(idCh).channelUserData{1}{ids(idNum)}];
        end
        channelNames{idCh} = tmp(2:end); % delete initial _
    end
    out(idx).channelNames = channelNames;
end

end

