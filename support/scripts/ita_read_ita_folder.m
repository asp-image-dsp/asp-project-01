
function result = ita_read_ita_folder(folderName,varargin)
% Read all *.ita files from a folder and combine them in a list of ita
% objects

%  Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
%  Created:  21-Jan-2019
try
filelist = dir(fullfile(folderName,'*.ita'));
numMeas = length(filelist);
fprintf(['Loading ' mat2str(numMeas), ' *.ita files: ']);
for index = 1:numMeas
   
   % read a single measurement
%    relation = ita_read_ita(sprintf('%s/data/%d.ita',fullFolderName,index));
   tmp = ita_read_ita([folderName,filesep,filelist(index).name]);
   if( size(tmp,1) > 1 )
       itaObjTmp(:,index) = tmp;
   elseif ( size(tmp,2) > 1 )
       itaObjTmp(index,:) = tmp;
   else
       itaObjTmp(index) = tmp;
   end
   
   
   % indicate progress by 10 sharp symbols
   if(diff( floor((index+(0:1)) / numMeas * 10) ) > 0)
      fprintf('#'); 
   end
end
fprintf('\n'); 
result = itaObjTmp;
catch ME
    % result = itaAudio;
    rethrow(ME);
end

end
