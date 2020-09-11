%% compute_balancing
% 
% Computes the needed balancing value for the ANOVA analyses.
%
%% Synopsis
%
%   [blc] = compute_balancing(splitID, measures, balanced, idx)
%  
% *Parameters*
%
% * *|splitID|* - the identifier of the split to process.
% * *|measures|* - a cell array of measure matrixes, one for each shard.
% * *|balanced|* - the type of design to enforce. if |unb| it
% will use an unbalanced design where missing values are denoted by |NaN|;
% if |zero|, it will force a balanced design by substituting |NaN| values 
% with zeros; if |med|, it will force a balanced design by substituting 
% |NaN| values with the median value (ignoring |NaN|s) across all topics
% and systems; if |mean|, it will force a balanced design by substituting 
% |NaN| values with the mean value (ignoring |NaN|s) across all topics
% and systems; if |lq|, it will force a balanced design by substituting 
% |NaN| values with the lower quartile value (ignoring |NaN|s) across all 
% topics and systems; if |uq|, it will force a balanced design by 
% substituting |NaN| values with the upper quartile value (ignoring |NaN|s)
% across all topics and systems; % if |one|, it will force a balanced 
% design by substituting |NaN| values with zeros; 
% * *|idx|* the indexes of the systems who belong to the requested quartile
% of the measure, i.e. those systems to be kept.
%
%
% *Returns*
%
% * *|blc|* - a struct where |blc.type| is equal to the passed |balanced|
% parameter and |blc.value| contains the value to be used for forcing a
% balanced design.
% * *|measures|* - the input cell array of measures where the balanced
% design has been enforced and only the system specified in |idx| are kept.


%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: MATTERS 1.0 or higher; Matlab 2017a
% * *Copyright:* (C) 2018-2019 <http://www.dei.unipd.it/ 
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

function [blc, measures] = compute_balancing(splitID, measures, balanced, idx)

    % the type of balancing to be performed
    blc.type = balanced;
    
    common_parameters;

    % the number of topics and runs
    T = height(measures{1});
    R = width(measures{1});

    % total number of elements in the list
    N = T * R * EXPERIMENT.split.(splitID).shard;

    data = NaN(1, N);

    % for each shard
    for s = 1:EXPERIMENT.split.(splitID).shard
        % copy the measures in the correct range of the data
        data((s-1)*T*R + 1 : s*T*R) = measures{s}{:, :}(:);
    end
    
    % determine the balancing value
    switch lower(balanced)
        case {'zero', 'b'}
            blc.value = 0;
        case {'one', 'o'}
            blc.value = 1;
        case {'unb', 'u'}
            blc.value = NaN;
        case 'med'
            blc.value = median(data, 'omitnan');
        case 'mean'
            blc.value = mean(data, 'omitnan');
        case 'lq'
            blc.value = prctile(data, 25);
        case 'uq'
            blc.value = prctile(data, 75);
    end
    
    % for each shard, balance it and keep only the systems in the
    % selected quartile
    for s = 1:EXPERIMENT.split.(splitID).shard
        
        measure = measures{s};
        tmp = measure{:, :};
        tmp(isnan(tmp)) = blc.value;
        measure{:, :} = tmp;
        
        % keep only runs in the requested quartile of the whole corpus
        measure = measure(:, idx);
        
        measures{s} = measure;
        
        clear tmp measure;
        
    end % for shard
    
end
