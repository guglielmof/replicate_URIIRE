%% importAnSaveCollectionFromDirectoryTRECFormat
% 
% Imports a pool and runs from several directories in the standard TREC 
% format. It also sersaves them to specific .mat files

%% Synopsis
%
%   [pool, poolReport, runSet, runSetReport] = importCollectionFromDirectoryTRECFormat(Name, Value)
%  
% As far as runs are concerned, it assumes that the given directory 
% contains the runs to be imported as text files with extension |.txt|.
%
% It will create the following .mat files:
%
% * pool_<CollectionIdentifier>.mat: it contains the pool;
% * poolReport_<CollectionIdentifier>.mat: it contains the pool report;
% * runSet_<CollectionIdentifier>.mat: it contains the merged runs;
% * runSetReport_<CollectionIdentifier>.mat: it contains the report about
% the merged runs.
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
% * *|PoolFileName|* (mandatory) - the path to the pool text file to be 
% imported;
% * *|PoolDelimiter|* (optional) - a string specifying the delimiter used in 
% the pool text file to be imported. Possible values are: |comma|, |space|, 
% |tab|, |semi|, or |bar|. If not specified, then |space| is used as default. 
% See the documentation of 
% <http://www.mathworks.it/it/help/matlab/ref/readtable.html readtable> 
% for further information about allowed delimiters.
% * *|RequiredTopics|* (optional) - a cell array of strings with the list 
% of topics required to be found in the pool text file to be imported. 
% Topics  found in the import file and not present in |RequiredTopics| will
%  be discared while, if any topic in |RequiredTopics| is not found in the
% import file, an error will be raised.
% * *|RunSetPath|* (optional) - a cell array of strings containing the
% directories from which runs have to be imported.
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
% |importCollectionFromDirectoryTRECFormat| relies on
% |importPoolFromFileTRECFormat| and |importRunsFromDirectoryTRECFormat| to
% carry out the actual work. 
%
% Please refer to <importPoolFromFileTRECFormat.html
% importPoolFromFileTRECFormat> for specific Name-Value pairs for importing
% the pool and to <importRunsFromDirectoryTRECFormat.html
% importRunsFromDirectoryTRECFormat> for specific Name-Value pairs for
% importing the runs.
%
% *Returns*
%
% * |pool|  - the imported pool. See <importPoolFromFileTRECFormat.html 
% importPoolFromFileTRECFormat> for more  information.
% * |poolReport|  - the report on the imported pool. See 
% <importPoolFromFileTRECFormat.html importPoolFromFileTRECFormat> for more 
% information
% % * |runSet|  - the imported run set. See <importRunsFromDirectoryTRECFormat.html 
% importRunsFromDirectoryTRECFormat> for more  information.
% * |runSetReport|  - the report on the imported run set. See 
% <importRunsFromDirectoryTRECFormat.html importRunsFromDirectoryTRECFormat> for more 
% information
% 

%% Example of use
%  
%   [pool, poolReport, runSet, runSetReport] = importAndSaveCollectionFromDirectoryTRECFormat('CollectionIdentifier', 'TREC_03_1994_AdHoc', ...
%    'OutputPath', '/Users/ferro/Documents/progetti/software/matters/output', ...
%    'PoolFileName', '/Users/ferro/Documents/experimental-collections/TREC/TREC_03_1994_AdHoc/pool/qrels.151-200.disk1-3.txt', ...
%    'RelevanceDegrees', {'NotRelevant', 'Relevant'}, 'RelevanceGrades', [0:1], ...
%    'RunSetPath', {'/Users/ferro/Documents/experimental-collections/TREC/TREC_03_1994_AdHoc/runs/automatic', ...
%    '/Users/ferro/Documents/experimental-collections/TREC/TREC_03_1994_AdHoc/runs/interactive', ...
%    '/Users/ferro/Documents/experimental-collections/TREC/TREC_03_1994_AdHoc/runs/manual'}, ...
%    'DocumentOrdering', 'TrecEvalLexDesc', ...
%    'SinglePrecision', true, ...
%    'RunSetDelimiter', 'space');
%
% It imports a collection named |TREC_03_1994_AdHoc| consisting of the pool 
% |qrels.151-200.disk1-3.txt| and  all the 
% runs in the directories
% |/Users/ferro/Documents/experimental-collections/TREC/TREC_03_1994_AdHoc/runs/automatic|,
% |/Users/ferro/Documents/experimental-collections/TREC/TREC_03_1994_AdHoc/runs/interactive|,
% and
% |/Users/ferro/Documents/experimental-collections/TREC/TREC_03_1994_AdHoc/runs/manual|.
% 
% Note that the name-value pairs |RelevanceDegrees| and |RelevanceGrades|
% are mandatory for correctly importing the pool and their documentation
% can be found in <importPoolFromFileTRECFormat.html
% importPoolFromFileTRECFormat>. Similary, the name-value pairs
% |DocumentOrdering| and |SinglePrecision| control how the runs are
% imported and their documentation can be found in <importRunsFromDirectoryTRECFormat.html 
% importRunsFromDirectoryTRECFormat>.
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
function [pool, poolReport, runSet, runSetReport] = importAndSaveCollectionFromDirectoryTRECFormat(varargin)

    persistent importPool assignPool importRunSet assignRunSet savePool savePoolReport saveRunSet saveRunSetReport;
    
    if isempty(importPool)
        
        % imports the pool
        importPool = '[pool_%1$s, poolReport_%1$s] = importPoolFromFileTRECFormat(''FileName'', ''%2$s'', ''Identifier'', ''pool_%1$s'', ''RequiredTopics'', requiredTopics, ''Delimiter'', poolDelimiter, otherArgs{:});';
        
        % assigns the pool to the results of the function
        assignPool = 'pool = pool_%1$s; poolReport = poolReport_%1$s;';
        
        % imports the run set
        importRunSet = '[datasets{%1$d, 1}, datasets{%1$d, 2}] = importRunsFromDirectoryTRECFormat(''Path'', ''%2$s'', ''Identifier'', ''runSet_%3$s'', ''RequiredTopics'', pool.Properties.RowNames, ''Delimiter'', runSetDelimiter, ''DocumentOrdering'', documentOrdering, otherArgs{:});';
        
        % assigns the run set to the results of the function
        assignRunSet = 'runSet_%1$s = runSet; runSetReport_%1$s = runSetReport;';
        
        % save pool variable
        savePool = 'sersave(''%1$spool_%2$s'', pool_%2$s);';
        
        % save pool report variable
        savePoolReport = 'sersave(''%1$spoolReport_%2$s'', poolReport_%2$s);';
        
        % save run set variable
        saveRunSet = 'sersave(''%1$srunSet_%2$s'', runSet_%2$s);';
        
        % save run set report variable
        saveRunSetReport = 'sersave(''%1$srunSetReport_%2$s'', runSetReport_%2$s);';
        
    end;
    
    % disable warnings, not needed for bulk import
    warning('off');
     
    % parse the variable inputs
    pnames = {'CollectionIdentifier' 'OutputPath' 'PoolFileName' 'PoolDelimiter' 'RequiredTopics' 'RunSetPath' 'DocumentOrdering' 'RunSetDelimiter'};
    dflts =  {[]                     []           []             'space'         []               []           'TrecEvalLexDesc'  'tab'};
    [collectionIdentifier, outputPath, poolFileName, poolDelimiter, requiredTopics, runSetPath,  documentOrdering, runSetDelimiter, supplied, otherArgs] ...
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
        error('MATTERS:MissingArgument', 'Parameter ''CollectionIdentifier'' not provided: the unique identifier of the collection is mandatory.');
    end;
        
    if supplied.OutputPath
        % check that path is a non-empty string
        validateattributes(outputPath, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'OutputPath');
        
        if iscell(outputPath)
            % check that path is a cell array of strings with one element
            assert(iscellstr(outputPath) && numel(outputPathpath) == 1, ...
                'MATTERS:IllegalArgument', 'Expected OutputPath to be a cell array of strings containing just one string.');
        end

        % remove useless white spaces, if any, and ensure it is a char row
        outputPath = char(strtrim(outputPath));
        outputPath = outputPath(:).';

        % check if the path is a directory and if it exists
        if ~(isdir(outputPath))
            warning('MATTERS:IllegalArgument', 'Expected OutputPath to be a directory.');
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
    
    if supplied.PoolFileName
        % check that fileName is a non-empty string
        validateattributes(poolFileName, {'char', 'cell'}, {'nonempty'}, '', 'FileName');
    
        if iscell(poolFileName)
            % check that fileName is a cell array of strings with one element
            assert(iscellstr(poolFileName) && numel(poolFileName) == 1, ...
                'MATTERS:IllegalArgument', 'Expected PoolFileName to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        poolFileName = char(strtrim(poolFileName));
        poolFileName = poolFileName(:).';
    else
        error('MATTERS:MissingArgument', 'Parameter ''PoolFileName'' not provided: the input file from which the pool has to be imported is mandatory.');
    end;
    
    if supplied.RunSetPath
        % check that path is a cell array
        validateattributes(runSetPath, {'cell'}, {'nonempty', 'vector'}, '', 'RunSetPath');
        
        % check that path is a cell array of strings with one element
        assert(iscellstr(runSetPath), ...
            'MATTERS:IllegalArgument', 'Expected RunSetPath to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a char row
        runSetPath = strtrim(runSetPath);
        runSetPath = runSetPath(:).';
        
        for k = 1:length(runSetPath)
             % check if the path is a directory and if it exists
            if ~(isdir(runSetPath{k}))
                error('MATTERS:IllegalArgument', 'Expected run set path %s to be a directory.', runSetPath{k});
            end;

            % check if the given directory path has the correct separator at the
            % end.
            if runSetPath{k}(end) ~= filesep;
               runSetPath{k}(end + 1) = filesep;
            end; 
        end;
        
    else
        error('MATTERS:MissingArgument', 'Parameter ''RunSetPath'' not provided: the directories from which the run sets have to be imported are mandatory.');
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
        validatestring(documentOrdering,{'Original', 'TrecEvalLexDesc', 'TrecEvalLexAsc', 'Conservative', 'MATTERS'}, '', 'DocumentOrdering');                        
    end;
    % remove useless white spaces, if any, lower case, and ensure it is
    % a char row
    documentOrdering = lower(char(strtrim(documentOrdering)));
    documentOrdering = documentOrdering(:).';
    
    
    % start import
    begin = tic;
    
    fprintf('\n\n>>>>>>>> Importing collection %s with document ordering %s<<<<<<<<\n\n', ...
        collectionIdentifier, documentOrdering);

    fprintf('+ Settings\n');
    fprintf('  - imported on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - Matlab version: %s\n', version);
    fprintf('  - platform: %s\n', computer('arch'));
    fprintf('  - output path: %s\n', outputPath);
    fprintf('  - pool: %s\n', poolFileName);
    fprintf('  - pool delimiter: %s\n', poolDelimiter);
    fprintf('  - run set path(s):\n');    
    for k = 1:length(runSetPath)
        fprintf('    *  %s\n', runSetPath{k});
    end;
    fprintf('  - run set delimiter: %s\n', runSetDelimiter);
    fprintf('\n');    
    
    % import the pool
    start = tic;

    fprintf('+ Importing pool: pool_%s\n', collectionIdentifier);
    eval(sprintf(importPool, collectionIdentifier, poolFileName)); 
    eval(sprintf(assignPool, collectionIdentifier)); 

    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
    fprintf('  - total number of topics: %d\n', height(pool));

    % sersave the pool 
    start = tic;
    fprintf('\n+ Saving pool: pool_%s\n', collectionIdentifier);
    
    eval(sprintf(savePool, outputPath, collectionIdentifier));
    
    eval(sprintf(savePoolReport, outputPath, collectionIdentifier));
    
    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

    % free space
    clear(['pool_' collectionIdentifier], ['poolReport_' collectionIdentifier]);
    
    datasets = cell(length(runSetPath), 2);
   
    for k = 1:length(runSetPath)

        start = tic;
        fprintf('\n+ Importing run set: %s\n', runSetPath{k});
        
        eval(sprintf(importRunSet, k, runSetPath{k}, collectionIdentifier)); 

        fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
        fprintf('  - total number of runs: %d\n', width(datasets{k, 1}));

    end;
    
    start = tic;
    fprintf('\n+ Merging the imported run sets into run set: runSet_%s\n', collectionIdentifier);
    runSet = [];
    runSetReport = [];
    for k = 1:length(runSetPath)        
        runSet = [runSet datasets{k, 1}];
        runSetReport = [runSetReport datasets{k, 2}];        
    end;
    
    % assign the correct identifier at the run set
    runSet.Properties.UserData.identifier = sprintf('runSet_%s_%s', collectionIdentifier, documentOrdering);
    runSetReport.Properties.UserData.identifier = sprintf('runSet_%s_%s', collectionIdentifier, documentOrdering);

    % free space
    clear datasets;
    
    eval(sprintf(assignRunSet, collectionIdentifier)); 
    
    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
    fprintf('  - total number of runs: %d\n', width(runSet))
    
    % sersave the run set
    
    fprintf('\n+ Saving run set: runSet_%s\n', collectionIdentifier);
    
    start = tic;
    
    eval(sprintf(saveRunSet, outputPath, collectionIdentifier)); 
    
    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

    fprintf('\n+ Saving run set report: runSetReport_%s\n', collectionIdentifier);
    
    start = tic;
    
    eval(sprintf(saveRunSetReport, outputPath, collectionIdentifier)); 
    
    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                                                           
    fprintf('\n\n>>>>>>>> Total elapsed time for importing collection %s with document ordering %s: %s <<<<<<<<\n\n', ...
        collectionIdentifier, documentOrdering, elapsedToHourMinutesSeconds(toc(begin)));
    
    % re-enable warnings
    warning('on');
end

