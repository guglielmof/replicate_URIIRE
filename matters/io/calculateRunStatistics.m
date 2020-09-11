%% calculateRunStatistics
% 
% Calculates aggregated statistics for a run. 
% It returns four tables reporting the number of swapped documents along with 
% a measure of the misplacements of this documents. 
%
%% Synopsis
%
%   [runSetAggregatedStatistics, totalAggregatedPerRunStatistics, totalAggregatedPerTopicStatistics, totalRunSetStatistics] = calculateRunStatistics(pool, runReportSet, varargin)
%  
% *Parameters*
%
% * *|runSetReport|* (mandatory) - the table containing the statistics of a run set as returned by the  <matlab:doc('importRunsFromDirectoryTRECFormat') 
% importRunFromFileTRECFormat> function. 
% * *|pool|* (mandatory) - the table of the pool containing a row for each topic and a
% single column with the identifier of the pool. 
% * *|RankDepth|* - a positive integer specifying the maximum rank above
% which the swapped documents are considered.
% This is an optional parameter, if not specified, then depth is set to the
% length of the run.
%
%% *Returns*
%
% * *|runSetAggregatedStatistics|*  - a table containing a row for each topic and a column
% for each run in the run set. Each cell contains two tables; the first one reports the
% number of swapped documents between relevance degrees; in this table rows and columns are the 
% relevance degrees used in the run set and each cell contains an integer 
% which is the number of swapped documents with the indicated relevance degrees. 
% The second table reports a measure of the misplacements of the swapped
% documents; rows and columns are relevance degrees and cells contain
% arrays of integers reporting the misplacements of the swapped documents
% between the relevance degrees indicated by rows and columns.
% * *|totalAggregatedPerRunStatistics|*  - a table containing the statistics about 
% swapped documents and misplacements aggregated by run. Columns are runs
% and there are two rows, one for the total swapped documents and one for
% the total misplacements. Each cell contains two tables with the same
% form of the tables described above, one for swapped documents and the
% other for misplacements.
% * *|totalAggregatedPerTopicStatistics|*  - a table containing the statistics about 
% swapped documents and misplacements aggregated by topic. Rows are topics
% and there are two columns, one for the total swapped documents and one for
% the total misplacements. Each cell contains two tables with the same
% form of the tables described above, one for swapped documents and the
% other for misplacements.
% * *|totalRunSetStatistics|*  - a table containing the aggregated
% statistics for the run set. There are two columns called
% totalSwappedDocuments and totalMisplacements and one single row. Each
% cell contains a table with the form described above.
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
% * *License:* Apache License, Version 2.0

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
function [runSetAggregatedStatistics, totalAggregatedPerRunStatistics, totalAggregatedPerTopicStatistics, totalRunSetStatistics] = calculateRunStatistics(pool, runSetReport, varargin)
    
    % parse the variable inputs
    pnames = {'RankDepth'};
    dflts =  {[]};
    [depth, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

     % check the input parameters
    if supplied.RankDepth
        % check that depth is a non-negative integer 
        validateattributes(depth, {'double'}, {'nonnegative','scalar'}, '', 'RankDepth');
        depth = int32(depth);
    end;   
     
    % get the relevance degrees from the pool
    relevanceDegrees = categories(pool{:,1}{1,1}{:,2});
    
    % get the topic ids
    topicIds = runSetReport.Properties.RowNames;

    totalNotContiguousBlocks = 0;
    totalSwaps = 0;
    totalSameRankDocuments = 0;   
    
    % initialize the global stat row for the output table
    globalSwappedDocumentsPerRunRow = array2table(cell(1, width(runSetReport))); 
    globalMisplacementsPerRunRow = array2table(cell(1, width(runSetReport))); 
    
    % initialize the global stat column for the output table
    globalSwappedDocumentsPerTopicColumn = array2table(cell(length(topicIds), 1)); 
    globalMisplacementsPerTopicColumn = array2table(cell(length(topicIds), 1)); 
    
    % initialize the total gloal cell containing the global swaps and
    % misplacements for the collection
    totalCollectionSwappedDocumentsStatistics = array2table(cell(1, 1)); 
    totalCollectionMisplacementsStatistics = array2table(cell(1, 1)); 
    
    totalCollectionSwappedDocumentsStatistics = array2table(zeros(length(relevanceDegrees), length(relevanceDegrees)));
    totalCollectionMisplacementsStatistics = array2table(cell(length(relevanceDegrees), length(relevanceDegrees)));
    
    totalCollectionSwappedDocumentsStatistics.Properties.VariableNames = relevanceDegrees;
    totalCollectionSwappedDocumentsStatistics.Properties.RowNames = relevanceDegrees;
    totalCollectionMisplacementsStatistics.Properties.VariableNames = relevanceDegrees;
    totalCollectionMisplacementsStatistics.Properties.RowNames = relevanceDegrees;

    % a topic counter for the internal function
    ct = 0;
    
    % initialize the global output table
    runSetAggregatedStatistics = array2table(cell(length(topicIds),  width(runSetReport)));
    runSetAggregatedStatistics.Properties.VariableNames = [runSetReport.Properties.VariableNames];
    runSetAggregatedStatistics.Properties.RowNames = topicIds;
    
    % call this function for each row in the report
    rowfun(@getSwaps, runSetReport, 'ExtractCellContents', true, 'SeparateInputs', false, 'NumOutputs', 0);
     
    totalAggregatedPerRunStatistics = cell2table([globalSwappedDocumentsPerRunRow{:,:}; globalMisplacementsPerRunRow{:,:}]);
    totalAggregatedPerRunStatistics.Properties.RowNames = {'totalSwappedDocuments' 'totalMisplacements'};
    totalAggregatedPerRunStatistics.Properties.VariableNames = runSetReport.Properties.VariableNames;
    
    totalAggregatedPerTopicStatistics = cell2table([globalSwappedDocumentsPerTopicColumn{:,:} globalMisplacementsPerTopicColumn{:,:}]);
    totalAggregatedPerTopicStatistics.Properties.RowNames = topicIds;
    totalAggregatedPerTopicStatistics.Properties.VariableNames = {'totalSwappedDocuments' 'totalMisplacements'};
    
    totalRunSetStatistics = table(totalCollectionSwappedDocumentsStatistics, totalCollectionMisplacementsStatistics);
    totalRunSetStatistics.Properties.VariableNames = {'totalSwappedDocuments' 'totalMisplacements'};
    
    totalRunSetStatistics.Properties.UserData.notContiguousDocumentBlocks = totalNotContiguousBlocks;
    totalRunSetStatistics.Properties.UserData.totalSwaps = totalSwaps;
    totalRunSetStatistics.Properties.UserData.totalSameRankDocuments = totalSameRankDocuments;
    
    % the internal function for processing the rows of the report and for
    % calculating the document swaps for each topic
    function getSwaps(topicReportSet)
        % the topic being processed
        ct = ct + 1;

        % initialize the run counter
        cr = 0;

        % given a topic, this function calculates the statistics for all the
        % run set
        arrayfun(@calculateRunStatsPerTopic, topicReportSet, 'UniformOutput', false);

        function calculateRunStatsPerTopic(topicReport)
            % increment the index for the run under assessment
            cr = cr + 1;

            % initialize the global run stats only for the first topic
            if(ct == 1)  
                % initialize the cell containing the global swaps and
                % misplacements per run
                globalSwappedDocumentsPerRunRow{1, cr}{1, 1} = ...
                    array2table(zeros(length(relevanceDegrees), length(relevanceDegrees)));
                globalMisplacementsPerRunRow{1, cr}{1, 1} = ...
                    array2table(cell(length(relevanceDegrees), length(relevanceDegrees)));
                globalSwappedDocumentsPerRunRow{1, cr}{1, 1}.Properties.VariableNames = relevanceDegrees;
                globalSwappedDocumentsPerRunRow{1, cr}{1, 1}.Properties.RowNames = relevanceDegrees;
                globalMisplacementsPerRunRow{1, cr}{1, 1}.Properties.VariableNames = relevanceDegrees;
                globalMisplacementsPerRunRow{1, cr}{1, 1}.Properties.RowNames = relevanceDegrees;

                % initialize the user data information
                globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.documentOrdering = topicReport.documentOrdering;
                globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.notContiguousDocumentBlocks = 0;
                globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.swappedDocuments = 0;
                globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.sameRankDocuments = 0;
            end

            % initialize the global run stats only for the first run
            if (cr == 1)
                % initialize the cell containing the global swaps and
                % misplacements per topic
                globalSwappedDocumentsPerTopicColumn{ct, 1}{1, 1} = ...
                        array2table(zeros(length(relevanceDegrees), length(relevanceDegrees)));
                globalMisplacementsPerTopicColumn{ct, 1}{1, 1} = ...
                    array2table(cell(length(relevanceDegrees), length(relevanceDegrees)));
                globalSwappedDocumentsPerTopicColumn{ct, 1}{1, 1}.Properties.VariableNames = relevanceDegrees;
                globalSwappedDocumentsPerTopicColumn{ct, 1}{1, 1}.Properties.RowNames = relevanceDegrees;

                % initialize the misplacements table
                globalMisplacementsPerTopicColumn{ct, 1}{1, 1}.Properties.VariableNames = relevanceDegrees;
                globalMisplacementsPerTopicColumn{ct, 1}{1, 1}.Properties.RowNames = relevanceDegrees;
            end

            % if there are swapped documents then fill the tables, otherwise
            % leave them empty
            if (topicReport.swappedDocuments ~= 0)
                % if the depth is not set by the user, then consider all the
                % swapped documents
                if ~supplied.RankDepth
                    depth = height(topicReport.swappedDocumentsTable);
                elseif depth > height(topicReport.swappedDocumentsTable)
                    error('MATTERS:IllegalState', 'Parameter ''RankDepth'' (%s) greater than the length of the runs which is %s', num2str(depth), num2str(topicReport.swappedDocuments));
                end

                % initialize the local (per topic) swapped documents table 
                swappedDocsPerTopic = array2table(zeros(length(relevanceDegrees), length(relevanceDegrees)));
                swappedDocsPerTopic.Properties.VariableNames = relevanceDegrees;
                swappedDocsPerTopic.Properties.RowNames = relevanceDegrees;

                % initialize the local (per topic) misplacements table 
                misplacementsPerTopic = array2table(cell(length(relevanceDegrees), length(relevanceDegrees)));
                misplacementsPerTopic.Properties.VariableNames = relevanceDegrees;
                misplacementsPerTopic.Properties.RowNames = relevanceDegrees;

                % Determine the relevance judgments for the original column of
                % swapped documents
                if ~isempty(topicReport.swappedDocumentsTable)

                    % determine the ranks at which there are no swapped documents
                    emptyCellLogical = topicReport.swappedDocumentsTable{:,3} == 0;

                    % create a temporanean table for the join
                    tmpJoinTable = table(topicReport.swappedDocumentsTable{:, 1});
                    tmpJoinTable{:,1}(emptyCellLogical) = {'NaN'};
                    tmpJoinTable.Properties.VariableNames = {'Original'};

                    % Determine the relevance judgments for the original column of
                    % swapped documents
                    [tmpJoinTable, io] = outerjoin(tmpJoinTable(1:depth, 1), ...
                        pool{ct, 1}{:, 1}, 'LeftKey', {'Original'}, ...
                        'RightKey', {'Document'}, 'Type', 'left', 'LeftVariables', {},...
                        'RightVariables', 'RelevanceDegree'); 

                    % ensure that the results of the join are in the same order as
                    % in the original table
                    original = sortrows(table(tmpJoinTable{:, 1}, io), 2);

                    tmpJoinTable = table(topicReport.swappedDocumentsTable{:, 2});
                    tmpJoinTable{:,1}(emptyCellLogical) = {'NaN'};
                    tmpJoinTable.Properties.VariableNames = {'Actual'};

                    % Determine the relevance judgments for the actual (final) column of
                    % swapped documents
                    [actual, ia] = outerjoin(tmpJoinTable(1:depth, 1), ...
                        pool{ct, 1}{:, 1}, 'LeftKey', {'Actual'}, ...
                        'RightKey', {'Document'},'Type', 'left', 'LeftVariables', {},...
                        'RightVariables', 'RelevanceDegree');

                    % ensure that the results of the join are in the same order as
                    % in the original table
                    actual = sortrows(table(actual{:, 1}, ia), 2);
                    actual(:, 2) = [];

                    % create a common table for original and actual
                    swappedTable = table(original{:, 1}, actual{:, 1}, topicReport.swappedDocumentsTable{1:depth, 3});
                    swappedTable.Properties.VariableNames = {'OriginalRelevanceDegree', 'ActualRelevanceDegree', 'Misplacement'};

                    % fill the local table
                    for row = 1:length(relevanceDegrees)
                        for column = 1:length(relevanceDegrees)
                            % create a matrix where the first column contains all the documents with 
                            % relevance degree equals to the current degree and 
                            % the second column contains all the documents with relevance degree higher than the
                            % current degree
                            tmp = [swappedTable{:, 1} == relevanceDegrees(row) swappedTable{:, 2} == relevanceDegrees(column)];

                            % count all the documents swapped with a degree higher then
                            % the degree under analysis
                            numberOfSwappedDocuments = sum(sum(tmp, 2) > 1);
                            swappedDocsPerTopic{row, column} = numberOfSwappedDocuments;

                            % cumulates the swaps across all topics
                            globalSwappedDocumentsPerTopicColumn{ct, 1}{1, 1}{row, column} = ...
                                globalSwappedDocumentsPerTopicColumn{ct, 1}{1, 1}{row, column} + numberOfSwappedDocuments;

                            totalCollectionSwappedDocumentsStatistics{row, column} = ...
                                totalCollectionSwappedDocumentsStatistics{row, column} + numberOfSwappedDocuments;
                            % cumulates the swaps across all runs
                            globalSwappedDocumentsPerRunRow{1, cr}{1, 1}{row, column} = ...
                                globalSwappedDocumentsPerRunRow{1, cr}{1, 1}{row, column} + numberOfSwappedDocuments;

                            % determine the misplacements of each swapped document and store
                            % them in an array
                            misplacements = swappedTable{:,3}(sum(tmp, 2) > 1);

                            % if the misplacement is not empty then save and cumulate it
                            if (~isempty(misplacements))    
                                misplacementsPerTopic{row, column} = {misplacements};
                                % cumulates the misplacements across all topics

                                 globalMisplacementsPerTopicColumn{ct, 1}{1, 1}{row, column}{1, 1} = ...
                                [globalMisplacementsPerTopicColumn{ct, 1}{1, 1}{row, column}{1, 1} {misplacements}];

                                 totalCollectionMisplacementsStatistics{row, column}{1, 1} = ...
                                [totalCollectionMisplacementsStatistics{row, column}{1, 1} {misplacements}];

                                % cumulates the misplacements across all runs
                                 globalMisplacementsPerRunRow{1, cr}{1, 1}{row, column}{1, 1} = ...
                                [globalMisplacementsPerRunRow{1, cr}{1, 1}{row, column}{1, 1} {misplacements}];

                                globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.notContiguousDocumentBlocks = globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.notContiguousDocumentBlocks + topicReport.notContiguousDocumentBlocks;
                                globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.swappedDocuments = globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.swappedDocuments + topicReport.swappedDocuments;
                                globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.sameRankDocuments = globalMisplacementsPerRunRow{1, cr}{1,1}.Properties.UserData.sameRankDocuments + topicReport.sameRankDocuments;
                            end
                        end
                    end
                end

                % upper triangular excluding the diagonal
                swappedDocsPerTopic{:,length(relevanceDegrees) + 1} = ...
                    sum(triu(table2array(swappedDocsPerTopic(:, 1:length(relevanceDegrees))), 1), 2);
                % lower triangular excluding the diagonal
                swappedDocsPerTopic{:,length(relevanceDegrees) + 2} = ...
                    sum(tril(table2array(swappedDocsPerTopic(:, 1:length(relevanceDegrees))), -1), 2);
                 % global total per topic
                swappedDocsPerTopic{:,length(relevanceDegrees) + 3} = ...
                    sum(table2array(swappedDocsPerTopic(:, 1:length(relevanceDegrees))), 2);

                swappedDocsPerTopic.Properties.VariableNames(length(relevanceDegrees) + 1:length(relevanceDegrees) + 3) = {'upperTotal', 'lowerTotal', 'total'};

                % increment these global counters
                totalSwaps = totalSwaps + topicReport.swappedDocuments;
                totalNotContiguousBlocks = totalNotContiguousBlocks + topicReport.notContiguousDocumentBlocks;
                totalSameRankDocuments = totalSameRankDocuments + topicReport.sameRankDocuments;

                runSetAggregatedStatistics{ct, cr}{1, 1} = table(swappedDocsPerTopic, misplacementsPerTopic);
            end
        end
    end
end