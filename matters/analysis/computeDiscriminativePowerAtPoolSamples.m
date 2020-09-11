%% computeDiscriminativePowerAtPoolSamples
% 
% For each iteration and pool sample, it computes the discriminative power
% of the given measure.
%
%% Synopsis
%
%   [asl, aslStats, dp, dpStats, delta, deltaStats, replicates] = computeDiscriminativePowerAtPoolSamples(varargin)
%  
%
% *Parameters*
%
% * *|measuredRunSet1|*, *|measuredRunSet2|*, ..., *|measuredRunSetN|* - 
% two or more variables corresponding to different measures. Each measured 
% run set is a table in the same format returned by 
% <../measure/computeMeasureAtPoolSamples.html computeMeasureAtPoolSamples>.
%
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|CIAlpha|* (optional) - a scalar specifying the requested confidence
% level for computing confidence intervals. The default is |0.05|.
%
% For other possible Name-Value pairs, please see the documentation of
% <discriminativePower.html discriminativePower>
%
% *Returns*
%
% * *|asl|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the ASL
% computed on the given pool sample at the given iteration.
% * *|aslStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% ASL in |asl|.
% * *|dp|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the discriminative
% power computed on the given pool sample at the given iteration.
% * *|dpStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% discriminative power in |dp|.
% * *|delta|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the delta
% computed on the given pool sample at the given iteration.
% * *|deltaStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% delta in |delta|.
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
%   [asl, aslStats] = computeDiscriminativePowerAtPoolSamples(ap, bpref, 'CIAlpha', 0.01);
%
% It computes the Kendall's tau B among average precision, R-precision and
% precision at 10 retrieved documents and returns the following tables.
%
%   asl = 
%   
%                         Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                        ___________    ________________    ________________    ________________
%   
%       Iteration_001    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       Iteration_002    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       Iteration_003    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       Iteration_004    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       Iteration_005    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%
% As you can note, for each iteration and pool sample, contains a 2x1 table
% with the ASL for AP and bpref. For example, the ASL for the second iteration 
% and the 90% samples is given by:
%
%   asl{2, 2}{1, 1}
%   
%   ans = 
%   
%                     ASL     
%                _____________
%   
%       AP       [5x5 table]
%       bpref    [5x5 table]
%
%
% The ASL for bpref is thus given by
%
%   asl{2, 2}{1, 1}{2, 1}{1, 1}
%   
%   ans = 
%   
%                 Brkly3    CLARTA    CLARTM    CnQst1    CnQst2    
%                 ______    ______    ______    ______    ______    
%   
%       Brkly3    NaN       0.883     0.937     0.252     0.368     
%       CLARTA    NaN         NaN     0.702      0.22     0.364     
%       CLARTM    NaN         NaN       NaN     0.178     0.311     
%       CnQst1    NaN         NaN       NaN       NaN     0.055     
%       CnQst2    NaN         NaN       NaN       NaN       NaN     
%
% Similarly, for the statistics about ASL, it returns the following
% table.
%
%   aslStats = 
%   
%                                   Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                                  ___________    ________________    ________________    ________________
%   
%       Minimum                    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       Maximum                    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       Mean                       [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       StandardDeviation          [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]     
%       ConfidenceIntervalDelta    [2x1 table]    [2x1 table]         [2x1 table]         [2x1 table]        
%   
%
% where each cell has a similar structure to the ones shown above.

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
function [asl, aslStats, dp, dpStats, delta, deltaStats, replicates] = computeDiscriminativePowerAtPoolSamples(varargin)

    persistent MIN1 MAX1 MEAN1 STD1 ...
        MY_MIN MY_MAX MY_MEAN MY_STD MY_CIDELTA ...
        MIN2 MAX2 MEAN2 STD2 ...
        MY_MIN2 MY_MAX2 MY_MEAN2 MY_STD2 MY_CIDELTA2 ...
        STAT_NAMES;
    
    if isempty(MY_MIN) 
        
         MIN1 = @(x) min(x, [], 1);
         MAX1 = @(x) max(x, [], 1);
         MEAN1 = @(x) mean(x, 1);
         STD1 = @(x) std(x, 0, 1);        
        
         MY_MIN = @(x) myfunc(MIN1, x);
         MY_MAX = @(x) myfunc(MAX1, x);
         MY_MEAN = @(x) myfunc(MEAN1, x);
         MY_STD = @(x) myfunc(STD1, x);        
         MY_CIDELTA = @(x) myfunc(@myCIDelta, x);
         
         MIN2 = @(x) min(x, [], 3);
         MAX2 = @(x) max(x, [], 3);
         MEAN2 = @(x) mean(x, 3);
         STD2 = @(x) std(x, 0, 3);        
         
         MY_MIN2 = @(x) myfunc2(MIN2, x);
         MY_MAX2 = @(x) myfunc2(MAX2, x);
         MY_MEAN2 = @(x) myfunc2(MEAN2, x);
         MY_STD2 = @(x) myfunc2(STD2, x);        
         MY_CIDELTA2 = @(x) myfunc2(@myCIDelta2, x);
         
         STAT_NAMES = {'Minimum', 'Maximum', 'Mean', 'StandardDeviation', ...
             'ConfidenceIntervalDelta'};
    end;
       
    % check that we have the correct number of input arguments. 
    narginchk(1, Inf);
    
    % extract additional name-value pairs
    [nvp, varargin] = extractNameValuePairs(varargin{:});
    
    % the names of the compared measures
    measureNames = cell(1, length(varargin));
    measureShortNames = cell(1, length(varargin));

    
    for k = 1:length(varargin)
        % check that k-th measured run set is a non-empty table
        validateattributes(varargin{k}, {'table'}, {'nonempty'}, '', 'measuredRunSet', k);
        
        measureNames{k} = varargin{k}.Properties.UserData.name;
        measureShortNames{k} = varargin{k}.Properties.UserData.shortName;
    end;
    
        
    % parse the variable inputs
    pnames = {'CIAlpha', 'Replicates'};
    dflts =  {0.05,       []};
    [ciAlpha, replicates, supplied, otherArgs] = matlab.internal.table.parseArgs(pnames, dflts, nvp{:});
    
    if supplied.CIAlpha
        % check that CIAlpha is a nonempty scalar "real" value
        % greater than 0 and less than or equal to 1
        validateattributes(ciAlpha, {'numeric'}, ...
            {'nonempty', 'scalar', 'real', '>', 0, '<=', 1}, '', 'CIAlpha');
    end;
    
    if supplied.Replicates
        % check that replicates is a nonempty integer-valued matrix 
        validateattributes(replicates, {'numeric'}, ...
            {'nonempty', 'integer', '>', 0}, '', 'Replicates');        
    end;
    
    
    iterations = varargin{1}.Properties.UserData.iterations;
    sampleNum = length(varargin{1}.Properties.UserData.sampleSize) + 1;
        
    % the ASL at different iterations and pool samples
    asl = cell2table(cell(iterations, sampleNum));
    asl.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    asl.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    asl.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    asl.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    asl.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    asl.Properties.UserData.name = measureNames;
    asl.Properties.UserData.shortName = measureShortNames;
    asl.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    asl.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    asl.Properties.UserData.ciAlpha = ciAlpha;
    asl.Properties.RowNames = varargin{1}.Properties.RowNames;
    asl.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
    
    dp = cell2table(cell(iterations, sampleNum));
    dp.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    dp.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    dp.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    dp.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    dp.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    dp.Properties.UserData.name = measureNames;
    dp.Properties.UserData.shortName = measureShortNames;
    dp.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    dp.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    dp.Properties.UserData.ciAlpha = ciAlpha;
    dp.Properties.RowNames = varargin{1}.Properties.RowNames;
    dp.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;

    delta = cell2table(cell(iterations, sampleNum));
    delta.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    delta.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    delta.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    delta.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    delta.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    delta.Properties.UserData.name = measureNames;
    delta.Properties.UserData.shortName = measureShortNames;
    delta.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    delta.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    delta.Properties.UserData.ciAlpha = ciAlpha;
    delta.Properties.RowNames = varargin{1}.Properties.RowNames;
    delta.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
   
    
    % compute the discriminative power for each iteration
    for k = 1:iterations
                                              
        % compute the discriminative power for each sample
        for s = 1:sampleNum
            
            % the original pool is present only in the first column of the
            % first iteration, skip senseless computations afterwards
            if s == 1 && k > 1
                asl{k, s} = asl{1, 1};
                dp{k, s} = dp{1, 1};
                delta{k, s} = delta{1, 1};                    
                continue;
            end;
            
            % prepare the input to discriminative power by extracting the
            % measured run sets for a given pool sample and iteration
            input = cell(1, length(varargin));
            for m = 1:length(varargin)
        
                tmp = varargin{m}{k, 1}{1, 1}{:, s};
                tmp = vertcat(tmp{:, :});
                tmp.Properties.UserData.shortName = varargin{m}{k, 1}{1, 1}.Properties.UserData.shortName;

                input{m} = tmp;
            end;   
            
            % in the first iteration, we need to check whether we have
            % input replicates or we need to obtain them from discriminative
            % power for the first time, while in the following iterations
            % we will always use the already existing replicates
            if s == 1 && k == 1
                if supplied.Replicates
                    [currentAsl, currentDp, currentDelta] = discriminativePower(input{:}, 'Replicates', replicates, otherArgs{:});
                else
                    [currentAsl, currentDp, currentDelta, replicates] = discriminativePower(input{:}, otherArgs{:});
                end;
                
                % set also some general properties we do not know until the
                % first run of discriminative power
                asl.Properties.UserData.method = currentAsl.Properties.UserData.method;
                asl.Properties.UserData.shortMethod = currentAsl.Properties.UserData.shortMethod;
                asl.Properties.UserData.alpha = currentAsl.Properties.UserData.alpha;
                asl.Properties.UserData.replicates = currentAsl.Properties.UserData.replicates;

                dp.Properties.UserData.method = currentDp.Properties.UserData.method;
                dp.Properties.UserData.shortMethod = currentDp.Properties.UserData.shortMethod;
                dp.Properties.UserData.alpha = currentDp.Properties.UserData.alpha;
                dp.Properties.UserData.replicates = currentDp.Properties.UserData.replicates;
                
                delta.Properties.UserData.method = currentDelta.Properties.UserData.method;
                delta.Properties.UserData.shortMethod = currentDelta.Properties.UserData.shortMethod;
                delta.Properties.UserData.alpha = currentDelta.Properties.UserData.alpha;
                delta.Properties.UserData.replicates = currentDelta.Properties.UserData.replicates;
                
            else
                [currentAsl, currentDp, currentDelta] = discriminativePower(input{:}, 'Replicates', replicates, otherArgs{:});
            end;
            
            asl{k, s} = {currentAsl};
            dp{k, s} = {currentDp};
            delta{k, s} = {currentDelta};
                
        end;                   
    end;
             
    % the statistics of the ASL over different iterations
    aslStats = cell2table(cell(length(STAT_NAMES), sampleNum));
    aslStats.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    aslStats.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    aslStats.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    aslStats.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    aslStats.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    aslStats.Properties.UserData.name = measureNames;
    aslStats.Properties.UserData.shortName = measureShortNames;
    aslStats.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    aslStats.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    aslStats.Properties.UserData.method =  asl.Properties.UserData.method;
    aslStats.Properties.UserData.shortMethod = asl.Properties.UserData.shortMethod;
    aslStats.Properties.UserData.alpha = asl.Properties.UserData.alpha;
    aslStats.Properties.UserData.replicates = asl.Properties.UserData.replicates;
    aslStats.Properties.UserData.ciAlpha = ciAlpha;
    aslStats.Properties.RowNames = STAT_NAMES;
    aslStats.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
    
    aslStats(STAT_NAMES(1), :) = varfun(MY_MIN2, asl);
    aslStats(STAT_NAMES(2), :) = varfun(MY_MAX2, asl);    
    aslStats(STAT_NAMES(3), :) = varfun(MY_MEAN2, asl);
    aslStats(STAT_NAMES(4), :) = varfun(MY_STD2, asl);
    aslStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA2, asl);
    
    % the statistics of the discriminative power over different iterations
    dpStats = cell2table(cell(length(STAT_NAMES), sampleNum));
    dpStats.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    dpStats.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    dpStats.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    dpStats.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    dpStats.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    dpStats.Properties.UserData.name = measureNames;
    dpStats.Properties.UserData.shortName = measureShortNames;
    dpStats.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    dpStats.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    dpStats.Properties.UserData.method = dp.Properties.UserData.method;
    dpStats.Properties.UserData.shortMethod = dp.Properties.UserData.shortMethod;
    dpStats.Properties.UserData.alpha = dp.Properties.UserData.alpha;
    dpStats.Properties.UserData.replicates = dp.Properties.UserData.replicates;
    dpStats.Properties.UserData.ciAlpha = ciAlpha;
    dpStats.Properties.RowNames = STAT_NAMES;
    dpStats.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
    
    dpStats(STAT_NAMES(1), :) = varfun(MY_MIN, dp);
    dpStats(STAT_NAMES(2), :) = varfun(MY_MAX, dp);    
    dpStats(STAT_NAMES(3), :) = varfun(MY_MEAN, dp);
    dpStats(STAT_NAMES(4), :) = varfun(MY_STD, dp);
    dpStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA, dp);
    
    % the statistics of the delta over different iterations
    deltaStats = cell2table(cell(length(STAT_NAMES), sampleNum));
    deltaStats.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    deltaStats.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    deltaStats.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    deltaStats.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    deltaStats.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    deltaStats.Properties.UserData.name = measureNames;
    deltaStats.Properties.UserData.shortName = measureShortNames;
    deltaStats.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    deltaStats.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    deltaStats.Properties.UserData.method = delta.Properties.UserData.method;
    deltaStats.Properties.UserData.shortMethod = delta.Properties.UserData.shortMethod;
    deltaStats.Properties.UserData.alpha = delta.Properties.UserData.alpha;
    deltaStats.Properties.UserData.replicates = delta.Properties.UserData.replicates;
    deltaStats.Properties.UserData.ciAlpha = ciAlpha;
    deltaStats.Properties.RowNames = STAT_NAMES;
    deltaStats.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;    
    
    
    deltaStats(STAT_NAMES(1), :) = varfun(MY_MIN, delta);
    deltaStats(STAT_NAMES(2), :) = varfun(MY_MAX, delta);    
    deltaStats(STAT_NAMES(3), :) = varfun(MY_MEAN, delta);
    deltaStats(STAT_NAMES(4), :) = varfun(MY_STD, delta);
    deltaStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA, delta);


    %%

    % Wraps confidenteIntervalDelta to use the currently passed ciAlpha
    function [delta] = myCIDelta(data) 
        delta = confidenceIntervalDelta(data, ciAlpha);
    end % myCIDelta       

    %%

    % Wraps confidenteIntervalDelta to use the currently passed ciAlpha and
    % compute standard deviation on the 3rd dimension
    function [delta] = myCIDelta2(data) 
        delta = confidenceIntervalDelta(data, ciAlpha, 3);
    end % myCIDelta2      
end %computeDiscriminativePowerAtPoolSamples

%%

% Properly unwraps nested tables in order to compute descriptive
% statistics for dp and delta
function [b] = myfunc(func, a) 

    % contains the descriptive statistic for each measure
    b = a{1, 1};
    
    % number of iterations
    na = length(a);
    
    % number of compared systems
    nb = height(b);
       
    data = NaN(na, nb);
            
    % extract the data
    for k = 1:na      
        data(k, :) = a{k, 1}{:, :}.';
    end;
    
    b{:, :} = func(data).';
    
    b = {b};

end

%%

% Properly unwraps nested tables in order to compute descriptive
% statistics for asl
function [b] = myfunc2(func, a) 

    % contains the descriptive statistics for each measure
    b = a{1, 1};

    % contains the descriptive statistics about a given measure
    c = b{1, 1}{1, 1};
    
    % number of iterations
    na = length(a);
    
    % number of measures
    nb = height(b);
    
    % number of compared systems
    nc = height(c);
       
    % extract the data
    for m = 1:nb
        
        % each plane is a nc*nc matrix with the asl for each system pair,
        % there are as many planes are the iterations are (na)
        data = NaN(nc, nc, na);
        
        for k = 1:na
            data(:, :, k) = a{k, 1}{m, 1}{1, 1}{:, :};
        end;
        
        % compute the descriptive statistic
        c{:, :} = func(data);
        
        % assign it to the proper matrix
        b{m, 1} = {c};
    end;
    
    b = {b};
end


