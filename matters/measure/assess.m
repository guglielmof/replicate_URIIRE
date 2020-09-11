%% assess
% 
% Assesses the given run(s) with respect to the given pool.

%% Synopsis
%
%   [assessedRunSet, poolStats, runSetStats, inputParams] = assess(pool, runSet, varargin)
%  
% *Parameters*
%
% * *|pool|* - the pool to be used to assess the run(s). It is a table in the
% same format returned by <../io/importPoolFromFileTRECFormat.html 
% importPoolFromFileTRECFormat>;
% * *|runSet|* - the run(s) to be assessed. It is a table in the same format
% returned by <../io/importRunFromFileTRECFormat.html 
% importRunFromFileTRECFormat> or by <../io/importRunsFromDirectoryTRECFormat.html 
% importRunsFromDirectoryTRECFormat>;
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|NotAssessed|* (optional) - a string indicating how not assessed
% documents, i.e. those in the run but not in the pool, have to be
% processed: |NotRevelant|, the minimum of the relevance degrees of the 
% pool is used as |NotRelevant|; |Undefined|, the categorical
% <http://www.mathworks.it/it/help/matlab/ref/isundefined.html undefined> 
% is used as |NotAssessed|; |Condensed|, the not assessed documents are 
% removed from the run. If not specified, the default value  is 
% |NotRelevant| to mimic the behaviour of trec_eval.
% * *|MapToBinaryRelevance|* (optional) - a string specifying whether and
% how relevance degrees have to be mapped to binary relevance. The
% following values can be used: _|Hard|_ considers only the maximum degree
% of relevance in the pool as |Relevant| and any degree below it as
% |NotRelevant|; _|Lenient|_ considers any degree of relevance in the pool
% above the minimum one as |Relevant| and only the minimum one is
% considered as |NotRelevant|; _|RelevanceDegree|_ considers the relevance
% degrees in the pool stricly above the specified one as |Relevant| and all
% those less than or equal to it as |NotRelevant|. In this latter case, if
% |RelevanceDegree| does not correspond to any of the relevance degrees in
% the pool, an error is raised. If not specified, mapping to binary
% relevance will not be performed.
% * *|MapToRelevanceWeights|* (optional) - a vector of numbers to which the
% relevance degrees in the pool will be mapped. It must be an increasing
% vector with as many elements as the relevance degrees in the pool are. In
% case also |MapToBinaryRelevance| is used, it must have two elements. If 
% not specified, mapping to relevance weights will not be performed.
% * *|FixNumberRetrievedDocuments|* (optional) - an integer value
% specifying the expected length of the retrieved document list. Topics
% retrieving more documents than |FixNumberRetrievedDocuments| will be 
% truncated at |FixNumberRetrievedDocuments|; tocpis retrieving less
% documents than |FixNumberRetrievedDocuments| will be padded with
% additional documents according to the strategy defined in 
% |FixedNumberRetrievedDocumentsPaddingStrategy|. If not specified, the 
% value 1,000 will be used as default, to mimic the behaviour of trec_eval.
% Pass an empty matrix to let topics retrieve a variable number of
% documents.
% * *|FixedNumberRetrievedDocumentsPaddingStrategy|* (optional) - a string
% specifying how topics with less than |FixNumberRetrievedDocuments| have
% to be padded. The following values can be used: _|NotRelevant|_ documents
% assessed as |NotRelevant|, i.e. the minimum relevance degree in the pool,
% are added; _|NotAssessed|_ documents not assessed are added, the 
% categorical <http://www.mathworks.it/it/help/matlab/ref/isundefined.html
% undefined> is used as |NotAssessed|; _|NotRelevantAfterRecallBase|
% documents |NotAssessed| are added up to the recall base for that topic 
% and, after it, |NotRelevant| ones. If not specified, |NotRelevant| is 
% used as default to mimic the behaviour of trec_eval.
% * *|RemoveUUFromPool|* (optional) - a boolean indicating whether
% unsampled or unjudged documents have to be removed from the pool before
% assessing the run. The default is true.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default. 
%
% *Returns*
%
% * *|assessedRunSet|*  - a table containing a row for each topic and a column 
% for each run named |runName|. The value contained in the column, for each 
% row, is a cell array of one element, wrapping a table with one column:
% |Assessment| with the assessments for the retrieved documents for
% that topic. The |UserData| property of  the table contains a struct 
% with the following fields: _|identifier|_ is the identifier of the run. 
% * *|poolStats|* - a table containing statistics about the pool. Rows are 
% topics while the columns are: _|RelevanceDegrees|_, one colum for each
% relevance degree in the pool reporting the total number of documents for
% that relevance degree; _|RecallBase|_ reporting the recall base, i.e. the
% total number of documents strictly above the minimum relevance degree in
% the pool; _|Assessment|_ reporting the total number of assessed documents
% for that topic; _|BinaryNotRelevant|_ reporting the number of
% |NotRelevant| documents when mapping to binary relevance; 
% _|BinaryRelevant|_ reporting the number of |Relevant| document when 
%  mapping to binary relevance.
% * *|runSetStats|* - a table containing statistics about the run set where
% each row is a topic and columns are runs. Each table cell contains a
% strcut with the following fields: a field for each _|RelevanceDegree|_
% reporting the total number of documents for that relevance degree in that
% topic; _|notAssessed|_ reporting the total number of not assessed
% documents for that topic; _|relevantRetrieved|_ reporting the total
% number of relevant retrieved documents for that topic, i.e. the
% total number of documents strictly above the minimum relevance degree; 
%  _|retrieved|_ reporting the total number of retrieved 
% documents for that topic. The structure contains a substructure
% _|original|_ with the same information as above but before any processing
% is applied, e.g. mapping to binary relevance, mapping to relevance weight
% or padding. The structure contains another substructure _|binary|_ with
% two fields: the minimum relevance degree in the pool reporting the total
% number of not relevant documents for that topic and the maximum relevance
% degree in the pool reporting the total number of relevant documents for
% that topic. The structure contains another substructure
% _|fixNumberRetrievedDocuments|_ with two fields: _|paddedDocuments|_ the
% total number of documents added for that topic, if any, and 
% _|discardedDocuments|_ the total number of documents discarder for that
% topic, if any.
% * *|inputParams|* - a struct summarizing the input parameters passed.

%% Example of use
%  
%   assessedRun = assess(pool, run);
%
% In this example each run has two topics, |351| and |352|. It returns the 
% following table.
%
%              APL985LC          APL985SC          AntHoc01   
%           ______________    ______________    ______________
%
%    351    [1000x1 table]    [1000x1 table]    [1000x1 table]
%    352    [1000x1 table]    [1000x1 table]    [1000x1 table]
%
% Column names are run identifiers, row names are topic identifiers.
% 
%   APL985LC_351 = assessedRun{'351','APL985LC'}{1, 1};
%
% It returns the table containing the assessed documents for topic
% |351| and run |APL985LC|.
%
%   APL985LC_351(1:5,1)
% 
% It returns the first five documents assessed for run |APL985LC| for topic
% |351|.
%
%    Assessment
%    _______________
%
%     not_relevant   
%     not_relevant   
%     not_relevant   
%     not_relevant   
%     not_relevant   
%% References
% 
% For condensed result lists (|Condensed| in parameter |NotAssessed|), 
% please refer to:
%
% * Sakai, T. (2007). Alternatives to Bpref. In Kraaij, W., de Vries, A. P., 
% Clarke, C. L. A., Fuhr, N., and Kando, N., editors, _Proc. 30th Annual 
% International ACM SIGIR Conference on Research and Development in 
% Information Retrieval (SIGIR 2007)_, pages 71?78. ACM Press, New York, 
% USA.

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
function [assessedRunSet, poolStats, runSetStats, inputParams] = assess(pool, runSet, varargin)
    
    % cache of already assessed run sets
    persistent ASSESSMENT_CACHE UNSAMPLED_UNJUDGED;
    
    if isempty(UNSAMPLED_UNJUDGED)        
        % New categorical value to be added to the pool to indicate not
        % sampled documents or documents that have been pooled but
        % unjudged. See Yilmaz and Aslam, CIKM 2006
        UNSAMPLED_UNJUDGED = 'U_U';
    end;
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % check that pool is a non-empty table
    validateattributes(pool, {'table'}, {'nonempty'}, '', 'pool', 1);
    
    % check that runSet is a non-empty table
    validateattributes(runSet, {'table'}, {'nonempty'}, '', 'runSet', 2);
    
    % check that the pool and the runSet tables refer to the same set of
    % topics
    if ~isequal(pool.Properties.RowNames, runSet.Properties.RowNames)
        poolOnly = setdiff(pool.Properties.RowNames, runSet.Properties.RowNames).';
        runOnly = setdiff(runSet.Properties.RowNames, pool.Properties.RowNames).';
        msg = [];
        
        if ~isempty(poolOnly)
            msg = sprintf('The following topics are only in the pool: %s. ', ...
                strjoin(poolOnly, ', '));
        end;
        
        if ~isempty(runOnly)
            msg = sprintf('%sThe following topics are only in the run set %s.', ...
                msg, strjoin(runOnly, ', '));
        end;
        
        error('MATTERS:IllegalArgument', 'The pool %s and the run set %s must refer to the same set of topics. %s', ...
            pool.Properties.UserData.identifier, runSet.Properties.UserData.identifier, msg);
    end;
        
    % total number of topics to be assessed
    inputParams.topics = length(pool.Properties.RowNames);
  
    % total number of runs to be assessed
    inputParams.runs = length(runSet.Properties.VariableNames);

    % the possible relevance degrees according to the pool and ensure it is
    % a row
    inputParams.relevanceDegrees = categories(pool{:, 1}{1, 1}.RelevanceDegree);
    inputParams.relevanceDegrees = inputParams.relevanceDegrees(:);
        
    % a given relevance degree (just to have that categorical type)
    oneRelevanceDegree = pool{1, 1}{1, 1}{1, 2};
    
    % parse the variable inputs
    pnames = {'NotAssessed' 'MapToBinaryRelevance' 'MapToRelevanceWeights' 'FixNumberRetrievedDocuments' 'FixedNumberRetrievedDocumentsPaddingStrategy' 'RemoveUUFromPool' 'Verbose'};
    dflts =  {'NotRelevant' []                     []                      1000                          'NotRelevant'                                   true              false};
    
    if verLessThan('matlab', '9.2.0')
        [notAssessed, mapToBinaryRelevance, mapToRelevanceWeights, fixNumberRetrievedDocuments, fixedNumberRetrievedDocumentsPaddingStrategy, removeUUFromPool verbose, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [notAssessed, mapToBinaryRelevance, mapToRelevanceWeights, fixNumberRetrievedDocuments, fixedNumberRetrievedDocumentsPaddingStrategy, removeUUFromPool verbose, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end    
    

    % check whether the parameters have been passed by the user (and then 
    % perform additional checks) or they are set to their default  
    
    
    if supplied.NotAssessed
         % check that notAssessed is a non-empty string
        validateattributes(notAssessed, ...
            {'char', 'cell'}, {'nonempty', 'vector'}, '', ...
            'NotAssessed');
        
         if iscell(notAssessed)
            % check that notAssessed is a cell array of strings with one element
            assert(iscellstr(notAssessed) && numel(notAssessed) == 1, ...
                'MATTERS:IllegalArgument', 'Expected NotAssessed to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        notAssessed = char(strtrim(notAssessed));
        notAssessed = notAssessed(:).';
        
        % check that NotAssessed assumes a valid value
        validatestring(notAssessed, ...
            {'NotRelevant', 'Undefined', 'Condensed'}, '', 'notAssessed');               
    end;    
    inputParams.notAssessed = notAssessed;
    
    if supplied.MapToBinaryRelevance
        % check that mapToBinaryRelevance is a non-empty string
        validateattributes(mapToBinaryRelevance, {'char', 'cell'}, ...
            {'nonempty', 'vector'}, '', 'MapToBinaryRelevance');

        if iscell(mapToBinaryRelevance)
            % check that mapToBinaryRelevance is a cell array of strings with one element
            assert(iscellstr(mapToBinaryRelevance) && numel(mapToBinaryRelevance) == 1, ...
                'MATTERS:IllegalArgument', 'Expected MapToBinaryRelevance to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        mapToBinaryRelevance = char(strtrim(mapToBinaryRelevance));
        mapToBinaryRelevance = mapToBinaryRelevance(:).';
                
        switch lower(mapToBinaryRelevance)

            % all the documents that are somehow relevant are
            % considered as relevant
            case 'lenient'
                % use the minimum relevance degree in the pool as the
                % threshold stricly above which documents are 
                % considered as relevant
                
                % if the lowest relevance degree in the pool is 
                % UNSAMPLED_UNJUDGED, then take the next one as minimum of
                % the relevance degrees
                if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                    mapToBinaryRelevance = inputParams.relevanceDegrees{2}; 
                else
                     mapToBinaryRelevance = inputParams.relevanceDegrees{1}; 
                end;

            % only the documents that are maximamlly relevant are
            % considered as relevant.
            case 'hard'
                % use the relevance degree just before the maximum one 
                % in the pool as the threshold stricly above which 
                % documents are  considered as relevant
                mapToBinaryRelevance = inputParams.relevanceDegrees{end-1};

            % check that the threshold set by the user is one of the
            % relevance degrees actually used in the pool
            otherwise
                if ~ismember(mapToBinaryRelevance, inputParams.relevanceDegrees)  
                    error('MATTERS:IllegalArgument', 'The threshold %s strictly above which a document is considered relevant must be one of the relevance degrees (%s) actually used in the pool %s.', ...
                    mapToBinaryRelevance, strjoin(inputParams.relevanceDegrees.', ', '), pool.Properties.UserData.identifier);
                end;
                
                if strcmp(mapToBinaryRelevance, inputParams.relevanceDegrees{end})
                     warning('MATTERS:UncommonPattern', 'The threshold %s strictly above which a document is considered relevant is equal to the maximum relevance degree in the pool %s. As a consequence, all the documents will be considered as not relevant.', ...
                        mapToBinaryRelevance, pool.Properties.UserData.identifier);
                end;
        end;
    end;
    inputParams.mapToBinaryRelevance = mapToBinaryRelevance;
    
    if supplied.MapToRelevanceWeights
        if supplied.MapToBinaryRelevance
                        
            validateattributes(mapToRelevanceWeights, {'numeric'}, ...
                {'vector', 'nonempty', 'increasing', 'numel', 2}, '', ....
                'MapToRelevanceWeights');            
        else                            
            % check that mapToRelevanceWeights is a non-empty numeric vector 
            % with increasing values and the same number of elements as the
            % number of relevance degrees in the pool, to ensure
            % one-to-one mapping
                        
            % if the lowest relevance degree in the pool is 
            % UNSAMPLED_UNJUDGED, then there is one less relevance weight
            % than the degrees in the pool
            if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 

                
                validateattributes(mapToRelevanceWeights, {'numeric'}, ....
                {'vector', 'nonempty', 'increasing', 'numel', numel(inputParams.relevanceDegrees)-1}, ...
                '', 'MapToRelevanceWeights');
            else
                
             
                 validateattributes(mapToRelevanceWeights, {'numeric'}, ....
                {'vector', 'nonempty', 'increasing', 'numel', numel(inputParams.relevanceDegrees)}, ...
                '', 'MapToRelevanceWeights');
            end;

        end;
        
        % ensure it is a column vector
        mapToRelevanceWeights = mapToRelevanceWeights(:);
    end;
    inputParams.mapToRelevanceWeights = mapToRelevanceWeights;
    
    if supplied.FixNumberRetrievedDocuments && ~isempty(fixNumberRetrievedDocuments)
        % check that FixNumberRetrievedDocuments is a scalar integer value 
        % greater than 0
        validateattributes(fixNumberRetrievedDocuments, {'numeric'}, ...
            {'scalar', 'integer', '>', 0}, '', 'FixNumberRetrievedDocuments');
    end;
    inputParams.fixNumberRetrievedDocuments = fixNumberRetrievedDocuments;
    
    if supplied.FixedNumberRetrievedDocumentsPaddingStrategy
        
        if ~supplied.FixNumberRetrievedDocuments
             error('MATTERS:IllegalArgument', 'Cannot specify a padding strategy when the number of retrieved documents to be considered for each topic has not been set (FixNumberRetrievedDocuments not used).');
        end;
        
        % check that FixedNumberRetrievedDocumentsPaddingStrategy is a non-empty string
        validateattributes(fixedNumberRetrievedDocumentsPaddingStrategy, ...
            {'char', 'cell'}, {'nonempty', 'vector'}, '', ...
            'FixedNumberRetrievedDocumentsPaddingStrategy');
        
         if iscell(fixedNumberRetrievedDocumentsPaddingStrategy)
            % check that fixedNumberRetrievedDocumentsPaddingStrategy is a cell array of strings with one element
            assert(iscellstr(fixedNumberRetrievedDocumentsPaddingStrategy) && numel(fixedNumberRetrievedDocumentsPaddingStrategy) == 1, ...
                'MATTERS:IllegalArgument', 'Expected FixedNumberRetrievedDocumentsPaddingStrategy to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        fixedNumberRetrievedDocumentsPaddingStrategy = char(strtrim(fixedNumberRetrievedDocumentsPaddingStrategy));
        fixedNumberRetrievedDocumentsPaddingStrategy = fixedNumberRetrievedDocumentsPaddingStrategy(:).';
        
        % check that FixedNumberRetrievedDocumentsPaddingStrategy assumes a valid value
        validatestring(fixedNumberRetrievedDocumentsPaddingStrategy, ...
            {'NotRelevant', 'Undefined', 'NotRelevantAfterRecallBase'}, ...
            '', 'FixedNumberRetrievedDocumentsPaddingStrategy');             
    end;       
    inputParams.fixedNumberRetrievedDocumentsPaddingStrategy = fixedNumberRetrievedDocumentsPaddingStrategy;
    
     if supplied.RemoveUUFromPool
        % check that removeUUFromPool is a non-empty scalar
        % logical value
        validateattributes(removeUUFromPool, {'logical'}, {'nonempty','scalar'}, '', 'RemoveUUFromPool');
    end;    
    inputParams.removeUUFromPool = removeUUFromPool;    
    
    if supplied.Verbose
        % check that verbose is a non-empty scalar
        % logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
    inputParams.verbose = verbose;       
      
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Assessing run set %s with respect to pool %s: %d run(s) and %d topic(s) to be assessed.\n\n', ...
            runSet.Properties.UserData.identifier, pool.Properties.UserData.identifier, inputParams.runs, inputParams.topics);

        fprintf('Settings:\n');
        fprintf('  - relevance degrees in the pool: %s;\n', strjoin(inputParams.relevanceDegrees.', ', '));        
        fprintf('  - not assessed documents are: %s;\n', inputParams.notAssessed);
        
        if removeUUFromPool
            fprintf('  - not sampled or not judged documents will be removed from the pool;\n');
        else
            fprintf('  - not sampled or not judged documents will not be removed from the pool;\n');
        end;
        
        if ~isempty(mapToBinaryRelevance)
            fprintf('  - mapping to binary relevance enabled. Documents strictly above %s are considered as %s;\n', char(mapToBinaryRelevance), inputParams.relevanceDegrees{end});
        else    
            fprintf('  - mapping to binary relevance not enabled;\n');
        end;
        
        if ~isempty(mapToRelevanceWeights)
            fprintf('  - mapping to relevance weights enabled. Relevance degrees are mapped to the following relevance weights: %s;\n', strjoin(cellstr(num2str(mapToRelevanceWeights(:))).', ', '));
        else    
            fprintf('  - mapping to relevance weights not enabled;\n');
        end;
        
        if ~isempty(fixNumberRetrievedDocuments)
            fprintf('  - fixed number of retrieved documents enabled. The threshold for the number of retrieved documents per topic is %d;\n', fixNumberRetrievedDocuments);
            fprintf('    + topics above the threshold will discard documents, topics below the threshold will pad documents;\n');
            fprintf('    + padded documents are assumed to be %s;\n', inputParams.fixedNumberRetrievedDocumentsPaddingStrategy);
        else
            fprintf('  - fixed number of retrieved documents not enabled. Runs may retrieve a different number of documents per topic;\n');
        end;
        
        fprintf('\n');
    end;
    
    % check whether we have the results in the cache
    if isCached()
        
        if verbose
            fprintf('Assessments have been previously computed, returning the cached results.\n');
        end;
        
        return;
    end;
    
    % poolStatistics contains one column for each relevance degree in the
    % pool (which will report the total number of documents for that
    % column), one colum for the mapping to binary relevance (if any), and
    % one column for the mapping to relevance weights (if any)
    poolStats = array2table(NaN(inputParams.topics, 4 + length(inputParams.relevanceDegrees)));
    poolStats.Properties.RowNames = pool.Properties.RowNames;
    poolStats.Properties.VariableNames = vertcat(inputParams.relevanceDegrees, 'RecallBase', 'Assessment', 'BinaryNotRelevant', 'BinaryRelevant');
    poolStats.Properties.UserData.identifier = pool.Properties.UserData.identifier;
    
    % create an empty structure for statistics about the runs
    runStats = cell2struct(num2cell(NaN(3 + length(inputParams.relevanceDegrees), 1)), vertcat(inputParams.relevanceDegrees, 'notAssessed', 'relevantRetrieved', 'retrieved'));
    runStats.original = cell2struct(num2cell(NaN(3 + length(inputParams.relevanceDegrees), 1)), vertcat(inputParams.relevanceDegrees, 'notAssessed', 'relevantRetrieved', 'retrieved'));
    runStats.binary = cell2struct(num2cell(NaN(2, 1)), {inputParams.relevanceDegrees{1}; inputParams.relevanceDegrees{end}});
    runStats.fixedNumberRetrievedDocuments = cell2struct(num2cell(NaN(2, 1)), {'paddedDocuments'; 'discardedDocuments'});
    
    runSetStats = array2table(repmat(runStats, inputParams.topics, inputParams.runs));
    runSetStats.Properties.RowNames = runSet.Properties.RowNames;
    runSetStats.Properties.VariableNames = runSet.Properties.VariableNames;
    runSetStats.Properties.UserData.identifier = runSet.Properties.UserData.identifier;
        
    % the topic currently under assessment
    ct = 1;
        
    % the run currently under assessment
    cr = 1;
            
    % perform the assessment topic-by-topic
    assessedRunSet = rowfun(@assessTopic, runSet, 'OutputVariableNames', runSet.Properties.VariableNames, 'OutputFormat', 'table', 'ExtractCellContents', true, 'SeparateInputs', false);
    assessedRunSet.Properties.UserData.identifier = runSet.Properties.UserData.identifier;

    % cache the assessment for the current input
    cache();
    
    if verbose
        fprintf('\nAssessment cached.\n');
        fprintf('Assessment completed.\n');
    end;
    
    %%
   
    % compute the assessments for a given topic over all the runs
    function [varargout] = assessTopic(topic)

        
        if(verbose)
            fprintf('Assessing topic %s (%d out of %d)\n', pool.Properties.RowNames{ct}, ct, inputParams.topics);
            fprintf('  - run(s): ');
        end;
        
        % reset the index of the run under assessment for each processed 
        % topic
        cr = 1;
        
        % compute the assessments only on those column which contain the
        % actual runs
        varargout = cellfun(@assessRun, topic);
        
        % increment the index of the current topic under assessment
        ct = ct + 1;    
        
         if(verbose)
            fprintf('\n');
        end;
        
        %%
        
        % compute the assessment for a given topic of a given run
        function [judgement] = assessRun(runTopic)
            
            if(verbose)
                fprintf('%s ', runSet.Properties.VariableNames{cr});
            end;
                                   
            % we have to remove the unsampled/unjudged documents and the
            % pool contains them
            if(removeUUFromPool && strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED))
                                               
                rows = (pool{ct, 1}{1, 1}.RelevanceDegree == UNSAMPLED_UNJUDGED);
                
                pool{ct, 1}{1, 1}(rows, :) = [];
            end
            
            % compute the assessment by joining the documents retrieved by
            % the run with the pool for that topic
      %      if strcmpi(notAssessed, 'condensed')
      %          judgement = innerjoin(runTopic, pool{ct, 1}{1, 1}, 'LeftVariables', 'Document', 'RightVariables', 'RelevanceDegree');
      %      else 
      %          judgement = outerjoin(runTopic, pool{ct, 1}{1, 1}, 'Type', 'left', 'LeftVariables', 'Document', 'RightVariables', 'RelevanceDegree');
      %      end;
      %      judgement.Properties.VariableNames = {'Document', 'Assessment'};            
            
            % extract the documents to be judged (the first column is
            % Document
            documents = runTopic{:, 1};
            
            % prepare a vector with dummy judgements with the same length
            % of the run
            judgement = oneRelevanceDegree(ones(length(documents), 1));
            
            
            % find where the documents in the run topic appear in the pool
            % topic (the first column of pool is Document)
            [lia, loc] = ismember(documents, pool{ct, 1}{1, 1}{:, 1});
            
            % copy the relevance judgements from the pool to the
            % corresponding positions in the run
            judgement(lia) = pool{ct, 1}{1, 1}{loc(lia), 2};
            
            % remove the not assessd documents, if asked
            if strcmpi(notAssessed, 'condensed')
                judgement(~lia) = [];
            else
                % set them to categorical <undefined>
                judgement(~lia) = char('');
            end;
            
            % transform it into a table
            judgement = table(judgement, 'VariableNames', {'Assessment'});         
            
            % collect statistics about the pool
            cats = countcats(pool{ct, 1}{1, 1}.RelevanceDegree); 
            cats = cats(:).';
            poolStats{ct, 1:length(cats)} = cats;   
            
            
            % if the lowest relevance degree in the pool is 
            % UNSAMPLED_UNJUDGED, then the recall base starts from the
            % third degree in the pood
            if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                poolStats{ct, 'RecallBase'} = sum(cats(3:end));
            else
                poolStats{ct, 'RecallBase'} = sum(cats(2:end));
            end;
                      
            poolStats{ct, 'Assessment'} = height(pool{ct, 1}{1, 1});
            
            % the original total number of documents retrieved by the run
            runSetStats{ct, cr}.original.retrieved = height(runTopic);
            
            % the original total number of not assessed documents
            rows = isundefined(judgement.Assessment);
            runSetStats{ct, cr}.original.notAssessed = length(find(rows));

            % the original total number of document by relevance degree
            cats = countcats(judgement.Assessment); 
            for k = 1:length(cats)  % not found a better way to access multiple fields in one shot :=(
                runSetStats{ct, cr}.original.(inputParams.relevanceDegrees{k}) = cats(k);
            end;
            
            % the original total number of relevant retrieved documents.
            % If the lowest relevance degree in the pool is 
            % UNSAMPLED_UNJUDGED, then the recall base starts from the
            % third degree in the pool
            if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                runSetStats{ct, cr}.original.relevantRetrieved = sum(cats(3:end));
            else
                runSetStats{ct, cr}.original.relevantRetrieved = sum(cats(2:end));
            end;
            
            
            % check if we have to transform not assessed documents into not
            % relevant ones, i.e. the minimum of the relevance degrees in the
            % pool, or if we have to leave them as <undefined> in case of
            % not consended result list
            if strcmpi(notAssessed, 'notrelevant')                
                % If the lowest relevance degree in the pool is 
                % UNSAMPLED_UNJUDGED, then the not relevant one is the
                % second one
                if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                    judgement.Assessment(rows) = inputParams.relevanceDegrees{2};
                else
                    judgement.Assessment(rows) = inputParams.relevanceDegrees{1};
                end;                                                  
            end;
            
            
            % check whether we have to transform multigraded relevance
            % judgements into binary ones where documents less than or equal
            % to the threshold become not relevant, i.e. the minimum of the 
            % relevance degrees in the pool, and documents greater than the
            % threshold become relevant, , i.e. the maximum of the 
            % relevance degrees in the pool.
            if ~isempty(mapToBinaryRelevance) 
                
                % If the lowest relevance degree in the pool is 
                % UNSAMPLED_UNJUDGED, then the not relevant one is the
                % second one
                if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                    rows = (judgement.Assessment > UNSAMPLED_UNJUDGED & judgement.Assessment <= mapToBinaryRelevance);
                    judgement.Assessment(rows) = inputParams.relevanceDegrees{2};
                    runSetStats{ct, cr}.binary.(inputParams.relevanceDegrees{2}) = length(find(rows));

                    rows = (judgement.Assessment > mapToBinaryRelevance);
                    judgement.Assessment(rows) = inputParams.relevanceDegrees{end};
                    runSetStats{ct, cr}.binary.(inputParams.relevanceDegrees{end}) = length(find(rows));

                    poolStats{ct, 'BinaryNotRelevant'} = length(find(( ...
                        pool{ct, 1}{1, 1}.RelevanceDegree > UNSAMPLED_UNJUDGED & ...
                        pool{ct, 1}{1, 1}.RelevanceDegree <= mapToBinaryRelevance)));
                    poolStats{ct, 'BinaryRelevant'} = length(find((pool{ct, 1}{1, 1}.RelevanceDegree > mapToBinaryRelevance)));
                else
                    rows = (judgement.Assessment <= mapToBinaryRelevance);
                    judgement.Assessment(rows) = inputParams.relevanceDegrees{1};
                    runSetStats{ct, cr}.binary.(inputParams.relevanceDegrees{1}) = length(find(rows));

                    rows = (judgement.Assessment > mapToBinaryRelevance);
                    judgement.Assessment(rows) = inputParams.relevanceDegrees{end};
                    runSetStats{ct, cr}.binary.(inputParams.relevanceDegrees{end}) = length(find(rows));

                    poolStats{ct, 'BinaryNotRelevant'} = length(find((pool{ct, 1}{1, 1}.RelevanceDegree <= mapToBinaryRelevance)));
                    poolStats{ct, 'BinaryRelevant'} = length(find((pool{ct, 1}{1, 1}.RelevanceDegree > mapToBinaryRelevance)));
                end;  
                                
            end;
            
            % check whether we have to return a fixed number of documents
            % for each topic
            if ~isempty(fixNumberRetrievedDocuments)
                
                h = height(judgement);
                
                % if there are more retrieved documents than the threshold,
                % simply remove them
                if h > fixNumberRetrievedDocuments
                    
                    judgement = judgement(1:fixNumberRetrievedDocuments, :);
                    
                    runSetStats{ct, cr}.fixedNumberRetrievedDocuments.discardedDocuments = h - fixNumberRetrievedDocuments;
                    runSetStats{ct, cr}.fixedNumberRetrievedDocuments.paddedDocuments = 0;
                    
                % if there are less retrieved documents than the threshold,
                % pad them either with 'NotRelevant' oens or with
                % 'NotAssessed' ones
                elseif h < fixNumberRetrievedDocuments
                    
                     if strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'NotRelevant')
                         
                        % If the lowest relevance degree in the pool is 
                        % UNSAMPLED_UNJUDGED, then the not relevant one is the
                        % second one
                        if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                            padding = table(repmat(categorical(inputParams.relevanceDegrees(2), inputParams.relevanceDegrees, 'Ordinal', true), ...
                            fixNumberRetrievedDocuments - h, 1)); 
                        else
                            padding = table(repmat(categorical(inputParams.relevanceDegrees(1), inputParams.relevanceDegrees, 'Ordinal', true), ...
                            fixNumberRetrievedDocuments - h, 1)); 
                        end;  
                                                                          
                     elseif strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'Undefined')
                         padding = table(repmat(categorical({categorical.undefLabel}, inputParams.relevanceDegrees, 'Ordinal', true), ...
                            fixNumberRetrievedDocuments - h, 1)); 
                     elseif strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'NotRelevantAfterRecallBase') 
                         
                         % determine the recall base depending on whether
                         % we are using binary relevance or not
                         if ~isempty(mapToBinaryRelevance)
                             rb =  poolStats{ct, 'BinaryRelevant'};
                         else
                             rb = poolStats{ct, 'RecallBase'};
                         end
                                                  
                         % if we are already after the recall base, add
                         % only not relevant documents
                         if h >= rb  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                             
                            % If the lowest relevance degree in the pool is 
                            % UNSAMPLED_UNJUDGED, then the not relevant one is the
                            % second one
                            if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                                 padding = table(repmat(categorical(inputParams.relevanceDegrees(2), inputParams.relevanceDegrees, 'Ordinal', true), ...
                                    fixNumberRetrievedDocuments - h, 1));  
                            else
                                padding = table(repmat(categorical(inputParams.relevanceDegrees(1), inputParams.relevanceDegrees, 'Ordinal', true), ...
                                    fixNumberRetrievedDocuments - h, 1));       
                            end;  
                             
                                               
                         else
                            % fill with not assessed documents up to the
                            % recall base
                            padding = table(repmat(categorical({categorical.undefLabel}, inputParams.relevanceDegrees, 'Ordinal', true), ...
                                rb - h, 1)); 
                             
                            % fill with not relevant documents after the
                            % recall base
                            % If the lowest relevance degree in the pool is 
                            % UNSAMPLED_UNJUDGED, then the not relevant one is the
                            % second one
                            if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                                 padding = [padding; table(repmat(categorical(inputParams.relevanceDegrees(2), inputParams.relevanceDegrees, 'Ordinal', true), ...
                                fixNumberRetrievedDocuments - rb, 1))]; 
                            else
                                padding = [padding; table(repmat(categorical(inputParams.relevanceDegrees(1), inputParams.relevanceDegrees, 'Ordinal', true), ...
                                    fixNumberRetrievedDocuments - rb, 1))];       
                            end;  
                            
                         end                                                 
                     end;
                                                             
                     padding.Properties.VariableNames = {'Assessment'};                     
                     judgement = [judgement; padding];
                     
                     runSetStats{ct, cr}.fixedNumberRetrievedDocuments.discardedDocuments = 0;
                     runSetStats{ct, cr}.fixedNumberRetrievedDocuments.paddedDocuments = fixNumberRetrievedDocuments - h;
                    
                end;
                
            end;
            
            % compute the final run statistcs, after all the possible
            % transformation but before the possible mapping to relevance
            % weights
            
            % the actual total number of documents retrieved by the run,
            % after processing
            runSetStats{ct, cr}.retrieved = height(judgement);
            
            % the actual total number of not assessed documents, after
            % processing
            runSetStats{ct, cr}.notAssessed = length(find(isundefined(judgement.Assessment)));

             % the actual total number of document by relevance degree,
             % after processing
            cats = countcats(judgement.Assessment);  
            for k = 1:length(cats)  % not found a better way to access multiple fields in one shot :=(
                runSetStats{ct, cr}.(inputParams.relevanceDegrees{k}) = cats(k);
            end;
            
            % the total number of relevant retrieved, after processing
             
            % If the lowest relevance degree in the pool is 
            % UNSAMPLED_UNJUDGED, then the not relevant one is the
            % second one
            if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                 runSetStats{ct, cr}.relevantRetrieved = sum(cats(3:end));
            else
                runSetStats{ct, cr}.relevantRetrieved = sum(cats(2:end));
            end;  

                        
            if ~isempty(mapToRelevanceWeights)
                
                weightedJudgement = array2table(NaN(runSetStats{ct, cr}.retrieved, 1));
                weightedJudgement.Properties.VariableNames = judgement.Properties.VariableNames;
                
                if ~isempty(mapToBinaryRelevance)
                    
                    % If the lowest relevance degree in the pool is 
                    % UNSAMPLED_UNJUDGED, then the not relevant one is the
                    % second one
                    if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED) 
                        
                        % search for unsampled/unjudged documents
                        rows = (judgement.Assessment == UNSAMPLED_UNJUDGED);
                        weightedJudgement.Assessment(rows) = -inf;
                        
                        % search for not relevant documents
                        rows = (judgement.Assessment == inputParams.relevanceDegrees{2});
                        weightedJudgement.Assessment(rows) = mapToRelevanceWeights(1);

                        % search for relevant documents
                        rows = (judgement.Assessment == inputParams.relevanceDegrees{end});
                        weightedJudgement.Assessment(rows) = mapToRelevanceWeights(2); 
                    else
                        % search for not relevant documents
                        rows = (judgement.Assessment == inputParams.relevanceDegrees{1});
                        weightedJudgement.Assessment(rows) = mapToRelevanceWeights(1);

                        % search for relevant documents
                        rows = (judgement.Assessment == inputParams.relevanceDegrees{end});
                        weightedJudgement.Assessment(rows) = mapToRelevanceWeights(2); 
                    end;  
                    
                    
                else                                       
                    % search for documents in each relevance degree
                    [~, locb] = ismember(judgement.Assessment, inputParams.relevanceDegrees);
                    
                    % if we considered not assessed documents as undefined,
                    % we need a further value (NaN) in the relevance
                    % weights to map undefined assessed documents to it
                    %
                    % If the lowest relevance degree in the pool is 
                    % UNSAMPLED_UNJUDGED, then add -Inf to map it
                    if strcmpi(inputParams.relevanceDegrees{1}, UNSAMPLED_UNJUDGED)                         
                       w = [NaN; -inf; inputParams.mapToRelevanceWeights];
                    else
                        w = [NaN; inputParams.mapToRelevanceWeights];
                    end;  
                                                           
                    % in case of undefined assessed documents, the index of
                    % undefined assessed documents is 0 in locb. Increment
                    % locb by 1 in order to match this index with the first
                    % element of w just created. All the rest shifts
                    % accordingly. If there are no undefined assessed
                    % documents, it simply does not matter.
                    locb = locb + 1;
                                        
                    weightedJudgement{:, 'Assessment'} = w(locb);  
                end;
                
                judgement = weightedJudgement;
            end
            
            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            judgement = {{judgement}};
            
            % increment the index of the current run under assessment
            cr = cr + 1;
        end
    end


    %%
    
    % generates the field names in the cache for the current input.
    %
    % The structure of the cache is as follows
    % cache.<pool-identifier>.<runSet-identifier>.<notAssessed>.
    %       <mapToBinaryRelevance>.<mapToRelevanceWeights>
    %
    % It uses MD5 hash of the field parameters to ensure fixed length
    % strings as field names and to not exceed the 63 characters MATLAB
    % limit to identifiers
    function [fieldNames] = generateCacheFieldNames()
        
        % allocate the array for the fieldNames
        fieldNames = cell(8, 1);
        
        fieldNames{1} = ['pool_' md5(pool.Properties.UserData.identifier)];
        fieldNames{2} = ['runSet_' md5(runSet.Properties.UserData.identifier)];
        
        
        fieldNames{3} = ['notAssessed_' md5(notAssessed)];

        if ~isempty(mapToBinaryRelevance)
            fieldNames{4} = ['mapToBinaryRelevance_' ...
                md5(mapToBinaryRelevance)];
        else
            fieldNames{4} = 'mapToBinaryRelevance_none';
        end;

        if ~isempty(mapToRelevanceWeights) 
            fieldNames{5} = ['mapToRelevanceWeights_' ...
                    md5(num2str(mapToRelevanceWeights(:).'))];
        else
            fieldNames{5} = 'mapToRelevanceWeights_none';
        end;
        
        if ~isempty(fixNumberRetrievedDocuments)
            fieldNames{6} = ['fixNumberRetrievedDocuments_', ...
                md5(num2str(fixNumberRetrievedDocuments(:).'))];
        else
            fieldNames{6} = 'fixNumberRetrievedDocuments_none';
        end; 
           
        fieldNames{7} = ['paddingStrategy_', ...
                md5(fixedNumberRetrievedDocumentsPaddingStrategy)];
            
        if removeUUFromPool
            fieldNames{8} = 'removeUUFromPool_true';
        else
            fieldNames{8} = 'removeUUFromPool_false';
        end;
            
    end

    %%
    
    % checks whether there is a cached assessment for the current input 
    % and, when true, sets the output variables properly
    function [cached] = isCached()
                
        try 
            % get the cached results, if any
            fieldNames = generateCacheFieldNames();
            s = getfield(ASSESSMENT_CACHE, fieldNames{:});
            
            % if there are cached results, sets the output variables
            % accordingly
            assessedRunSet = s.assessedRunSet;
            runSetStats = s.runSetStats;
            poolStats = s.poolStats;
            inputParams = s.inputParams;
        
            % indicate that we are using cached results
            cached = true;
        catch err           
            % when an error is raised, it means that the (sub-)fields does
            % not exist in the cache, and so indicate that there are no
            % cached results
            cached = false;
        end;
    end;
    
    %%
    
    % caches  the assessment for the current input
    function cache()
                         
        % temporary struct for copying data into the cache
        s.assessedRunSet = assessedRunSet;
        s.runSetStats = runSetStats;
        s.poolStats = poolStats;
        s.inputParams = inputParams;
    
        fieldNames = generateCacheFieldNames();
        ASSESSMENT_CACHE = setfield(ASSESSMENT_CACHE, fieldNames{:}, s);
    end;
        
end



