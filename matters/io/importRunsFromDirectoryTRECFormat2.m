%% importRunsFromDirectoryTRECFormat
% 
% Imports the runs in the given directory, where each run is a text file
% with extension |.txt| in the standard TREC format.

%% Synopsis
%
%   [runSet, report] = importRunsFromDirectoryTRECFormat(Name, Value)
%  
% It assumes that the given directory contains the runs to be imported as 
% text files named as follows:  
%
%  <runName>.txt
% 
% where:
%
% * |runName| is the name of the run to be imported.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|Path|* (mandatory) - a string specifying the path to the directory 
% containing the run text files to be imported. 
% * *|Identifier|* (mandatory) - the unique identifier of the pool. It must
% be compliant with MATLAB rules for 
% <http://www.mathworks.it/it/help/matlab/matlab_prog/variable-names.html 
% variable names>, otherwise an error is raised.
% * *|RequiredTopics|* (optional) - a cell array of strings with the list 
% of topics required to be found in the text file to be imported. Topics 
% found in the import file and not present in |RequiredTopics| will be
% discared while, if any topic in |RequiredTopics| is not found in the
% import file, an error will be raised.
% * *|DocumentOrdering|* (optional) - a string specifying how to sort
% documents when reading them from the import file. It can assume the
% following values: _|Original|_, i.e. keep the documents in the same 
% order as in the import file; _|TrecEval|_, i.e. sort document by 
% descending order of |score| and ascending lexicographical order of 
% |document-id|; _|Matters|_, i.e. sort documents by descending order of
% |score|, ascending order of |rank|, and ascending lexicographical order 
% of |document-id|; _|Conservative|_, i.e. sort documents by descending 
% order of |score| and, for the documents with the same |score| keep the 
% same ordering used in the import file. If not specified, |TrecEval| is
% used as default.
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
% * *|runSet|*  - a table containing a row for each topic and a column for each
% run named with the identifier of the run as deduced from the run text file. 
% The value contained in the column, for each row, is a cell array of one 
% element, wrapping a table with three columns: |Document|, with the list 
% of the identifiers of the retrieved documents; |Rank| with the score for
% each document; and, |Score| with the score for each document. The 
% |UserData| property of  the table contains a struct  with the following 
% fields: _|identifier|_ is the identifier of the run set; _|path|_ is the 
% path from with the runs have been imported; as many _|runID|_ as the
% column in the table are, containing a sub-structure with the same
% information contained in |run.UserData| as explained in
% <importRunFromFileTRECFormat.html importRunFromFileTRECFormat>.
% * *|report|* -  table containing a row for each topic and a column for each
% run named with the identifier of the run as deduced from the run text file. 
%  The value contained in the column, for each row, is
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
% ascending order of rank or not. The 
% |UserData| property of  the table contains a struct  with the following 
% fields: _|identifier|_ is the identifier of the run set; _|path|_ is the 
% path from with the runs have been imported; as many _|runID|_ as the
% column in the table are, containing a sub-structure with the same
% information contained in |run.UserData| as explained in
% <importRunFromFileTRECFormat.html importRunFromFileTRECFormat>.

%% Example of use
%  
%   runSet = importRunsFromDirectoryTRECFormat('Path', '/campaign/collection_1/runs/', 'Identifier', 'coll1');
%
% It imports all the runs in the directory |/campaign/collection_1/runs/|.
% The directory contains the  following text files:
% 
% * |APL985LC.txt|
% * |AntHoc01.txt|
% * |acsys7al.txt|
%
% In this example each run has two topics, |351| and |352|. It returns the 
% following table.
%
%              APL985LC          AntHoc01          acsys7al   
%           ______________    ______________    ______________
%
%    351    [1000x2 table]    [1000x2 table]    [1000x2 table]
%    352    [1000x2 table]    [1000x2 table]    [1000x2 table]
%
% Column names are run identifiers, row names are topic identifiers.
% 
%   APL985LC_351 = runs{'351','APL985LC'}{1, 1};
%
% It returns the table containing the documents and their scores for topic
% |351| and run |APL985LC|.
%
%   APL985LC_351(1:5,1)
% 
% It returns the first five documents retrieved by |APL985LC| for the topic
% |351|.
%
%     Document   
%    _____________
%
%    'FT921-8458' 
%    'FT921-8241' 
%    'FT922-15099'
%    'FT921-2097' 
%    'FT923-11890'
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
function [runSet, report] = importRunsFromDirectoryTRECFormat(varargin)
    
    % parse the variable inputs
    pnames = {'Path',  'Identifier', 'Verbose'};
    dflts =  {[]       []            false};
    [path, identifier, verbose, supplied, otherArgs] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

    if supplied.Path
        % check that path is a non-empty string
        validateattributes(path, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'Path');
        
        if iscell(path)
            % check that path is a cell array of strings with one element
            assert(iscellstr(path) && numel(path) == 1, ...
                'MATTERS:IllegalArgument', 'Expected Path to be a cell array of strings containing just one string.');
        end

        % remove useless white spaces, if any, and ensure it is a char row
        path = char(strtrim(path));
        path = path(:).';

        % check if the path is a directory and if it exists
        if ~(isdir(path))
            error('MATTERS:IllegalArgument', 'Expected Path to be a directory.');
        end;

        % check if the given directory path has the correct separator at the
        % end.
        if path(end) ~= filesep;
           path(end + 1) = filesep;
        end; 
    else
        error('MATTERS:MissingArgument', 'Parameter ''Path'' not provided: the directory from which the runs have to be imported is mandatory.');
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
        error('MATTERS:MissingArgument', 'Parameter ''Identifier'' not provided: the unique identifier of the run set is mandatory.');
    end;
    
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty', 'scalar'}, '', 'Verbose');
    end; 
    
    % return the list of text files in the directory. It ignores non-text
    % files.
    files = dir([path '*.txt']);
    n = length(files);
    
    % extract an horizontal cell array of file names
    [runFiles{1:n}] = deal(files.name);
    
    % concatenate the file names with the directory
    runFiles = strcat(repmat(path, n, 1), runFiles.');
    
     if(verbose)
        fprintf('\n\n----------\n');
        
        fprintf('Importing runs directory %s, %d file(s) to be imported\n', path, n);
        fprintf('  - run set identifier: %s\n', identifier);
    end;
    
    %create an empty run set table
    runSet = table();
    
    %create an empty report table
    report = table();
    
    % apply importRunFromTRECFile to each run file and concatenate the
    % result with the runs table.
    %
    % NB dynamically growing the table seems to be outperforming even
    % pre-allocation; it may need to be re-checked in the future
    for f = 1:n
        
        [run, runReport] = importRunFromFileTRECFormat('FileName', runFiles{f}, 'Verbose', verbose, otherArgs{:});
        
        run.Properties.RowNames = {'cluster'};
        runReport.Properties.RowNames = {'cluster'};
        
        
        runSet = [runSet run];
        report = [report runReport];
        
        % copy the data about the run into the run set and report properties
        runSet.Properties.UserData.runs.(run.Properties.UserData.identifier) = run.Properties.UserData;
        report.Properties.UserData.runs.(runReport.Properties.UserData.identifier) = runReport.Properties.UserData;        
    end;  
    
    % set the correct properties
    runSet.Properties.UserData.identifier = identifier;
    runSet.Properties.UserData.path = path;
    
    % remove a wrong field caused by adding columns to an initially empty
    % table
    runSet.Properties.UserData = rmfield(runSet.Properties.UserData, 'fileName');
    
    report.Properties.UserData.identifier = identifier;
    report.Properties.UserData.path = path;

    % remove a wrong field caused by adding columns to an initially empty
    % table
    report.Properties.UserData = rmfield(report.Properties.UserData, 'fileName');

    
    
    if verbose
        fprintf('Import of directory %s completed.\n', path);
    end;
end

