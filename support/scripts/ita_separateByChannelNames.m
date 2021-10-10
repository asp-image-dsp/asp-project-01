function [ out, nChannels ] = ita_separateByChannelNames( in, chanNameId )
% Find all channels with a certain name
% INPUT:
%   - in: itaObj 
%   - chanNameId: 1 old "comment", 2 old "channelName", 3 old "fileName"
%
% OUTPUT:
%   - out: selected channels
%   - nChannels: number of different channels found
%

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Date:  21-Jan-2019

if nargin < 2
    chanNameId = 1; 
end

channelNames = in.channelNames;
uniqueChanNames = unique(channelNames);
nChannels = length(uniqueChanNames);

for idx = 1:nChannels
    idxCurrentChan = strcmp(channelNames,uniqueChanNames(idx));
    out(idx) = in.ch(idxCurrentChan);
    out(idx).comment = uniqueChanNames{idx};
    
    % extract measurement situation from channelUserData if existent
    if(~isempty(out(idx).channelUserData))
        tmpUserData = out(idx).channelUserData{1};
        if isa(tmpUserData,'char')
            numEntry = 1;
            tmp = {out(idx).channelUserData{:}};
        else
            numEntry = length(tmpUserData);
            tmp = [out(idx).channelUserData{:}];
        end
        out(idx).channelNames = tmp(chanNameId:numEntry:end); % first entrance is old "comment", second entrance is old "channelName", third is old "fileName"
    end
end

end

