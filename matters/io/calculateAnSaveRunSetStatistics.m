%% calculateAnSaveRunSetStatistics
% 
% Load the pool and the runSet report (this funzction assumes these tables are already available) 
% of an experimental collection and calculates the runSet statistics.

%% Synopsis
%
%   [runSetAggregatedStatistics, totalAggregatedPerRunStatistics, totalAggregatedPerTopicStatistics, totalRunSetStatistics] = calculateAnSaveRunSetStatistics(Name, Value)
%  
% It will create the following .mat files:
%
% * runSetAggregatedStatistics_<CollectionIdentifier>.mat: it contains the
% table with the statistics divided per run and per topics.
% * totalAggregatedPerRunStatistics_<CollectionIdentifier>.mat: it contains
% the statistics aggregated per run.
% * totalAggregatedPerTopicStatistics_<CollectionIdentifier>.mat: it
% contains the statistics aggregated per topic.
% * totalRunSetStatistics_<CollectionIdentifier>.mat: it contains the total
% aggregated statistics.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|CollectionIdentifier|* (mandatory) - the unique identifier of the 
% collection. It must be compliant with MATLAB rules for 
% <http://www.mathworks.it/it/help/matlab/matlab_prog/variable-names.html 
% variable names>, otherwise an error is raised.
% * *|OutputPath|* (mandatory) - a string specifying the path to the output 
% directory where the .mat files will be sersaved.
% * *|ExperimentalCollectionsPath|* (mandatory) - the path to the parent directory
% containing the experimental collections;
% * *|DocumentOrdering|* (optional) - a string specifying how to sort
% documents when reading them from the import file. It can assume the
% following values: _|Original|_, i.e. keep the documents in the same 
% order as in the import file; _|TrecEvalLexDesc|_, i.e. sort document by 
% descending order of |score| and descending lexicographical order of 
% |document-id|; _|TrecEvalLexAsc|_, i.e. sort document by descending order 
% of |score| and ascending lexicographical order of |document-id|; 
% _|Matters|_, i.e. sort documents by descending order of
% |score|, ascending order of |rank|, and ascending lexicographical order 
% of |document-id|; _|Conservative|_, i.e. sort documents by descending 
% order of |score| and, for the documents with the same |score| keep the 
% same ordering used in the import file. The default is |TrecEvalLexDesc|
% to mimic |trec_eval| behaviour.
% * *|RunSetDelimiter|* (optional) - a string specifying the delimiter used 
% in  the run text file to be imported. Possible values are: |comma|, |space|, 
% |tab|, |semi|, or |bar|. If not specified, then |tab| is used as default. 
% See the documentation of 
% <http://www.mathworks.it/it/help/matlab/ref/readtable.html readtable> 
% for further information about allowed delimiters.
%
% Please refer to <importPoolFromFileTRECFormat.html
% importPoolFromFileTRECFormat> for specific Name-Value pairs for importing
% the pool and to <importRunsFromDirectoryTRECFormat.html
% importRunsFromDirectoryTRECFormat> for specific Name-Value pairs for
% importing the runs.
%
% 
%% Example of use
%  
%  experimentalCollectionPath = '/nas1/promise/ims/experimental-collections/TREC/';
%
%   calculateAnSaveRunSetStatistics('CollectionIdentifier', collectionIdentifier, ...
%       'ExperimentalCollectionsPath', experimentalCollectionPath, ...
%       'OutputPath', outputPath, 'DocumentOrdering', 'Original');
%
% It serloads a collection in the path experimentalCollectionPath joined with the collectionIdentifier string
% and it calculates the statistics for it.
% 
%
%
%
%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>,
% <mailto:silvello@dei.unipd.it Gianmaria Silvello>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: Matlab 2013b or higher
% * *Copyright:* (C) 2013-2014 <http://ims.dei.unipd.it/ Information 
% Management Systems> (IMS) research group, <http://www.dei.unipd.it/ 
% Department of Information Engineering> (DEI), <http://www.unipd.it/ 
% University of Padua>, Italy
% * *License:* Apache License, Version 2.0

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
function [runSetAggregatedStatistics, totalAggregatedPerRunStatistics, totalAggregatedPerTopicStatistics, totalRunSetStatistics] = calculateAnSaveRunSetStatistics(varargin)

    
    % disable warnings, not needed for bulk import
    warning('off');
    
    persistent calculateStatistics assignStatistics saveRunSetAggregatedStatistics saveTotalAggregatedPerRunStatistics saveTotalAggregatedPerTopicStatistics saveTotalRunSetStatistics;
 
    if isempty(calculateStatistics)
        
        % calculate run set statistics
        calculateStatistics = '[runSetAggregatedStatistics_%1$s, totalAggregatedPerRunStatistics_%1$s, totalAggregatedPerTopicStatistics_%1$s, totalRunSetStatistics_%1$s] = calculateRunStatistics(pool_%1$s, runSetReport_%1$s);';
        
        % assigns the statistics to the results of the function
        assignStatistics = 'runSetAggregatedStatistics = runSetAggregatedStatistics_%1$s; totalAggregatedPerRunStatistics = totalAggregatedPerRunStatistics_%1$s; totalAggregatedPerTopicStatistics = totalAggregatedPerTopicStatistics_%1$s; totalRunSetStatistics = totalRunSetStatistics_%1$s';
        
        % save RunSetAggregatedStatistics variable
        saveRunSetAggregatedStatistics = 'sersave(''%1$srunSetAggregatedStatistics_%2$s'', runSetAggregatedStatistics_%2$s);';
        
        % save RunSetAggregatedStatistics variable
        saveTotalAggregatedPerRunStatistics = 'sersave(''%1$stotalAggregatedPerRunStatistics_%2$s'', totalAggregatedPerRunStatistics_%2$s);';
        
        % save RunSetAggregatedStatistics variable
        saveTotalAggregatedPerTopicStatistics = 'sersave(''%1$stotalAggregatedPerTopicStatistics_%2$s'', totalAggregatedPerTopicStatistics_%2$s);';
        
        % save RunSetAggregatedStatistics variable
        saveTotalRunSetStatistics = 'sersave(''%1$stotalRunSetStatistics_%2$s'', totalRunSetStatistics_%2$s);';
        
    end;
    
    % parse the variable inputs
    pnames = {'CollectionIdentifier' 'OutputPath' 'ExperimentalCollectionsPath', 'DocumentOrdering'};
    dflts =  {[]                     []               []        []};
    [collectionIdentifier, outputPath, experimentalCollectionsPath, documentOrdering, supplied, otherArgs] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

     
    if supplied.CollectionIdentifier
        % check that identifier is a non-empty string
        validateattributes(collectionIdentifier, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'CollectionIdentifier');
    
         if iscell(collectionIdentifier)
            % check that identifier is a cell array of strings with one element
            assert(iscellstr(collectionIdentifier) && numel(collectionIdentifier) == 1, ...
                'MATTERS:IllegalArgument', 'Expected CollectionIdentifier to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        collectionIdentifier = char(strtrim(collectionIdentifier));
        collectionIdentifier = collectionIdentifier(:).';
        
         % check that the identifier is ok according to the matlab rules
        if ~isempty(regexp(collectionIdentifier, '(^[0-9_])?\W*', 'once'))
            error('MATTERS:IllegalArgument', 'Collection identifier %s is not valid: identifiers can contain only letters, numbers, and the underscore character and they must start with a letter.', ...
                collectionIdentifier);
        end      
    else
        error('MATTERS:MissingArgument', 'Parameter ''CollectionIdentifier'' not provided: the unique identifier of the pool is mandatory.');
    end;
        
    if supplied.OutputPath
        % check that path is a non-empty string
        validateattributes(outputPath, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'OutputPath');
        
        if iscell(outputPath)
            % check that path is a cell array of strings with one element
            assert(iscellstr(outputPath) && numel(outputPath) == 1, ...
                'MATTERS:IllegalArgument', 'Expected OutputPath to be a cell array of strings containing just one string.');
        end

        % remove useless white spaces, if any, and ensure it is a char row
        outputPath = char(strtrim(outputPath));
        outputPath = outputPath(:).';

        % check if the path is a directory and if it exists
        if ~(isdir(outputPath))
            warning('MATTERS:IllegalArgument', 'Expected OutputPath to be an existing directory.');
            % create the output directory 
            mkdir(outputPath);
        end;

        % check if the given directory path has the correct separator at the
        % end.
        if outputPath(end) ~= filesep;
           outputPath(end + 1) = filesep;
        end; 
    else
        error('MATTERS:MissingArgument', 'Parameter ''OutputPath'' not provided: the directory to which the collection has to be written is mandatory.');
    end;
    
   
    
    if supplied.ExperimentalCollectionsPath
        % check that path is a cell array
        validateattributes(experimentalCollectionsPath, {'cell'}, {'nonempty', 'vector'}, '', 'ExperimentalCollectionsPath');
        
        % check that path is a cell array of strings with one element
        assert(iscellstr(experimentalCollectionsPath), ...
            'MATTERS:IllegalArgument', 'Expected ExperimentalCollectionsPath to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a char row
        experimentalCollectionsPath = strtrim(experimentalCollectionsPath);
        experimentalCollectionsPath = experimentalCollectionsPath(:).';
        
        for k = 1:length(experimentalCollectionsPath)
             % check if the path is a directory and if it exists
            if ~(isdir(experimentalCollectionsPath{k}))
                error('MATTERS:IllegalArgument', 'Expected matlab dataset path %s to be a directory.', experimentalCollectionsPath{k});
            end;

            % check if the given directory path has the correct separator at the
            % end.
            if experimentalCollectionsPath{k}(end) ~= filesep;
               experimentalCollectionsPath{k}(end + 1) = filesep;
            end; 
        end;
        
    else
        error('MATTERS:MissingArgument', 'Parameter ''ExperimentalCollectionsPath'' not provided: the directories from which the matlab datasets have to be imported are mandatory.');
    end;

     if supplied.DocumentOrdering
        % check that documentOrdering is a non-empty string
        validateattributes(documentOrdering, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'DocumentOrdering');
        
        if iscell(documentOrdering)
            % check that documentOrdering is a cell array of strings with one element
            assert(iscellstr(documentOrdering) && numel(documentOrdering) == 1, ...
                'MATTERS:IllegalArgument', 'Expected DocumentOrdering to be a cell array of strings containing just one string.');
        end
               
        % check that documentOrdering assumes a valid value
        validatestring(documentOrdering,{'Original',  'TrecEval', 'TrecEval_Asc', 'Conservative', 'MATTERS'}, '', 'DocumentOrdering');                        
    end;
    % remove useless white spaces, if any, lower case, and ensure it is
    % a char row
    documentOrdering = lower(char(strtrim(documentOrdering)));
    documentOrdering = documentOrdering(:).';
    
    % start import
    begin = tic;
    
    fprintf('\n\n>>>>>>>> Importing pool and RunSetReport for collection %s <<<<<<<<\n\n', ...
        collectionIdentifier);

    fprintf('+ Settings\n');
    fprintf('  - imported on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - Matlab version: %s\n', version);
    fprintf('  - platform: %s\n', computer('arch'));
    fprintf('  - output path: %s\n', outputPath);
    fprintf('\n');    
    
    % serload conservative pool
    poolFile = [experimentalCollectionsPath collectionIdentifier filesep 'matlab' filesep 'datasets' filesep documentOrdering filesep 'pool_' collectionIdentifier '.mat'];
    runSetReportFile = [experimentalCollectionsPath collectionIdentifier filesep 'matlab' filesep 'datasets' filesep documentOrdering filesep 'runSetReport_' collectionIdentifier '.mat'];
    
    % import the pool
    start = tic;

    fprintf('+ Import %s ordering data \n', documentOrdering);
    
    fprintf('+ Importing pool: pool_%s from file: %s \n', collectionIdentifier, strcat(poolFile{:}));

    serload(strcat(poolFile{:}));
    
    fprintf('+ Importing run set report: runSetReport_%s from file: %s \n', collectionIdentifier, strcat(runSetReportFile{:}));
    
    serload(strcat(runSetReportFile{:}));
    
    eval(sprintf(calculateStatistics, collectionIdentifier)); 
    eval(sprintf(assignStatistics, collectionIdentifier)); 
   
    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
    
    % sersave the statistics 
    start = tic;
    fprintf('\n+ Saving run set aggregated statistics: runSetAggregatedStatistics_%s\n', collectionIdentifier);    
    
    eval(sprintf(saveRunSetAggregatedStatistics, collectionIdentifier)); 
    
    fprintf('\n+ Saving run set aggregated per run statistics: totalAggregatedPerRunStatistics_%s\n', collectionIdentifier);
    
    eval(sprintf(saveTotalAggregatedPerRunStatistics, collectionIdentifier)); 
    
    fprintf('\n+ Saving run set aggregated per topic statistics: totalAggregatedPerTopicStatistics_%s\n', collectionIdentifier);
    
    eval(sprintf(saveTotalAggregatedPerTopicStatistics, collectionIdentifier)); 
    
    fprintf('\n+ Saving run set total statistics: totalRunSetStatistics_%s\n', collectionIdentifier);
    
    eval(sprintf(saveTotalRunSetStatistics, collectionIdentifier)); 
    
    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

    % free space
    clear(['runSetAggregatedStatistics_' collectionIdentifier], ['totalAggregatedPerRunStatistics_' collectionIdentifier], ['totalAggregatedPerTopicStatistics_' collectionIdentifier], ['totalRunSetStatistics_' collectionIdentifier]);
    
  
    % re-enable warnings
    warning('on');
end

