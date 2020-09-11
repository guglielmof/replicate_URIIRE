%% random_split_corpus
% 
% Splits a corpus into a set of random shards.
%
%% Synopsis
%
%   [] = random_split_corpus(splitID)
%  
%
% *Parameters*
%
% * *|splitID|* - the identifier of the split to be used.
%
% *Returns*
%
% Nothing
%

%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: MATTERS 1.0 or higher; Matlab 2017a
% * *Copyright:* (C) 2018-2019 <http://www.dei.unipd.it/ 
% Department of Information Engineering> (DEI), <http://www.unipd.it/ 
% University of Padua>, Italy
% * *License:* <http://www.apache.org/licenses/LICENSE-2.0 Apache License, 
% Version 2.0>

%%
%{
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
      http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
%}

%%
function [] = random_split_corpus(splitID)
   
    % check that we have the correct number of input arguments. 
    narginchk(1, 1);
    
    % setup common parameters
    common_parameters;
              
    % check that splitID is a non-empty string
    validateattributes(splitID,{'char', 'cell'}, {'nonempty', 'vector'}, '', 'splitID');

    if iscell(splitID)
        % check that splitID is a cell array of strings with one element
        assert(iscellstr(splitID) && numel(splitID) == 1, ...
            'MATTERS:IllegalArgument', 'Expected splitID to be a cell array of strings containing just one string.');
    end

    % remove useless white spaces, if any, and ensure it is a char row
    splitID = char(strtrim(splitID));
    splitID = splitID(:).';    
            
    % start of overall computations
    startComputation = tic;

    fprintf('\n\n######## Generating random shards for %s ########\n\n', splitID);

    fprintf('+ Settings\n');
    fprintf('  - computed on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - split: %s\n', splitID);
    fprintf('  - number of shards: %d\n', EXPERIMENT.split.(splitID).shard);
    fprintf('  - shard ratios: %s\n', num2str(EXPERIMENT.split.(splitID).ratio, '%3.2f '));
    fprintf('  - number of samples: %d\n\n', EXPERIMENT.split.sample);
    
    % check that shard ratios sum up to 1.00
    %assert(sum(EXPERIMENT.split.(splitID).ratio) == 1, 'shard ratios must sum up to 1.');

    fprintf('+ Loading the corpus\n');
    
    corpus = importdata(EXPERIMENT.pattern.file.corpus(EXPERIMENT.split.(splitID).corpus));
    
    % the total lenght of the corpus
    N = length(corpus);
        
    fprintf('+ Computing the splits\n');
    
    % turn the shard ratios into number of documents for each shard
    range = floor(EXPERIMENT.split.(splitID).ratio * N);
    
    % find the position of the biggest element
    [~, idx] = max(range);
    
    % get only the first biggest element in case of ties
    idx = idx(1);
    
    % add to the biggest element any round up, i.e. 
    range(idx) = range(idx) + (N - sum(range));
    
    % ensure it is a row
    range = range(:).';
    
    % turn the number of elements in each split into the last index of the
    % range of each split
    range = cumsum(range);
    
    % add the start index of the range of each split (first row)
    range = [1 range(1:end-1)+1; range];
    
    fprintf('+ Generating the shards for the requested samples\n');
    
    % repeat the shard generation for each sample
    for smpl = 1:EXPERIMENT.split.sample
        
        fprintf('  - sample %d\n', smpl);
    
        % generate a random sampling of the corpus
        corpus = corpus(randperm(N));
        
        for shr = 1:length(EXPERIMENT.split.(splitID).ratio)
            
            shardID = EXPERIMENT.pattern.identifier.shard(splitID, shr, smpl);
            
            fprintf('    * shard %s\n', shardID);
            
            fid = fopen(EXPERIMENT.pattern.file.shard(splitID, shardID), 'w');
            tmp = corpus(range(1, shr):range(2, shr));
            
            fprintf(fid,'%s\n', tmp{:});
            
            fclose(fid);
            
        end % for each shard    
    end % for each sample
       
    fprintf('\n\n######## Total elapsed time for generating  random shards for %s: %s ########\n\n', ...
            splitID, elapsedToHourMinutesSeconds(toc(startComputation)));    
end
