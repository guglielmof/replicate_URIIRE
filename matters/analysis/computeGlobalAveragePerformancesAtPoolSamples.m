%% computeGlobalAveragePerformancesAtPoolSamples
% 
% For each iteration and pool sample, it computes the global average
% performances over all the runs and topics in a given measured run set.
%
%% Synopsis
%
%   [globalAvgPerf, globalAvgPerfStats] = computeGlobalAveragePerformancesAtPoolSamples(measuredRunSet, varargin)
%  
%
% *Parameters*
%
% * *|measuredRunSet|* - the measured run set. It is a table in the
% same format returned by <../measure/computeMeasureAtPoolSamples.html 
% computeMeasureAtPoolSamples>;
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
% * *|IgnoreNaN|* (optional) - a boolean specifying whether |NaN| values 
% have to be ignored when computing the averages. The default is |false|.
%
%
% *Returns*
%
% * *|globalAvgPerf|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the average of the
% performances over all the runs and topics in the run set for that
% iteration and pool sample.
% * *|globalAvgPerfStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, and _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% global averages contained in |globalAvgPerf|.

%% Example of use
%  
%   [globalAvgPerf, globalAvgPerfStats] = computeGlobalAveragePerformancesAtPoolSamples(measuredRunSet);
%
% It returns the following tables.
%
%   globalAvgPerf = 
%   
%                        Original    SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                        ________    ________________    ________________    ________________
%   
%       Iteration_001    0.21682       0.196              0.1577             0.11725         
%       Iteration_002    0.21682      0.1973              0.1624             0.12395         
%       Iteration_003    0.21682      0.1898             0.15383             0.12117         
%       Iteration_004    0.21682     0.19526             0.14801             0.11335         
%       Iteration_005    0.21682     0.19712             0.15493             0.11529         
%
%
%   globalAvgPerfStats = 
%   
%                                  Original    SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                                  ________    ________________    ________________    ________________
%   
%       Minimum                    0.21682        0.1898             0.14801             0.11335       
%       Maximum                    0.21682        0.1973              0.1624             0.12395       
%       Mean                       0.21682        0.1951             0.15537              0.1182       
%       StandardDeviation                0     0.0030767           0.0052786           0.0043224       
%       ConfidenceIntervalDelta          0     0.0038202           0.0065542            0.005367       
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
function [globalAvgPerf, globalAvgPerfStats] = computeGlobalAveragePerformancesAtPoolSamples(measuredRunSet, varargin)

    persistent STAT_NAMES;
    
    if isempty(STAT_NAMES)
           STAT_NAMES = {'Minimum', 'Maximum', 'Mean', 'StandardDeviation', ...
             'ConfidenceIntervalDelta'};
    end;
           
    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
    % check that measured run set is a non-empty table
    validateattributes(measuredRunSet, {'table'}, {'nonempty'}, '', 'measuredRunSet', 1);
        
    % parse the variable inputs
    pnames = {'IgnoreNaN', 'CIAlpha'};
    dflts =  {false,       0.05};
    [ignoreNaN, ciAlpha, supplied] = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    
    if supplied.IgnoreNaN
        % check that ignoreNaN is a non-empty scalar logical value
        validateattributes(ignoreNaN, {'logical'}, {'nonempty','scalar'}, '', 'IgnoreNaN');
    end;   
    
    if supplied.CIAlpha
        % check that CIAlpha is a nonempty scalar "real" value
        % greater than 0 and less than or equal to 1
        validateattributes(ciAlpha, {'numeric'}, ...
            {'nonempty', 'scalar', 'real', '>', 0, '<=', 1}, '', 'CIAlpha');
    end;
    
                 
    iterations = measuredRunSet.Properties.UserData.iterations;
    sampleNum = length(measuredRunSet.Properties.UserData.sampleSize) + 1;
        
    % the average performances at different iterations
    globalAvgPerf = array2table(NaN(iterations, sampleNum));
    globalAvgPerf.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
    globalAvgPerf.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
    globalAvgPerf.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
    globalAvgPerf.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
    globalAvgPerf.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
    globalAvgPerf.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
    globalAvgPerf.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;
    globalAvgPerf.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
    globalAvgPerf.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
    globalAvgPerf.Properties.RowNames = measuredRunSet.Properties.RowNames;
    globalAvgPerf.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
    
                     
    % compute the average performances for each iteration
    for k = 1:iterations
                                      
        % compute the average performances for each sample
        for s = 1:sampleNum
            
            % the original pool is present only in the first column of the
            % first iteration, use the same value
            if s == 1 && k > 1
                globalAvgPerf{k, s} = globalAvgPerf{1, 1};
                continue;
            end;
            
            tmp = measuredRunSet{k, 1}{1, 1}{:, s};
            tmp = vertcat(tmp{:, :});
            
            if ignoreNaN
                globalAvgPerf{k, s} = nanmean(nanmean(tmp{:, :}));
            else
                globalAvgPerf{k, s} = mean(mean(tmp{:, :}));
            end;
        end;                   
    end;
           
    
    % the mean of the average performances over different iterations
    globalAvgPerfStats = array2table(NaN(length(STAT_NAMES), sampleNum));
    globalAvgPerfStats.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
    globalAvgPerfStats.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
    globalAvgPerfStats.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
    globalAvgPerfStats.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
    globalAvgPerfStats.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
    globalAvgPerfStats.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
    globalAvgPerfStats.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;
    globalAvgPerfStats.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
    globalAvgPerfStats.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
    globalAvgPerfStats.Properties.RowNames = STAT_NAMES;
    globalAvgPerfStats.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
    
    
    
    globalAvgPerfStats(STAT_NAMES(1), :) = varfun(@min, globalAvgPerf);
    globalAvgPerfStats(STAT_NAMES(2), :) = varfun(@max, globalAvgPerf);
    globalAvgPerfStats(STAT_NAMES(3), :) = varfun(@mean, globalAvgPerf);
    globalAvgPerfStats(STAT_NAMES(4), :) = varfun(@std, globalAvgPerf);
    globalAvgPerfStats(STAT_NAMES(5), :) = varfun(@myCIDelta, globalAvgPerf);
            
    
    %%

    % Wraps confidenteIntervalDelta to use the currently passed ciAlpha
    function [delta] = myCIDelta(data) 
        delta = confidenceIntervalDelta(data, ciAlpha);
    end % myCIDelta       

end



