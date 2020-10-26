%% compute_measures_corpus
% 
% Computes measures for the given track and saves them to a
% |.mat| file.
%
%% Synopsis
%
%   [] = compute_measures_corpus(trackID, startMeasure, endMeasure)
%  
%
% *Parameters*
%
% * *|trackID|* - the identifier of the track to process.
% * *|startMeasure|* - the index of the start measure to process. Optional.
% * *|endMeasure|* - the index of the end measure to process. Optional.
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

function [] = compute_measures_corpus(trackID, startMeasure, endMeasure)

    % check the number of input arguments
    narginchk(1, 3);

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
        
    if nargin == 3
        validateattributes(startMeasure, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', 1, '<=', EXPERIMENT.measure.number }, '', 'startMeasure');
        
        validateattributes(endMeasure, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', startMeasure, '<=', EXPERIMENT.measure.number }, '', 'endMeasure');
    else 
        startMeasure = 1;
        endMeasure = EXPERIMENT.measure.number;
    end
        
    % start of overall computations
    startComputation = tic;

    fprintf('\n\n######## Computing measures on track %s (%s) ########\n\n', EXPERIMENT.track.(trackID).name, EXPERIMENT.label.paper);

    fprintf('+ Settings\n');
    fprintf('  - computed on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - slice \n');
    fprintf('    * start measure: %d (%s)\n', startMeasure, EXPERIMENT.measure.getAcronym(startMeasure));
    fprintf('    * end measure: %d (%s)\n\n', endMeasure, EXPERIMENT.measure.getAcronym(endMeasure));


        
    fprintf('+ Loading the dataset\n');
        
    poolID = EXPERIMENT.pattern.identifier.pool(EXPERIMENT.track.(trackID).corpus, trackID);
    fprintf('  - %s\n', poolID);
    
    serload2(EXPERIMENT.pattern.file.dataset.corpus(trackID, poolID), ...
        'WorkspaceVarNames', {'pool'}, ...
        'FileVarNames', {poolID});
                

    runID = EXPERIMENT.pattern.identifier.run(EXPERIMENT.track.(trackID).corpus, trackID);
    fprintf('  - %s\n\n', runID);
    
    serload2(EXPERIMENT.pattern.file.dataset.corpus(trackID, runID), ...
        'WorkspaceVarNames', {'runSet'}, ...
        'FileVarNames', {runID});
    
    % for each measure
    for m = startMeasure:endMeasure

        start = tic;

        fprintf('+ Computing %s\n', EXPERIMENT.measure.getAcronym(m));

        mid = EXPERIMENT.measure.list{m};

        measure = EXPERIMENT.measure.(mid).compute(pool, runSet, EXPERIMENT.track.(trackID).runLength);
        
        measureID = EXPERIMENT.pattern.identifier.measure(mid, EXPERIMENT.track.(trackID).corpus, trackID);

        sersave2(EXPERIMENT.pattern.file.measure.corpus(trackID, measureID), ...
            'WorkspaceVarNames', {'measure'}, ...
            'FileVarNames', {measureID});

        clear measure;

        fprintf('  - elapsed time: %s\n\n', elapsedToHourMinutesSeconds(toc(start)));

    end % for measure
        
    fprintf('\n\n######## Total elapsed time for computing measures on track %s (%s): %s ########\n\n', ...
            EXPERIMENT.track.(trackID).name, EXPERIMENT.label.paper, elapsedToHourMinutesSeconds(toc(startComputation)));
end
