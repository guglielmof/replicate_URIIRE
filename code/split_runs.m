%% split_runs
% 
% Splits runs into different sets of runs, each one corresponding 
% to one of the shard of the specified split.
%
%% Synopsis
%
%   [] = split_runs(trackID, splitID)
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
function [] = split_runs(trackID, splitID)
    %parpool(24);
    common_parameters;

    persistent PROCESS_RUN;
    
    if isempty(PROCESS_RUN)        
        PROCESS_RUN = @processRun;
    end

    % start of overall computations
    startComputation = tic;

    fprintf('\n\n######## Splitting runs for track %s ########\n\n', EXPERIMENT.track.(trackID).name);

    fprintf('+ Settings\n');
    fprintf('  - computed on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - split: %s\n', splitID);
    fprintf('    * shard(s): %d\n\n', EXPERIMENT.split.(splitID).shard);


    fprintf('+ Loading runs of the corpus\n');
        
    corpusRunID = EXPERIMENT.pattern.identifier.run(EXPERIMENT.split.(splitID).corpus, trackID);
    fprintf('  - %s\n', corpusRunID);
    
    serload2(EXPERIMENT.pattern.file.dataset.corpus(trackID, corpusRunID), ...
        'WorkspaceVarNames', {'corpusRun'}, ...
        'FileVarNames', {corpusRunID});
    
    % the total number of topics in the set
    T = height(corpusRun);
    
    % the total number of runs in the set
    R = width(corpusRun);
    
    disp(R);
   
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
            
            % improves subsequent lookup operations
            shard = sort(shard);
            
            % replicate the shard to properly work with cellfun
            shard = repmat({shard}, 1, R);
            
            shardRun = corpusRun;
            
            %parfor t = 1:T
            for t = 1:T
                shardRun{t, :} = cellfun(PROCESS_RUN, shardRun{t, :}, shard, 'UniformOutput', false);
            end % for topic
            
            shardRunID = EXPERIMENT.pattern.identifier.run(shardID, trackID);
            shardRun.Properties.UserData.identifier = shardRunID;
            
            sersave2(EXPERIMENT.pattern.file.dataset.shard(trackID, splitID, shardRunID), ...
                'WorkspaceVarNames', {'shardRun'}, ...
                'FileVarNames', {shardRunID});
            
            clear shard shardRun
            
            fprintf('elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            
        end % for shard
        
    end % for sample
    
    fprintf('\n\n######## Total elapsed time for splitting runs for track %s: %s ########\n\n', ...
            EXPERIMENT.track.(trackID).name, elapsedToHourMinutesSeconds(toc(startComputation)));
    
end


function [shardTopic] = processRun(topic, shard)

    persistent DUMMY_TABLE;
   
    if isempty(DUMMY_TABLE)        
        DUMMY_TABLE = cell2table({'#####DUMMY_DOC_ID^^^^^^', 1, 1});
        DUMMY_TABLE.Properties.VariableNames = {'Document', 'Rank', 'Score'};        
    end
    
    docs = ismember(topic.Document, shard);
    
    % if there is at least one document, use it, otherwise use a default
    % dummy document, which will be not relevant when assessed.
    if any(docs)
        shardTopic = topic(docs, :);
    else
        shardTopic = DUMMY_TABLE;
    end
end
