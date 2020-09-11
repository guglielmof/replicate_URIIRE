%% gradedRankBiasedPrecision
% 
% Computes the graded version of rank-biased precision (gRBP) as proposed by 
% [Sakai and Kando, 2008]. gRBP works only with graded
% relevance judgments and it is not possible to ask for a mapping to binary
% relevance; if binary relevance is needed please use the original version
% of RBP: _gradedRankBiasedPrecision_.

%% Synopsis
%
%   [measuredRunSet, poolStats, runSetStats, inputParams] = gradedRankBiasedPrecision(pool, runSet, Name, Value)
%  
% Note that rank-biased precision will be NaN when there are no relevant
% documents for a given topic in the pool (this may happen due to the way
% in which relevance degrees are mapped to binary relevance).
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
% * *|Persistence|* (optional) - a real value providing the persistence
% parameter of gRBP. The default is 0.8.
% * *|ShortNameSuffix|* (optional) - a string providing a suffix which will
% be concatenated to the short name of the measure. It can contain only
% letters, numbers and the underscore. The default is empty.
% * *|NotAssessed|* (optional) - a string indicating how not assessed
% documents, i.e. those in the run but not in the pool, have to be
% processed: |NotRevelant|, the minimum of the relevance degrees of the 
% pool is used as |NotRelevant|; |Condensed|, the not assessed documents 
% are  removed from the run. If not specified, the default value  is 
% |NotRelevant| to mimic the behaviour of trec_eval.
% * *|MapToRelevanceWeights|* (optional) - a vector of numbers to which the
% relevance degrees in the pool will be mapped. It must be an increasing
% vector with as many elements as the relevance degrees in the pool are.
% The default is |[0, 5, 10, ...]| up to as many relevance degrees are in
% the pool.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |measureRunSet|  - a table containing a row for each topic and a column 
% for each run named |runName|. Each cell of the table contains a scalar
% representing the average precision. The |UserData| property of  the table 
% contains a struct  with the  following fields: _|identifier|_ is the 
% identifier of the run; _|name|_  is the name of the computed measure, i.e.
% |gradedRankBiasedPrecision|; _|shortName|_ is a short name of the computed 
% measure, i.e. |gRBP|; _|pool|_ is the identifier of the pool with respect 
% to which the measure has been computed. Note that when the condensed
% measure is requested, as in (Sakai, SIGIR 2007), then the name and short
% name are, respectively, |condensedRankBiasedPrecision| and |congRBP|.
% * *|poolStats|* - see description in <assess.html assess>.
% * *|runSetStats|* - see description in <assess.html assess>.
% * *|inputParams|* - a struct summarizing the input parameters passed.

%% Example of use
%  
%   measuredRunSet = gradedRankBiasedPrecision(pool, runSet);
%
% It computes the rank-biased precision values for a run set. Suppose the 
% run set contains the following runs:
% 
% * |JuruDes.txt|
% * |JuruDesAggr.txt|
%
% In this example each run has two topics, |301| and |302|. It returns the 
% following table.
%
%            JuruDes      JuruDesAggr
%           __________    ___________
%    301       0.12685       0.12676 
%    302       0.38576       0.38576 
%
% Column names are run identifiers, row names are topic identifiers; cells
% contain a row vector with the value of the rank-biased precision.
% 
%   JuruDes_301 = measuredRunSet{'301','JuruDes'}
%
%   ans =
%
%    0.12685
%
% It returns the graded rank-biased precision for topic 301 of run JuruDes.
%
%% References
% 
% For the original version of RBP please refer to :
%
% * Moffat, A. and Zobel, J. (2008). Rank-biased Precision for Measurement 
% of Retrieval Effectiveness. _ACM Transactions on Information Systems 
% (TOIS)_, 27(1):2:1?2:27.
% 
% For the graded version of RBP please refer to :
%
% * Sakai, T. and Kando, N. (2008).On information retrieval metrics 
% designed for evaluation with incomplete relevance assessmentss. 
% _Information Retrieval (IR)_, 11:447?470.
% DOI 10.1007/s10791-008-9059-7
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
function [measuredRunSet, poolStats, runSetStats, inputParams] = gradedRankBiasedPrecision(pool, runSet, varargin)
    
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
    pnames = {'ShortNameSuffix', 'MapToRelevanceWeights'  'NotAssessed' 'Persistence' 'FixNumberRetrievedDocuments' 'Verbose'};
    dflts =  {[]                       []                  'NotRelevant'     0.8               []                          false};
        
     if verLessThan('matlab', '9.2.0')
        [shortNameSuffix, mapToRelevanceWeights, notAssessed, persistence, fixNumberRetrievedDocuments, verbose, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
     else
         [shortNameSuffix, mapToRelevanceWeights, notAssessed, persistence, fixNumberRetrievedDocuments, verbose, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end
     
    % actual parameters to be passed to assess.m, at least 6
    assessInput = cell(1, 8);

     % get the relevance degrees in the pools
     relevanceDegrees = categories(pool{:, 1}{1, 1}.RelevanceDegree);
     relevanceDegrees = relevanceDegrees(:).';
    
    if supplied.MapToRelevanceWeights                        
        validateattributes(mapToRelevanceWeights, {'numeric'}, ....
        {'vector', 'nonempty', 'increasing', 'numel', numel(relevanceDegrees)}, ...
        '', 'MapToRelevanceWeights');

        % ensure it is a row vector
        mapToRelevanceWeights = mapToRelevanceWeights(:).';
    else
        
        
        if strcmpi(relevanceDegrees{1}, UNSAMPLED_UNJUDGED)         
            % set default 5-based relevance weights skipping U_U docs
            mapToRelevanceWeights = 0:5:5*(length(relevanceDegrees) - 2);
        else
            % set default 5-based relevance weights
            mapToRelevanceWeights = 0:5:5*(length(relevanceDegrees) - 1);
        end;
    end;
    
    
    % not assessed documents must be considered as not relevant for
    % precision
    assessInput{1, 1} = 'NotAssessed';
    assessInput{1, 2} = notAssessed;

    % map to binary relevance weights to make follow-up computations
    % handier
    assessInput{1, 3} = 'MapToRelevanceWeights';
    assessInput{1, 4} = mapToRelevanceWeights;
     
    % padding is not needed
    assessInput{1, 5} = 'FixNumberRetrievedDocuments';
    assessInput{1, 6} = fixNumberRetrievedDocuments;
    
    % remove unsampled/unjudged documents because they are not appropriate
    % for average precision computation
    assessInput{1, 7} = 'RemoveUUFromPool';
    assessInput{1, 8} = true;
    
    if supplied.ShortNameSuffix
        if iscell(shortNameSuffix)
            % check that nameSuffix is a cell array of strings with one element
            assert(iscellstr(shortNameSuffix) && numel(shortNameSuffix) == 1, ...
                'MATTERS:IllegalArgument', 'Expected NameSuffix to be a cell array of strings containing just one string.');
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
    
    if supplied.Persistence                     
        % check that persistence is a nonempty scalar real value
        % greater than 0 and less than 1
        validateattributes(persistence, {'numeric'}, ...
            {'nonempty', 'scalar', 'real', '>', 0 '<', 1}, '', 'Persistence');
    end;
    
       
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing rank-biased precision for run set %s with respect to pool %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            runSet.Properties.UserData.identifier, pool.Properties.UserData.identifier, width(runSet), height(runSet));
    end;
    
    [assessedRunSet, poolStats, runSetStats, inputParams] = assess(pool, runSet, 'Verbose', verbose, assessInput{:});
    
     % the topic currently under processing
    ct = 1;
        
    % the run currently under processing
    cr = 1;
    
    % compute the measure topic-by-topic
    measuredRunSet = rowfun(@processTopic, assessedRunSet, 'OutputVariableNames', runSet.Properties.VariableNames, 'OutputFormat', 'table', 'ExtractCellContents', true, 'SeparateInputs', false);
    measuredRunSet.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    measuredRunSet.Properties.UserData.pool = pool.Properties.UserData.identifier;
    
    measuredRunSet.Properties.UserData.name = 'gradedRankBiasedPrecision_';
    measuredRunSet.Properties.UserData.shortName = 'gRBP_';
    
    if strcmpi(notAssessed, 'condensed')
      measuredRunSet.Properties.UserData.name = 'condensedGradedRankBiasedPrecision_';
      measuredRunSet.Properties.UserData.shortName = 'condgRBP_';
    end;
    
    measuredRunSet.Properties.UserData.name = [measuredRunSet.Properties.UserData.name num2str(persistence*100, '%03.0f')];
    measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName num2str(persistence*100, '%03.0f')];
    
    
    if ~isempty(shortNameSuffix)
        measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
            '_' shortNameSuffix];
    end;

    if verbose
        fprintf('Computation of graded rank-biased precision completed.\n');
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
            
            % avoid useless computations when you already know that either
            % the run has retrieved no relevant documents (0) or that there
            % are no relevant documents in the pool (NaN)
            if(runSetStats{ct, cr}.relevantRetrieved == 0)                
                if (poolStats{ct, 'NotRelevant'} == poolStats{ct, 'Assessment'})
                    measure = {NaN};
                else
                    measure = {0};
                end;
                
                % increment the index of the current run under processing
                cr = cr + 1;
               
                return;
            end;
                                   
            % determine the powers, which corresponds to the positions of
            % the relevant documents minus one
            powers = find(runTopic{:, 'Assessment'}) - 1;
            
            % determine the weight of the relevant documents
            weights = runTopic{powers + 1, 'Assessment'};
            
            % compute persistence ^ (i-1) at each relevant retrieved
            % document 
            measure = (persistence .^ powers) .* weights;
                                                        
            % sum and multiply by 1 - persistence divided by the maximum
            % weight in the pool all divided by the max weight
            measure = sum(measure) .* ((1 - persistence) / max(mapToRelevanceWeights));
                                   
            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            measure = {measure};
            
            % increment the index of the current run under processing
            cr = cr + 1;
        end
    end
    
end



