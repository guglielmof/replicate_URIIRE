%% qMeasure
% 
% Computes the Q-measure.

%% Synopsis
%
%   [measuredRunSet, poolStats, runSetStats, inputParams] = qMeasure(pool, runSet, Name, Value)
%
% Note that Q-measure will be NaN when there are no relevant
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
% * *|MapToRelevanceWeights|* (optional) - a vector of numbers to which the
% relevance degrees in the pool will be mapped. It must be an increasing
% vector with as many elements as the relevance degrees in the pool are.
% The default is |[0, 5, 10, ...]| up to as many relevance degrees are in
% the pool.
% % * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |measureRunSet|  - a table containing a row for each topic and a column 
% for each run named |runName|. Each cell of the table contains the value
% of Q-measure for the given run and topic. The |UserData| property of
% the table contains a struct  with the following fields: _|identifier|_ is 
% the identifier of the run; _|name|_  is the name of the computed measure; 
% _|shortName|_ is a short name of the computed measure; _|pool|_ is the 
% identifier of the pool with respect to which the measure has been computed.
% * *|poolStats|* - see description in <assess.html assess>.
% * *|runSetStats|* - see description in <assess.html assess>.
% * *|inputParams|* - a struct summarizing the input parameters passed.
% 

%% Example of use
%  
%   measuredRunSet = qMeasure(pool, runSet);
%
% It computes the cumulated gain at standard document cut-off values for a run
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
%    351    0.18719             0.16069           0.20889
%    352    0.24294             0.27852           0.28572  
%
% Column names are run identifiers, row names are topic identifiers; cells
% contain the value of Q-measure.
% 

%% References
% 
% Please refer to:
%
% * Sakai, T. (2004). New Performance Metrics Based on Multigrade Relevance: 
% Their Application to Question Answering. In Kando, N. and Takaku, M., editors, 
% _Proc. 4th NTCIR Workshop Meeting on Evaluation of Information Access Technologies: Information Retrieval, Question Answering and Cross-Lingual Information Access_.
% National Institute of Informatics, Published Online.
% * Sakai, T. (2005). Ranking the NTCIR Systems Based on Multigrade Relevance. 
% In Myaeng, S., Zhou, M., Wong, K.-F., and Zhang, H.-J., editors, 
% _Information Retrieval Technology - Asia Information Retrieval Sympo- sium (AIRS 2004)_, 
% pages 251-262. Lecture Notes in Computer Science (LNCS) 3411, Springer, Heidelberg, Germany.
% * Sakai, T. (2014). Metrics, Statistics, Tests. In Ferro, N., editor, 
% _Bridging Between Information Retrieval and Databases - PROMISE Winter School 2013, Revised Tutorial Lectures_, 
% pages 116-163. Lecture Notes in Com- puter Science (LNCS) 8173, Springer, 
% Heidelberg, Germany.
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
function [measuredRunSet, poolStats, runSetStats, inputParams] = cumulatedGain(pool, runSet, varargin)
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % parse the variable inputs
    pnames = {'ShortNameSuffix' 'MapToRelevanceWeights' 'NotAssessed' 'Beta' 'Verbose'};
    dflts =  {[]                []                      'NotRelevant' 1.0    false};
    [shortNameSuffix, mapToRelevanceWeights, notAssessed, beta, verbose, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

    % actual parameters to be passed to assess.m, at least 6
    assessInput = cell(1, 6);
    
    % not assessed documents must be considered as not relevant for
    % precision
    assessInput{1, 1} = 'NotAssessed';
    assessInput{1, 2} = notAssessed;

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
        % set default 5-based relevance weights
        mapToRelevanceWeights = 0:5:5*(length(relevanceDegrees) - 1);
    end;
    
    % map to relevance weights must be performed. Either use the passed
    % values or the default ones.
    assessInput{1, 3} = 'MapToRelevanceWeights';
    assessInput{1, 4} = mapToRelevanceWeights;
        
    % remove unsampled/unjudged documents because they are not appropriate
    % for precision computation
    assessInput{1, 5} = 'RemoveUUFromPool';
    assessInput{1, 6} = true;
    
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
        
    if supplied.Beta
        % check that beta is a non-empty scalar numeric value equal to or
        % greater than 0
        validateattributes(beta.mmalize, {'numeric'}, {'nonempty', 'scalar', '>=', 0}, '', 'Beta');
    end;    
       
    if supplied.Verbose
        % check that verbose is a non-empty scalar
        % logical value
        validateattributes(verbose, {'logical'}, {'nonempty', 'scalar'}, '', 'Verbose');
    end;    
               
      
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing Q-measure for run set %s with respect to pool %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            runSet.Properties.UserData.identifier, pool.Properties.UserData.identifier, width(runSet), height(runSet));

        fprintf('Settings:\n');
        fprintf('  - relevance degrees: %s;\n', strjoin(relevanceDegrees, ', '));
        fprintf('  - relevance weights: %s;\n', num2str(mapToRelevanceWeights));
        fprintf('  - beta: %f;\n', beta);
               
        fprintf('\n');
    end;
    
    [assessedRunSet, poolStats, runSetStats, inputParams] = assess(pool, runSet, 'Verbose', verbose, assessInput{:});
    
    idealRun = assess(pool, pool, assessInput{:});
    
     % the topic currently under processing
    ct = 1;
        
    % the run currently under processing
    cr = 1;
    
    % compute the measure topic-by-topic
    measuredRunSet = rowfun(@processTopic, assessedRunSet, 'OutputVariableNames', runSet.Properties.VariableNames, 'OutputFormat', 'table', 'ExtractCellContents', true, 'SeparateInputs', false);
    measuredRunSet.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    measuredRunSet.Properties.UserData.pool = pool.Properties.UserData.identifier;
    
    measuredRunSet.Properties.UserData.name = ['qMeasure_' num2str(beta, '%03d')];
    measuredRunSet.Properties.UserData.shortName = ['Q_'  num2str(beta, '%03d')];

    if strcmpi(notAssessed, 'condensed')
        measuredRunSet.Properties.UserData.name = ['condensedQ'  measuredRunSet.Properties.UserData.name(2:end)];
        measuredRunSet.Properties.UserData.shortName = ['cond'  measuredRunSet.Properties.UserData.shortName];
    end;
        
    if ~isempty(shortNameSuffix)
        measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
            '_' shortNameSuffix];
    end;
    
    if verbose
        fprintf('Computation of Q-measure completed.\n');
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
                if (poolStats{ct, 'RecallBase'} == 0)
                    measure = {NaN};
                else
                    measure = {0};
                end;   
                
                 % increment the index of the current run under processing
                cr = cr + 1;
               
                return;
            end;                
                
            
             % determine the positions of the relevant documents. Assessment
            % is already a binary relevance vector where 1s correspond also
            % to the positions of the relevant documents when we look at
            % them as a logical vector
            relPos = logical(runTopic{:, 'Assessment'}).';
                                  
            % cumulate the number of rel docs at each relevant retrieved document
            c = cumsum(relPos(relPos));
            
            % cumulate the gains up to each rank position 
            cg = cumsum(runTopic{:, 'Assessment'}).';
            cg = cg(relPos);

            ideal = cumsum(sort(idealRun{ct, 1}{1, 1}{:, :}.', 2, 'descend'));
            ideal = ideal(relPos);
            
            
            measure = (c + beta * cg) ./ (find(relPos) + beta * ideal);
            
            % average over the total number of relevant documents
            measure = sum(measure) ./ poolStats{ct, 'RecallBase'};

            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            measure = {measure};
            
            % increment the index of the current run under processing
            cr = cr + 1;
        end
    end
    
end



