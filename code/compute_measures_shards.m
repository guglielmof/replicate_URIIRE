%% compute_measures_shards
% 
% Computes measures for the split of the given track and saves them to a
% |.mat| file.
%
%% Synopsis
%
%   [] = compute_measures_shards(trackID, splitID, startMeasure, endMeasure, startSample, endSample)
%  
%
% *Parameters*
%
% * *|trackID|* - the identifier of the track to process.
% * *|splitID|* - the identifier of the split to process.
% * *|startMeasure|* - the index of the start measure to process. Optional.
% * *|endMeasure|* - the index of the end measure to process. Optional.
% * *|startSample|* - the index of the start sample to process. Optional.
% * *|endSample|* - the index of the end sample to process. Optional.
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
% * *Requirements*: MATTERS 1.0 or higher; Matlab 2015b or higher
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

function [] = compute_measures_shards(trackID, splitID, startMeasure, endMeasure, startSample, endSample)

    % check the number of input arguments
    narginchk(2, 6);

    % setup common parameters
    common_parameters;
        
    % check that trackID is a non-empty string
    validateattributes(trackID,{'char', 'cell'}, {'nonempty', 'vector'}, '', 'trackID');

    if iscell(trackID)
        % check that trackID is a cell array of strings with one element
        assert(iscellstr(trackID) && numel(trackID) == 1, ...
            'MATTERS:IllegalArgument', 'Expected trackID to be a cell array of strings containing just one string.');
    end

    % remove useless white spaces, if any, and ensure it is a char row
    trackID = char(strtrim(trackID));
    trackID = trackID(:).';
    
    % check that trackID assumes a valid value
    validatestring(trackID, ...
        EXPERIMENT.track.list, '', 'trackID');
    
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
    
    % check that splitID assumes a valid value
    validatestring(splitID, ...
        EXPERIMENT.split.list, '', 'splitID');        

    % check that the track and the split rely on the same corpus
    assert(strcmp(EXPERIMENT.track.(trackID).corpus, EXPERIMENT.split.(splitID).corpus), 'Track %s and split %s do not rely on the same corpus', trackID, splitID);
    
    
    if nargin >= 4
        validateattributes(startMeasure, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', 1, '<=', EXPERIMENT.measure.number }, '', 'startMeasure');
        
        validateattributes(endMeasure, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', startMeasure, '<=', EXPERIMENT.measure.number }, '', 'endMeasure');
    else 
        startMeasure = 1;
        endMeasure = EXPERIMENT.measure.number;
    end
    
    if nargin == 6
        validateattributes(startSample, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', 1, '<=', EXPERIMENT.split.sample }, '', 'startSample');
        
        validateattributes(endSample, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', startSample, '<=', EXPERIMENT.split.sample }, '', 'endSample');
    else 
        startSample = 1;
        endSample = EXPERIMENT.split.sample;
    end
    

    % start of overall computations
    startComputation = tic;

    fprintf('\n\n######## Computing shard measures on track %s (%s) ########\n\n', EXPERIMENT.track.(trackID).name, EXPERIMENT.label.paper);

    fprintf('+ Settings\n');
    fprintf('  - computed on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - split: %s\n', splitID);
    fprintf('    * shard(s): %d\n', EXPERIMENT.split.(splitID).shard);
    fprintf('    * start sample: %d\n', startSample);
    fprintf('    * end sample: %d\n', endSample);    
    fprintf('  - slice \n');
    fprintf('    * start measure: %d (%s)\n', startMeasure, EXPERIMENT.measure.getAcronym(startMeasure));
    fprintf('    * end measure: %d (%s)\n\n', endMeasure, EXPERIMENT.measure.getAcronym(endMeasure));


    fprintf('+ Processing shards\n');
    
    % repeat the computation for each sample
    for smpl = startSample:endSample
        
        fprintf('  - sample %d\n', smpl);
        
        % for each shard
        for shr = 1:EXPERIMENT.split.(splitID).shard
                        
            shardID = EXPERIMENT.pattern.identifier.shard(splitID, shr, smpl);
            
            fprintf('    * loading the dataset for shard %s\n', shardID);
                        
            shardPoolID = EXPERIMENT.pattern.identifier.pool(shardID, trackID);
            serload2(EXPERIMENT.pattern.file.dataset.shard(trackID, splitID, shardPoolID), ...
                'WorkspaceVarNames', {'pool'}, ...
                'FileVarNames', {shardPoolID});
            
            shardRunID = EXPERIMENT.pattern.identifier.run(shardID, trackID);
            serload2(EXPERIMENT.pattern.file.dataset.shard(trackID, splitID, shardRunID), ...
                'WorkspaceVarNames', {'runSet'}, ...
                'FileVarNames', {shardRunID});
            
            % for each measure
            for m = startMeasure:endMeasure
                
                start = tic;
                                
                fprintf('      # computing %s... ', EXPERIMENT.measure.getAcronym(m));
                
                mid = EXPERIMENT.measure.list{m};
                
                measure = EXPERIMENT.measure.(mid).compute(pool, runSet, EXPERIMENT.track.(trackID).runLength);
                
                measureID = EXPERIMENT.pattern.identifier.measure(mid, shardID, trackID);
                
                sersave2(EXPERIMENT.pattern.file.measure.shard(trackID, splitID, measureID), ...
                    'WorkspaceVarNames', {'measure'}, ...
                    'FileVarNames', {measureID});
                
                clear measure;
                
                fprintf('elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                
            end % for measure
            
            clear assess;
            clear pool runSet;
            
        end % for shard
    end % for sample
              
    fprintf('\n\n######## Total elapsed time for computing shard measures on track %s (%s): %s ########\n\n', ...
            EXPERIMENT.track.(trackID).name, EXPERIMENT.label.paper, elapsedToHourMinutesSeconds(toc(startComputation)));
end
