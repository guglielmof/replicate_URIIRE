%% importRunFromFileTRECFormat
% 
% Imports a run from a text file in the standard TREC format.

%% Synopsis
%
%   [run, report] = importRunFromFileTRECFormat(Name, Value)
%  
% It assumes the file to be in the following format:
%
%  <topic-id> Q0 <document-id> <rank> <score> <run-id>
% 
% where
%
% * fields are assumed to be separated by a tab, if not differently
% specified;
% * |topic-id| - a string, specifying the identifier of a topic;
% * |Q0| - a constant unused field. It is discarded during the import;
% * |document-id| - a string, specifying the identifier of a document;
% * |rank| - an integer, specifying the rank of document |document-id| for
% topic |topic-id|. It is discarded during the import;
% * |score| - a numeric value, specifying the score of document 
% |document-id| for topic |topic-id|. The list of retrieved documents for
% each topic will be sorted in descending order by |score|.
% * |run-id| - a string, specifying the identifier of the run. It must
% always have the same value in all the rows of a file. It must
% be compliant with MATLAB rules for 
% <http://www.mathworks.it/it/help/matlab/matlab_prog/variable-names.html 
% variable names>; if not, it will be made compliant by removing not
% allowed characters and prefixing it with the string |matters_| to
% indicate the change.
%
% It performs the following sanity checks on the input file:
% 
% * it checks that the input file contains the same run identifier |run-id| 
% 
%  PREFORMATTED
%  TEXT
% 
% on every input line, otherwise an error is raised.
% * when |expectedTopics| is used and it is not empty, it checks that no 
% topic listed in |expectedTopics| is missing, otherwise an error is 
% raised. If the input file contains topics that are not listed in 
% |expectedTopics|, a warning is raised and these topics are discarded from
% the subsequent processing;
% * it checks that all the retrieved documents for a given topic are
% contiguous, i.e. there are not lines for topic |x|, then lines for topic
% |y|, and then again lines for topic |x| in the input file, otherwise a 
% warning is raised. In any case, all the lines for a given topic are 
% processed as if they were contiguous in the file;
% * it checks that, for a given topic, the same |document-id| is not 
% retrieved more than once, otherwise an error is raised;
% * it checks that, for a given topic, documents are sorted in descending
% order of |score| and ascending order of |rank|, otherwise a warning is 
% raised. See the documentation of the |DocumentOrdering| parameter for a
% detailed discussion on the options for dealing with the ordering of
% documents.
%
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|FileName|* (mandatory) - the path to the text file to be imported;
% * *|RequiredTopics|* (optional) - a cell array of strings with the list 
% of topics required to be found in the text file to be imported. Topics 
% found in the import file and not present in |RequiredTopics| will be
% discared while, if any topic in |RequiredTopics| is not found in the
% import file, an error will be raised.
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
% * *|SinglePrecision|* (optional) - a boolean value specifying if the scores 
% of the run has to be casted to single precison (float) or not. The default 
% value is true to mimic the |trec_eval| behaviour.
% * *|Delimiter|* (optional) - a string specifying the delimiter used in 
% the text file to be imported. Possible values are: |comma|, |space|, 
% |tab|, |semi|, or |bar|. If not specified, then |tab| is used as default. 
% See the documentation of 
% <http://www.mathworks.it/it/help/matlab/ref/readtable.html readtable> 
% for further information about allowed delimiters.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default. 
%
%
% *Returns*
%
% * *|run|*  - a table containing a row for each topic and a single column
% named |run-id|. The value contained in the column, for each row, is
% a cell array of one element, wrapping a table three columns: 
% |Document|, with the list  of the identifiers of the retrieved documents; 
% |Rank| with the score for each document; and, |Score| with the score for 
% each document. The |UserData| property of  the table contains a struct 
% with the following fields: _|identifier|_ is the identifier of the run 
% from the import file; _|fileName|_ is the name of the import file.
% * *|report|* - a table containing a row for each topic and a single column
% named |run-id|. The value contained in the column, for each row, is
% a struct with the following fields: _|notContiguousDocumentBlocks|_ is
% the number of blocks of not contiguous documents in the import file;
% _|swappedDocuments|_ is the total number of documents swapped as effect of 
% the |DocumentOrdering| parameter; _|swappedDocumentsTable|_ is a table 
% containing the details of each swapped document pair; _|sameRankDocument|_ 
% is the total number of document which have the same rank in the import 
% file; _|sameRankDocumentsList|_ is the list of the identifiers of the 
% documents with the same rank; _|sortedByScoreDescending|_ is boolean
% indicating whether the documents in the import file were sorted in
% desceding order of score or not; _|sortedByRankAscending|_ is boolean
% indicating whether the documents in the import file were sorted in
% ascending order of rank or not. The |UserData| property of 
% the table contains a struct with the following fields: _|identifier|_ is
% the identifier of the run from the import file; _|fileName|_ is the name
% of the import file; _|requiredTopics|_ is the list of required topics, if
% any; _|removedTopics|_ is the list of topics removed from the import file
% because not present in |requiredTopics|; _|swappedTopics|_ is a table
% containing the pairs of topics which were not in ascending 
% lexicographical order.
% 

%% Example of use
%
%   run = importRunFromFileTRECFormat('FileName', 'run.txt');
%
% It imports the file |run.txt| in the current directory. The run 
% identifier contained in the file is |runxyz|.
%
%   topic351 = run{'351', 'runxyz'}{1, 1};
%
% It retrieves the retrieved documents for the topic with identifier |351|.
% Note that, since the sub-table containing the retrieved documents for 
% topic |351| is wrapped by a cell array, you need to extract the subtable 
% via indexing the cell array |{1, 1}|. 
%
%   topic351(1:5, :)
%
% It shows the first five retrieved documents for the topic |351| and 
% produces the following output.
% 
%  ans = 
%
%      Document      Rank       Score
%    _____________   ______     _____
%
%    'FT932-16710'      1       15.73
%    'FT944-15849'      2       15.73
%    'FT931-10913'      3       12.48
%    'FT934-4848'       4       11.48
%    'FT941-13429'      5       11.25
 
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
function [run, report] = importRunFromFileTRECFormat(varargin)


    if verLessThan('matlab', '9.2.0')
        % parse the variable inputs
        pnames = {'FileName' 'RequiredTopics' 'DocumentOrdering' 'SinglePrecision' 'Delimiter' 'Verbose'};
        dflts =  {[]         []               'TrecEvalLexDesc'   true             'tab'       false};
        [fileName, requiredTopics, documentOrdering, singlePrecision, delimiter, verbose, supplied, otherArgs] ...
             = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        % parse the variable inputs
        pnames = {'FileName' 'RequiredTopics' 'DocumentOrdering' 'SinglePrecision' 'Delimiter' 'Verbose'};
        dflts =  {[]         []               'TrecEvalLexDesc'   true             'tab'       false};
        [fileName, requiredTopics, documentOrdering, singlePrecision, delimiter, verbose, supplied, otherArgs] ...
             = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end

    
   if supplied.FileName
        % check that fileName is a non-empty string
        validateattributes(fileName, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'FileName');
    
        if iscell(fileName)
            % check that fileName is a cell array of strings with one element
            assert(iscellstr(fileName) && numel(fileName) == 1, ...
                'MATTERS:IllegalArgument', 'Expected FileName to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        fileName = char(strtrim(fileName));
        fileName = fileName(:).';
    else
        error('MATTERS:MissingArgument', 'Parameter ''FileName'' not provided: the input file from which the run has to be imported is mandatory.');
    end;
    
    if supplied.RequiredTopics
        % check that requiredTopics is a non-empty cell array 
        validateattributes(requiredTopics, {'cell'}, {'vector', 'nonempty'}, '', 'RequiredTopics');
        
        % check that requiredTopics is a cell array of strings
        assert(iscellstr(requiredTopics), 'MATTERS:IllegalArgument', 'Expected RequiredTopics to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a row
        % vector
        requiredTopics = strtrim(requiredTopics);
        requiredTopics = requiredTopics(:).';
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

    if supplied.Delimiter
        % check that delimiter is a non-empty string
        validateattributes(delimiter,{'char', 'cell'}, {'nonempty', 'vector'}, '', 'Delimiter');
        
        if iscell(delimiter)
            % check that documentOrdering is a cell array of strings with one element
            assert(iscellstr(delimiter) && numel(delimiter) == 1, ...
                'MATTERS:IllegalArgument', 'Expected Delimiter to be a cell array of strings containing just one string.');
        end
        
        % check that delimiter assumes a valid value
        validatestring(delimiter,{'comma', 'space', 'tab', 'semi', 'bar'}, '', 'Delimiter');        
    end;
    % remove useless white spaces, if any, lower case, and ensure it is
    % a char row
    delimiter = lower(char(strtrim(delimiter)));     
    delimiter = delimiter(:).';
    
    
    if supplied.SinglePrecision
        % check that SinglePrecision is a non-empty scalar logical value
        validateattributes(singlePrecision, {'logical'}, {'nonempty','scalar'}, '', 'SinglePrecision');
    end;
    
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;   
    
    if(verbose)
        fprintf('\n\n----------\n');
        
        fprintf('Importing run from file %s\n', fileName);
        fprintf('  - delimiter: %s\n', delimiter);
        
        if supplied.RequiredTopics
            fprintf('  - expected topics: %s\n', strjoin(requiredTopics, ', '));
        end;
        
        fprintf('  - document ordering: %s\n', documentOrdering);
        
        if ~isempty(singlePrecision)
            fprintf('  - cast to float (single)');
        else
            fprintf('  - using maximum MATLAB precision;\n');
        end
    end;
    
    % read the table from the file
    inputFile = readtable(fileName, 'FileType', 'text', 'Delimiter', delimiter, ...
        'ReadVariableNames', false, 'Format', '%s %s %s %f %f %s', 'MultipleDelimsAsOne', true);

    % extract the run identifiers and ensure they are a row vector
    runID = unique(inputFile{:, 6});
    runID = runID(:).';
    
    % there is more than one run identifier in the file
    if numel(runID) > 1
        error('MATTERS:IllegalContent', 'Input file %s contains more than one run identifier: %s.', ...
            fileName, strjoin(runID, ', '));
    end;
    
    % transform into a char string and ensure it is a row vector
    runID = char(runID);
    runID = runID(:).';
    
    % check that the identifier is ok according to the matlab rules
    if ~isempty(regexp(runID, '(^[0-9_])?\W*', 'once'))
                
        %try to make it compliant with MATLAB rules
        tmp = ['matters_' regexprep(runID, '\W', '')];
        
        warning('MATTERS:UnexpectedContent', 'Run identifier %s (%s) changed to %s to make it compliant with MATLAB rules for identifiers.', ...
                runID, fileName, tmp);
       
       % substitute the identifier of the run with a new one
       runID = tmp;
    end
    
    if(verbose)
        fprintf('  - run identifier: %s\n', runID);
    end;
    
    % remove the useless second column in the format (Q0)
    inputFile(:, 2) = [];
    
    % remove the useless sixth column in the format (run-id) [now at
    % position 5]
    inputFile(:, 5) = [];
        
    % set the proper column names
    inputFile.Properties.VariableNames = {'Topic', 'Document', 'Rank', 'Score'};
    
    
    % list of topics which may be removed
    removedTopics = [];
    % perform correspondence check with required topics, if asked
    if supplied.RequiredTopics
                
        % check whether there are required topics which are not in the run
        missingTopics = setdiff(requiredTopics, inputFile.Topic);
                
        if ~isempty(missingTopics)
            error('MATTERS:IllegalContent', 'Run %s (%s) does not contain the following required topic(s): %s.', ...
                runID, fileName, strjoin(missingTopics, ', '));
        end;
        
        % check whether there are topics in the run which are not required
        removedTopics = setdiff(inputFile.Topic, requiredTopics).';
        
        if ~isempty(removedTopics)
            warning('MATTERS:UnexpectedContent', 'Run %s (%s) contains the following not required topic(s) which will be removed: %s.', ...
                runID, fileName, strjoin(removedTopics, ', '));
            
            % remove the rows read from the file not corresponding to the
            % required topics
            inputFile(ismember(inputFile.Topic, removedTopics), :) = [];
        end;
    end;
    
    % extract the unique topics in the run and sort them in ascending 
    % lexicographical order
    topics = unique(inputFile.Topic);
    
    %  extract the unique topics in the run and preserve their appearance
    %  order in the file
    tmp = unique(inputFile.Topic, 'stable');
    
    % check whether the topics are in ascending lexicographical order
    swappedTopics = [];
    if ~isequal(topics, tmp)
        
        % find the positions (loc) of the original topics with respect to 
        % the sorted ones
        [~, loc] = ismember(topics, tmp);
        
        % find where the positions of the original topics (loc) deviate 
        % from the positions of the sorted ones (1:length(loc)). 
        rows = [1:length(loc)].' - loc ~= 0;
        
        % each row is a swap, first column indicates the topic swapped with
        % the one in the second column
        swappedTopics = table(tmp(rows), topics(rows));
        swappedTopics.Properties.VariableNames = {'Original'; 'Actual'};
        
        warning('MATTERS:UnexpectedContent', 'Run %s (%s) contains %d topic(s) not sorted in ascending lexicographical order.', ...
            runID, fileName, height(swappedTopics));
    end;
    
    % create a run with as many rows as different topics in the file
    run = cell2table(cell(length(topics), 1));
    run.Properties.RowNames = topics;
    run.Properties.VariableNames = {runID};
    run.Properties.UserData.identifier = runID;
    run.Properties.UserData.fileName = fileName;
    
    
    % create an empty structure for statistics about the run    
    report = array2table(repmat(...
        cell2struct(num2cell(NaN(8, 1)), ...
            {'notContiguousDocumentBlocks'; 'documentOrdering'; ...
            'swappedDocuments'; 'swappedDocumentsTable'; ...
            'sameRankDocuments'; 'sameRankDocumentsList'; 'sortedByScoreDescending'; ...
            'sortedByRankAscending'}), length(topics), 1));
    report.Properties.RowNames = topics;
    report.Properties.VariableNames = {runID};
    report.Properties.UserData.identifier = runID;
    report.Properties.UserData.fileName = fileName;
    report.Properties.UserData.requiredTopics = requiredTopics;    
    report.Properties.UserData.removedTopics = removedTopics;
    report.Properties.UserData = setfield(report.Properties.UserData, 'swappedTopics', swappedTopics);
    
    if(verbose)
        fprintf('  - topics:\n');
    end;

    % iterate over each topic and assign the result list imported from the
    % file to the row in the run table corresponding to that topic,
    % wrapping it into a cell array
    for k = 1:length(topics)
        
        if(verbose)
            fprintf('    + topic %s (%d out of %d)... ', topics{k}, k, length(topics));
        end;
                
        % the rows, i.e. retrieved documents, for the current topic
        rows = ismember(inputFile.Topic, topics{k});
        
        % assume that are all contiguous and then check
        report{k, 1}.notContiguousDocumentBlocks = 0;
                
        % check whether all the retrieved documents are contiguous
        % look where we find rows for the topics [find(rows == 1)] and whether
        % these rows are at a distance greated thar 1 [diff(find(rows==1)) > 1]
        % from each other, which means that we have holes inbetween
        tmp = length(find(diff(find(rows==1)) > 1)) + 1;
        if tmp > 1
            warning('MATTERS:UnexpectedContent', 'Run %s (%s) at topic %s contains %d blocks of not contiguous documents.', ...
                runID, fileName, topics{k}, tmp);
            report{k, 1}.notContiguousDocumentBlocks = tmp;
        end;
                        
        % extract the rows corresponding to the current topic
        topic = inputFile(rows, {'Document', 'Rank', 'Score'});
        
        % cast to float
        if (singlePrecision)
            topic.Score = single(topic.Score);
        end
        
        % check whether there are duplicated documents
        [tmp, ia, ic] = unique(topic.Document);
        rows = histc(ic, 1:length(ia)) > 1;
        if any(rows)
            duplicated = tmp{rows,1};
            
            % it may be a char array when only one duplicated exist
            if ~iscell(duplicated)
                duplicated = cellstr(duplicated);
            end;
            
            % ensure it is a row vector
            duplicated = duplicated(:).';
            
            error('MATTERS:IllegalContent', 'Run %s (%s) at topic %s contains the following duplicated document(s): %s.', ...
                runID, fileName, topics{k}, strjoin(duplicated, ', '));
        end;
                
        % check whether the retrieved documents are sorted in descending
        % order of score. NB isSorted checks for ascending ordering so we
        % take the vector from bottom to top
        report{k, 1}.sortedByScoreDescending = issorted(topic{end:-1:1, 'Score'});        
        if ~report{k, 1}.sortedByScoreDescending
             warning('MATTERS:UnexpectedContent', 'Run %s (%s) at topic %s contains documents not sorted by descending order of score.', ...
                runID, fileName, topics{k});
        end;
        
        report{k, 1}.sortedByRankAscending = issorted(topic{:, 'Rank'});
        if ~report{k, 1}.sortedByRankAscending
             warning('MATTERS:UnexpectedContent', 'Run %s (%s) at topic %s contains documents not sorted by ascending order of rank.', ...
                runID, fileName, topics{k});
        end;
        
        
        % assume the ordering of the documents is correct and then check
        report{k, 1}.swappedDocuments = 0;
        report{k, 1} = setfield(report{k, 1}, 'swappedDocumentsTable', table());
        report{k, 1}.sameRankDocuments = 0;
        report{k, 1}.sameRankDocumentsList = [];
        report{k, 1}.documentOrdering = documentOrdering;
        
         % check whether there are duplicated rank values
        [rank, ia, ic] = unique(topic.Rank);
        rows = histc(ic, 1:length(ia)) > 1;

        % vector of the duplicated ranks
        rank = rank(rows);                

        % find the rows in the original topic where documents are
        % retrieved with the same rank
        rows = ismember(topic.Rank, rank);
        if any(rows)
            duplicated = topic{rows,1};
            warning('MATTERS:UnexpectedContent', 'Run %s (%s) at topic %s contains the following document(s) with the same rank: %s.', ...
                runID, fileName, topics{k}, strjoin(duplicated.', ', '));
            
            report{k, 1}.sameRankDocuments = length(duplicated);
            report{k, 1}.sameRankDocumentsList = duplicated;
        end;
        
        % order the documents according to the user request
        switch documentOrdering
            case 'original'
                tmp = topic;
                
            case 'trecevallexdesc'
                tmp = sortrows(topic, {'Score', 'Document'}, {'descend', 'descend'});
                
            case 'trecevallexasc'
                tmp = sortrows(topic, {'Score', 'Document'}, {'descend', 'ascend'});
                
            case 'matters'
                tmp = sortrows(topic, {'Score', 'Rank', 'Document'}, {'descend', 'ascend', 'ascend'});
                
                if report{k, 1}.sameRankDocuments > 0
                    warning('MATTERS:UnexpectedContent', 'Run %s (%s) at topic %s contains the documents with the same rank. As a consequence, for these documents, ordering by score descending, rank ascending, and document identifier ascending (MATTERS style) will behave like ordering by score descending and document idenfier ascending (trec_eval syle).', ...
                        runID, fileName, topics{k});
                end;
                
            case 'conservative'
                tmp = sortrows(topic, {'Score'}, {'descend'});
                
                % check whether there are duplicated score values
                [score, ia, ic] = unique(tmp.Score);
                rows = histc(ic, 1:length(ia)) > 1;
                
                % vector of the duplicated scores
                score = score(rows);                
                
                % find the rows in the original topic where documents are
                % retrieved with the same score
                rows = ismember(topic.Score, score);
                
                % find the rows in the ordered topic where documents are
                % retrieved with the same score. These may be a permutation
                % of rows2
                rows2 = ismember(tmp.Score, score);
                
                assert(isequal(sort(rows), sort(rows2)), ...
                    'MATTERS:IllegalState', 'Violation of conservative ordering assumptions.');
                
                % substitute the rows with the same score in the ordered
                % with those in the orginal one so that we can mantain the
                % same ordering as in the original one, still having the
                % whole topic ordered
                tmp(rows2, :) = topic(rows, :);
                
            otherwise
                error('MATTERS:IllegalState', 'Unknown document ordering %s.', documentOrdering);
        end;    
        
        % check whether retrieved documents are properly ordered       
        if ~isequal(topic, tmp)
                       
            % find the positions (loc) of the original documents with respect to 
            % the sorted ones
            [~, loc] = ismember(topic, tmp);

            % find where the positions of the original document (loc) from the
            % positions of the sorted ones (1:length(loc)). A negative value
            % indicate that a document that should have come first has been moved
            % lower in the ranking and thus it was swapped
            misplacement = [1:length(loc)].' - loc;
            
            rows = misplacement ~= 0;
            
            swappedDocuments = table(cell(height(topic), 1), cell(height(topic), 1), misplacement);
            
            % each row is a swap, first column indicates the document swapped with
            % the one in the second column
            swappedDocuments{rows, 1} = topic{rows, 'Document'};
            swappedDocuments{rows, 2} = tmp{rows, 'Document'};
            swappedDocuments.Properties.VariableNames = {'Original'; 'Actual'; 'Misplacement'};

            report{k, 1}.swappedDocuments = sum(rows);
            report{k, 1} = setfield(report{k, 1}, 'swappedDocumentsTable', swappedDocuments);

            % use the sorted version from now on
            topic = tmp;
            
            switch documentOrdering
                case 'trecevallexdesc'
                    sorting = 'score descending and document identifier descending (trec_eval style)';
                    
                case 'trecevallexasc'
                    sorting = 'score descending and document identifier ascending (variation of trec_eval style)';

                case 'matters'
                    sorting = 'score descending, rank ascending, and document identifier ascending (MATTERS style)';
                    
                case 'conservative'
                    sorting = 'score descending (conservative style)';
                    
                case 'original'
                    sorting = 'original ordering (THIS SHOULD NOT HAPPEN)';
                    
                    fprintf('\n\n Run %s (%s) at topic %s contains %d retrieved document(s) not sorted by %s.\n\n', ...
                      runID, fileName, topics{k}, height(swappedDocuments), sorting);
                  
                    warning('MATTERS:IllegalState', '\n\n Run %s (%s) at topic %s contains %d retrieved document(s) not sorted by %s.\n\n', ...
                      runID, fileName, topics{k}, height(swappedDocuments), sorting);
                  
                otherwise
                    error('MATTERS:IllegalState', 'Unknown document ordering %s.', documentOrdering);
            end;    
                       
            warning('MATTERS:UnexpectedContent', 'Run %s (%s) at topic %s contains %d retrieved document(s) not sorted by %s.', ...
                runID, fileName, topics{k}, height(swappedDocuments), sorting);
            
        end;
                                         
        % assign the ranked result list to the row in the run table
        % corresponding to topic t, sorted in descending order of score
        run{k, 1} = {topic};
        
        if(verbose)
            fprintf('%d retrieved document(s)\n', height(topic));
        end;
    end;
    
    if verbose
        fprintf('Import of run %s completed.\n', runID);
    end;

end

