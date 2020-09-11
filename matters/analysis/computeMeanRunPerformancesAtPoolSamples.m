%% computeMeanRunPerformancesAtPoolSamples
% 
% For each iteration and pool sample, for each run, it computes the mean
% performances of the run over all the topics.
%
%% Synopsis
%
%   [meanRunPerf, meanRunPerfStats] = computeMeanRunPerformancesAtPoolSamples(measuredRunSet, varargin)
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
% * *|meanRunPerf|*  - a table containing a row for each iteration and a 
% column for each pool sample. The value of each cell is the average of the
% performances over all the runs and topics in the run set for that
% iteration and pool sample.
% * *|meanRunPerfStats|* - a table containing descriptive statistics over
% iterations for each pool sample. The rows are: _|Minimum|_, _|Maximum|_,
% _|Mean|_, _|StandardDeviation|_, and _|ConfidenceIntervalDelta|_; 
% the colums are the pool samples.
% Each cell contains the descriptive statistics named in the row for the
% global averages contained in |globalAvgPerf|.

%% Example of use
%  
%   [meanRunPerf, meanRunPerfStats] = computeMeanRunPerformancesAtPoolSamples(measuredRunSet);
%
% It returns the following tables.
%
%   meanRunPerf = 
%   
%                       Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050    
%                        ___________    ________________    ________________    ________________  
%   
%       Iteration_001    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]       
%       Iteration_002    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]       
%       Iteration_003    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]       
%       Iteration_004    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]       
%       Iteration_005    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]       
%
% where each cell contains a table with as many columns as the runs in the
% run set and the mean performances over the topics for each run. So, for
% example, this returns the mean performances at the 90% pool sample in the
% second iteration.
%
%
%   meanRunPerf{2, 2}{1, 1} =
%   
%       Brkly3     CLARTA     CLARTM      CnQst1     CnQst2    HNCad1     HNCad2     INQ001
%       _______    _______    _______    ________    ______    _______    _______    ______
%   
%       0.18662    0.18247    0.18775    0.084982    0.1067    0.18305    0.18682    0.1849
%
%
%   meanRunPerfStats = 
%   
%                                   Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%                                  ___________    ________________    ________________    ________________
%   
%       Minimum                    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]     
%       Maximum                    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]     
%       Mean                       [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]     
%       StandardDeviation          [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]     
%       ConfidenceIntervalDelta    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]     
%
% where each cell contains a table with as many columns as the runs in the
% run set and the descriptive statistic specified in the over of 
% the mean performances over the topics for each run over the different iterations. 
% So, for example, this returns the average mean performances at the 90%
% pool sample over all the iterations.
%
%   meanRunPerfStats{3, 2}{1, 1} = 
%   
%       Brkly3     CLARTA     CLARTM     CnQst1     CnQst2    HNCad1     HNCad2     INQ001 
%       _______    _______    _______    _______    ______    _______    _______    _______
%   
%       0.18312    0.18281    0.18792    0.08394    0.1047    0.18603    0.19156    0.18241

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
function [meanRunPerf, meanRunPerfStats] = computeMeanRunPerformancesAtPoolSamples(measuredRunSet, varargin)
       
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
        
    % the mean performances at different iterations
    meanRunPerf = cell2table(cell(iterations, sampleNum));
    meanRunPerf.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
    meanRunPerf.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
    meanRunPerf.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
    meanRunPerf.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
    meanRunPerf.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
    meanRunPerf.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
    meanRunPerf.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;    
    meanRunPerf.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
    meanRunPerf.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
    meanRunPerf.Properties.RowNames = measuredRunSet.Properties.RowNames;
    meanRunPerf.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
    
                     
    % compute the mean performances for each iteration
    for k = 1:iterations
                                      
        % compute the mean performances for each sample
        for s = 1:sampleNum
            
            % the original pool is present only in the first column of the
            % first iteration, use the same value
            if s == 1 && k > 1
                meanRunPerf{k, s} = meanRunPerf{1, 1};
                continue;
            end;
            
            tmp = measuredRunSet{k, 1}{1, 1}{:, s};
            tmp = vertcat(tmp{:, :});
            
            if ignoreNaN
               tmp = varfun(@nanmean, tmp);
            else
                tmp = varfun(@nanmean, tmp);
            end;
            
            tmp.Properties.VariableNames = measuredRunSet{k, 1}{1, 1}{:, s}{1, 1}.Properties.VariableNames;
            
            meanRunPerf{k, s} = {tmp};
            
        end;                   
    end;
           
    
    % the mean of the average performances over different iterations
    meanRunPerfStats = cell2table(cell(length(STAT_NAMES), sampleNum));
    meanRunPerfStats.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier;
    meanRunPerfStats.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool;
    meanRunPerfStats.Properties.UserData.funcName = measuredRunSet.Properties.UserData.funcName;
    meanRunPerfStats.Properties.UserData.downsampling = measuredRunSet.Properties.UserData.downsampling;
    meanRunPerfStats.Properties.UserData.shortDownsampling = measuredRunSet.Properties.UserData.shortDownsampling;
    meanRunPerfStats.Properties.UserData.name = measuredRunSet.Properties.UserData.name;
    meanRunPerfStats.Properties.UserData.shortName = measuredRunSet.Properties.UserData.shortName;    
    meanRunPerfStats.Properties.UserData.sampleSize = measuredRunSet.Properties.UserData.sampleSize;
    meanRunPerfStats.Properties.UserData.iterations = measuredRunSet.Properties.UserData.iterations;
    meanRunPerfStats.Properties.RowNames = STAT_NAMES;
    meanRunPerfStats.Properties.VariableNames= measuredRunSet{1, 1}{1, 1}.Properties.VariableNames;
    
        
    meanRunPerfStats(STAT_NAMES(1), :) = varfun(MY_MIN, meanRunPerf);
    meanRunPerfStats(STAT_NAMES(2), :) = varfun(MY_MAX, meanRunPerf);
    meanRunPerfStats(STAT_NAMES(3), :) = varfun(MY_MEAN, meanRunPerf);
    meanRunPerfStats(STAT_NAMES(4), :) = varfun(MY_STD, meanRunPerf);
    meanRunPerfStats(STAT_NAMES(5), :) = varfun(MY_CIDELTA, meanRunPerf);
    
    %%

    % Wraps confidenteIntervalDelta to use the currently passed ciAlpha
    function [delta] = myCIDelta(data) 
        delta = confidenceIntervalDelta(data, ciAlpha);
    end % myCIDelta                   
end % computeMeanRunPerformancesAtPoolSamples

%%

% Properly unwraps nested tables in order to compute descriptive
% statistics
function [b] = myfunc(func, a) 
    b = varfun(func, vertcat(a{:, :}));
    b.Properties.VariableNames = a{1, 1}.Properties.VariableNames;
    
    b = {b};
end






