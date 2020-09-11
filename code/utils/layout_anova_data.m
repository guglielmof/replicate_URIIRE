%%  layout_anova_data
% 
% Prepare measures for the subsequent ANOVA analyses. 
%
%% Synopsis
%
%   [N, R, T, S, data, subject, factorA, factorB] = layout_anova_data(splitID, measures)
%  
% *Parameters*
%
% * *|splitID|* - the identifier of the split to process.
% * *|measures|* - a cell array of measure matrixes, one for each shard.
%
% *Returns*
%
% * *|N|* - the total number of elements in |data|.
% * *|T|* - the total number of topics.
% * *|R|* - the total number of runs.
% * *|S|* - the total number of shards.
% * *|data|* - the data vector, i.e. the |measures| properly laid out for
% ANOVA.
% * *|subject|* - the labels for the subjects, i.e. topics, in the |data|
% vector
% * *|factorA|* - the labels for the factorA, i.e. systems, in the |data|
% vector
% * *|factorB|* - the labels for the factorB, i.e. shards, in the |data|
% vector

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
function [N, R, T, S, data, subject, factorA, factorB] = layout_anova_data(splitID, measures)

    persistent SHR_ID;
    
    if isempty(SHR_ID)
       SHR_ID = @(shr) sprintf('shr%03d', shr);
    end

    common_parameters;

    % the number of topics, runs, and shards
    T = height(measures{1});
    R = width(measures{1});
    S = EXPERIMENT.split.(splitID).shard;

    % total number of elements in the list
    N = T * R * S;

    % the data is layed out as follows:
    %
    % Data      Subject         FactorA FactorB
    % 0.10      T1              S1      SHARD1
    % 0.20      T2              S1      SHARD1
    % 0.30      T1              S2      SHARD1
    % 0.40      T2              S2      SHARD1
    % 0.50      T1              S3      SHARD1
    % 0.60      T2              S3      SHARD1
    % 0.15      T1              S1      SHARD2
    % 0.25      T2              S1      SHARD2
    % 0.35      T1              S2      SHARD2
    % 0.45      T2              S2      SHARD2
    % 0.55      T1              S3      SHARD2
    % 0.65      T2              S3      SHARD2

    data = NaN(1, N);
    shards = cell(1, S);
    
    % for each shard, 
    for shr = 1:S
        %copy the measure on that shard in the correct range of the data
        data((shr-1)*T*R + 1 : shr*T*R) = measures{shr}{:, :}(:);
        
        % add the identifier of the shard to the list of shards
        shards{shr} = SHR_ID(shr);
    end
    
    % grouping variable for the subjects (topic)
    subject = repmat(measures{1}.Properties.RowNames, S*R, 1);

    % grouping variable for factorA (system)
    factorA = repmat(measures{1}.Properties.VariableNames, T, 1);
    factorA = repmat(factorA(:), S, 1);

    % grouping variable for factorB (shard)
    factorB = repmat(shards, T*R, 1);
    factorB = factorB(:);
end



