%% downsamplePool
% 
% Downsamples a pool according to different strategies.
%
%% Synopsis
%
%   [downsampledPool] = downsamplePool(pool, runSet, varargin)
%  
%
% *Parameters*
%
% * *|pool|* - the pool to be downsampled. It is a table in the
% same format returned by <../io/importPoolFromFileTRECFormat.html 
% importPoolFromFileTRECFormat>;
% * *|runSet|* - the run(s) to be used for downsampling, if needed. It is a 
% table in the same format returned by <../io/importRunFromFileTRECFormat.html 
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
% * *|Downsampling|* (optional) - a string providing the type of
% downsampling to be applied. It can assume the following values:
% |PoolDepthSampling|, where a new pool considering the first _k_ documents
% of each run in the |runSet| is created and the documents in common with
% the orginal pool are then kept as assessed; |StratifiedRandomSampling| 
% applies the sampling strategy described in Buckley and Voorhees, 2004, 
% where the first _p%_ relevant and not relevant documents taken from the 
% original pool are merged into a new pool; |RandomSampling| applies the 
% sampling strategy described in Yilmaz and Aslam, 2006 and 2008, where the 
% _p%_ of the pool constitutes the new pool. The defaul is 
% |StratifiedRandomSampling|.
% * *|SampleSize|* (optional) - a vector of integers containing the
% different samples sizes of for the pool. In the case of
% |StratifiedRandomSampling| and |RandomSampling|, they represent the fraction _p%_ 
% of documents of the pool to be sampled; in the case of |PoolDepthSampling|,
% they represent the different depths _k_ at which the new pool has to be
% created. The default is |[90 70 50 30 10]|.
% * *|Iterations|* (optional) - an integer representing the number of times
% the pool sampling has to be repeated. It can be used only in the case of
% |StratifiedSampling| and |RandomSampling|. The default is |1|.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |downsamplePool|  - a table containing a row for each iteration and one
% single column. Each cell contains a table where rows are topics and
% columns are pool samples. The first column is the original pool and it is
% reported only in the first iteration to avoid waste space, repeating it
% equal iteration after iteration. The |UserData| property of the table
% contains the following fields: _|identifier|_ the unique identifier of
% the sampled pools; _|downsampling|_ the value of the |Downsampling|
% parameter; _|shortDownsampling|_ an acronym corresponding to the chosen
% downsampling, |SRS| for StratifiedRandomSampling, |RS| for
% RandomSampling, and |PDS| for PoolDepthSampling; _|samplesize|_ the value
% of the |SampleSize| parameter; _|iterations|_ the value of the
% |Iterations| parameter.
%
% Note that documents that were in the original pool but not in the sampled
% one are part of the table and marked with the special relevance degree
% *|U_U|* which is added as lowest relevance degree in the pool. Please
% note that <../measure/assess.html assess> is able to correctly take into
% account this value while processing a run.

%% Example of use
%  
%   sp = downsamplePool(pool, runSet, 'Downsampling', 'RandomSampling', 'SampleSize', [70 50 30], 'Iteration', 10)
%
% It computes the random sampling of the given pool at 70%, 50%, and 30%
% of its original size and it repeats the sampling 10 times.
%
% It returns the following table.
%
%                       Samples   
%                     ____________
%
%    Iteration_001    [50x4 table]
%    Iteration_002    [50x4 table]
%    Iteration_003    [50x4 table]
%    Iteration_004    [50x4 table]
%    Iteration_005    [50x4 table]
%    Iteration_006    [50x4 table]
%    Iteration_007    [50x4 table]
%    Iteration_008    [50x4 table]
%    Iteration_009    [50x4 table]
%    Iteration_010    [50x4 table]
%
% You can extract the pools for the first iteration via |sp{1, 1}{1, 1}|
% and you obtain the following table.
%
%
%            Original        RS_SampleAt_070     RS_SampleAt_050    RS_SampleAt_030 
%           ______________    ______________    ______________    ______________
%
%    101    [ 862x2 table]    [ 862x2 table]    [ 862x2 table]    [ 862x2 table]
%    102    [1254x2 table]    [1254x2 table]    [1254x2 table]    [1254x2 table]
%    103    [1032x2 table]    [1032x2 table]    [1032x2 table]    [1032x2 table]
%    104    [1046x2 table]    [1046x2 table]    [1046x2 table]    [1046x2 table]
%    105    [1205x2 table]    [1205x2 table]    [1205x2 table]    [1205x2 table]
%    106    [1420x2 table]    [1420x2 table]    [1420x2 table]    [1420x2 table]
%    107    [1273x2 table]    [1273x2 table]    [1273x2 table]    [1273x2 table]
%    108    [1568x2 table]    [1568x2 table]    [1568x2 table]    [1568x2 table]
%
% where each cell contains the sampled pool for the given topic.
%% References
% 
% Please refer to:
%
% * Buckley, C. and Voorhees, E. M. (2004). Retrieval Evaluation with 
% Incomplete Information. In Sanderson, M., Järvelin, K., Allan, J., and 
% Bruza, P., editors, _Proc. 27th Annual International ACM SIGIR Conference 
% on Research and Development in Information Retrieval (SIGIR 2004)_, pages 
% 25-32. ACM Press, New York, USA.
% * Yilmaz, E. and Aslam, J. A. (2006). Estimating Average Precision With 
% Incomplete and Imperfect Judgments. In Yu, P. S., Tsotras, V., Fox, E. A.,
% and Liu, C.-B., editors, _Proc. 15th International Conference on 
% Information and Knowledge Management (CIKM 2006)_, pages 102-111. ACM 
% Press, New York, USA.
% * Yilmaz, E. and Aslam, J. A. (2008). Estimating average precision when 
% judgments are incomplete. _Knowledge and Information Systems_, 
% 16(2):173-211.

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
function [downsampledPool] = downsamplePool(pool, runSet, varargin)

    % helper variables
    persistent UNSAMPLED_UNJUDGED BV_R_MIN BV_NR_MIN;
    
    if isempty(UNSAMPLED_UNJUDGED)
        
        % New categorical value to be added to the pool to indicate not
        % sampled documents or documents that have been pooled but
        % unjudged. See Yilmaz and Aslam, CIKM 2006
        UNSAMPLED_UNJUDGED = 'U_U';
        
        % Minimum number of relevant documents to be sampled. See Buckley
        % and Voorhees, SIGIR 2004
        BV_R_MIN = 1;
        
        % Minimum number of not relevant documents to be sampled. See 
        % Buckley and Voorhees, SIGIR 2004
        BV_NR_MIN = 10;
    end;

    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % parse the variable inputs
    pnames = {'Downsampling'              'SampleSize'     'Iterations' 'Verbose'};
    dflts =  {'StratifiedRandomSampling'  [90 70 50 30 10 5 2 1] 1            false};
    
    
    if verLessThan('matlab', '9.2.0')
        [downsampling, sampleSize, iterations, verbose, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [downsampling, sampleSize, iterations, verbose, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end
                
    if supplied.Downsampling
        
        % check that Downsampling is a non-empty string
        validateattributes(downsampling, ...
            {'char', 'cell'}, {'nonempty', 'vector'}, '', 'Downsampling');
        
        if iscell(downsampling)
            % check that Downsampling is a cell array of strings with one element
            assert(iscellstr(downsampling) && numel(downsampling) == 1, ...
                'MATTERS:IllegalArgument', 'Expected Downsampling to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        downsampling = char(strtrim(downsampling));
        downsampling = downsampling(:).';
        
        % check that Downsampling assumes a valid value
        validatestring(downsampling, ...
            {'StratifiedRandomSampling', 'RandomSampling', 'PoolDepthSampling'}, ...
            '', 'Downsampling');             
    end;  
    
    if supplied.SampleSize        
        switch lower(downsampling)
            
            case {'stratifiedrandomsampling', 'randomsampling'}
                % check that SampleSize is a nonempty scalar integer value
                % greater than 0 and less than 100 (sampling ratio)
                validateattributes(sampleSize, {'numeric'}, ...
                    {'nonempty', 'integer', 'vector', '>', 0, '<', 100}, '', 'SampleSize');
                
            case 'pooldepthsampling'
                % check that SampleSize is a nonempty scalar integer value
                % greater than 0
                validateattributes(sampleSize, {'numeric'}, ...
                    {'nonempty', 'integer', 'vector', '>', 0}, '', 'SampleSize');
        end;
        
        % ensure it is a row vector
        sampleSize = sampleSize(:).';
    end;
    
    if supplied.Iterations
        
        if strcmpi(downsampling, 'PoolDepthSampling')            
            error('MATTERS:IllegalArgument', 'Repeated samplting (Iterations parameter) can be choosen only with stratified and random sampling but not with pool depth sampling.');
        end;
        
        % check that Iteration is a nonempty scalar integer value
        % greater than 0
        validateattributes(iterations, {'numeric'}, ...
            {'nonempty', 'scalar', 'integer', '>', 0}, '', 'Iterations');
    end;
          
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Downsampling pool pool %s with respect to run set %s with %s.\n\n', ...
            pool.Properties.UserData.identifier, runSet.Properties.UserData.identifier, downsampling);
    end;
    
    % determine the relevance degree in the pool corresponding to not 
    % relevant documents
    degrees = categories(pool{:, 1}{1, 1}.RelevanceDegree);
    
    % the total number of relevance degrees
    D = length(degrees);

    % If the lowest relevance degree in the pool is 
    % UNSAMPLED_UNJUDGED, then the pool has been already downsampled and
    % cannot do it twice
    if strcmpi(degrees{1}, UNSAMPLED_UNJUDGED) 
        error('MATTERS:IllegalState', 'Pool %s already contains unsampled or unjudged documents. Cannot downsample it twice.', ...
                pool.Properties.UserData.identifier);
    end;     
    
    % the not relevant document is the lowest degree
    notRelevant = degrees{1};
    
    % the total number of samples of the pool to be produced
    sampleNumber = length(sampleSize);
                    
    % the samples of the pool at different iterations
    downsampledPool = cell2table(cell(iterations, 1));
    
    switch lower(downsampling)
        case 'stratifiedrandomsampling'
            downsampledPool.Properties.UserData.shortDownsampling = 'SRS';
        case 'randomsampling'
            downsampledPool.Properties.UserData.shortDownsampling = 'RS';
        case 'pooldepthsampling'
            downsampledPool.Properties.UserData.shortDownsampling = 'PDS';
    end;
        
    downsampledPool.Properties.UserData.identifier = sprintf('%s_%s_%04d_samples_%04d_iterations', pool.Properties.UserData.identifier, ...
    downsampledPool.Properties.UserData.shortDownsampling, sampleNumber + 1, iterations);       
    downsampledPool.Properties.UserData.sampleSize = sampleSize;
    downsampledPool.Properties.UserData.downsampling = downsampling;       
    downsampledPool.Properties.UserData.iterations = iterations;
    downsampledPool.Properties.RowNames = strtrim(cellstr(num2str([1:iterations].', 'Iteration_%04d')));
    downsampledPool.Properties.VariableNames = {'Samples'};

              
    % downsample the pool topic-by-topic as many times as many iterations
    % are requested
    for k = 1:iterations
        
        % the topic currently under processing
        ct = 1;
        
        % compute the current downsampled pool
        tmp = rowfun(@processTopic, pool, 'OutputVariableNames', ['Original'; strtrim(cellstr(num2str(sampleSize(:),  ...
            [downsampledPool.Properties.UserData.shortDownsampling '_SampleAt_%04d'])))], ...
            'OutputFormat', 'table', 'ExtractCellContents', true, 'SeparateInputs', false);
        tmp.Properties.UserData.identifier = sprintf('%s__iteration_%04d', downsampledPool.Properties.UserData.identifier, k);       
        tmp.Properties.UserData.sampleSize = sampleSize;
        tmp.Properties.UserData.downsampling = downsampling;
        tmp.Properties.UserData.shortDownsampling = downsampledPool.Properties.UserData.shortDownsampling;
        tmp.Properties.UserData.iteration = k;
                    
        % add the current downsampled pool to the set of downsampled pools
        downsampledPool{k, :} = {tmp};
    end;
           
    if verbose
        fprintf('Downsampling of pool completed.\n');
    end;
    
    %%
    
    % compute the measure for a given topic over all the runs
    function [varargout] = processTopic(topic)
        
        if(verbose)
            fprintf('Iteration %d, processing topic %s (%d out of %d)\n', k, pool.Properties.RowNames{ct}, ct, height(pool));            
        end;
        
        % pre-allocate the outputs. There are as many output as the number
        % of different samples of the pool requested
        % (sampleSize/sampleNumber) plus 1 which is the original pool
        varargout = cell(1, sampleNumber + 1);
                
        % the fist output is the original topic only in the first iteration
        % then it is empty to avoid memory consumption
        if k == 1
            varargout{1} = topic;
        else
            varargout{1} = {NaN};
        end;
               
        switch lower(downsampling)

            % Description taken from Buckley and Voorhees, SIGIR 2004.
            %
            % For each topic in the 100% qrels, we create a list of the 
            % relevant documents in a random order, and a separate list of 
            % the judged nonrelevant documents in a random order. We then 
            % create 16 additional qrels by taking 90, 80, 70, 60, 50, 40, 
            % 30, 25, 20, 15, 10, 5, 4, 3, 2, and 1 percent of the 100% qrels. 
            % For a target qrels that is P% as large as the 100% qrels, we 
            % select X = P×R relevant documents and Y = PxN nonrelevant 
            % documents for each topic where R is the number of relevant 
            % documents in the 100% qrels and N is the number of judged 
            % nonrelevant documents in the 100% qrels for that topic. We 
            % use 1 as the minimum number of relevant documents and 10 as 
            % the minimum number of judged nonrelevant documents per topic
            % to include in a qrels. Thus if X or Y is less than the 
            % corresponding minimum it is set to the minimum. We add the 
            % first X relevant documents from the random list of relevant 
            % documents and the first Y judged nonrelevant documents from 
            % the random list of nonrelevant documents to the target qrels. 
            % Since we take random subsets of a qrels that is assumed to be 
            % fair, the reduced qrels are also unbiased with respect to 
            % systems. Each of the smaller qrels is a subset of a larger 
            % qrels since we always select from the top of the randomized 
            % lists.
            case 'stratifiedrandomsampling'
                
                % the position of the documents in the different relevance
                % degrees
                docs = cell(1, D);
                
                
                % determine the indices of the documents in each relevance
                % degree (docs{1} is NotRelevant documents) and permute
                % them
                for r = 1:D
                    
                    % determine the indices of the documents a the r-th
                    % relevance degree
                    docs{r} = find(topic{1, 1}.RelevanceDegree == degrees{r});
                    
                    % randomly permute the documents at the r-th relevance
                    % degree
                    docs{r} = docs{r}(randperm(length(docs{r})));
                    
                end;
                                                                               
                % the indices of all the documents in the topic
                all = 1:height(topic{1, 1});
                all = all(:);
                                
                
                % at each iteration, determine the relevant and not
                % relevant documents that have to be sampled, their
                % complement, i.e. those that will be left out by the
                % sampling, and return a new pool topic with the same
                % documents as the original one but marking the unsampled
                % ones. They will be place in the output from the second
                % element to the last one (the first is the original topic)
                for s = 1:sampleNumber
                                      
                    % the documents sampled for each relevance degree
                    sampled = cell(1, D);
                    
                    % sample the documents for each relevance degree
                    for r = 1:D
                        
                        % if the r-th relevance degree has no documents,
                        % there is nothing to sample. Simply return it.
                        if isempty(docs{r})
                            sampled{r} = docs{r};
                        else
                            sampled{r} = docs{r}(1 : max(BV_NR_MIN*(r==1)+BV_R_MIN*(r>1), round(sampleSize(s) * length(docs{r}) / 100)) ) ;
                        end;
                    end;
                    
                                      
                    % determine the unsampled documents
                    unsampled = setdiff(all, vertcat(sampled{:}));
                                          
                    % copy the topic and add the unsampled/unjudeged
                    % relevantce degree
                    sample = topic{1, 1};                    
                    sample.RelevanceDegree = addcats(sample.RelevanceDegree, ...
                        UNSAMPLED_UNJUDGED, 'Before', notRelevant);
                    
                    % mark the unsampled documents with the
                    % unsampled/unjudged relevance degree
                    sample.RelevanceDegree(unsampled) = UNSAMPLED_UNJUDGED;
                                                         
                    varargout{s+1} = {sample};
                end;

            % Description taken from Yilmaz and Aslam, 2006 and 2008.
            %
            % We form incomplete judgment sets by randomly sampling from 
            % the entire depth-100 pool over all submitted runs. This is 
            % done by selecting p% of the complete judgment set uniformly 
            % at random for each topic, where p is in {1, 2, 3, 4, 5, 10, 
            % 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100}. Note that
            % especially for small sampling percentages, the random sample 
            % may not contain any relevant documents. In this case, we 
            % remove the entire random sample and pick another p% random 
            % sample until a random sample with at least one relevant 
            % document is obtained.
            case 'randomsampling'
                
                % find the indices of the relevant documents in the current 
                % topic
                rel = find(topic{1, 1}.RelevanceDegree > notRelevant);                
                 R = length(rel);
                
                % the indices of all the documents in the topic
                A = height(topic{1, 1});
                all = 1:A;
                all = all(:);
                                                
                % there are not enough relevant documents for the topic, 
                % nothing to sample. Return the topic itself but adding the
                % U_U category to be compatible with the others.
                if(R < BV_R_MIN)
                    
                    sample = topic{1, 1};                    
                    sample.RelevanceDegree = addcats(sample.RelevanceDegree, ...
                        UNSAMPLED_UNJUDGED, 'Before', notRelevant);
                    
                    varargout(2:end) = {{sample}};

                    warning('MATTERS:IllegalState', 'Pool %s has not enough relevant documents for topic %s: %d instead of at least %d.', ...
                    pool.Properties.UserData.identifier, pool.Properties.RowNames{ct}, R, BV_R_MIN);

                    % increment the index of the current topic under processing
                    ct = ct + 1; 
                    
                    return;
                end;
                
                % generate the samples
                for s = 1:sampleNumber
                    
                    % generate the sampled documents
                    sampled = randperm(A, floor(sampleSize(s) * A / 100));
                    
                    % re-generate the sample documents if they do not
                    % contain any relevant document
                    while isempty(intersect(sampled, rel))
                        sampled = randperm(A, floor(sampleSize(s) * A / 100));
                    end;
                                        
                    % determine the unsampled documents
                    unsampled = setdiff(all, sampled);
                                          
                    % copy the topic and add the unsampled/unjudeged
                    % relevantce degree
                    sample = topic{1, 1};                    
                    sample.RelevanceDegree = addcats(sample.RelevanceDegree, ...
                        UNSAMPLED_UNJUDGED, 'Before', notRelevant);
                    
                    % mark the unsampled documents with the
                    % unsampled/unjudged relevance degree
                    sample.RelevanceDegree(unsampled) = UNSAMPLED_UNJUDGED;
                                                         
                    varargout{s+1} = {sample};
                    
                end;

            % It takes the first sampleSize(s) documents from each topic of
            % each run, merges them into a pool for that topic and
            % intersect this pool with the original one to get the
            % assessments.
            case 'pooldepthsampling'
                        
                % the total number of runs
                RUNS = width(runSet);
                
                % generate the samples
                for s = 1:sampleNumber
                    
                    % reset the newly pooled documents
                    documents = {};
                    
                    % for each run, extract the top sampleSize(s)
                    % documents. If the run retrieves less than 
                    % sampleSize(s), then return all the documents
                    % retrieved by the run.
                    for cr = 1:RUNS
                        documents = union(documents, ...
                            runSet{ct, cr}{1, 1}{ ...
                                1:min(height(runSet{ct, cr}{1, 1}), sampleSize(s)), ...
                                'Document'}); 
                         
                    end;
                    
                    % copy the topic and add the unsampled/unjudeged
                    % relevantce degree
                    sample = topic{1, 1};                    
                    sample.RelevanceDegree = addcats(sample.RelevanceDegree, ...
                        UNSAMPLED_UNJUDGED, 'Before', notRelevant);

                    % find which documents in the pool correspond to the 
                    % newly pooled documents
                    unsampled = ismember(sample.Document, documents);

                    % identify those documents in the pool which have no
                    % correspondence in the newely pooled documents
                    unsampled = ~unsampled;
            
                    % mark the unsampled documents with the
                    % unsampled/unjudged relevance degree
                    sample.RelevanceDegree(unsampled) = UNSAMPLED_UNJUDGED;

                    varargout{s+1} = {sample};
                    
                end;                             
                
        end;
                      
        % increment the index of the current topic under processing
        ct = ct + 1;    
        
         if(verbose)
            fprintf('\n');
        end;
                      
    end % processTopic
    
end



