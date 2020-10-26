%% split_pool
% 
% Splits a pool into different pools, each one corresponding to one of the
% shards of the specified split.
%
%% Synopsis
%
%   [] = split_pool(trackID, splitID)
%  
%
% *Parameters*
%
% * *|trackID|* - the identifier of the track to process.
% * *|splitID|* - the identifier of the split to process.
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
function [] = split_pool(trackID, splitID)
    
    % setup common parameters
    common_parameters;
        
    % start of overall computations
    startComputation = tic;

    fprintf('\n\n######## Splitting pool for track %s ########\n\n', EXPERIMENT.track.(trackID).name);

    fprintf('+ Settings\n');
    fprintf('  - computed on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - split: %s\n', splitID);
    fprintf('    * shard(s): %d\n\n', EXPERIMENT.split.(splitID).shard);


    fprintf('+ Loading pool of the corpus\n');
        
    corpusPoolID = EXPERIMENT.pattern.identifier.pool(EXPERIMENT.split.(splitID).corpus, trackID);
    fprintf('  - %s\n', corpusPoolID);
    
    serload2(EXPERIMENT.pattern.file.dataset.corpus(trackID, corpusPoolID), ...
        'WorkspaceVarNames', {'corpusPool'}, ...
        'FileVarNames', {corpusPoolID});
    
    % the total number of topics in the pool
    T = height(corpusPool);
    

    % create a dummy table with a dummy document and the lowest relevance
    % degree possible among those in the pool    
    dummyTable = corpusPool{:, 1}{1, 1}(:, :);
    
    relevanceDegrees = categories(dummyTable.RelevanceDegree);

    idx = find(dummyTable.RelevanceDegree == relevanceDegrees(1), 1, 'first');
    
    dummyTable = dummyTable(idx, :);
    dummyTable(1, 'Document') = {'#####DUMMY_DOC_ID^^^^^^'};
    
    
    
    fprintf('+ Processing shards\n');
    
    % repeat the splitting for each sample
    for smpl = 1:EXPERIMENT.split.sample
        
        fprintf('  - sample %d\n', smpl);
        
        % for each shard
        for shr = 1:EXPERIMENT.split.(splitID).shard
            
            start = tic;
            
            shardID = EXPERIMENT.pattern.identifier.shard(splitID, shr, smpl);
            
            fprintf('    * shard %s... ', shardID);
            
            shard = importdata(EXPERIMENT.pattern.file.shard(splitID, shardID));
            
            shardPool = corpusPool;
            
            % for each topic
            for t = 1:T
                
                % extract the inner table contained in the topic
                topic = shardPool{t, 1}{1, 1};
                
                % find which rows (documents) have to be kept
                keep = ismember(topic.Document, shard);
                
                relevance = shardPool{t, :}{1}{:, 2};
                rel_idx = (relevance=='Relevant');
                rel_docs =  shardPool{t, :}{1}{rel_idx, 1};
                if contains('NEMP', splitID) && ~any(ismember(rel_docs, shard))
                    fprintf("ERROR: REQUESTED NEMP SHARD, BUT RELEVANTS NOT FOUND");
                end
                
                if any(keep)
                    shardPool{t, 1} = {topic(keep, :)};
                else
                    shardPool{t, 1} = {dummyTable};
                end
                
            end % for topic
                        
            shardPoolID = EXPERIMENT.pattern.identifier.pool(shardID, trackID);
            shardPool.Properties.UserData.identifier = shardPoolID;
            shardPool.Properties.VariableNames = {shardPoolID};
            
            sersave2(EXPERIMENT.pattern.file.dataset.shard(trackID, splitID, shardPoolID), ...
                'WorkspaceVarNames', {'shardPool'}, ...
                'FileVarNames', {shardPoolID});
            
            clear shard shardPool
            
            fprintf('elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            
        end % for shard
        
    end % for sample
    
    fprintf('\n\n######## Total elapsed time for splitting pool for track %s: %s ########\n\n', ...
            EXPERIMENT.track.(trackID).name, elapsedToHourMinutesSeconds(toc(startComputation)));
    
end

