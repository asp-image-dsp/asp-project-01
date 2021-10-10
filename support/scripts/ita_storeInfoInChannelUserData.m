function [ out ] = ita_storeInfoInChannelUserData( in )
% Stores comment and channel name in channelUserData - workaround for
% ita_merge
% INPUT:
%   - in: itaObj
%
% OUTPUT:
%   - out: selected channels
%

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Date:  21-Jan-2019
out = in;
if ~isempty(out)
    for idx = 1:numel(out) % multi instance
        for idCh = 1:out(idx).nChannels % multiple channels
            % construct userdata for one instance
            userData{idCh} = {out(idx).comment, ...
                out(idx).channelNames{idCh},...
                out(idx).fileName}; 
            % combine comment (assuming measurement situation) and channelName
        end
        out(idx).channelUserData = userData;
    end
end

end

