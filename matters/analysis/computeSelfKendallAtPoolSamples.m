%% computeSelfKendallAtPoolSamples
% 
% For each iteration and pool sample, it computes the Kendall's tau B
% correlation between the measure on the orginal pool and the measure on
% the sampled pool.
%
%% Synopsis
%
%   [tauB, tauBStats, meanTauB, meanTauBStats, stdTauB, stdTauBStats, ciTauB, ciTauBStats] = computeSelfKendallAtPoolSamples(measuredRunSet, varargin)
%  
%
% *Parameters*
%
% * *|measuredRunSet|* - the measured run set. It is a table in the
% same format returned by <../measure/computeMeasureAtPoolSamples.html 
% computeMeasureAtPoolSamples>;
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
%   [tauB, tauBStats] = computeSelfKendallAtPoolSamples(measuredRunSet)
%
% It returns the following tables.
%
%   tauB = 
%   
%                        Original    SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                        ________    ________________    ________________    ________________
%   
%       Iteration_001    1                 1             0.95556             0.91111         
%       Iteration_002    1           0.95556             0.91111             0.95556         
%       Iteration_003    1                 1             0.91111             0.86667         
%       Iteration_004    1           0.95556                   1                   1         
%       Iteration_005    1           0.95556             0.86667             0.77778         
%
%
%   tauBStats = 
%   
%                                  Original    SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                                  ________    ________________    ________________    ________________
%   
%       Minimum                    1            0.95556             0.86667             0.77778        
%       Maximum                    1                  1                   1                   1        
%       Mean                       1            0.97333             0.92889             0.90222        
%       StandardDeviation          0           0.024343            0.050674            0.085491        
%       ConfidenceIntervalDelta    0           0.030226            0.062921             0.10615        
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
function [tauB, tauBStats, meanTauB, meanTauBStats, stdTauB, stdTauBStats, ciTauB, ciTauBStats] = computeSelfKendallAtPoolSamples(measuredRunSet, varargin)
       
    persistent STAT_NAMES;
    
    if isempty(STAT_NAMES)
           STAT_NAMES = {'Minimum', 'Maximum', 'Mean', 'StandardDeviation', ...
             'ConfidenceIntervalDelta'};
    end;

    % check that we have the correct number of input arguments. 
    narginchk(1, Inf);
    
    % check that measured run set is a non-empty table
    validateattributes(measuredRunSet, {'table'}, {'nonempty'}, '', 'measuredRunSet', 1);
    
     % parse the variable inputs
    pnames = {'Bootstrap', 'CIAlpha'};
    dflts =  {false,       0.05};
    [bootstrap, ciAlpha, supplied, otherArgs] = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    
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
    
                     
    iterations = measuredRunSet.Properties.UserData.iterations;
    sampleNum = length(measuredRunSet.Properties.UserData.sampleSize) + 1;
        
    % the Kendall's tau B at different iterations
    tauB = array2table(NaN(iterations, sampleNum));
    tauB.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
    tauB.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
    tauB.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
    tauB.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
    tauB.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
    tauB.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
    tauB.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;
    tauB.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
    tauB.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
    tauB.Properties.RowNames = measuredRunSet.Properties.RowNames;
    tauB.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
    
    if bootstrap
        meanTauB = array2table(NaN(iterations, sampleNum));
        meanTauB.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
        meanTauB.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
        meanTauB.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
        meanTauB.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
        meanTauB.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
        meanTauB.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
        meanTauB.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;
        meanTauB.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
        meanTauB.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
        meanTauB.Properties.RowNames = measuredRunSet.Properties.RowNames;
        meanTauB.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
        
        stdTauB = array2table(NaN(iterations, sampleNum));
        stdTauB.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
        stdTauB.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
        stdTauB.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
        stdTauB.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
        stdTauB.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
        stdTauB.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
        stdTauB.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;
        stdTauB.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
        stdTauB.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
        stdTauB.Properties.RowNames = measuredRunSet.Properties.RowNames;
        stdTauB.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
        
        ciTauB = cell2table(repmat({NaN(1, 2)}, iterations, sampleNum));
        ciTauB.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
        ciTauB.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
        ciTauB.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
        ciTauB.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
        ciTauB.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
        ciTauB.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
        ciTauB.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;
        ciTauB.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
        ciTauB.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
        ciTauB.Properties.RowNames = measuredRunSet.Properties.RowNames;
        ciTauB.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
    end;
    
    % the measure computed on the original pool    
    original = measuredRunSet{1, 1}{1, 1}{:, 1};
    original = vertcat(original{:, :});
    original.Properties.UserData.shortName = [measuredRunSet{1, 1}{1, 1}.Properties.UserData.shortName '_original'];
                     
    % compute the Kendall's tau B for each iteration
    for k = 1:iterations
                                              
        % compute the Kendall's tau B for each sample
        for s = 2:sampleNum
            
            % the measure computed on the sampled pool
            tmp = measuredRunSet{k, 1}{1, 1}{:, s};
            tmp = vertcat(tmp{:, :});
            
            % the name is the short name of the measure plus the sample in
            % order to differentiate, e.g., between AP at pool sample 100%
            % and AP at pool sample 50%
            tmp.Properties.UserData.shortName = [measuredRunSet{k, 1}{1, 1}.Properties.UserData.shortName '_' ...
                    measuredRunSet{k, 1}{1, 1}.Properties.VariableNames{s}];
            
            if bootstrap
                [tau, ~, meanTau, stdTau, ciTau] = kendall(original, tmp, 'Bootstrap', bootstrap, otherArgs{:});
                
                tauB{k, s} = tau{1, 2};
                meanTauB{k, s} = meanTau{1, 2};
                stdTauB{k, s} = stdTau{1, 2};
                ciTauB{k, s} = ciTau{1, 2};
            else
                tau = kendall(original, tmp, otherArgs{:});
                
                tauB{k, s} = tau{1, 2}; 
            end;
            
            
        end;                   
    end;
           
    tauB{:, 1} = 1;
    
    if bootstrap
        meanTauB{:, 1} = 1;
        stdTauB{:, 1} = 0;
        ciTauB{:, 1} = [1 1];
    end;
    
    % the mean of the average performances over different iterations
    tauBStats = array2table(NaN(length(STAT_NAMES), sampleNum));
    tauBStats.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
    tauBStats.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
    tauBStats.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
    tauBStats.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
    tauBStats.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
    tauBStats.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
    tauBStats.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;
    tauBStats.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
    tauBStats.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
    tauBStats.Properties.RowNames = STAT_NAMES;
    tauBStats.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
        
    tauBStats(STAT_NAMES(1), :) = varfun(@min, tauB);
    tauBStats(STAT_NAMES(2), :) = varfun(@max, tauB);
    tauBStats(STAT_NAMES(3), :) = varfun(@mean, tauB);
    tauBStats(STAT_NAMES(4), :) = varfun(@std, tauB);
    tauBStats(STAT_NAMES(5), :) = varfun(@myCIDelta, tauB);
    
    
    if bootstrap
        meanTauBStats = array2table(NaN(length(STAT_NAMES), sampleNum));
        meanTauBStats.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
        meanTauBStats.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
        meanTauBStats.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
        meanTauBStats.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
        meanTauBStats.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
        meanTauBStats.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
        meanTauBStats.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;        
        meanTauBStats.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
        meanTauBStats.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
        meanTauBStats.Properties.RowNames = STAT_NAMES;
        meanTauBStats.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
        
        meanTauBStats(STAT_NAMES(1), :) = varfun(@min, meanTauB);
        meanTauBStats(STAT_NAMES(2), :) = varfun(@max, meanTauB);
        meanTauBStats(STAT_NAMES(3), :) = varfun(@mean, meanTauB);
        meanTauBStats(STAT_NAMES(4), :) = varfun(@std, meanTauB);
        meanTauBStats(STAT_NAMES(5), :) = varfun(@myCIDelta, meanTauB);
     
        
        stdTauBStats = array2table(NaN(length(STAT_NAMES), sampleNum));
        stdTauBStats.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
        stdTauBStats.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
        stdTauBStats.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
        stdTauBStats.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
        stdTauBStats.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
        stdTauBStats.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
        stdTauBStats.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;                
        stdTauBStats.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
        stdTauBStats.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
        stdTauBStats.Properties.RowNames = STAT_NAMES;
        stdTauBStats.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
        
        stdTauBStats(STAT_NAMES(1), :) = varfun(@min, stdTauB);
        stdTauBStats(STAT_NAMES(2), :) = varfun(@max, stdTauB);
        stdTauBStats(STAT_NAMES(3), :) = varfun(@mean, stdTauB);
        stdTauBStats(STAT_NAMES(4), :) = varfun(@std, stdTauB);
        stdTauBStats(STAT_NAMES(5), :) = varfun(@myCIDelta, stdTauB);

        
        ciTauBStats = cell2table(repmat({NaN(1, 2)}, length(STAT_NAMES), sampleNum));
        ciTauBStats.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
        ciTauBStats.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
        ciTauBStats.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
        ciTauBStats.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
        ciTauBStats.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
        ciTauBStats.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
        ciTauBStats.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;                        
        ciTauBStats.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
        ciTauBStats.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
        ciTauBStats.Properties.RowNames = STAT_NAMES;
        ciTauBStats.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
        
        ciTauBStats(STAT_NAMES(1), :) = varfun(@min, ciTauB);
        ciTauBStats(STAT_NAMES(2), :) = varfun(@max, ciTauB);
        ciTauBStats(STAT_NAMES(3), :) = varfun(@mean, ciTauB);
        ciTauBStats(STAT_NAMES(4), :) = varfun(@std, ciTauB);
        ciTauBStats(STAT_NAMES(5), :) = varfun(@myCIDelta, ciTauB);
    end;
    
        
    %%

    % Wraps confidenteIntervalDelta to use the currently passed ciAlpha
    function [delta] = myCIDelta(data) 
        delta = confidenceIntervalDelta(data, ciAlpha);
    end % myCIDelta       

            
end



