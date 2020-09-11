%% twist
% 
% Computes the cumulated relative position at each rank position, or at 
% document cut-offs values, or at the recall base, or
% at each relevant retrieved document.

%% Synopsis
%
%   [tau, measuredRunSet, poolStats, runSetStats, inputParams, rho, sigma] = twist(pool, runSet, varargin)
%
% Note that cumulated relative position will be NaN when there are no relevant
% documents for a given topic in the pool.
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
% * *|ShortNameSuffix|* (optional) - a string providing a suffix which will
% be concatenated to the short name of the measure. It can contain only
% letters, numbers and the underscore. The default is empty.
% * *|NotAssessed|* (optional) - a string indicating how not assessed
% documents, i.e. those in the run but not in the pool, have to be
% processed: |NotRevelant|, the minimum of the relevance degrees of the 
% pool is used as |NotRelevant|; |Condensed|, the not assessed documents 
% are  removed from the run. If not specified, the default value  is 
% |NotRelevant| to mimic the behaviour of trec_eval.
% * *|MapToBinaryRelevance|* (optional) - a string specifying how relevance 
% degrees have to be mapped to binary relevance. The following values can 
% be used: _|Hard|_ considers only the maximum degree of relevance in the 
% pool as |Relevant| and any degree below it as |NotRelevant|; _|Lenient|_ 
% considers any degree of relevance in the pool above the minimum one as 
% |Relevant| and only the minimum one is considered as |NotRelevant|; 
% * *|Normalize|* (optional) - a boolean indicating whether normalization
% has to be performed or not, i.e whether CRP or nCRP has to be computed.
% Default is |false|.
% * *|CutOffs|* (optional) - specifies whether CRP at document
% cut-offs values has to be returned instead of CRP at each rank
% position. It can be either the string _|Standard|_ to use the standard
% trec_eval document cut-off values [5 10 15 20 30 100 200 500 1000]; a
% numeric integer increasing vector with the desired document cut-off
% values; _|RelevantRetrieved|_ to compute cumulated gain at each relevant
% retrieved documentor, _|LastRelevantRetrieved|_ to return the value of
% the measure at the last relevant retrieved document. If not specified, 
% cumulated relative position at each rank position will be computed.
% * *|RecallBase|* (optional) - a boolean specifying whether CRP 
% at the recall base has to be computed or not. If not specified, then 
% |false| is  used as default. Note that this option is mutually exclusive 
% with |CutOffs|.
% * *|FixNumberRetrievedDocuments|* (optional) - an integer value
% specifying the expected length of the retrieved document list. Topics
% retrieving more documents than |FixNumberRetrievedDocuments| will be 
% truncated at |FixNumberRetrievedDocuments|; topics retrieving less
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
% are added and then the measure will be computed; _|NaN|_ the measure
% vector will be filled in with 
% <http://www.mathworks.it/it/help/matlab/ref/nan.html NaN> values; 
% _|LastValue| the measure vector will be filled in with the last value
% achieved by the measure itself; _|LastValueAfterRecallBase|_
% |NotRelevant| documents will be added up to the recall base and then the
% measure will be computed while after the recall base the measure vector
% will be filled in with the last value achieved by the measure itself.
% If not specified, |NotRelevant| is used as default to mimic the behaviour 
% of trec_eval.
% % * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * *|tau|* - a table containing the twist for each run and topic.
% * |measureRunSet|  - a table containing a row for each topic and a column 
% for each run named |runName|. Each cell of the table contains either a 
% vector of CRP values, when CRP or CRP at document 
% cut-off values are asked, or a scalar, when CRP at recall base is 
% asked. The |UserData| property of  the table contains a struct  with the 
% following fields: _|identifier|_ is the identifier of the run; _|name|_ 
% is the name of the computed measure; _|shortName|_ is a short name of the
% computed measure; _|pool|_ is the identifier of the pool with respect to
% which the measure has been computed; |cutOffs| are the request document 
% cut-offs values, if any.
% * *|poolStats|* - see description in <assess.html assess>.
% * *|runSetStats|* - see description in <assess.html assess>.
% * *|inputParams|* - a struct summarizing the input parameters passed.
% * *|rho|* - a table containing the recovery ratio for each run and
% topic.
% * *|sigma|* - a table containing the space for each run and
% topic.
% 

%% Example of use
%  
%   [tau, ~, ~, ~, ~, rho, sigma] = twist(pool, runSet, 'CutOffs', 'Standard');
%
% It computes the cumulated relative at standard document cut-off values for a run
% set. Suppose the run set contains the following runs:
% 
% * |APL985LC.txt|
% * |AntHoc01.txt|
% * |Brkly24.txt|
%
% In this example each run has two topics, |351| and |352|. It returns the 
% following table.
%
%              APL985LC          AntHoc01          Brkly24   
%           ______________    ______________    ______________
%
%    351    [1x9 double]      [1x9 double]      [1x9 double]
%    352    [1x9 double]      [1x9 double]      [1x9 double]
%
% Column names are run identifiers, row names are topic identifiers; cells
% contain a row vector with the nine values of precision at standard
% document cut-off values.
% 
%   Brkly24_351 = measuredRunSet{'351','Brkly24'}
%
%   ans =
%
%    -171        -379        -614        -824       -1169       -1389        -718        1774        8618
%
% It returns the cumulated gain at 5, 10, 15, 20, 30, 100, 200, 500, and 1000
% retrieved documents for topic 351 of run Brkly24.
%
% As far as the summary indicators are concerned, we have
%
%   rho = 
%   
%              APL985LC   AntHoc01   Brkly24
%              _______    _______    _______    
%   
%       351     0.2379     0.2218    0.24583    
%       352    0.29907    0.21695    0.21993  
%
%
%   sigma = 
%   
%              APL985LC   AntHoc01   Brkly24    
%              _______    _______    _______    
%   
%       351    0.24389    0.20974    0.27241    
%       352    0.43222    0.40082    0.42611 
%
%
%
%   tau = 
%   
%              APL985LC   AntHoc01   Brkly24  
%              _______    _______    _______  
%   
%       351    0.24089    0.21577    0.25912  
%       352    0.36564    0.30889    0.32302 

%% References
% 
% Please refer to:
%
% * Angelini, M., Ferro, N., Järvelin, K., Keskustalo, H., Pirkola, A., Santucci,
% G., and Silvello, G. (2012). Cumulated Relative Position: A Metric for 
% Ranking Evaluation. In Catarci, T., Forner, P., Hiemstra, D., Peñas, A., 
% and Santucci, G., editors, 
% _Information Access Evaluation. Multilinguality, Multimodality, and Visual Analytics. Proceedings of the Third International Conference of the CLEF Initiative (CLEF 2012)_,
% pages 112-123. Lecture Notes in Computer Science (LNCS) 7488, Springer, Heidelberg, Germany.
% * Angelini, M., Ferro, N., Järvelin, K., Keskustalo, H., Pirkola, A., 
% Santucci, G., and Silvello, G. (2013). Cumulated Relative Position: A 
% Metric for Ranking Evaluation. In Basili, R., Sebastiani, F., and
% Semeraro, G., editors, Proc. 4th Italian Information Retrieval Workshop 
% (IIR 2013) http: // ceur-ws. org/ Vol-964/, pages 57-60.
% 
%
% For condensed result lists (|Condensed| in parameter |NotAssessed|), 
% please refer to:
%
% * Sakai, T. (2007). Alternatives to Bpref. In Kraaij, W., de Vries, A. P., 
% Clarke, C. L. A., Fuhr, N., and Kando, N., editors, _Proc. 30th Annual 
% International ACM SIGIR Conference on Research and Development in 
% Information Retrieval (SIGIR 2007)_, pages 71-78. ACM Press, New York, 
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
function [tau, measuredRunSet, poolStats, runSetStats, inputParams, rho, sigma] = twist(pool, runSet, varargin)

    persistent MY_SORTROWS UNSAMPLED_UNJUDGED;
    
    if isempty(MY_SORTROWS)
        
        MY_SORTROWS = @(x) {sortrows(x, 2, 'descend')};
        
        % New categorical value to be added to the pool to indicate not
        % sampled documents or documents that have been pooled but
        % unjudged. See Yilmaz and Aslam, CIKM 2006
        UNSAMPLED_UNJUDGED = 'U_U';
        
    end;
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % parse the variable inputs
    pnames = {'ShortNameSuffix' 'CutOffs' 'NotAssessed' 'MapToBinaryRelevance' 'FixNumberRetrievedDocuments' 'FixedNumberRetrievedDocumentsPaddingStrategy' 'RecallBase' 'Normalize' 'Verbose'};
    dflts =  {[]                []        'NotRelevant' []                     1000                          'NotRelevant'                                  false        false       false};
    
    if verLessThan('matlab', '9.2.0')
        [shortNameSuffix, cutOffs, notAssessed, mapToBinaryRelevance, fixNumberRetrievedDocuments, fixedNumberRetrievedDocumentsPaddingStrategy, recallBase, normalize, verbose, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [shortNameSuffix, cutOffs, notAssessed, mapToBinaryRelevance, fixNumberRetrievedDocuments, fixedNumberRetrievedDocumentsPaddingStrategy, recallBase, normalize, verbose, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end      
    
   
    % actual parameters to be passed to assess.m, at least 6
    assessInput = cell(1, 6);
    
    % not assessed documents must be considered as not relevant for
    % precision
    assessInput{1, 1} = 'NotAssessed';
    assessInput{1, 2} = notAssessed;

    if supplied.MapToBinaryRelevance
        % there will be only two relevance degrees after mapping (no matter
        % their names for the following settings in assessInput)
        relevanceDegrees = {'BinaryNotRelevant', 'BinaryRelevant'};
    else
        % get the relevance degrees in the pools
        relevanceDegrees = categories(pool{:, 1}{1, 1}.RelevanceDegree);
        relevanceDegrees = relevanceDegrees(:).';
    end;
    if strcmpi(relevanceDegrees{1}, UNSAMPLED_UNJUDGED)         
        % set default 5-based relevance weights skipping U_U docs
        mapToRelevanceWeights = 0:5:5*(length(relevanceDegrees) - 2);
    else
        % set default 5-based relevance weights
        mapToRelevanceWeights = 0:5:5*(length(relevanceDegrees) - 1);
    end;
    
    % map to relevance weights must be performed to ease subsequent
    % computations
    assessInput{1, 3} = 'MapToRelevanceWeights';
    assessInput{1, 4} = mapToRelevanceWeights;
        
    % remove unsampled/unjudged documents because they are not appropriate
    % for precision computation
    assessInput{1, 5} = 'RemoveUUFromPool';
    assessInput{1, 6} = true;
    
    % add the mapping to binary relevance, if needed
    if supplied.MapToBinaryRelevance
        assessInput{1, end+1} = 'MapToBinaryRelevance';
        assessInput{1, end+1} = mapToBinaryRelevance;
    end;  
    
    if supplied.ShortNameSuffix
        if iscell(shortNameSuffix)
            % check that nameSuffix is a cell array of strings with one element
            assert(iscellstr(shortNameSuffix) && numel(shortNameSuffix) == 1, ...
                'MATTERS:IllegalArgument', 'Expected ShortNameSuffix to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        shortNameSuffix = char(strtrim(shortNameSuffix));
        shortNameSuffix = shortNameSuffix(:).';
        
        % check that the nameSuffix is ok according to the matlab rules
        if ~isempty(regexp(shortNameSuffix, '\W*', 'once'))
            error('MATTERS:IllegalArgument', 'NameSuffix %s is not valid: it can contain only letters, numbers, and the underscore.', ...
                shortNameSuffix);
        end  
        
        % if it starts with an underscore, remove it since il will be
        % appended afterwards
        if strcmp(shortNameSuffix(1), '_')
            shortNameSuffix = shortNameSuffix(2:end);
        end;
    end;
    
    if supplied.FixNumberRetrievedDocuments && ~isempty(fixNumberRetrievedDocuments)
        % check that FixNumberRetrievedDocuments is a scalar integer value
        % greater than 0
        validateattributes(fixNumberRetrievedDocuments, {'numeric'}, ...
            {'scalar', 'integer', '>', 0}, '', 'FixNumberRetrievedDocuments');
    end;
    
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
            {'NotRelevant', 'NaN', 'LastValue', 'LastValueAfterRecallBase'}, ...
            '', 'FixedNumberRetrievedDocumentsPaddingStrategy');             
    end;       
    
    % when (i) no fixed number of retrieved docs is specified OR (ii) it is
    % specified but no padding strategy is specified or 'NotRelevant'
    % padding is specified OR (iii) it is empty to mean no padding at all, 
    % let assess.m know it
    if ~supplied.FixNumberRetrievedDocuments || ...
        (supplied.FixNumberRetrievedDocuments && ...
            (~supplied.FixedNumberRetrievedDocumentsPaddingStrategy || ...
                strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'NotRelevant') ...
            ) ...
        ) || ...
        isempty(fixNumberRetrievedDocuments)
     
        assessInput{1, end+1} = 'FixNumberRetrievedDocuments';
        assessInput{1, end+1} = fixNumberRetrievedDocuments;
        
        assessInput{1, end+1} = 'FixedNumberRetrievedDocumentsPaddingStrategy';
        assessInput{1, end+1} = fixedNumberRetrievedDocumentsPaddingStrategy;
    end
     
    if supplied.CutOffs
        
        if isnumeric(cutOffs)
            % check that cutOffs is a non-empty numeric vector with
            % increasing and integer values
            validateattributes(cutOffs, {'numeric'}, ...
                {'vector', 'integer', 'nonempty', 'positive', 'increasing'}, ...
                '', 'CutOffs');

            % ensure it is a row vector
            cutOffs = cutOffs(:).';

            % check we are not asking cut-offs we cannot achieve 
            if supplied.FixNumberRetrievedDocuments && cutOffs(end) > fixNumberRetrievedDocuments
                error('MATTERS:IllegalArgument', 'The highest cut-off requested (%d) is bigger than the number of documents to be returned (%d).', ...
                     cutOffs(end), fixNumberRetrievedDocuments);
            end;
            
        % if it is not numeric, 
        elseif ischar(cutOffs)
            
            % check that CutOffs is a non-empty string
            validateattributes(cutOffs, ...
                {'char', 'cell'}, {'nonempty', 'vector'}, '', ...
                'CutOffs');
        
            if iscell(cutOffs)
                % check that cutOffs is a cell array of strings with one element
                assert(iscellstr(cutOffs) && numel(cutOffs) == 1, ...
                    'MATTERS:IllegalArgument', 'Expected cCtOffs to be a cell array of strings containing just one string.');
            end
        
            % remove useless white spaces, if any, and ensure it is a char row
            cutOffs = char(strtrim(cutOffs));
            cutOffs = cutOffs(:).';
        
            % check that CutOffs assumes a valid value
            validatestring(cutOffs, ...
                {'Standard', 'RelevantRetrieved', 'LastRelevantRetrieved'}, ...
                '', 'CutOffs');   
            
            switch lower(cutOffs)
                case 'standard'
                    cutOffs = [5 10 15 20 30 100 200 500 1000];
                case 'relevantretrieved'
                    cutOffs = NaN;
                case 'lastrelevantretrieved'
                    cutOffs = Inf;
            end;                       
        else
            error('MATTERS:IllegalArgument', 'Invalid type for CutOffs: only numeric and chars are allowed.).');
        end;
    end;
    
    if supplied.RecallBase
        % check that recallBase is a non-empty scalar
        % logical value
        validateattributes(recallBase, {'logical'}, {'nonempty', 'scalar'}, '', 'RecallBase');
        
        if supplied.CutOffs
             error('MATTERS:IllegalArgument', 'Cannot compute CRP at recall base and CRP@DCV at the same time.');
        end; 
    end; 
    
    if supplied.Normalize
        % check that normalize is a non-empty scalar
        % logical value
        validateattributes(normalize, {'logical'}, {'nonempty', 'scalar'}, '', 'Normalize');
    end;    
       
    if supplied.Verbose
        % check that verbose is a non-empty scalar
        % logical value
        validateattributes(verbose, {'logical'}, {'nonempty', 'scalar'}, '', 'Verbose');
    end;    
               
      
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing cumultated relative position for run set %s with respect to pool %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            runSet.Properties.UserData.identifier, pool.Properties.UserData.identifier, width(runSet), height(runSet));

        fprintf('Settings:\n');
        fprintf('  - relevance degrees: %s;\n', strjoin(relevanceDegrees, ', '));
        fprintf('  - relevance weights: %s;\n', num2str(mapToRelevanceWeights));
        
        if normalize
            fprintf('  - performing normalization\n');
        else
            fprintf('  - not performing normalization\n');
        end;
        
        if ~isempty(fixNumberRetrievedDocuments)
            fprintf('  - fixed number of retrieved documents enabled. The threshold for the number of retrieved documents per topic is %d;\n', fixNumberRetrievedDocuments);
            fprintf('    + topics above the threshold will discard documents, topics below the threshold will pad documents;\n');
            fprintf('    + documents will be padded as follows: %s;\n', fixedNumberRetrievedDocumentsPaddingStrategy);
        else
            fprintf('  - fixed number of retrieved documents not enabled. Runs may retrieve a different number of documents per topic;\n');
        end;
        
        if ~isempty(cutOffs)
            fprintf('  - documents cut-offs: %s;\n', num2str(cutOffs));
        else
            fprintf('  - documents cut-offs not enabled;\n');
        end;
        
        if ~isempty(recallBase)
            fprintf('  - CRP at recall base will be computed;\n');
        end;
        
        fprintf('\n');
    end;
    
    [assessedRunSet, poolStats, runSetStats, inputParams] = assess(pool, runSet, 'Verbose', verbose, assessInput{:});
    
    % get the minimum weight which is associated to notRelevant documents
    MIN_WEIGHT = min(mapToRelevanceWeights);
    
    % create an ideal run
    idealRun = rowfun(MY_SORTROWS, pool, 'ExtractCellContents', true);
    idealRun.Properties.UserData.identifier = ['idealRun_' pool.Properties.UserData.identifier];
    idealRun = assess(pool, idealRun, 'Verbose', verbose, assessInput{:});
    
    % adjust input parameters if padding was not managed by assess.m
    if supplied.FixNumberRetrievedDocuments && ...
            ~strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'NotRelevant')        
        inputParams.fixNumberRetrievedDocuments = fixNumberRetrievedDocuments;
        inputParams.fixedNumberRetrievedDocumentsPaddingStrategy = fixedNumberRetrievedDocumentsPaddingStrategy;
    end;
    
    inputParams.cutOffs = cutOffs;
    inputParams.rPrec = recallBase;

    
     % the topic currently under processing
    ct = 1;
        
    % the run currently under processing
    cr = 1;
    
    % the rho summary indicator
    rho = array2table(NaN(height(runSet), width(runSet)));
    rho.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    rho.Properties.UserData.pool = pool.Properties.UserData.identifier;
    rho.Properties.RowNames = runSet.Properties.RowNames;
    rho.Properties.VariableNames = runSet.Properties.VariableNames;
    rho.Properties.UserData.name = 'rho';        
    rho.Properties.UserData.shortName = 'rho';
    
    % the sigma summary indicator
    sigma = array2table(NaN(height(runSet), width(runSet)));
    sigma.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    sigma.Properties.UserData.pool = pool.Properties.UserData.identifier;
    sigma.Properties.RowNames = runSet.Properties.RowNames;
    sigma.Properties.VariableNames = runSet.Properties.VariableNames;
    sigma.Properties.UserData.name = 'sigma';        
    sigma.Properties.UserData.shortName = 'sigma';
    
    % the tau summary indicator
    tau = array2table(NaN(height(runSet), width(runSet)));
    tau.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    tau.Properties.UserData.pool = pool.Properties.UserData.identifier;
    tau.Properties.RowNames = runSet.Properties.RowNames;
    tau.Properties.VariableNames = runSet.Properties.VariableNames;
    tau.Properties.UserData.name = 'tau';        
    tau.Properties.UserData.shortName = 'tau';
    
    % compute the measure topic-by-topic
    measuredRunSet = rowfun(@processTopic, assessedRunSet, 'OutputVariableNames', runSet.Properties.VariableNames, 'OutputFormat', 'table', 'ExtractCellContents', true, 'SeparateInputs', false);
    measuredRunSet.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    measuredRunSet.Properties.UserData.pool = pool.Properties.UserData.identifier;
    
    if ~isempty(cutOffs)
        if numel(cutOffs) > 1
            measuredRunSet.Properties.UserData.name = 'cumulatedRelativePositionAtDocumentCutOffValues';        
            measuredRunSet.Properties.UserData.shortName = 'CRP_DCV';
        else
            if isnan(cutOffs)
                measuredRunSet.Properties.UserData.name = 'cumulatedRelativePositionAtRelevantRetrievedDocuments';        
                measuredRunSet.Properties.UserData.shortName = 'CRP_RR';
            else
                measuredRunSet.Properties.UserData.name = ['cumulatedRelativePositionAt_' num2str(cutOffs) '_DocumentCutOffValue'];        
                measuredRunSet.Properties.UserData.shortName = ['CRP_' num2str(cutOffs)];
            end;
        end;
                
        measuredRunSet.Properties.UserData.cutOffs = cutOffs;
    elseif recallBase
        measuredRunSet.Properties.UserData.name = 'cumulatedRelativePositionAtRecallBase';
        measuredRunSet.Properties.UserData.shortName = 'CRP_RB';
    else
        measuredRunSet.Properties.UserData.name = 'cumulatedRelativePosition';
        measuredRunSet.Properties.UserData.shortName = 'CRP';
    end;
    
    if normalize
         measuredRunSet.Properties.UserData.name = ['normalizedC'  measuredRunSet.Properties.UserData.name(2:end)];
         measuredRunSet.Properties.UserData.shortName = ['n'  measuredRunSet.Properties.UserData.shortName];
    end
    
    if strcmpi(notAssessed, 'condensed')
         if normalize
             measuredRunSet.Properties.UserData.name = ['condensedN'  measuredRunSet.Properties.UserData.name(2:end)];
             measuredRunSet.Properties.UserData.shortName = ['condN'  measuredRunSet.Properties.UserData.shortName(2:end)];
         else
             measuredRunSet.Properties.UserData.name = ['condensedC'  measuredRunSet.Properties.UserData.name(2:end)];
             measuredRunSet.Properties.UserData.shortName = ['condC'  measuredRunSet.Properties.UserData.shortName(2:end)];
         end;
         
        rho.Properties.UserData.name = ['condensedR' rho.Properties.UserData.name(2:end)];
        rho.Properties.UserData.shortName = ['condR' rho.Properties.UserData.shortName(2:end)];
        
        sigma.Properties.UserData.name = ['condensedS' sigma.Properties.UserData.name(2:end)];
        sigma.Properties.UserData.shortName = ['condS' sigma.Properties.UserData.shortName(2:end)];
        
        tau.Properties.UserData.name = ['condensedT' tau.Properties.UserData.name(2:end)];
        tau.Properties.UserData.shortName = ['condT' tau.Properties.UserData.shortName(2:end)];         
    end;
        
    if ~isempty(shortNameSuffix)
        measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
            '_' shortNameSuffix];
                
        rho.Properties.UserData.shortName = [rho.Properties.UserData.shortName ...
            '_' shortNameSuffix];
        sigma.Properties.UserData.shortName = [sigma.Properties.UserData.shortName ...
            '_' shortNameSuffix];
        tau.Properties.UserData.shortName = [tau.Properties.UserData.shortName ...
            '_' shortNameSuffix];    
    end;
    
    if verbose
        fprintf('Computation of cumulated relative position completed.\n');
    end;
    
    %%
    
    % compute the measure for a given topic over all the runs
    function [varargout] = processTopic(topic)

        
        if(verbose)
            fprintf('Processing topic %s (%d out of %d)\n', pool.Properties.RowNames{ct}, ct, inputParams.topics);
            fprintf('  - run(s): ');
        end;
        
        % reset the index of the run under processing for each topic
        cr = 1;
        
        % compute the measure only on those column which contain the
        % actual runs
        varargout = cellfun(@processRun, topic);
        
        % increment the index of the current topic under processing
        ct = ct + 1;    
        
         if(verbose)
            fprintf('\n');
        end;
        
        %% 
        
        % compute the measure for a given topic of a given run
        function [measure] = processRun(runTopic)
            
            if(verbose)
                fprintf('%s ', runSet.Properties.VariableNames{cr});
            end;
            
            % avoid useless computations when you already know that
            % there are no relevant documents in the pool (NaN)
            if(poolStats{ct, 'RecallBase'} == 0)                
                    measure = NaN(1, height(runTopic));
                    rho{ct, cr} = NaN;
                    sigma{ct, cr} = NaN;
                    tau{ct, cr} = NaN;
            else                
                run = runTopic{:, 'Assessment'}.';
                rp_run = zeros(size(run));
                
                ideal = idealRun{ct, 1}{1, 1}{:, :}.';
                
                fullScale = ideal(end:-1:1);
                rp_fullScale = zeros(size(fullScale));
                
                % set measure to the worst run - i.e. no rel retrieved
                % = worst run
                worst = zeros(1, length(run));
                rp_worst = zeros(size(worst));
                    
                for k = 1:length(mapToRelevanceWeights)
                    
                    minRange = find(ideal == mapToRelevanceWeights(k), 1);
                    maxRange = find(ideal == mapToRelevanceWeights(k), 1, 'last');
                    
                    % compute RP for the run
                    pos = find(run == mapToRelevanceWeights(k));
       
                    maxPos = pos(pos > maxRange);
                    minPos = pos(pos < minRange);

                    rp_run(maxPos) = maxPos - maxRange;
                    rp_run(minPos) = minPos - minRange;
                    
                    % compute RP for the full scale run
                    pos = find(fullScale == mapToRelevanceWeights(k));
       
                    maxPos = pos(pos > maxRange);
                    minPos = pos(pos < minRange);

                    rp_fullScale(maxPos) = maxPos - maxRange;
                    rp_fullScale(minPos) = minPos - minRange;   
                    
                    % compute RP for the worst run
                    pos = find(worst == mapToRelevanceWeights(k));
       
                    maxPos = pos(pos > maxRange);
                    minPos = pos(pos < minRange);
                    
                    rp_worst(maxPos) = maxPos - maxRange;   
                    rp_worst(minPos) = minPos - minRange;   
                                        
                end;
                
                if(runSetStats{ct, cr}.relevantRetrieved ~= 0)
                    % cumulate the relative position up to each rank position 
                    measure = cumsum(rp_run);

                    % compute the recovery ratio
                    x = ones(size(measure));
                    x(measure <= 0) = -1;

                    if isempty(find(diff(x), 1))
                        if (size(find(measure == 0), 2) == length(measure))
                            % it is the ideal run
                            rho{ct, cr} = 1;
                        else
                            % it is a typical B or a worst
                            rho{ct, cr} = 0;
                        end
                        
                    else
                        rho{ct, cr} = poolStats{ct, 'RecallBase'} ./ max([poolStats{ct, 'RecallBase'} find(diff(x), 1)]);
                    end

                    % compute the space ratio
                    fspace_ratio = 1 - sum(rp_run(rp_run > 0)) ./ sum(rp_fullScale(rp_fullScale > 0));
                    bspace_ratio = 1 - sum(rp_run(rp_run < 0)) ./ sum(rp_fullScale(rp_fullScale < 0));

                    sigma{ct, cr} = 2 .* fspace_ratio .* bspace_ratio ./ (fspace_ratio + bspace_ratio);

                    % compute the twist
                    tau{ct, cr} = (rho{ct, cr} + sigma{ct, cr}) ./ 2;
                else
                    % it is the worst run
                    measure = cumsum(rp_worst);
                    rho{ct, cr} = 0;
                    sigma{ct, cr} = 0;
                    tau{ct, cr} = 0;
                end;
                
                % normalize by the full scale
                if normalize 
                    
                    crp_fullScale = cumsum(rp_fullScale);
                    mu = max(crp_fullScale);
                    nu = min(crp_fullScale);
                    
                    measure = (measure .* 2 - mu - nu) ./ (mu - nu);
                end;
                
                
            end;
            
            % check whether we have to retrieve a fixed number of documents
            % and this is not already done in assess.m
            if ~isempty(fixNumberRetrievedDocuments) && ...
                    ~strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'NotRelevant')        
                
                h = length(measure);
                
                % if there are more retrieved documents than the threshold,
                % simply remove them
                if h > fixNumberRetrievedDocuments
                    measure = measure(1:h);    
                    
                    runSetStats{ct, cr}.fixedNumberRetrievedDocuments.discardedDocuments = h - fixNumberRetrievedDocuments;
                    runSetStats{ct, cr}.fixedNumberRetrievedDocuments.paddedDocuments = 0;
                
                % if there are less retrieved documents than the threshold,
                % pad them according to the requested padding strategy
                elseif h < fixNumberRetrievedDocuments 
                    
                    % fill with NaN
                    if strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'NaN')
                        measure(h + 1, fixNumberRetrievedDocuments) = NaN(1, fixedNumberRetrievedDocumentsPaddingStrategy - h);
                    
                    % fill with the last value achieved by the measure
                    elseif strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'LastValue')
                        measure(h + 1, fixNumberRetrievedDocuments) = measure(h);
                        
                    % fill with not relevant between h and recall base and
                    % after recall base with the last value achieved by the
                    % measure
                    elseif strcmpi(fixedNumberRetrievedDocumentsPaddingStrategy, 'LastValueAfterRecallBase')
                        
                        rb =  poolStats{ct, 'RecallBase'};
                        
                        % if we are already after the recall base, fill
                        % with the last value achieved by the measure
                        if h >= rb
                            measure(h + 1, fixNumberRetrievedDocuments) = measure(h);                        
                        else
                            
                            % the padding between h and rb is as if only
                            % not relevant documents were retrieved.
                            % Compute the total number of relevant
                            % retrieved at the end of the vector
                            % (measure(h)*h), repeat it for as many
                            % positions there are up to the recall base,
                            % divide by the index of those position to get
                            % precision
                            measure(h + 1, rb) = repmat(measure(h) * h, 1, rb - h) ...
                                                    ./ ...
                                                 (h+1:rb);
                             
                            % fill with the last value achieved by the 
                            % measure at the recall base
                            measure(rb + 1, fixNumberRetrievedDocuments) = measure(rb);                        
                         end    
                        
                    end;                                            
                    
                    runSetStats{ct, cr}.fixedNumberRetrievedDocuments.discardedDocuments = 0;
                    runSetStats{ct, cr}.fixedNumberRetrievedDocuments.paddedDocuments = fixNumberRetrievedDocuments - h;
                end;
                                   
            end;
            
            % return only the requested cut-offs
            if ~isempty(cutOffs)
                
                % if cutOffs is NaN, then return precision at each relevant
                % retrieved document, which means where there a 1s in
                % runTopic. Note that all the vectors in a table must have
                % the same length, so we cannot return only the relevant
                % documents but instead we return the full precision vector
                % with NaNs at not relevant documents
                if isnan(cutOffs)
                    measure(~logical(runTopic{:, 'Assessment'})) = NaN;
                elseif isinf(cutOffs)
                    measure = measure(find(runTopic{:, 'Assessment'} ~= MIN_WEIGHT, 1, 'last'));   
                    
                    % if the are no relevant documents in the run
                    if isempty(measure)
                        measure = 0;
                    end;
                else
                    
                    % check we are not asking cut-offs we cannot achieve 
                    if cutOffs(end) > length(measure)
                        error('MATTERS:IllegalState', 'Run %s retrieved %d document(s) for topic %s which is less than the highest document cut-off value requested (%d).', ...
                            runSet.Properties.VariableNames{cr}, length(measure), ... 
                            pool.Properties.RowNames{ct}, cutOffs(end));
                    end;

                    measure = measure(cutOffs);
                end;
                
            end;
            
            % return Rprecision is asked
            if recallBase
                
                rb =  poolStats{ct, 'RecallBase'};
                
                % check we are not asking cut-offs we cannot achieve 
                if rb > length(measure)
                    error('MATTERS:IllegalState', 'Run %s retrieved %d document(s) for topic %s which is less than the recall base requested (%d).', ...
                        runSet.Properties.VariableNames{cr}, length(measure), ... 
                        pool.Properties.RowNames{ct}, rb);
                end;
                
                if (rb == 0)
                    measure = NaN;
                else                
                    measure = measure(rb);
                end;
                
            end;
            
            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            measure = {measure};
            
            % increment the index of the current run under processing
            cr = cr + 1;
        end
    end
    
end



