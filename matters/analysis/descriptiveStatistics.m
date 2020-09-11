%% descriptiveStatistics
% 
% Computes descriptive statistics about a measured run set.

%% Synopsis
%
%   [dsByRun, dsByTopic] = descriptiveStatistics(measuredRunSet, varargin)
%  
% *Parameters*
%
% * *|measuredRunSet|* - the run(s) whose descriptive statistics have to be
% computed. It is a table in the same format
% returned by, for example, <../measure/precision.html 
% precision> or by <../measure/averagePrecision.html 
% averagePrecision>;
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|IgnoreNaN|* (optional) - a boolean specifying whether |NaN| values 
% have to be ignored when computing mean, standard deviation, and variance.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |dsByRun|  - a table containing descriptive statistics for each run
% across the set of topics. Rows are descriptive statistics, columns are
% runs. The computed descriptive stastistics are: _|minimum|_, always
% ignoring |NaN| values; _|maximum|_, always ignoring |NaN| values; 
% _|first quartile|_, always ignoring |NaN| values; _|second quartile|_ 
% (_|median|_), always ignoring |NaN| values; _|third quartile|_, always 
% ignoring |NaN| values; _|mean|, ignoring |NaN| values depending on the
% |IgnoreNaN| parameter;  _|standard deviation|, ignoring |NaN| values 
% depending on the |IgnoreNaN| parameter;  _|variance|, ignoring |NaN| 
% values depending on the |IgnoreNaN| parameter; _|geometric mean|, always
% considering|NaN| values; _|harmonic mean|, always considering|NaN|
% values. The |UserData| property of  the table contains a struct  with the  
% following fields: _|identifier|_ is the identifier of the run set; 
% _|pool|_  is the identifier of the pool used the compute measure;
% _|name|_ is |descriptiveStatisticsByRun|; _|measureName|_ is the name of
% the measure the descriptive stastistcs are about; _|measureShortName|_ is 
% the short name of the measure the descriptive stastistcs are about.
% * *|dsByTopic|* - a table containing descriptive statistics for each
% topic across the set of runs. Rows are topics, columns are descriptive 
% statistics. See |dsByRun| for further details.


%% Example of use
%  
%   ap = averagePrecision(pool, runSet);
%   [dsByRun, dsByTopic] = descriptiveStastistics(ap);
%
% It computes the average precision and then descriptive statistics about it. 
% Suppose the run set contains the following runs:
% 
% * |APL985LC.txt|
% * |AntHoc01.txt|
% * |acsys7al.txt|
%
% In this example each run has two topics, |351| and |352|. 
%
% It returns the |dsByRun| table.
%
%                          APL985LC          AntHoc01          acsys7al   
%                     ______________    ______________    ______________
%
%    Minimum              0.0040658      0.0015396          0.018189
%    Maximum                0.78749        0.74425           0.74892
%    FirstQuartile          0.10434       0.091743          0.095049
%    SecondQuartile         0.25182        0.25168           0.26518
%    ThirdQuartile          0.44807        0.41576           0.50745
%    Mean                   0.29445        0.28268           0.29385
%    StandardDeviation      0.22039        0.21028           0.21762
%    Variance               0.04857       0.044219          0.047357
%    GeometricMean          0.19292        0.17224           0.19287
%    HarmonicMean          0.074377       0.040722           0.10109
%
% It returns the |dsByTopic| table.
%
%           Minimum     Maximum    FirstQuartile    SecondQuartile    ThirdQuartile
%           ________    _______    _____________    ______________    _____________
%
%   351    0.031063     0.11904    0.049723         0.069558          0.093342     
%   352    0.022186     0.25032    0.039697          0.11005           0.15253     
%
%           Mean      StandardDeviation     Variance     GeometricMean    HarmonicMean
%          ________    _________________    __________    _____________     ____________
%
%   351    0.072392    0.025028             0.00062639    0.068017         0.063644    
%   352     0.10957    0.068492              0.0046911    0.085292         0.062965    
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
function [dsByRun, dsByTopic] = descriptiveStatistics(measuredRunSet, varargin)
    
    % handles to anonymous functions to ease computations
    persistent FIRST_QUARTILE SECOND_QUARTILE THIRD_QUARTILE;
    
    % initialize anonymous functions
    if isempty(FIRST_QUARTILE)
        % first quartile (ignoring NaN)
        FIRST_QUARTILE = @(x) prctile(x, 25);
        
        % second quartile (ignoring NaN)
        SECOND_QUARTILE = @(x) prctile(x, 50);
        
        % third quartile (ignoring NaN)
        THIRD_QUARTILE = @(x) prctile(x, 75);
    end

    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
    % check that measuredRunSet is a non-empty table
    validateattributes(measuredRunSet, {'table'}, {'nonempty'}, '', 'measuredRunSet', 1);
    
    % parse the variable inputs
    pnames = {'IgnoreNaN', 'Verbose'};
    dflts =  {false, false};
    [ignoreNaN, verbose, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
          
    if supplied.IgnoreNaN
        % check that ignoreNaN is a non-empty scalar logical value
        validateattributes(ignoreNaN, {'logical'}, {'nonempty','scalar'}, '', 'IgnoreNaN');
    end;   
    
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing descriptive statistics for run set %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            measuredRunSet.Properties.UserData.identifier, width(measuredRunSet), height(measuredRunSet));
    end;
    
    % compute the descriptive statistics run-by-run
    dsByRun =  cell2table(repmat({NaN(size(measuredRunSet{1, 1}))}, 10, width(measuredRunSet)));

    dsByRun.Properties.VariableNames = measuredRunSet.Properties.VariableNames;    
    dsByRun.Properties.RowNames = {'Minimum', 'Maximum', ...
        'FirstQuartile', 'SecondQuartile', 'ThirdQuartile', ...
        'Mean', 'StandardDeviation', 'Variance', ...
        'GeometricMean', 'HarmonicMean'};
           
    dsByRun.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier; 
    dsByRun.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool; 
    dsByRun.Properties.UserData.name = 'descriptiveStatisticsByRun';
    dsByRun.Properties.UserData.shortName = 'dsByRun';
    dsByRun.Properties.UserData.measureName = measuredRunSet.Properties.UserData.name;
    dsByRun.Properties.UserData.measureShortName = measuredRunSet.Properties.UserData.shortName;

    % minimum (always ignores NaN)
    dsByRun(1, :) = varfun(@min, measuredRunSet);
    
    % maximum (always ignores NaN)
    dsByRun(2, :) = varfun(@max, measuredRunSet);
    
    % first quartile (always ignores NaN)
    dsByRun(3, :) = varfun(FIRST_QUARTILE, measuredRunSet);
    
    % second quartile / median (always ignores NaN)
    dsByRun(4, :) = varfun(SECOND_QUARTILE, measuredRunSet);
    
    % third quartile (always ignores NaN)
    dsByRun(5, :) = varfun(THIRD_QUARTILE, measuredRunSet);
    
    % mean
    if ignoreNaN
        dsByRun(6, :) = varfun(@nanmean, measuredRunSet);
    else
        dsByRun(6, :) = varfun(@mean, measuredRunSet);
    end;
    
    % standard deviation
    if ignoreNaN
        dsByRun(7, :) = varfun(@nanstd, measuredRunSet);
    else
        dsByRun(7, :) = varfun(@std, measuredRunSet);
    end;
    
    % variance
    if ignoreNaN
        dsByRun(8, :) = varfun(@nanvar, measuredRunSet);
    else
        dsByRun(8, :) = varfun(@var, measuredRunSet);
    end;
    
    % geometric mean
    dsByRun(9, :) = varfun(@geomean, measuredRunSet);
    
    % harmonic mean
    dsByRun(10, :) = varfun(@harmmean, measuredRunSet);
   
  
    % compute the descriptive statistics topic-by-topic
    if verbose
        fprintf('Computation of descriptive statistics topic-by-topic.\n');
    end;
    
    dsByTopic =  cell2table(repmat({NaN(size(measuredRunSet{1, 1}))}, height(measuredRunSet), 10));

    dsByTopic.Properties.RowNames = measuredRunSet.Properties.RowNames;    
    dsByTopic.Properties.VariableNames = {'Minimum', 'Maximum', ...
        'FirstQuartile', 'SecondQuartile', 'ThirdQuartile', ...
        'Mean', 'StandardDeviation', 'Variance', ...
        'GeometricMean', 'HarmonicMean'};
            
    dsByTopic.Properties.UserData.identifier = measuredRunSet.Properties.UserData.identifier; 
    dsByTopic.Properties.UserData.pool = measuredRunSet.Properties.UserData.pool; 
    dsByTopic.Properties.UserData.name = 'descriptiveStatisticsByTopic';
    dsByTopic.Properties.UserData.shortName = 'dsByTopic';
    dsByTopic.Properties.UserData.measureName = measuredRunSet.Properties.UserData.name;
    dsByTopic.Properties.UserData.measureShortName = measuredRunSet.Properties.UserData.shortName;

    
    % create a MxNxP matrix where M is the number of topics, N is the
    % number of measure points and P is the number of runs
    data = reshape(measuredRunSet{:, :}, ...
        height(measuredRunSet), ...
        size(measuredRunSet{1, 1}, 2), ...
        width(measuredRunSet));
        
    % minimum (always ignores NaN)
    dsByTopic.Minimum = min(data, [], 3);
    
    % maximum (always ignores NaN)
    dsByTopic.Maximum = max(data, [], 3);
    
    % first quartile (always ignores NaN)
    dsByTopic.FirstQuartile = prctile(data, 25, 3);
    
    % second quartile / median (always ignores NaN)
    dsByTopic.SecondQuartile = prctile(data, 50, 3);
    
    % third quartile (always ignores NaN)
    dsByTopic.ThirdQuartile = prctile(data, 75, 3);
    
    % mean
    if ignoreNaN
        dsByTopic.Mean = nanmean(data, 3);
    else
        dsByTopic.Mean = mean(data, 3);
    end;
    
    % standard deviation
    if ignoreNaN
        dsByTopic.StandardDeviation = nanstd(data, 0, 3);
    else
        dsByTopic.StandardDeviation = std(data, 0, 3);
    end;
    
    % variance
    if ignoreNaN
        dsByTopic.Variance = nanvar(data, 0, 3);
    else
        dsByTopic.Variance = var(data, 0, 3);
    end;
    
    % geometric mean
    dsByTopic.GeometricMean = geomean(data, 3);
    
    % harmonic mean
    dsByTopic.HarmonicMean = harmmean(data, 3);
       
    if verbose
        fprintf('Computation of descriptive statistics completed.\n');
    end;    
end


