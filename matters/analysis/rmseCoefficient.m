%% rmseCoefficient
% 
% Returns a P-by-P matrix containing the pairwise root mean square error 
% for each pair of columns in the N-by-P matrix X.

%% Synopsis
%
%   [rmse] = rmseCoefficient(varargin)
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
% * *|IgnoreNaN|* (optional) - a boolean specifying whether |NaN| values 
% have to be ignored when computing mean and standard deviation. The
% default is |false|.
% * *|Statistic|* (optional) - a string specifying the statistic to be used
% to aggregate the measures, either |Mean| or |Median|. The default is
% |Mean|.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |rmse| - a table containing the pairwise AP orrelation
% among the provided measures according to the specified aggregation
% statistic. Row and column names are the short names of the analysed
% measures.


%% Example of use
%  
%   ap = averagePrecision(pool, runSet);
%   p10 = precision(pool, runSet, 'CutOffs', 10);
%   p20 = precision(pool, runSet, 'CutOffs', 20);
%   p30 = precision(pool, runSet, 'CutOffs', 30);
%   Rprec = precision(pool, runSet, 'Rprec', true);
%   [rmse] = apCorrelation(ap, p10, p20, p30, Rprec)
%
% It computes the root mean square error between AP, P@10, P@20, P@30, and Rprec.
%
% It returns the |rmse| table.
%
%   rmse = 
%   
%                  AP        P_10       P_20       P_30       Rprec 
%                _______    _______    _______    _______    _______
%   
%       AP             0    0.65004    0.70668    0.80255    0.87043
%       P_10     0.65004          0    0.80984    0.71957    0.66636
%       P_20     0.70668    0.80984          0    0.88171    0.76391
%       P_30     0.80255    0.71957    0.88171          0    0.83417
%       Rprec    0.87043    0.66636    0.76391    0.83417          0
%
%
%

%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>,
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: Matlab 2013b or higher
% * *Copyright:* (C) 2013-2015 <http://ims.dei.unipd.it/ Information 
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
function [rmse] = rmseCoefficient(varargin)

    % handles to anonymous functions to ease computations
    persistent MEDIAN;
    
     % initialize anonymous functions
    if isempty(MEDIAN)        
        % median (ignoring NaN)
        MEDIAN = @(x) prctile(x, 50);
    end;
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
          
    % extract additional name-value pairs
    [nvp, varargin] = extractNameValuePairs(varargin{:});
    
    % parse the variable inputs
    pnames = {'IgnoreNaN', 'Statistic', 'Verbose'};
    dflts =  {false,       'mean',      false};
    [ignoreNaN, statistic, verbose, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, nvp{:});
    
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
        
        fprintf('Computing Root Mean Square Error for run set %s with respect to pool %s: %d measures to be processed across %d runs.\n\n', ...
            varargin{1}.Properties.UserData.identifier, ....
            varargin{1}.Properties.UserData.pool, n, width(varargin{1}));

        fprintf('Settings:\n');
        fprintf('  - statistics used to aggregate measures: %s;\n', statistic);
        
        if ignoreNaN
           fprintf('  - NaN values will be ignored, when using mean as aggregate statistic;\n');
        else
            fprintf('  - NaN values will not be ignored, when using mean as aggregate statistic;\n');
        end
    end;
            
    % compute the statistic of the first measure
    ranks(:, 1) = varfun(stat, varargin{1}, 'OutputFormat', 'Uniform').';
    
    % save the short name of the measure
    measures{1} = varargin{1}.Properties.UserData.shortName;
    
    % check input tables and compute mean
    for k = 2:n
        
        % ensure we have a table of measures as input
        validateattributes(varargin{k}, {'table'}, {'nonempty'}, '', 'measuredRunSet', 1);
                    
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
    
    
    [rmse] = rmseCoeff(ranks);
    
    rmse = array2table(rmse);
    rmse.Properties.RowNames = measures;
    rmse.Properties.VariableNames = measures;
    
    
 
end % rmseCoefficient
