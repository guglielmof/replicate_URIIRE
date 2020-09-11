%% discriminativePower
% 
% Computes the discriminative power of a measure.

%% Synopsis
%
%   [asl, dp, delta, replicates] = discriminativePower(measuredRunSet, varargin)
%
% 
% *Parameters*
%
% * *|measuredRunSet1|*, *|measuredRunSet2|*, ..., *|measuredRunSetN|* - 
% two or more variables corresponding to different measures of a given run 
% set. It is a table in the same format returned by, for example, 
% <../measure/precision.html precision> or by 
% <../measure/averagePrecision.html averagePrecision>. All the measured run
% sets must refer to the same pool, topics, and runs. Moreover, they must
% be scalar-valued measures, like average precision or precision at 10
% retrieved documents.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|Method|* (optional) - a string specifying the method to be used for
% computing discriminative power. It can be either |PairedBootstrapTest|
% (see Sakai, 2006) or |RandomisedTukeyHSDTest| (see Sakai, 2012).
% The default is |PairedBootstrapTest|.
% * *|Alpha|* (optional) - a scalar specifying the requested confidence
% level. The default is |0.05|.
% * *|IgnoreNaN|* (optional) - a boolean specifying whether |NaN| values 
% have to be ignored when computing mean and standard deviation. The
% default is |false|.
% * *|Samples|* (optional) - a scalar integer value greater than
% zero which indicates how many samples have to be used in the test.
% The default is |1000| in the case of |PairedBootstrapTest| (see 
% Sakai, 2006, 2012 and 2014) and |5000| in the case of 
% |RandomisedTukeyHSDTest|(see Sakai, 2012 and 2014).
% * *|Replicates|* (optional) - an integer-valued matrix containing the
% replicates to be used for the bootstrap or randomization. In the case of
% the |PairedBootstrapTest|, it is a |t*samples| matrix (|t| number of
% topics) where each column (a replicate) represents a sampling with 
% repetitions of the topics. In the case of the |RandomisedTukeyHSDTest|,
% it is a |samples*(t*s)| matrix (|t| number of topics, |s| number of 
% systems) where each row (a replicate) represents a topic-by-topic random
% permutation of a full |measuredRunSet|; each row contains the linear
% indexes needed to produce such permutation.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |asl| - a table containing as many rows as many input measures and each
% cell contains a table with the pairwise Achieved Significance Level (ASL) 
% among the  provided systems. The |UserData| property contains a struct 
% with the following fields: |identifier| of the analysed run set; |pool| with the
% identifier of the pool with respect to which the measure has been computed;
% |name| and |shortName| of the computed measure; |method| with the method
% used for computing the discriminative power; |alpha| with the requested
% significance level alpha; |samples| with the number of samples used for
% computing the discriminative power.
% * |dp|  - a table containing as many rows as many input measures and each
% cell contains the discriminative power, i.e. the ratio of the number of 
% times the requested ASL has been achieved over all the possible system
% pairs.
% * |delta| - a table containing as many rows as many input measures and each
% cell contains the estimated difference needed to expect two system being
% significantly different.
% * |replicates| - an integer-valued matrix containing the
% replicates that have been used for the bootstrap or randomization. In the case of
% the |PairedBootstrapTest|, it is a |t*samples| matrix (|t| number of
% topics) where each column (a replicate) represents a sampling with 
% repetitions of the topics. In the case of the |RandomisedTukeyHSDTest|,
% it is a |samples*(t*s)| matrix (|t| number of topics, |s| number of 
% systems) where each row (a replicate) represents a topic-by-topic random
% permutation of a full |measuredRunSet|; each row contains the linear
% indexes needed to produce such permutation.

%% Example of use
%  
%   [asl, dp, delta] = discriminativePower(ap, p10, p100, Rprec, bpref, rbp, 'Method', 'PairedBootstrapTest');
%
% It produces the following results.
%
%   asl = 
%   
%                       ASL     
%                  _____________
%   
%       AP         [5x5 table]
%       P_10       [5x5 table]
%       P_100      [5x5 table]
%       Rprec      [5x5 table]
%       bpref      [5x5 table]
%       RBP_080    [5x5 table]   
%
% It is possible to get the ASL for AP with
%
%   asl{'AP', 1}{1, 1}
%
% which returns
%
%   ans = 
%                   System_1    System_2    System_3    System_4    System_5
%                   ________    ________    ________    ________    ________
%   
%       System_1    NaN         0.955       0.048        0.32       0.007   
%       System_2    NaN           NaN       0.703       0.511       0.133   
%       System_3    NaN           NaN         NaN       0.776       0.024   
%       System_4    NaN           NaN         NaN         NaN       0.007   
%       System_5    NaN           NaN         NaN         NaN         NaN   
%
% Note that all the ASL outside the upper triangle are NaN since it does
% not make sense to compute them.
%
%   dp = 
%   
%                  DiscriminativePower
%                  ___________________
%   
%       AP               0.15556  
%       P_10             0.15556  
%       P_100                0.2  
%       Rprec            0.17778  
%       bpref            0.17778  
%       RBP_080          0.13333     
%   
%   delta = 
%   
%                   Delta  
%                  ________
%   
%       AP         0.095244
%       P_10           0.29
%       P_100         0.152
%       Rprec        0.1018
%       bpref      0.096026
%       RBP_080     0.18276
%
%
%% References
% 
% Please refer to:
%
% * Carterette, B. A. (2012). Multiple Testing in Statistical Analysis of 
% Systems-Based Information Retrieval Experiments. _ACM Transactions on 
% Information Systems (TOIS)_, 30(1):4:1-4:34.
% * Sakai, T. (2006). Evaluating Evaluation Metrics based on the Bootstrap. 
% In Efthimiadis, E. N., Dumais, S., Hawking, D., and Järvelin, K., editors, 
% _Proc. 29th Annual International ACM SIGIR Conference on Research and 
% Development in Information Retrieval (SIGIR 2006)_, pages 525-532. ACM 
% Press, New York, USA.
% * Sakai, T. (2012). Evaluation with Informational and Navigational Intents. 
% In Mille, A., Gandon, F. L., Misselis, J., Rabinovich, M., and Staab, S.,
% editors, _Proc. 21st International Conference on World Wide Web (WWW 2012)_, 
% pages 499-508. ACM Press, New York, USA.
% * Sakai, T. (2014). Metrics, Statistics, Tests. In Ferro, N., editor,
% _Bridging Between Information Retrieval and Databases - PROMISE Winter School 2013, Revised Tutorial Lectures_, 
% pages 116-163. Lecture Notes in Computer Science (LNCS) 8173, Springer,
% Heidelberg, Germany.
% * Smucker, M. D., Allan, J., and Carterette, B. A. (2007). A Comparison
% of Statistical Significance Tests for Information Retrieval Evaluation. 
% In Silva, M. J., Laender, A. A. F., Baeza-Yates, R., McGuinness, D. L., 
% Olstad, B., Olsen, Ø. H., and Falcão, A. a., editors, 
% _Proc. 16th International Conference on Information and Knowledge Management (CIKM 2007)_,
% pages 623-632. ACM Press, New York, USA.
%
%% Acknowledgements
% 
% We would like to warmly thank Tetsuya Sakai, Waseda University, Japan for
% providing us his original C/shell source code for computing the Paired 
% Bootstrap Test and the Randomised Tukey HSD Test and for his great 
% willingness in discussing with us the details of the implementation.

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
function [asl, dp, delta, replicates] = discriminativePower(varargin)
   
    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
    % extract additional name-value pairs
    [nvp, varargin] = extractNameValuePairs(varargin{:});
    
    % parse the variable inputs
    pnames = {'Method',              'IgnoreNaN', 'Alpha', 'Samples', 'Replicates', 'Verbose'};
    dflts =  {'PairedBootstrapTest', false,       0.05,    1000,       [],          false};
    
    if verLessThan('matlab', '9.2.0')
        [method, ignoreNaN, alpha, samples, replicates, verbose, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, nvp{:});
    else
        [method, ignoreNaN, alpha, samples, replicates, verbose, supplied] ...
         = matlab.internal.datatypes.parseArgs(pnames, dflts, nvp{:});
    end  
        
    if supplied.Method        
        % check that method is a non-empty string
        validateattributes(method, ...
            {'char', 'cell'}, {'nonempty', 'vector'}, '', 'Method');
        
        if iscell(method)
            % check that method is a cell array of strings with one element
            assert(iscellstr(method) && numel(method) == 1, ...
                'MATTERS:IllegalArgument', 'Expected Method to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        method = char(strtrim(method));
        method = method(:).';
        
        % check that method assumes a valid value
        validatestring(method, ...
            {'PairedBootstrapTest', 'RandomisedTukeyHSDTest'}, '', 'Method');             
    end;  
              
    if supplied.IgnoreNaN
        % check that ignoreNaN is a non-empty scalar logical value
        validateattributes(ignoreNaN, {'logical'}, {'nonempty','scalar'}, '', 'IgnoreNaN');
    end;   
    
    if supplied.Alpha
        % check that Alpha is a nonempty scalar "real" value
        % greater than 0 and less than or equal to 1
        validateattributes(alpha, {'numeric'}, ...
            {'nonempty', 'scalar', 'real', '>', 0, '<=', 1}, '', 'Alpha');
    end;
            
    if supplied.Samples        
        % check that BootstrapSamples is a nonempty scalar integer value
        % greater than 0
        validateattributes(samples, {'numeric'}, ...
            {'nonempty', 'scalar', 'integer', '>', 0}, '', 'Samples');
    else 
        % if not explicitly provided, set a proper default for the samples
        if strcmpi(method, 'PairedBootstrapTest') 
            samples = 1000;
        else
            samples = 5000;
        end;
    end;
    
    % number of measures whose discriminative power has to be computed
    m = length(varargin);
    
    % number of systems to be compared
    s = length(varargin{1}.Properties.VariableNames);
    
    % number of pair
    pairs = nchoosek(s, 2);
    
    % number of topics to be processed
    t = length(varargin{1}.Properties.RowNames);

    
    if supplied.Replicates
        % check that replicates is a nonempty integer-valued matrix with
        % the correct size.
        if strcmpi(method, 'PairedBootstrapTest') 
            validateattributes(replicates, {'numeric'}, ...
                {'nonempty', 'integer', '>', 0, '<=', t, 'numel', t*samples}, ...
                '', 'Replicates');
        else
            validateattributes(replicates, {'numeric'}, ...
                {'nonempty', 'integer', '>', 0, '<=', t*s, 'numel', t*s*samples}, ...
                '', 'Replicates');
        end;                     
    end;
                         
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;  
    
    
    % ensure we have a table of measures as first input
    validateattributes(varargin{1}, {'table'}, {'nonempty'}, '', 'measuredRunSet_1', 1);
    
    % only numeric and scalar values can be processed
    if ~isnumeric(varargin{1}{1, 1}) || ~isscalar(varargin{1}{1, 1})
         error('MATTERS:IllegalArgument', 'Run set %s for measure %s does not contain numeric scalar values.', ...
            varargin{1}.Properties.UserData.identifier, varargin{1}.Properties.UserData.shortName);       
    end;
         
    % list of measure names
    measures = cell(1, m);
    
    % save the short name of the first measure
    measures{1} = varargin{1}.Properties.UserData.shortName;
    
    % check input tables and compute mean
    for v = 2:m
        
        % ensure we have a table of measures as input
        validateattributes(varargin{v}, {'table'}, {'nonempty'}, '', num2str(v, 'measuredRunSet_%d'));
             
        % check that the measures refer to the same topics
        if ~isequal(varargin{v-1}.Properties.RowNames, ...
            varargin{v}.Properties.RowNames)

            error('MATTERS:IllegalArgument', 'Run set %s for measure %s refers to topics different from those for measure %s.', ...
            varargin{v-1}.Properties.UserData.identifier, varargin{v-1}.Properties.UserData.shortName, ...
            varargin{v}.Properties.UserData.shortName);       
        end;
         
        % check that the measures refer to the same runs
        if ~isequal(varargin{v-1}.Properties.VariableNames, ...
            varargin{v}.Properties.VariableNames)

            error('MATTERS:IllegalArgument', 'Run set %s for measure %s refers to runs different from those for measure %s.', ...
            varargin{v-1}.Properties.UserData.identifier, varargin{v-1}.Properties.UserData.shortName, ...
            varargin{v}.Properties.UserData.shortName);            
        end;
        
        % only numeric and scalar values can be processed
        if ~isnumeric(varargin{v}{1, 1}) || ~isscalar(varargin{v}{1, 1})
             error('MATTERS:IllegalArgument', 'Run set %s for measure %s does not contain numeric scalar values.', ...
                varargin{v}.Properties.UserData.identifier, varargin{v}.Properties.UserData.shortName);       
        end;
                
        % save the short name of the measure
        measures{v} = varargin{v}.Properties.UserData.shortName;
    end;
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing discriminative power for run set %s and measure %s with respect to pool %s: %d runs and % pairs to be processed.\n\n', ...
            varargin{1}.Properties.UserData.identifier, ....
            varargin{1}.Properties.UserData.shortName, ...
            varargin{1}.Properties.UserData.pool, s, pairs);

        fprintf('Settings:\n');
        
        fprintf('  - method %s;\n', method);
        
        fprintf('  - confidence level alpha %d;\n', alpha);
        
        if ignoreNaN
           fprintf('  - NaN values will be ignored;\n');
        else
           fprintf('  - NaN values will not be ignored;\n');
        end
              
        fprintf('  - data samples: %d;\n', samples);

        fprintf('\n');
    end;
       
    % the achieved significance level for each measure
    asl = cell2table(cell(m, 1));
    asl.Properties.RowNames = measures;
    asl.Properties.VariableNames = {'ASL'};
    asl.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    asl.Properties.UserData.pool =varargin{1}.Properties.UserData.pool;
    asl.Properties.UserData.method = method;           
    switch lower(method)
        case 'pairedbootstraptest'            
            asl.Properties.UserData.shortMethod = 'PBT';  
        case 'randomisedtukeyhsdtest'
           asl.Properties.UserData.shortMethod = 'RTHSDT';
    end;   
    asl.Properties.UserData.alpha = alpha;
    asl.Properties.UserData.replicates = samples;
    
    % the achieved significance level ratio for each measure
    dp = array2table(NaN(m, 1));
    dp.Properties.RowNames = measures;
    dp.Properties.VariableNames = {'DiscriminativePower'};
    dp.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    dp.Properties.UserData.pool =varargin{1}.Properties.UserData.pool;
    dp.Properties.UserData.method = method;           
    switch lower(method)
        case 'pairedbootstraptest'            
            dp.Properties.UserData.shortMethod = 'PBT';  
        case 'randomisedtukeyhsdtest'
           dp.Properties.UserData.shortMethod = 'RTHSDT';
    end;   
    dp.Properties.UserData.alpha = alpha;
    dp.Properties.UserData.replicates = samples;
    
    % the achieved significance level ratio for each measure
    delta = array2table(NaN(m, 1));
    delta.Properties.RowNames = measures;
    delta.Properties.VariableNames = {'Delta'};
    delta.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    delta.Properties.UserData.pool =varargin{1}.Properties.UserData.pool;
    delta.Properties.UserData.method = method;           
    switch lower(method)
        case 'pairedbootstraptest'            
            delta.Properties.UserData.shortMethod = 'PBT';  
        case 'randomisedtukeyhsdtest'
           delta.Properties.UserData.shortMethod = 'RTHSDT';
    end;   
    delta.Properties.UserData.alpha = alpha;
    delta.Properties.UserData.replicates = samples;
        
    switch lower(method)
        case 'pairedbootstraptest'            
            % compute the Paired Bootstrap Test on each pair of systems
            computePairedBootstrapTest();
            
        case 'randomisedtukeyhsdtest'
            % compute the Randomise Tukey HSD Test on each pair of systems
            computeRandomisedTukeyHSDTest();
    end;
               
         
    %%
    
    % computes the Paired Bootstrap Test
    %
    % See Figures 1, 2 and 5 of Sakai, 2006
    % See Figures 2 and 3 of Sakai, 2012    
    % See Figures 11 and 12 of Sakai, 2014
    function [] = computePairedBootstrapTest()
        
        % fraction of the samples to pick up 
        ba = ceil(alpha * samples);
        
        % generate all the bootstrap replicates, if needed
        if ~supplied.Replicates
            replicates = randi(t, t, samples);
        end;
        
        % for each measure
        for k = 1:m
            
            % the achieved significance level (ASL) resulting from the test
            currentAsl = NaN(s);
        
            % estimated performance difference required for achieving a given
            % ASL
            currentDelta = NaN(s);
            
            % the dataset for the current measure
            dataset = varargin{k}{:, :};
                                    
            % compute only the upper triangle
            for r = 1:s
                for c = r+1:s 

                    % per topic performance differences - H0 z comes from a
                    % distribution with zero mean
                    z = dataset(:, r) - dataset(:, c);

                    if ignoreNaN
                        zMean = nanmean(z);
                        zStd = nanstd(z);

                        % if we have NaN values, the sample size is less than 
                        % the number of rows in the dataset 
                        sampleSize = sum(~isnan(z));
                    else
                        zMean = mean(z);
                        zStd = std(z);  

                       sampleSize = t;
                    end;

                    % compute the (absolute value of the) observed t statistics
                    zT = abs(zMean ./ (zStd ./ sqrt(sampleSize)));

                    % empirical distribution under H0 to be sampled with the
                    % bootstrap
                    w = z - zMean;

                    % observed t statistic for each bootstrap replicate
                    wbT = NaN(1, samples);

                    % observed mean for each bootstrap replicate
                    wbMean = NaN(1, samples);

                    for b = 1:samples

                        % get the b-th replicate
                        wb = w(replicates(:, b));

                        if ignoreNaN
                            wbMean(b) = nanmean(wb);
                            wbStd = nanstd(wb);

                            % if we have NaN values, the sample size is less 
                            % than  the number of rows in the dataset 
                            sampleSize = sum(~isnan(wb));
                        else
                            wbMean(b) = mean(wb);
                            wbStd = std(wb);  

                           sampleSize = t;
                        end;

                        % compute the (absolute value of the) observed t 
                        % statistics
                        wbT(b) = abs(wbMean(b) ./ (wbStd ./ sqrt(sampleSize)));
                    end;

                    % count how many times the observed t statistic of the
                    % empirical distribution is above the one of the per-topic
                    % performance differences
                    currentAsl(r, c) = length(find(wbT >= zT));

                    % sort the observed t statistics of the empirical 
                    % distribution in descending order (NaN first)
                    tmp = sort(wbT, 'descend');

                    % get the positions of the observed t statistic of the
                    % empirical distribution which are equal to the 
                    % bootstrapSamples*alpha-th largest value. It can be:
                    % - one single value
                    % - more values (but equal) 
                    % - empty, if the two systems are equal
                    pos = find(wbT == tmp(ba));

                    % if the systems are different, get absolute value of 
                    % the difference, considering only the first position 
                    % if multiple are possible
                    if ~isempty(pos)                                                              
                        currentDelta(r, c) = abs(wbMean(pos(1)));
                    end;
                end;
            end; 

            % compute the Achieved Significance Level (ASL) for each system
            % pair
            currentAsl = currentAsl / samples;

            % compute the ASL ratio and store it in the proper cell of the
            % ASL ratio table
            dp{k, 1} = length(find(currentAsl < alpha)) / pairs;

            % get the maximum delta to obtain significant differences among
            % systems and store it in the proper cell of the delta table
            delta{k, 1} = max(max(currentDelta));
            
            % transfor asl into a table and store it in the ASL table
            currentAsl = array2table(currentAsl);
            currentAsl.Properties.RowNames = varargin{k}.Properties.VariableNames;
            currentAsl.Properties.VariableNames = varargin{k}.Properties.VariableNames;
            currentAsl.Properties.UserData.identifier = varargin{k}.Properties.UserData.identifier;
            currentAsl.Properties.UserData.pool = varargin{k}.Properties.UserData.pool;
            currentAsl.Properties.UserData.name = varargin{k}.Properties.UserData.name;
            currentAsl.Properties.UserData.shortName = varargin{k}.Properties.UserData.shortName;
            currentAsl.Properties.UserData.method = method;                       
            currentAsl.Properties.UserData.shortMethod = 'PBT';  
            currentAsl.Properties.UserData.alpha = alpha;
            currentAsl.Properties.UserData.replicates = samples;
            
            asl{k, 1} = {currentAsl};
        
        end; % for each measure
        
    end % computePairedBootstrapTest

  
    %%
    
    % computes the Randomised Tukey HSD Test
    %
    % See Figures 4 and 5 of Sakai, 2012
    % See Figure 15 of Sakai, 2014
    function [] = computeRandomisedTukeyHSDTest()
            
        % for each measure, largest observed difference of mean performances 
        % for each randomised sample - honestly significant difference (HSD)
        hsd = NaN(m, samples);
        
        % generate the random each row contains the linear
        % indexes to the t*s elements in each measure, if needed
        if ~supplied.Replicates
            replicates = NaN(samples, t*s);
        end;
               
        % generate the replicates for each sample
        for b = 1:samples
                        
            % generate the permutations for each topic, transform them
            % into linear indexes and store them into the proper place of
            % replicates, if needed.
            %
            % Said (i, j) the subscript indexes, t the total number of
            % rows, bt the current row, the linear index is (j-1)*t + bt
            if ~supplied.Replicates
                for bt = 1:t                
                    replicates(b, (bt-1)*s+1:bt*s) = (randperm(s) - 1) * t + bt;                
                end;
            end;
            
            % compute the largest observed difference of mean performances for
            % each randomised sample for each measure
            for k = 1:m
                                  
                % the dataset for the current measure
                dataset = varargin{k}{:, :};

                % perform the random permutation            
                dataset = reshape(dataset(replicates(b, :)), s, t).';
                
                % compute the mean performances for each system in the
                % randomised dataset across all the topics
                if ignoreNaN
                    dMean = nanmean(dataset);
                else
                    dMean = mean(dataset); 
                end;

                % largest observed difference of the mean performances in the
                % randomised dataset for a given measure
                hsd(k, b) = max(dMean) - min(dMean);
            end;
        end;
        
        % for each measure
        for k = 1:m
            
            % the achieved significance level (ASL) resulting from the test
            currentAsl = NaN(s);

            % estimated performance difference required for achieving a given
            % ASL
            currentDelta = NaN(s);
            
            % the dataset for the current measure
            dataset = varargin{k}{:, :};
        
            % compute only the upper triangle
            for r = 1:s
                for c = r+1:s 

                    % compute the observed difference between the mean
                    % performances of the two compared systems
                    if ignoreNaN                    
                        currentDelta(r, c) = abs(nanmean(dataset(:, r)) - nanmean(dataset(:, c)));                    
                    else
                        currentDelta(r, c) = abs(nanmean(dataset(:, r)) - nanmean(dataset(:, c)));                    
                    end;


                    % compute the Achieved Significance Level (ASL) for each 
                    % system pair: number of times the observed difference is
                    % less than the honestly significant difference (HSD)
                    currentAsl(r, c) = length(find(hsd(k, :) >= currentDelta(r, c))) / samples;

                    % if the difference is not significant, then remove it
                    if (currentAsl(r, c) >= alpha)
                        currentDelta(r, c) = NaN;
                    end;
                end;
            end; 
            
              % compute the ASL ratio and store it in the proper cell of the
            % ASL ratio table
            dp{k, 1} = length(find(currentAsl < alpha)) / pairs;

            % get the maximum delta to obtain significant differences among
            % systems and store it in the proper cell of the delta table
            delta{k, 1} = max(max(currentDelta));
            
            % transfor asl into a table and store it in the ASL table
            currentAsl = array2table(currentAsl);
            currentAsl.Properties.RowNames = varargin{k}.Properties.VariableNames;
            currentAsl.Properties.VariableNames = varargin{k}.Properties.VariableNames;
            currentAsl.Properties.UserData.identifier = varargin{k}.Properties.UserData.identifier;
            currentAsl.Properties.UserData.pool = varargin{k}.Properties.UserData.pool;
            currentAsl.Properties.UserData.name = varargin{k}.Properties.UserData.name;
            currentAsl.Properties.UserData.shortName = varargin{k}.Properties.UserData.shortName;
            currentAsl.Properties.UserData.method = method;                       
            currentAsl.Properties.UserData.shortMethod = 'RTHSDT';
            currentAsl.Properties.UserData.alpha = alpha;
            currentAsl.Properties.UserData.replicates = samples;
            
            asl{k, 1} = {currentAsl};
                        
        end; % for each measure
    end % computeRandomisedTukeyHSDTest  
end % discriminativePower