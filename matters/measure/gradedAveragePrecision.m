%% gradedAveragePrecision
% 
% Computes graded average precision (GAP).

%% Synopsis
%
%   [measuredRunSet, poolStats, runSetStats, inputParams] = gradedAveragePrecision(pool, runSet, Name, Value)
%  
% Note that graded average precision will be NaN when there are no relevant
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
% * *|RelevanceThresholdProbability|* (mandatory) - a numeric vector of
% probabilities that a user choses the given relevance degree as threshold.
% It must have as many elements as the number of relevance degrees above
% not relevant in the pool; its elements must sum to 1.
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
% _|RelevanceDegree|_ considers the relevance degrees in the pool stricly 
% above the specified one as |Relevant| and all those less than or equal to 
% it as |NotRelevant|. In this latter case, if |RelevanceDegree| does not 
% correspond to any of the relevance degrees in the pool, an error is 
% raised.
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
% |gradedAveragePrecision|; _|shortName|_ is a short name of the computed 
% measure, i.e. |GAP|; _|pool|_ is the identifier of the pool with respect 
% to which the measure has been computed. Note that when the condensed
% measure is requested, as in (Sakai, SIGIR 2007), then the name and short
% name are, respectively, |condensedGradedAveragePrecision| and |conGAP|.
% * *|poolStats|* - see description in <assess.html assess>.
% * *|runSetStats|* - see description in <assess.html assess>.
% * *|inputParams|* - a struct summarizing the input parameters passed.

%% Example of use
%  
%   measuredRunSet = gradedAveragePrecision(pool, runSet);
%
% It computes theaverage precision values for a run set. Suppose the run 
% set contains the following runs:
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
%    351       0.1120            0.2899            0.3842
%    352       0.5527            0.0212            0.3758
%
% Column names are run identifiers, row names are topic identifiers; cells
% contain a row vector with the value of the average precision.
% 
%   APL985LC_351 = measuredRunSet{'351','APL985LC'}
%
%   ans =
%
%    0.1120
%
% It returns the average precision for topic 351 of run APL985LC.
%
%% References
% 
% Please refer to:
%
% * Robertson, S. E., Kanoulas, E., and Yilmaz, E. (2010). Extending 
% Average Precision to Graded Relevance Judgments. In Crestani, F., 
% Marchand- Maillet, S., Efthimiadis, E. N., and Savoy, J., editors, 
% _Proc. 33rd Annual International ACM SIGIR Conference on Research and Development in Information Retrieval (SIGIR 2010)_, 
% pages 603-610. ACM Press, New York, USA.
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
% <mailto:maistro@dei.unipd.it Maria Maistro>
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
function [measuredRunSet, poolStats, runSetStats, inputParams] = gradedAveragePrecision(pool, runSet, varargin)

    persistent UNSAMPLED_UNJUDGED;
    
    if isempty(UNSAMPLED_UNJUDGED)
        
        % New categorical value to be added to the pool to indicate not
        % sampled documents or documents that have been pooled but
        % unjudged. See Yilmaz and Aslam, CIKM 2006
        UNSAMPLED_UNJUDGED = 'U_U';
        
    end;
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % parse the variable inputs
    pnames = {'ShortNameSuffix', 'RelevanceThresholdProbability' 'MapToBinaryRelevance' 'NotAssessed' 'Verbose'};
    dflts =  {[]                 []                              []                     'NotRelevant' false};
    
    if verLessThan('matlab', '9.2.0')
        [shortNameSuffix, relevanceThresholdProbability, mapToBinaryRelevance, notAssessed, verbose, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [shortNameSuffix, relevanceThresholdProbability, mapToBinaryRelevance, notAssessed, verbose, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end
    
    

    % actual parameters to be passed to assess.m, at least 6
    assessInput = cell(1, 8);
    
    % not assessed documents must be considered as not relevant for
    % precision
    assessInput{1, 1} = 'NotAssessed';
    assessInput{1, 2} = notAssessed;
    
    if supplied.MapToBinaryRelevance
        % there will be only two relevance degrees after mapping (no matter
        % their names for the following settings in assessInput)
        relevanceDegrees = {'BinaryNotRelevant', 'BinaryRelevant'};
        
        % the total number of relevance degrees above not relevant
        D = length(relevanceDegrees) - 1;
    else
        % get the relevance degrees in the pools
        relevanceDegrees = categories(pool{:, 1}{1, 1}.RelevanceDegree);
        relevanceDegrees = relevanceDegrees(:).';
    end;
    if strcmpi(relevanceDegrees{1}, UNSAMPLED_UNJUDGED)
        % the total number of relevance degrees above not relevant
        D = length(relevanceDegrees) - 2;
    else
        % the total number of relevance degrees above not relevant
        D = length(relevanceDegrees) - 1;
    end;
    % set default 1-based relevance weights. They are not real weights but
    % they actually represent indexes into the relevanceThresholdProbability
    % vector, for "weights" above the not relevant one (0)
    mapToRelevanceWeights = 0:D;
    
    % map to relevance weights must be performed to ease subsequent
    % computations
    assessInput{1, 3} = 'MapToRelevanceWeights';
    assessInput{1, 4} = mapToRelevanceWeights;
    
    % remove unsampled/unjudged documents because they are not appropriate
    % for precision computation
    assessInput{1, 5} = 'RemoveUUFromPool';
    assessInput{1, 6} = true;
        
    % padding is not needed
    assessInput{1, 7} = 'FixNumberRetrievedDocuments';
    assessInput{1, 8} = [];
    
    % add the mapping to binary relevance, if needed
    if supplied.MapToBinaryRelevance
        assessInput{1, end+1} = 'MapToBinaryRelevance';
        assessInput{1, end+1} = mapToBinaryRelevance;
    end;  
    
    if supplied.RelevanceThresholdProbability
        
        % it must have as many elements as the number of relevance degrees,
        % excluding the NotRelevant degree and UNSAMPLE_UNJUDGED, if
        % present
        if strcmpi(relevanceDegrees{1}, UNSAMPLED_UNJUDGED)         
            
            validateattributes(relevanceThresholdProbability, ...
                {'numeric'}, ...
                {'nonempty', 'vector', 'numel', length(relevanceDegrees)-2, '>=', 0, '<=', 1}, '', ...
                'RelevanceThresholdProbability');
        else
             validateattributes(relevanceThresholdProbability, ...
                {'numeric'}, ...
                {'nonempty', 'vector', 'numel', length(relevanceDegrees)-1, '>=', 0, '<=', 1}, '', ...
                'RelevanceThresholdProbability');
        end;
        
        if abs(sum(relevanceThresholdProbability) - 1) > 1e-6
            error('MATTERS:IllegalArgument', 'The relevance threshold probabilities are expected to sum to 1.');
        end;
        
        % ensure it is a row vector
        relevanceThresholdProbability = relevanceThresholdProbability(:).';
    else
        error('MATTERS:IllegalArgument', 'The relevance threshold probabilities are missing.');
    end;
    
    % the cumulative sum of the relevance threshold probabilities
    g = cumsum(relevanceThresholdProbability);
    
    
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
       
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing graded average precision for run set %s with respect to pool %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
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
    
    measuredRunSet.Properties.UserData.name = 'gradedAveragePrecision';
    measuredRunSet.Properties.UserData.shortName = 'GAP';
    
    if strcmpi(notAssessed, 'condensed')
      measuredRunSet.Properties.UserData.name = 'condensedGradedAveragePrecision';
      measuredRunSet.Properties.UserData.shortName = 'condGAP';
    end;
    
    tmp = num2str(relevanceThresholdProbability*100, '%03.0f_');
    tmp = tmp(1:end-1);
    
    measuredRunSet.Properties.UserData.name = [measuredRunSet.Properties.UserData.name '_' tmp];
    measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName '_' tmp];
    
    if ~isempty(shortNameSuffix)
        measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
            '_' shortNameSuffix];
    end;

    if verbose
        fprintf('Computation of graded average precision completed.\n');
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
            % the run has retrieved no relevant documents (0) 
            if(runSetStats{ct, cr}.relevantRetrieved == 0)                
                
                measure = {0};
                
                % increment the index of the current run under processing
                cr = cr + 1;
               
                return;
            end;
            
            % count the number of documents by relevance degree,
            % excluding the not relevant ones
            if strcmpi(relevanceDegrees{1}, UNSAMPLED_UNJUDGED)                
                % poolStats is 
                % U_U | NotRelevant | Degree1 | Degree 2
                % so start from Degree1 (column 3) and take D column
                % (degrees), including column 3                
                relevanceCount = poolStats{ct, 3:3+(D-1)};
            else
                % poolStats is 
                % NotRelevant | Degree1 | Degree 2
                % so start from Degree1 (column 2) and take D column
                % (degrees), including column 2                
                relevanceCount = poolStats{ct, 2:2+(D-1)};
            end;
            
            %------------------- MODIFICHE -----------------------
            
            % exclude the initial g_i = 0
            J = find(g, 1, 'first') - 1;            
           
            % exclude the last R_i = R_{i+1} = ... = 0 elements
            K = find(relevanceCount, 1, 'last');
            
            % Il codice da problemi quando J >= K, in questo caso avrei una
            % divisione per zero e ottengo dei NaN ma la misura dovrebbe
            % valere 0 visto che gli utenti hanno soglie di
            % rilevanza alte e la run non recupera documenti che sono
            % considerati rilevanti dagli utenti
            if (J >= K)
                measure = {0};
                
                % increment the index of the current run under processing
                cr = cr + 1;
                
                return;
            end;
            
            %-------------------------------------------------------
                        
            % find the positions of the relevant documents
            relPos = find(runTopic{:, 'Assessment'});
                                                
            % initialize the delta matrix
            delta = zeros(runSetStats{ct, cr}.retrieved);
                                    
            for k = 1:length(relPos)
                delta(relPos(1:k), relPos(k)) = g(min(runTopic{relPos(1:k), 'Assessment'}, runTopic{relPos(k), 'Assessment'}));
            end;

            % average over the total number of relevant documents
            measure = ( (1 ./ (1:runSetStats{ct, cr}.retrieved)) * sum(delta).' ) ...
                        ./ ...
                      (relevanceCount * g.');
                                                           
            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            measure = {measure};
            
            % increment the index of the current run under processing
            cr = cr + 1;
        end
    end
    
end



