%% computeKendallAtPoolSamples
% 
% For each iteration and pool sample, it computes the Kendall's tau B
% correlation between the given measures.
%
%% Synopsis
%
%   [tauB, tauBStats, meanTauB, meanTauBStats, stdTauB, stdTauBStats, ciTauB, ciTauBStats] = computeKendallAtPoolSamples(varargin)
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
% * *|Bootstrap|* (optional) - a boolean specifying whether bootstrapping
% has to be performed. The output parameters depending on bootstrap
% (meanTauB, meanTauBStats, stdTauB, stdTauBStats, ciTauB, ciTauBStats) can 
% be used only if it is |true|. The default is |false|.
% * *|CIAlpha|* (optional) - a scalar specifying the requested confidence
% level for computing confidence intervals. The default is |0.05|.
%
% For other possible Name-Value pairs, please see the documentation of
% <kendall.html kendall>
%
% *Returns*
%
% * *|tauB|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the Kendall's tau B
% between the measure computed on the original pool and the measure
% computed on the given pool sample at the given iteration.
% * *|tauBStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, and _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% Kendall's tau B in |tauB|.
% * *|meanTauB|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the bootstrapped Kendall's tau B
% between the measure computed on the original pool and the measure
% computed on the given pool sample at the given iteration.
% * *|meanTauBStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, and _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% bootstrapped Kendall's tau B in |meanTauB|.
% * *|stdTauB|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the standard 
% deviation of the bootstrapped Kendall's tau B between the measure computed 
% on the original pool and the measure computed on the given pool sample at 
% the given iteration.
% * *|stdTauBStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, and _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% standard deviation of the bootstrapped Kendall's tau B in |stdTauB|.
% * *|ciTauB|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the confidence  
% interval of the bootstrapped Kendall's tau B between the measure computed 
% on the original pool and the measure computed on the given pool sample at 
% the given iteration.
% * *|ciTauBStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, and _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% confidence interval of the bootstrapped Kendall's tau B in |ciTauB|.

%% Example of use
%  
%   [tauB, tauBStats] = computeKendallAtPoolSamples(ap, Rprec, p10)
%
% It computes the Kendall's tau B among average precision, R-precision and
% precision at 10 retrieved documents and returns the following tables.
%
%   tauB = 
%   
%                         Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                        ___________    ________________    ________________    ________________
%   
%       Iteration_001    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       Iteration_002    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       Iteration_003    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       Iteration_004    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       Iteration_005    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%
% As you can note, for each iteration and pool sample, contains a 3x3 table
% with the collerations among AP, Rprec, and P@10. For example, the
% correlation for the second iteratation and the 90% samples is given by:
%
%   tauB{2, 2}{1, 1}
%   
%   ans = 
%   
%                  AP        Rprec      P_10  
%                _______    _______    _______
%   
%       AP             1    0.86667    0.49441
%       Rprec    0.86667          1    0.35957
%       P_10     0.49441    0.35957          1
%
% Similarly, for the statistics about tau B, it returns the following
% table.
%
%   tauBStats = 
%   
%                                   Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                                  ___________    ________________    ________________    ________________
%   
%       Minimum                    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       Maximum                    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       Mean                       [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       StandardDeviation          [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%       ConfidenceIntervalDelta    [3x3 table]    [3x3 table]         [3x3 table]         [3x3 table]     
%   
%
% For example, the mean correlation for the for the 90% samples is given by:
%
%   tauBStats{3, 2}{1, 1}
%   
%   ans = 
%   
%                  AP        Rprec      P_10  
%                _______    _______    _______
%   
%       AP             1    0.82222    0.54052
%       Rprec    0.82222          1     0.4133
%       P_10     0.54052     0.4133          1           
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
function [tauB, tauBStats, meanTauB, meanTauBStats, stdTauB, stdTauBStats, ciTauB, ciTauBStats] = computeKendallAtPoolSamples(varargin)

    persistent MIN1 MAX1 MEAN1 STD1 ...
        MY_MIN MY_MAX MY_MEAN MY_STD MY_CIDELTA ...
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
         
         STAT_NAMES = {'Minimum', 'Maximum', 'Mean', 'StandardDeviation', ...
             'ConfidenceIntervalDelta'};
    end;
       
    % check that we have the correct number of input arguments. 
    narginchk(2, Inf);
    
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
    pnames = {'Bootstrap' 'CIAlpha'};
    dflts =  {false,      0.05};
    [bootstrap, ciAlpha, supplied, otherArgs] = matlab.internal.table.parseArgs(pnames, dflts, nvp{:});
    
    if supplied.Bootstrap
        % check that bootstrap is a non-empty scalar logical value
        validateattributes(bootstrap, {'logical'}, {'nonempty', 'scalar'}, '', 'Bootstrap');
    end;
    
    % cannot ask for outputs derived from bootstrap if bootstrap has not
    % been asked
    if nargout > 2 && ~bootstrap
        error('MATTERS:IllegalArgument', 'Cannot ask for bootstrap dependent outputs (meanTauB, stdTauB, ciTauB and their statistics) when no bootstrap has been asked.');
    end;
    
    if supplied.CIAlpha
        % check that CIAlpha is a nonempty scalar "real" value
        % greater than 0 and less than or equal to 1
        validateattributes(ciAlpha, {'numeric'}, ...
            {'nonempty', 'scalar', 'real', '>', 0, '<=', 1}, '', 'CIAlpha');
    end;
    
                     
    iterations = varargin{1}.Properties.UserData.iterations;
    sampleNum = length(varargin{1}.Properties.UserData.sampleSize) + 1;
        
    % the Kendall's tau B at different iterations
    tauB = cell2table(cell(iterations, sampleNum));
    tauB.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    tauB.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    tauB.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    tauB.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    tauB.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    tauB.Properties.UserData.name = measureNames;
    tauB.Properties.UserData.shortName = measureShortNames;
    tauB.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    tauB.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    tauB.Properties.RowNames = varargin{1}.Properties.RowNames;
    tauB.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
    
    if bootstrap
        meanTauB = cell2table(cell(iterations, sampleNum));
        meanTauB.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
        meanTauB.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
        meanTauB.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
        meanTauB.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
        meanTauB.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
        meanTauB.Properties.UserData.name = measureNames;
        meanTauB.Properties.UserData.shortName = measureShortNames;
        meanTauB.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
        meanTauB.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
        meanTauB.Properties.RowNames = varargin{1}.Properties.RowNames;
        meanTauB.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
        
        stdTauB = cell2table(cell(iterations, sampleNum));
        stdTauB.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
        stdTauB.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
        stdTauB.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
        stdTauB.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
        stdTauB.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
        stdTauB.Properties.UserData.name = measureNames;
        stdTauB.Properties.UserData.shortName = measureShortNames;
        stdTauB.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
        stdTauB.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
        stdTauB.Properties.RowNames = varargin{1}.Properties.RowNames;
        stdTauB.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
        
        ciTauB = cell2table(cell(iterations, sampleNum));
        ciTauB.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
        ciTauB.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
        ciTauB.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
        ciTauB.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
        ciTauB.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
        ciTauB.Properties.UserData.name = measureNames;
        ciTauB.Properties.UserData.shortName = measureShortNames;
        ciTauB.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
        ciTauB.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
        ciTauB.Properties.RowNames = varargin{1}.Properties.RowNames;
        ciTauB.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
    end;
    
    % compute the Kendall's tau B for each iteration
    for k = 1:iterations
                                              
        % compute the Kendall's tau B for each sample
        for s = 1:sampleNum
            
            % the original pool is present only in the first column of the
            % first iteration, skip senseless computations afterwards
            if s == 1 && k > 1
                if bootstrap
                    tauB{k, s} = tauB{1, 1};
                    meanTauB{k, s} = meanTauB{1, 1};
                    stdTauB{k, s} = stdTauB{1, 1};
                    ciTauB{k, s} = ciTauB{1, 1};
                else
                   tauB{k, s} = tauB{1, 1};             
                end;
                                
                continue;
            end;
            
            % prepare the input to kendall
            input = cell(1, length(varargin));
            for m = 1:length(varargin)
        
                tmp = varargin{m}{k, 1}{1, 1}{:, s};
                
                tmp = vertcat(tmp{:, :});
                tmp.Properties.UserData.shortName = varargin{m}{k, 1}{1, 1}.Properties.UserData.shortName;

                input{m} = tmp;
            end;    
                        
            if bootstrap
                [tau, ~, meanTau, stdTau, ciTau] = kendall(input{:}, 'Bootstrap', bootstrap, otherArgs{:});
                
                tauB{k, s} = {tau};
                meanTauB{k, s} = {meanTau};
                stdTauB{k, s} = {stdTau};
                ciTauB{k, s} = {ciTau};
            else
                tau = kendall(input{:}, otherArgs{:});
                
                tauB{k, s} = {tau};               
            end;
            
            
        end;                   
    end;
             
    % the mean of the average performances over different iterations
    tauBStats = cell2table(cell(length(STAT_NAMES), sampleNum));
    tauBStats.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
    tauBStats.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
    tauBStats.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
    tauBStats.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
    tauBStats.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
    tauBStats.Properties.UserData.name = measureNames;
    tauBStats.Properties.UserData.shortName = measureShortNames;
    tauBStats.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
    tauBStats.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
    tauBStats.Properties.RowNames = STAT_NAMES;
    tauBStats.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
    
    tauBStats(STAT_NAMES(1), :) = varfun(MY_MIN, tauB);
    tauBStats(STAT_NAMES(2), :) = varfun(MY_MAX, tauB);    
    tauBStats(STAT_NAMES(3), :) = varfun(MY_MEAN, tauB);
    tauBStats(STAT_NAMES(4), :) = varfun(MY_STD, tauB);
    tauBStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA, tauB);

    
    if bootstrap
        meanTauBStats = cell2table(cell(length(STAT_NAMES), sampleNum));
        meanTauBStats.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
        meanTauBStats.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
        meanTauBStats.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
        meanTauBStats.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
        meanTauBStats.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
        meanTauBStats.Properties.UserData.name = measureNames;
        meanTauBStats.Properties.UserData.shortName = measureShortNames;
        meanTauBStats.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
        meanTauBStats.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
        meanTauBStats.Properties.RowNames = STAT_NAMES;
        meanTauBStats.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
        
        meanTauBStats(STAT_NAMES(1), :) = varfun(MY_MIN, meanTauB);
        meanTauBStats(STAT_NAMES(2), :) = varfun(MY_MAX, meanTauB);
        meanTauBStats(STAT_NAMES(3), :) = varfun(MY_MEAN, meanTauB);
        meanTauBStats(STAT_NAMES(4), :) = varfun(MY_STD, meanTauB);
        meanTauBStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA, meanTauB);

        
        stdTauBStats = cell2table(cell(length(STAT_NAMES), sampleNum));
        stdTauBStats.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
        stdTauBStats.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
        stdTauBStats.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
        stdTauBStats.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
        stdTauBStats.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
        stdTauBStats.Properties.UserData.name = measureNames;
        stdTauBStats.Properties.UserData.shortName = measureShortNames;
        stdTauBStats.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
        stdTauBStats.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
        stdTauBStats.Properties.RowNames = STAT_NAMES;
        stdTauBStats.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
        
        stdTauBStats(STAT_NAMES(1), :) = varfun(MY_MIN, stdTauB);
        stdTauBStats(STAT_NAMES(2), :) = varfun(MY_MAX, stdTauB);
        stdTauBStats(STAT_NAMES(3), :) = varfun(MY_MEAN, stdTauB);
        stdTauBStats(STAT_NAMES(4), :) = varfun(MY_STD, stdTauB);
        stdTauBStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA, stdTauB);
        

        ciTauBStats = cell2table(cell(length(STAT_NAMES), sampleNum));
        ciTauBStats.Properties.UserData.identifier = varargin{1}.Properties.UserData.identifier;
        ciTauBStats.Properties.UserData.pool = varargin{1}.Properties.UserData.pool;
        ciTauBStats.Properties.UserData.funcName = varargin{1}.Properties.UserData.funcName;
        ciTauBStats.Properties.UserData.downsampling = varargin{1}.Properties.UserData.downsampling;
        ciTauBStats.Properties.UserData.shortDownsampling = varargin{1}.Properties.UserData.shortDownsampling;
        ciTauBStats.Properties.UserData.name = measureNames;
        ciTauBStats.Properties.UserData.shortName = measureShortNames;
        ciTauBStats.Properties.UserData.sampleSize = varargin{1}.Properties.UserData.sampleSize;
        ciTauBStats.Properties.UserData.iterations = varargin{1}.Properties.UserData.iterations;
        ciTauBStats.Properties.RowNames = STAT_NAMES;
        ciTauBStats.Properties.VariableNames= varargin{1}{1, 1}{1, 1}.Properties.VariableNames;
        
        ciTauBStats(STAT_NAMES(1), :) = varfun(MY_MIN, ciTauB);
        ciTauBStats(STAT_NAMES(2), :) = varfun(MY_MAX, ciTauB);
        ciTauBStats(STAT_NAMES(3), :) = varfun(MY_MEAN, ciTauB);
        ciTauBStats(STAT_NAMES(4), :) = varfun(MY_STD, ciTauB);
        ciTauBStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA, ciTauB);
    end;
      
    
    %%

    % Wraps confidenteIntervalDelta to use the currently passed ciAlpha
    function [delta] = myCIDelta(data) 
        delta = confidenceIntervalDelta(data, ciAlpha);
    end % myCIDelta                   
end %computeKendallAtPoolSamples

%%

% Properly unwraps nested tables in order to compute descriptive
% statistics.
function [b] = myfunc(func, a) 

    % contains the mean over the iterations of each cell of the Kendall's
    % tau B
    b = a{1, 1};
    
    % number of iterations
    na = length(a);
    
    % number of compared systems
    nb = width(b);
    
    % number of values for each comparison
    nc = length(b{1, 1});
    
    
    % contains the extracted data. Each cell corresponds to each cell of
    % the Kendall's tau B. Within each cell, there is a matrix
    % with as many rows as the iterations are (na) and as many columns as
    % the number of values in each cell of a (nc)
    data = repmat({NaN(na, nc)}, nb, nb);
            
    % extract the data
    for k = 1:length(a)        
        for r = 1:nb
            for c = 1:nb                
                data{r, c}(k, 1:nc) = a{k}{r, c};                
            end;
        end;        
    end;
    
    b(:, :) = cellfun(func, data, 'UniformOutput', false);
    
    b = {b};

end



