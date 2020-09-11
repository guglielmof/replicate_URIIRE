%% meanAssessedDocument
% 
% Computes Markov precision (MP).

%% Synopsis
%
% [measuredRunSet, poolStats, runSetStats, inputParams] = markovPrecision(pool, runSet, Name, Value)
%  
% Note that Markov precision will be NaN when there are no relevant
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
% * *|MarkovModel|* (optional) - a string providing the Markov model to be
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
% raised. If not specified, |Lenient| will be used to map to binary
% relevance.
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
% |markovPrecision|; _|shortName|_ is a short name of the computed 
% measure, i.e. |MP|; _|pool|_ is the identifier of the pool with respect 
% to which the measure has been computed. Note that when the condensed
% measure is requested, as in (Sakai, SIGIR 2007), then the name and short
% name are, respectively, |conMarkovPrecision| and |condMP|). The name and
% short name are then suffixed with the used Markov model, according to the
% possible values of the |MarkovModel| parameter, and, when used, with the
% maximum allowed distance.
% * *|poolStats|* - see description in <assess.html assess>.
% * *|runSetStats|* - see description in <assess.html assess>.
% * *|inputParams|* - a struct summarizing the input parameters passed.

%% Example of use
%  
%   measuredRunSet = markovPrecision(pool, runSet, 'MarkovModel', 'mmAP');
%
% It computes the Markov precision. Suppose the run set contains the 
% following runs:
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
% It returns the Markov precision for topic 351 of run APL985LC.
%
%% References
% 
% Please refer to:
%
% * Ferrante, M., Ferro, N., Maistro, M. (2014). _Markov Precision_.
% Techical report, University of Padua, Italy.
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
% <mailto:maria.maistro@studenti.unipd.it Maria Maistro>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: Matlab 2013b or higher
% * *Copyright:* (C) 2014 <http://www.unipd.it/ University of Padua>, Italy
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
function [measuredRunSet, poolStats, runSetStats, inputParams] = meanAssessedDocument(pool, runSet, varargin)

    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % parse the variable inputs
    pnames = {'ShortNameSuffix', 'MapToBinaryRelevance' 'NotAssessed' 'P' 'Q'    'Verbose'};
    dflts =  {[]                 'lenient'              'NotRelevant' 0.8  0.15   false};
    [shortNameSuffix, mapToBinaryRelevance, notAssessed, p, q, verbose, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

    % actual parameters to be passed to assess.m, at least 6
    assessInput = cell(1, 10);
    
    % not assessed documents must be considered as not relevant for
    % precision
    assessInput{1, 1} = 'NotAssessed';
    assessInput{1, 2} = notAssessed;
    
    % map to binary relevance must be performed. Either use the value
    % passed by the caller or the default one
    assessInput{1, 3} = 'MapToBinaryRelevance';
    assessInput{1, 4} = mapToBinaryRelevance;
    
    % map to binary relevance weights to make follow-up computations
    % handier
    assessInput{1, 5} = 'MapToRelevanceWeights';
    assessInput{1, 6} = [0, 1];
     
    % padding is not needed
    assessInput{1, 7} = 'FixNumberRetrievedDocuments';
    assessInput{1, 8} = [];
    
    % remove unsampled/unjudged documents because they are not appropriate
    % for average precision computation
    assessInput{1, 9} = 'RemoveUUFromPool';
    assessInput{1, 10} = true;
    
    if supplied.P        
        % check that P is a non-empty scalar, greater than 0 and less than 1
        validateattributes(p, ...
            {'numeric'}, {'nonempty', 'scalar', '>', 0, '<', 1}, '', 'P');               
    end;     

    if supplied.Q        
        % check that Q is a non-empty scalar, greater than 0 and less than 1
        validateattributes(q, ...
            {'numeric'}, {'nonempty', 'scalar', '>=', 0, '<', 1}, '', 'Q');               
    end;     

	% check that Q is a non-empty scalar, greater than 0 and less than 1
    validateattributes(p+q, ...
		{'numeric'}, {'nonempty', 'scalar', '>', 0, '<', 1}, '', 'P+Q');               
        
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
            error('MATTERS:IllegalArgument', 'ShortNameSuffix %s is not valid: it can contain only letters, numbers, and the underscore.', ...
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
        
        fprintf('Computing mean assessed document %s for run set %s with respect to pool %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            markovModel, runSet.Properties.UserData.identifier, pool.Properties.UserData.identifier, width(runSet), height(runSet));
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
    
    measuredRunSet.Properties.UserData.name = 'meanAssessedDocument';
    measuredRunSet.Properties.UserData.shortName = 'MAD';
    
    if strcmpi(notAssessed, 'condensed')
      measuredRunSet.Properties.UserData.name = 'condensedMeanAssessedDocument';
      measuredRunSet.Properties.UserData.shortName = 'condMAD';
    end;
    
    % Add the used P and Q to the name
    measuredRunSet.Properties.UserData.name = [measuredRunSet.Properties.UserData.name ...
                                                '_P' num2str(p*100, '%03d') '_Q' num2str(q*100, '%03d')];
    measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
                                                '_P' num2str(p*100, '%03d') '_Q' num2str(q*100, '%03d')];
                                            
    if ~isempty(shortNameSuffix)
        measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
            '_' shortNameSuffix];
    end;
    
    if verbose
        fprintf('Computation of mean assessed document completed.\n');
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
                if (poolStats{ct, 'BinaryRelevant'} == 0)
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
            % them as a logical row vector
            relPos = runTopic{:, 'Assessment'};
            
                        
            % create the transition matrix
            P = diag(ones(1, runSetStats{ct, cr}.retrieved - 1)*p, 1) + ...
                diag(ones(1, runSetStats{ct, cr}.retrieved - 1)*q, -1);
            
            num = (eye(runSetStats{ct, cr}.retrieved) - P) \ relPos;
                        
            % check if it is empty. It should not happen 
            if isempty(num)                  
                 warning('MATTERS:IllegalState', 'The numerator for run %s at topic %s is empty.', ...
                        runSet.Properties.VariableNames{cr}, pool.Properties.RowNames{ct});
            end;
            
            % check if we have NaN values. It should not happen 
            if any(isnan(num))                  
                 warning('MATTERS:IllegalState', 'The numerator for run %s at topic %s contains NaN values.', ...
                        runSet.Properties.VariableNames{cr}, pool.Properties.RowNames{ct});
            end;
            
            den = (eye(runSetStats{ct, cr}.retrieved) - P) \ ones(runSetStats{ct, cr}.retrieved, 1);
                        
            % check if it is empty. It should not happen 
            if isempty(den)                  
                 warning('MATTERS:IllegalState', 'The denominator for run %s at topic %s is empty.', ...
                        runSet.Properties.VariableNames{cr}, pool.Properties.RowNames{ct});
            end;
            
            % check if we have NaN values. It should not happen 
            if any(isnan(den))                  
                 warning('MATTERS:IllegalState', 'The denominator for run %s at topic %s contains NaN values.', ...
                        runSet.Properties.VariableNames{cr}, pool.Properties.RowNames{ct});
            end;
                                               
            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            measure = {num(1)/den(1)};
            
            % increment the index of the current run under processing
            cr = cr + 1;
        end % processRun
    end % processTopic 
end % MAD
