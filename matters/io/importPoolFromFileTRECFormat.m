%% importPoolFromFileTRECFormat
% 
% Imports a pool from a text file in the standard TREC format.

%% Synopsis
%
%   [pool, report] = importPoolFromFileTRECFormat(Name, Value)
%  
% It assumes the file to be in the following format:
%
%  <topic-id> 0 <document-id> <relevance-grade>
% 
% where
%
% * fields are assumed to be separated by a space, if not differently
% specified;
% * |topic-id| - a string, specifying the identifier of a topic;
% * |0| - a constant unused field. It is discarded during the import;
% * |document-id| - a string, specifying the identifier of a document;
% * |relevance-grade| - a numeric value, specifying the degree of relevance 
% of document |document-id| for topic |topic-id|. 
%
% It performs the following sanity checks on the input file:
% 
% * it checks that all the assessed documents for a given topic are
% contiguous, i.e. there are not lines for topic |x|, then lines for topic
% |y|, and then again lines for topic |x| in the input file, otherwise a 
% warning is raised. In any case, all the lines for a given topic are 
% processed as if they were contiguous in the file;
% * it checks that, for a given topic, the same |document-id| is not 
% retrieved more than once, otherwise an error is raised.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|FileName|* (mandatory) - the path to the text file to be imported;
% * *|Identifier|* (mandatory) - the unique identifier of the pool. It must
% be compliant with MATLAB rules for 
% <http://www.mathworks.it/it/help/matlab/matlab_prog/variable-names.html 
% variable names>, otherwise an error is raised.
% * *|RelevanceGrades|* (mandatory) - a vector of numeric values which 
% correspond to the possible relevance grades used in the file. It must 
% contain increasing values where the lower the value the lower the 
% relevance degree.
% * *|RelevanceDegrees|* (mandatory) - a cell array of strings, each one 
% corresponding to one of the numeric relevance grades, defining the name 
% for that relevance grade. It must have the same number of elements as 
% |RelevanceGrades|.
% * *|RequiredTopics|* (optional) - a cell array of strings with the list 
% of topics required to be found in the text file to be imported. Topics 
% found in the import file and not present in |RequiredTopics| will be
% discared while, if any topic in |RequiredTopics| is not found in the
% import file, an error will be raised.
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
% * *|pool|*  - a table containing a row for each topic and a single column
% named as the |identifier| of the pool. The value contained in the column, 
% for each row, is a cell array of one element, wrapping a table with two 
% columns: |Document|, with the list of the identifiers of the assessed 
% documents; and, |RelevanceDegree| with the assessment for each document.
% The |UserData| property of the table contains a struct with two fields:
% |identifier| contains the unique identifier of the pool; |fileName|
% contains the name of the file from which the pool has been imported.
% * *|report|*  - a table containing a row for each topic and a single 
% column named |NotContiguousDocuments| containing the number of blocks of
% not contiguous documents for that topic. The |UserData| property of 
% the table contains a struct with the following fields: _|identifier|_ is
% the identifier of the pool; _|fileName|_ is the name
% of the import file; _|requiredTopics|_ is the list of required topics, if
% any; _|removedTopics|_ is the list of topics removed from the import file
% because not present in |requiredTopics|; _|swappedTopics|_ is a table
% containing the pairs of topics which were not in ascending 
% lexicographical order.

%% Example of use
% 
%   pool = importPoolFromFileTRECFormat('FileName', 'qrels.txt', 'Identifier', 'poolX', 'RelevanceGrades', 0:1, 'RelevanceDegrees', {'NotRelevant', 'Relevant'});
%
% It imports the file |qrels.txt| in the current directory. The file 
% contains binary relevance judgements, represented by the |0| and |1| 
% integer relevance grades and mapped to the |not_relevant| and |relevant| 
% relevance degrees.
%
%   topic351 = pool{'351', 'poolX'}{1, 1};
%
% It retrieves the ground truth for the topic with identifier |351|.
% Note that, since the sub-table containing the ground truth for topic
% |351| is wrapped by a cell array, you need to extract the subtable via 
% indexing the cell array |{1, 1}|.
%
%   topic351(1:5, :)
%
% It shows the first five assessed documents for the topic |351| and 
% produces the following output.
%
%  ans = 
%
%      Document       RelevanceDegree
%    _____________    _______________
%
%    'FBIS3-10411'    not_relevant   
%    'FBIS3-10433'    not_relevant   
%    'FBIS3-10464'    not_relevant   
%    'FBIS3-10551'    relevant       
%    'FBIS3-10646'    relevant     
 
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
function [pool, report] = importPoolFromFileTRECFormat(varargin)

    if verLessThan('matlab', '9.2.0')
        % parse the variable inputs
        pnames = {'Identifier' 'FileName' 'RelevanceGrades' 'RelevanceDegrees' 'RequiredTopics' 'Delimiter' 'Verbose'};
        dflts =  {[]           []         []                []                 []               'space'     false};
        [identifier, fileName, relevanceGrades, relevanceDegrees, requiredTopics, delimiter, verbose, supplied, otherArgs] ...
             = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        % parse the variable inputs
        pnames = {'Identifier' 'FileName' 'RelevanceGrades' 'RelevanceDegrees' 'RequiredTopics' 'Delimiter' 'Verbose'};
        dflts =  {[]           []         []                []                 []               'space'     false};
        [identifier, fileName, relevanceGrades, relevanceDegrees, requiredTopics, delimiter, verbose, supplied, otherArgs] ...
             = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end

        
    % check whether the parameters have been passed by the user (and then 
    % perform additional checks) or they are set to their default 

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
        error('MATTERS:MissingArgument', 'Parameter ''FileName'' not provided: the input file from which the pool has to be imported is mandatory.');
    end;
    
    if supplied.Identifier
        % check that identifier is a non-empty string
        validateattributes(identifier,{'char', 'cell'}, {'nonempty', 'vector'}, '', 'Identifier');
    
         if iscell(identifier)
            % check that identifier is a cell array of strings with one element
            assert(iscellstr(identifier) && numel(identifier) == 1, ...
                'MATTERS:IllegalArgument', 'Expected Identifier to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        identifier = char(strtrim(identifier));
        identifier = identifier(:).';
        
        % check that the identifier is ok according to the matlab rules
        if ~isempty(regexp(identifier, '(^[0-9_])?\W*', 'once'))
            error('MATTERS:IllegalArgument', 'Identifier %s is not valid: identifiers can contain only letters, numbers, and the underscore character and they must start with a letter.', ...
                identifier);
        end  
    else
        error('MATTERS:MissingArgument', 'Parameter ''Identifier'' not provided: the unique identifier of the pool is mandatory.');
    end;
        
    if supplied.RelevanceGrades
        % check that relevanceGrades is a non-empty numeric vector with
        % increasing values
        validateattributes(relevanceGrades,{'numeric'}, {'vector', 'nonempty', 'increasing'}, '', 'RelevanceGrades');
        
        % ensure it is a row vector
        relevanceGrades = relevanceGrades(:).';
    else
        error('MATTERS:MissingArgument', 'Parameter ''RelevanceGrades'' not provided: the relevance grades used the pool are mandatory.');
    end;
    
    if supplied.RelevanceDegrees
        % check that relevanceDegrees is a non-empty cell array with the same
        % number of elements as relevanceGrades
        validateattributes(relevanceDegrees,{'cell'}, {'vector', 'nonempty', 'numel', length(relevanceGrades)}, '', 'RelevanceDegrees');

        % check that relevanceDegrees is a cell array of strings
        assert(iscellstr(relevanceDegrees), 'MATTERS:IllegalArgument', 'Expected RelevanceDegrees to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a row
        % vector
        relevanceDegrees = strtrim(relevanceDegrees);
        relevanceDegrees = relevanceDegrees(:).';
        
        
         % check that the relavance degrees are ok according to the matlab 
         % rules for variable names
        if ~isempty(cell2mat(regexp(relevanceDegrees, '(^[0-9_])?\W*', 'once')))
            error('MATTERS:IllegalArgument', 'Relevance degree(s) %s are not valid: they can contain only letters, numbers, and the underscore character and they must start with a letter.', ...
                strjoin(relevanceDegrees, ', '));
        end 
    else
        error('MATTERS:MissingArgument', 'Parameter ''RelevanceDegrees'' not provided: the relevance degrees to which the relevance grades are mapped are mandatory.');
    end;
    
    if supplied.RequiredTopics && ~isempty(requiredTopics)
        % check that requiredTopics is a non-empty cell array 
        validateattributes(requiredTopics, {'cell'}, {'vector', 'nonempty'}, '', 'RequiredTopics');
        
        % check that requiredTopics is a cell array of strings
        assert(iscellstr(requiredTopics), 'MATTERS:IllegalArgument', 'Expected RequiredTopics to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a row
        % vector
        requiredTopics = strtrim(requiredTopics);
        requiredTopics = requiredTopics(:).';
    end;
    
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
        
        % remove useless white spaces, if any, lower case, and ensure it is
        % a char row
        delimiter = lower(char(strtrim(delimiter)));     
        delimiter = delimiter(:).';
    end;
    
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;   

    if(verbose)
        fprintf('\n\n----------\n');
        fprintf('Importing pool %s from file %s\n', identifier, fileName);       
        fprintf('  - delimiter: %s\n', delimiter);
    end;
    
    % read the table from the file
    inputFile = readtable(fileName, 'FileType', 'text', 'Delimiter', delimiter, 'ReadVariableNames', false, 'Format', '%s %s %s %f', 'MultipleDelimsAsOne', true);

    % remove the useless second column in the format (0)
    inputFile(:, 2) = [];

    % set the proper column names
    inputFile.Properties.VariableNames = {'Topic', 'Document', 'RelevanceDegree'};

    % transform from the relevance grades in numerical format into relevance
    % degrees as categories
    inputFile.RelevanceDegree = categorical(inputFile.RelevanceDegree, relevanceGrades, relevanceDegrees, 'Ordinal', true);

    % list of topics which may be removed
    removedTopics = [];
    % perform correspondence check with required topics, if asked
    if ~isempty(requiredTopics)
                
        % check whether there are required topics which are not in the run
        missingTopics = setdiff(requiredTopics, inputFile.Topic);
                
        if ~isempty(missingTopics)
            error('MATTERS:IllegalContent', 'Pool %s (%s) does not contain the following required topic(s): %s.', ...
                identifier, fileName, strjoin(missingTopics, ', '));
        end;
        
        % check whether there are topics in the run which are not required
        removedTopics = setdiff(inputFile.Topic, requiredTopics).';
        
        if ~isempty(removedTopics)
            warning('MATTERS:UnexpectedContent', 'Pool %s (%s) contains the following not required topic(s) which will be removed: %s.', ...
                identifier, fileName, strjoin(removedTopics, ', '));
            
            % remove the rows read from the file not corresponding to the
            % required topics
            inputFile(ismember(inputFile.Topic, removedTopics), :) = [];
        end;
    end;
        
    % extract the unique topics in the pool and sort them in ascending 
    % lexicographical order
    topics = unique(inputFile.Topic);
    
    %  extract the unique topics in the pool and preserve their appearance
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
        
        warning('MATTERS:UnexpectedContent', 'Pool %s (%s) contains %d topic(s) not sorted in ascending lexicographical order.', ...
            identifier, fileName, height(swappedTopics));
    end;

    % create a pool with as many rows as different topics in the file
    pool = cell2table(cell(length(topics), 1));
    pool.Properties.RowNames = topics;
    pool.Properties.VariableNames = {identifier};
    pool.Properties.UserData.identifier = identifier;
    pool.Properties.UserData.fileName = fileName;
    
    
    % create an empty structure for statistics about the pool    
    report = array2table(repmat(...
        cell2struct(num2cell(NaN(1, 1)), {'notContiguousDocumentBlocks'}), ...
            length(topics), 1));
    report.Properties.RowNames = topics;
    report.Properties.VariableNames = {identifier};
    report.Properties.UserData.identifier = identifier;
    report.Properties.UserData.fileName = fileName;
    report.Properties.UserData = setfield(report.Properties.UserData, 'swappedTopics', swappedTopics);
    report.Properties.UserData.removedTopics = removedTopics;
    
    if(verbose)
        fprintf('  - topics:\n');
    end;

        
    % iterate over each topic and assign the ground truth imported from the
    % file to the row in the pool table corresponding to that topic,
    % wrapping it into a cell array
    for k = 1:length(topics)
        
        if(verbose)
            fprintf('    + topic %s (%d out of %d)... ', topics{k}, k, length(topics));
        end;
        
        % the rows, i.e. assessed documents, for the current topic
        rows = ismember(inputFile.Topic, topics{k});
        
        % assume that are all contiguous and then check
        report{k, 1}.notContiguousDocumentBlocks = 0;
        
         % check whether all the assessed documents are contiguous
        % look where we find rows for the topics [find(rows == 1)] and whether
        % these rows are at a distance greated than 1 [diff(find(rows==1)) > 1]
        % from each other, which means that we have holes inbetween
        tmp = length(find(diff(find(rows==1)) > 1)) + 1;
        if tmp > 1
            warning('MATTERS:UnexpectedContent', 'Pool %s (%s) at topic %s contains %d blocks of not contiguous documents.', ...
                identifier, fileName, topics{k}, tmp);
            report{k, 1}.notContiguousDocumentBlocks = tmp;
        end;
        
        % extract the rows corresponding to the current topic
        topic = inputFile(rows, {'Document', 'RelevanceDegree'});
        
        % check whether there are duplicated documents
        [tmp, ia, ic] = unique(topic.Document);
        rows = histc(ic, 1:length(ia)) > 1;
        if any(rows)
            duplicated = tmp(rows);
            error('MATTERS:IllegalContent', 'Pool %s (%s) at topic %s contains the following duplicated document(s): %s.', ...
                identifier, fileName, topics{k}, strjoin(duplicated.', ', '));
        end;
        
        % check that no topic has an undefined relevance degree: this is
        % due to some relevance weight present in the pool but missing in
        % the parameters passed to import
        uu = isundefined(topic.RelevanceDegree);
        if any(uu)
            uu = topic{uu, 'Document'};
             error('MATTERS:IllegalContent', 'Pool %s (%s) at topic %s contains the following duplicated document(s) with improper relevance weight: %s.', ...
                identifier, fileName, topics{k}, strjoin(uu.', ', '));
        end

        
         % assign the ground truth for topic t to the corresponding row
         % in the pool table
        pool{k, 1} = {topic};
        
        if(verbose)
            fprintf('%d assessed document(s)\n', height(topic));
        end;
    end;
    
    if verbose
        fprintf('Import of pool %s completed.\n', identifier);
    end;

end

