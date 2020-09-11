%% kendall
% 
% Computes Kendall's tau B for a run set measured according to different
% measures.

%% Synopsis
%
%   [tauB, meanTauB, stdTauB, ciTauB] = kendall(varargin)
%
% For further details about the computation of Kendall's tau B correlation
% please see at the MATLAB <http://www.mathworks.it/it/help/stats/corr.html 
% corr> and <http://www.mathworks.it/it/help/stats/tiedrank.html tiedrank>
% functions on which |kendall| relies on.
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
% * *|IgnoreNaN|* (optional) - a boolean specifying whether |NaN| values 
% have to be ignored when computing mean and standard deviation. The
% default is |false|.
% * *|Statistic|* (optional) - a string specifying the statistic to be used
% to aggregate the measures, either |Mean| or |Median|. The default is
% |Mean|.
% * *|Bootstrap|* (optional) - a boolean specifying whether bootstrapping
% has to be performed. The output parameters depending on bootstrap
% (meanTauB, stdTauB, ciTauB) can be used only if it is |true|. The default
% is |false|.
% * *|BootstrapSample|* (optional) - a scalar integer value greater than
% zero which indicates how many samples have to be used in the bootstrap.
% The default is |1000|.
% * *|UseParalle|* (optional) - a boolean specifying whether parallel 
% computation of bootstrap has to be used or not. The default is |false|.
% * *|Rounding|* (optional) - a scalar integer value greater than zero
% specifying how many decimal digits to consider in computing correlation.
% An empty |[]| scalar can be passed to indicate to use the maximum
% precision possible. The default value is |4|. Note that, since compated
% measures are ratios, saying 4 digits means, e.g., |12.34%| and not
% |12.3456%|.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |tauB| - a table containing the pairwise Kendall's tau-B correlation
% among the provided measures according to the specified aggregation
% statistic. Row and column names are the short names of the analysed
% measures.
% * |pTauB| - a table containing the pairwise p-value of the Kendall's tau-B 
% correlation among the provided measures according to the specified 
% aggregation statistic. Row and column names are the short names of the analysed
% measures.
% * |meanTauB| (only if |Bootstrap| is |true|) - a table containing the 
%  mean of the pairwise bootstrapped Kendall's tau-B correlation
% among the provided measures according to the specified aggregation
% statitic. Row and column names are the short names of the analysed
% measures. 
% * |stdTauB| (only if |Bootstrap| is |true|) - a table containing the 
% standad deviation of the pairwise bootstrapped Kendall's tau-B correlation
% among the provided measures according to the specified aggregation
% statitic. Row and column names are the short names of the analysed
% measures. 
% * |ciTauB| (only if |Bootstrap| is |true|) - a table containing the 
% confidence intervals of the pairwise bootstrapped Kendall's tau-B 
% correlation among the provided measures according to the specified 
% aggregation statitic. Row and column names are the short names of the 
% analysed measures, values are bidimensional vector where the first and
% secondo element are, respectively, the lower and upper bound of the
% confidence interval for the correlation of that measure pair.

%% Example of use
%  
%   ap = averagePrecision(pool, runSet);
%   p10 = precision(pool, runSet, 'CutOffs', 10);
%   p20 = precision(pool, runSet, 'CutOffs', 20);
%   p30 = precision(pool, runSet, 'CutOffs', 30);
%   Rprec = precision(pool, runSet, 'Rprec', true);
%   [tauB, meanTauB, stdTauB, ciTauB] = kendall(ap, p10, p20, p30, Rprec, 'Bootstrap', true)
%
% It computes the correlation between AP, P@10, P@20, P@30, and Rprec, also
% using the bootstrap
%
% It returns the |tauB| table.
%
%   tauB = 
%
%               AP        P_10       P_20       P_30       Rprec 
%             _______    _______    _______    _______    _______
%
%    AP             1    0.74885    0.75949    0.71954    0.94483
%    P_10     0.74885          1    0.91119     0.8318    0.73042
%    P_20     0.75949    0.91119          1    0.88378    0.74108
%    P_30     0.71954     0.8318    0.88378          1    0.72874
%    Rprec    0.94483    0.73042    0.74108    0.72874          1
%
%
% The |meanTauB| and |stdTauB| tables have the same structure as the |tauB|
% table. 
%
% It returns the |ciTauB| table.
%
%   ciTauB = 
%                     AP                    P_10                   P_20        
%           ___________________    ___________________    ___________________
%
%    AP             1           1    0.57866     0.84471    0.59559     0.85289
%    P_10     0.57866     0.84471          1           1    0.72922     0.96674
%    P_20     0.59559     0.85289    0.72922     0.96674          1           1
%    P_30     0.47958     0.84234    0.66284     0.90703    0.71535     0.94313
%    Rprec    0.87039     0.98095    0.53826     0.82679    0.53358      0.8335
%
%
%                    P_30                   Rprec       
%             ___________________    ___________________
%
%    AP       0.47958     0.84234    0.87039     0.98095
%    P_10     0.66284     0.90703    0.53826     0.82679
%    P_20     0.71535     0.94313    0.53358      0.8335
%    P_30           1           1    0.52307     0.84435
%    Rprec    0.52307     0.84435          1           1
%
%% References
% 
% Please refer to:
%
% * Efron, B. and Tibshirani, R. J. (1994). _An Introduction to the 
% Bootstrap_. Chapman and Hall/CRC, USA.
% * Kendall, M. G. (1938). A New Measure of Rank Correlation. _Biometrika_, 
% 30(1/2):81-93.
% * Kendall, M. G. (1945). The Treatment of Ties in Ranking Problems.
% _Biometrika_, 33(3):239-251.
% * Kendall, M. G. and Gibbons, J. D. (1990). _Rank Correlation Methods_.
% Oxford University Press, New York, USA, 5th edition.
% * Lovric, M. (2011). _International Encyclopedia of Statistical Science_.
% Springer-Verlag, Heidelberg, Germany.
% * Sakai, T. (2006). Evaluating Evaluation Metrics based on the Bootstrap. 
% In Efthimiadis, E. N., Dumais, S., Hawking, D., and Jävelin, K., editors,
% _Proc. 29th Annual International ACM SIGIR Conference on Research and 
% Development in Information Retrieval (SIGIR 2006)_, pages 525-532. 
% ACM Press, New York, USA.
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
function [tauB, pTauB, meanTauB, stdTauB, ciTauB] = kendall(varargin)

    % handles to anonymous functions to ease computations
    persistent MEDIAN TAU_B;
    
     % initialize anonymous functions
    if isempty(MEDIAN)
        
        % median (ignoring NaN)
        MEDIAN = @(x) prctile(x, 50);
        
        % Kendall's tau-B
        TAU_B = @(x) corr(x, 'type', 'Kendall');    
    end;
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
          
    % extract additional name-value pairs
    [nvp, varargin] = extractNameValuePairs(varargin{:});
    
    % parse the variable inputs
    pnames = {'IgnoreNaN', 'Statistic', 'Bootstrap', 'BootstrapSamples', 'UseParallel', 'Rounding', 'Verbose'};
    dflts =  {false,       'mean',      false,       1000,                false,        4,           false};
    
    if verLessThan('matlab', '9.2.0')
        [ignoreNaN, statistic, bootstrap, bootstrapSamples, useParallel, rounding, verbose, supplied] ...
             = matlab.internal.table.parseArgs(pnames, dflts, nvp{:});
    else
        [ignoreNaN, statistic, bootstrap, bootstrapSamples, useParallel, rounding, verbose, supplied] ...
             = matlab.internal.datatypes.parseArgs(pnames, dflts, nvp{:});
    end
    
    
    
    if supplied.IgnoreNaN
        % check that ignoreNaN is a non-empty scalar logical value
        validateattributes(ignoreNaN, {'logical'}, {'nonempty','scalar'}, '', 'IgnoreNaN');
    end;   
        
    if supplied.Statistic        
        % check that Statistic is a non-empty string
        validateattributes(statistic, ...
            {'char', 'cell'}, {'nonempty', 'vector'}, '', ...
            'Statistic');
        
         if iscell(statistic)
            % check that statistic is a cell array of strings with one element
            assert(iscellstr(statistic) && numel(statistic) == 1, ...
                'MATTERS:IllegalArgument', 'Expected Statistic to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        statistic = char(strtrim(statistic));
        statistic = statistic(:).';
        
        % check that Statistic assumes a valid value
        validatestring(statistic, ...
            {'Mean', 'Median'}, '', 'Statistic');             
    end; 
    
    if supplied.Bootstrap
        % check that bootstrap is a non-empty scalar logical value
        validateattributes(bootstrap, {'logical'}, {'nonempty', 'scalar'}, '', 'Bootstrap');
    end;
    
    % cannot ask for outputs derived from bootstrap if bootstrap has not
    % been asked
    if nargout > 2 && ~bootstrap
        error('MATTERS:IllegalArgument', 'Cannot ask for bootstrap dependent outputs (meanTauB, stdTauB, ciTauB) when no bootstrap has been asked.');
    end;
    
    if supplied.BootstrapSamples
        % check that BootstrapSamples is a nonempty scalar integer value
        % greater than 0
        validateattributes(bootstrapSamples, {'numeric'}, ...
            {'nonempty', 'scalar', 'integer', '>', 0}, '', 'BootstrapSamples');
    end;
        
    if supplied.UseParallel
        if ~supplied.Bootstrap
             error('MATTERS:IllegalArgument', 'Cannot ask for parallel computation when no bootstrap has been asked.');
        end;
        
        % check that parallel is a non-empty scalar logical value
        validateattributes(useParallel, {'logical'}, {'nonempty','scalar'}, '', 'UseParallel');
    end;  
        
    if supplied.Rounding && ~isempty(rounding)
        % check that Rounding  is a nonempty scalar integer value
        % greater than 0
        validateattributes(rounding, {'numeric'}, ...
            {'nonempty', 'scalar', 'integer', '>', 0}, '', 'Rounding');
    end;
    
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;  
              
    % number of measures to be correlated
    n = length(varargin);
    
    % determine the statistics to be used
    switch lower(statistic)
        case 'mean'
            if ignoreNaN
                stat = @nanmean;
            else
                stat = @mean;
            end
        case 'median'
        stat = MEDIAN;
    end;   
    
    % ensure we have a table of measures as first input
    validateattributes(varargin{1}, {'table'}, {'nonempty'}, '', 'measuredRunSet', 1);
    
    % only numeric and scalar values can be processed
    if ~isnumeric(varargin{1}{1, 1}) || ~isscalar(varargin{1}{1, 1})
         error('MATTERS:IllegalArgument', 'Run set %s for measure %s does not contain numeric scalar values.', ...
            varargin{1}.Properties.UserData.identifier, varargin{1}.Properties.UserData.shortName);       
    end;
    
    % create a matrix with all the ranking of the systems according to the
    % different measures. Each row is a system (width of one of the input
    % tables), each column is a ranking of systems according to a measure
    % (number of input parameters)
    ranks = NaN(width(varargin{1}), n);
    
    % list of measure names
    measures = cell(1, n);
        
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing Kendall''s tau-B for run set %s with respect to pool %s: %d measures to be processed across %d runs.\n\n', ...
            varargin{1}.Properties.UserData.identifier, ....
            varargin{1}.Properties.UserData.pool, n, width(varargin{1}));

        fprintf('Settings:\n');
        fprintf('  - statistics used to aggregate measures: %s;\n', statistic);
        
        if ignoreNaN
           fprintf('  - NaN values will be ignored, when using mean as aggregate statistic;\n');
        else
            fprintf('  - NaN values will not be ignored, when using mean as aggregate statistic;\n');
        end
        
        if ~isempty(rounding)
            fprintf('  - rounding at %d decimal digits;\n', rounding);
        else
            fprintf('  - using maximum MATLAB precision;\n');
        end
        
        if bootstrap
            fprintf('  - bootstrap will be performed;\n');
            fprintf('    + bootstrap data samples: %s;\n', bootstrapSamples);
            
            if useParallel
                fprintf('    + parallel computing will be used;\n');
            else
                fprintf('    + parallel computing will not be used;\n');
            end;
        else
            fprintf('  - bootstrap will not be performed;\n');
        end;
                
        fprintf('\n');
    end;
    
    % compute the statistic of the first measure
    ranks(:, 1) = varfun(stat, varargin{1}, 'OutputFormat', 'Uniform').';
    
    % save the short name of the measure
    measures{1} = varargin{1}.Properties.UserData.shortName;
    
    % check input tables and compute mean
    for k = 2:n
        
        % ensure we have a table of measures as input
        validateattributes(varargin{k}, {'table'}, {'nonempty'}, '', 'measuredRunSet', 1);
        
        %{
            Imposing that the same run set and pool for all the compared
            mesaures may be too restrictive, e.g. it would not allow to
            compare correlation among two different pooling strategies.
        
            % check that measures are from the same run set
            if ~isequal(varargin{k-1}.Properties.UserData.identifier, ...
                varargin{k}.Properties.UserData.identifier) 

                error('MATTERS:IllegalArgument', 'Run set %s for measure %s cannot be compared to run set %s for measure %s.', ...
                varargin{k-1}.Properties.UserData.identifier, varargin{k-1}.Properties.UserData.shortName, ...
                varargin{k}.Properties.UserData.identifier, varargin{k}.Properties.UserData.shortName);       
            end;

            % check that measures are from the same pool
            if ~isequal(varargin{k-1}.Properties.UserData.pool, ...
                varargin{k}.Properties.UserData.pool) 

                error('MATTERS:IllegalArgument', 'Run set %s for measure %s refers to pool %s which is different from pool %s for measure %s.', ...
                varargin{k-1}.Properties.UserData.identifier, varargin{k-1}.Properties.UserData.shortName, ...
                varargin{k-1}.Properties.UserData.pool, varargin{k}.Properties.UserData.pool, ...
                varargin{k}.Properties.UserData.shortName);       
            end;
        %}
        
        % check that the measures refer to the same topics
        if ~isequal(varargin{k-1}.Properties.RowNames, ...
            varargin{k}.Properties.RowNames)

            error('MATTERS:IllegalArgument', 'Run set %s for measure %s refers to topics different from those for measure %s.', ...
            varargin{k-1}.Properties.UserData.identifier, varargin{k-1}.Properties.UserData.shortName, ...
            varargin{k}.Properties.UserData.shortName);       
        end;
         
        % check that the measures refer to the same runs
        if ~isequal(varargin{k-1}.Properties.VariableNames, ...
            varargin{k}.Properties.VariableNames)

            error('MATTERS:IllegalArgument', 'Run set %s for measure %s refers to runs different from those for measure %s.', ...
            varargin{k-1}.Properties.UserData.identifier, varargin{k-1}.Properties.UserData.shortName, ...
            varargin{k}.Properties.UserData.shortName);            
        end;
        
        % only numeric and scalar values can be processed
        if ~isnumeric(varargin{k}{1, 1}) || ~isscalar(varargin{k}{1, 1})
             error('MATTERS:IllegalArgument', 'Run set %s for measure %s does not contain numeric scalar values.', ...
                varargin{k}.Properties.UserData.identifier, varargin{k}.Properties.UserData.shortName);       
        end;
        
        % compute the statistic of the k-th measure
        ranks(:, k) = varfun(stat, varargin{k}, 'OutputFormat', 'Uniform').';  
        
        % save the short name of the measure
        measures{k} = varargin{k}.Properties.UserData.shortName;
    end;
    
    % round to the requested decimal digits
    if ~isempty(rounding) 
        ranks = roundn(ranks, -rounding);
    end;
    
    [tauB, pTauB] = corr(ranks, 'type', 'Kendall');
    
    tauB = array2table(tauB);
    tauB.Properties.RowNames = measures;
    tauB.Properties.VariableNames = measures;
    
    pTauB = array2table(pTauB);
    pTauB.Properties.RowNames = measures;
    pTauB.Properties.VariableNames = measures;
    
    
    if bootstrap
    
        if(verbose)
            fprintf('Computing the bootstrapped Kendall''s tau-B'\n');
        end;
        
        % additional options for the bootstrap
        opt = statset('UseParallel', useParallel);
        
        % compute Kendall's tauB with bootstrapStamples iterations
        tauBootstrap = bootstrp(bootstrapSamples, TAU_B, ranks, 'Options', opt);
        
        % computed the mean of the bootstrap tauB
        if ignoreNaN
            meanTauB = array2table(reshape(nanmean(tauBootstrap), n, n));
        else
            meanTauB = array2table(reshape(mean(tauBootstrap), n, n));
        end;        
        meanTauB.Properties.RowNames = measures;
        meanTauB.Properties.VariableNames = measures;
        
        % computed the standard deviationt of the bootstrap tauB
        if ignoreNaN
            stdTauB = array2table(reshape(nanstd(tauBootstrap), n, n));
        else
            stdTauB = array2table(reshape(std(tauBootstrap), n, n));
        end;
        stdTauB.Properties.RowNames = measures;
        stdTauB.Properties.VariableNames = measures;
        
        if(verbose)
            fprintf('Computing the confidence intervals for the bootstrapped Kendall''s tau-B'\n');
        end;
        
        % allocate the table for the confidence interval of tauB
        ciTauB = cell2table(repmat({NaN(1, 2)}, n, n));
        ciTauB.Properties.RowNames = measures;
        ciTauB.Properties.VariableNames = measures;
                
        % compute the confidence interval
        ci = bootci(bootstrapSamples, {TAU_B, ranks}, 'Options', opt);
        
        % extract the confidence intervals and put them into the table
        
        % transform ci into a 1xnxn cell array where the third  dimension
        % represents the confidence intervals for the correlation of each
        % measure of one measure with the others.
        % For example, assuming that n = 5, so we are correlating five
        % measures, the confidence intervals for the first measures 
        % will look like
        %
        % ci(:,:,1) = 
        %
        % [2x1 double]    [2x1 double]    [2x1 double]    [2x1 double]    [2x1 double]
        %
        % where each double array contains the lower and upper bounds of
        % the confidence interval for the correlation of the first measure
        % with the other five ones.
        % 
        % To transform it into a table we still have to transpose each double
        % array.
        ci = num2cell(ci, 1);
        for k = 1:n
            ciTauB(k, :) = cell2table(cellfun(@transpose, ...
                ci(:, :, k), 'UniformOutput', false));
        end;
                   
    end;
end % kendall
