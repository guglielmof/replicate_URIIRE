%% standardization
% 
% Computes the normal cumulative density function 
% standardization (z-scores) of a measured run set.
%
%% Synopsis
%
%   [standardizedMeasuredRunSet, mean, stdDev] = standardization(measuredRunSet, varargin)
%  
% *Parameters*
%
% * *|measuredRunSet|* - the run(s) whose descriptive statistics have to be
% computed. It is a table in the same format
% returned by, for example, <../measure/precision.html 
% precision> or by <../measure/averagePrecision.html 
% averagePrecision>;
% * *|mean|* - (optional) the mean to be used for standardization; 
% if not specified it will be calculated from the
% |measuredRunSet|.
% * *|stdDev|* - (optional) the standard deviation to be used for
% standardization; if not specified it will be calculated from the
% |measuredRunSet|.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |standardizedMeasuredRunSet|  - a table containing the standardized measures for each run
% across the set of topics. Rows are topics, columns are
% runs. 
% * |mean|  - the mean used for standardization.
% * |std_dev|  - the standard devistion used for standardization.
%
%% Example of use
% AP = averagePrecision(pool, runSet);
% sAP = standardization(AP);
%
% It computes the standardization of each value of the AP table and returns
% a table (sAP) with the same format as AP. 
%
%  
%% References
% 
% Please refer to:
%
% * William Webber, Alistair Moffat, and Justin Zobel. 2008. 
% Score standardization for inter-collection comparison of retrieval systems. 
% In Proceedings of the 31st annual international ACM SIGIR conference on 
% Research and development in information retrieval (SIGIR '08). ACM, 
% New York, NY, USA, 51-58. DOI=10.1145/1390334.1390346 
% http://doi.acm.org/10.1145/1390334.1390346
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
function [standardizedMeasuredRunSet, meanValue, stdDevValue] = standardization(measuredRunSet, varargin)
    
    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
    % check that measuredRunSet is a non-empty table
    validateattributes(measuredRunSet, {'table'}, {'nonempty'}, '', 'measuredRunSet', 1);
    
    % parse the variable inputs
    pnames = {'Mean', 'StdDev', 'Verbose'};
    dflts =  {NaN, NaN, false};
    [meanValue, stdDevValue, verbose, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
          
%      if supplied.Mean
%         % check that Mean is a scalar integer value 
%         % greater than 0
%         validateattributes(meanValue, {'numeric'}, ...
%             {'scalar', 'integer', '>', 0}, '', 'Mean');
%     end;
%     
%     if supplied.StdDev
%         % check that StdDev is a scalar integer value 
%         % greater than 0
%         validateattributes(stdDevValue, {'numeric'}, ...
%             {'scalar', 'integer', '>', 0}, '', 'StdDev');
%     end;
     
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing standardization for run set %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            measuredRunSet.Properties.UserData.identifier, width(measuredRunSet), height(measuredRunSet));
    end;
           
    
    if (isnan(meanValue) & isnan(stdDevValue))
        if verbose
            fprintf('Calculating mean...\n');
        end;
        
        meanValue = mean(measuredRunSet{:, :}, 2);
        
        if verbose
            fprintf('Calculating standard deviation...\n');
        end;
        
        stdDevValue = std(measuredRunSet{:, :}, 0, 2);
        
        if verbose
            fprintf('Calculating standardization...\n');
        end;
        
        standardizedMeasuredRunSet = normcdf(zscore(measuredRunSet{:, :}, 0, 2));
        
        standardizedMeasuredRunSet = array2table(standardizedMeasuredRunSet);
        standardizedMeasuredRunSet.Properties = measuredRunSet.Properties;
        standardizedMeasuredRunSet.Properties.UserData.shortName = strcat('s_', measuredRunSet.Properties.UserData.shortName);
        standardizedMeasuredRunSet.Properties.UserData.name = strcat('standardized_', measuredRunSet.Properties.UserData.shortName);
    else        
        if verbose
            fprintf('Calculating standardization with mean and standard deviation given in input...\n');
        end;
        z = bsxfun(@minus,measuredRunSet{:, :}, meanValue);
        std_devValue0 = stdDevValue;
        std_devValue0(std_devValue0==0) = 1;
        z = bsxfun(@rdivide, z, std_devValue0);
        standardizedMeasuredRunSet = normcdf(z);
        standardizedMeasuredRunSet = array2table(standardizedMeasuredRunSet);
        standardizedMeasuredRunSet.Properties = measuredRunSet.Properties;
        standardizedMeasuredRunSet.Properties.UserData.shortName = strcat('s_', measuredRunSet.Properties.UserData.shortName);
        standardizedMeasuredRunSet.Properties.UserData.name = strcat('standardized_', measuredRunSet.Properties.UserData.shortName);
    end
    if verbose
        fprintf('Standardization completed.\n');
    end;    
end


