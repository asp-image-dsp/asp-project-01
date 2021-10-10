function [ out, nChannels ] = ita_separateByChannelUserData( in, chanNameId )
% Separate by a certain entry in the channelUserData
% INPUT:
%   - in: itaObj 
%   - chanNameId: e.g. 1 old "comment", 2 old "channelName", 3 old "fileName",
%   old "fitting"
%
% OUTPUT:
%   - out: selected channels
%   - nChannels: number of different channels found
%

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Date:  01-Mar-2019

if nargin < 2
    chanNameId = 1; 
end

if(~isempty(in.channelUserData))
    channelUserData = in.channelUserData;
    % extract the desired chanNameId from the channelUserData
    numEntry = length(channelUserData{1});
    tmp = [channelUserData{:}];
    selected = tmp(chanNameId:numEntry:end);

    % determine the unique entries
    uniqueChanUserData = unique(selected);
    nChannels = length(uniqueChanUserData);

    for idx = 1:nChannels
        % find all entries with the selected unique entry
        idxCurrentChan = strcmp(selected,uniqueChanUserData(idx));
        out(idx) = in.ch(idxCurrentChan);
        out(idx).comment = uniqueChanUserData{idx};

    end
else
   warning('No channelUserData found') 
end

end

