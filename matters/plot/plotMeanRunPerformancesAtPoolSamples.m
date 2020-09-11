%% plotMeanRunPerformancesAtPoolSamples
% 
% It plots the mean performances of runs over all the topics across 
% iterations of sampled pools.
%
%% Synopsis
%
%   plotMeanRunPerformancesAtPoolSamples(meanPerfStats, varargin)
%  
%
% *Parameters*
%
% * *|meanPerfStats|* - a table containing the descriptive statistics over
% iterations for each pool sample of the mean performances of the reuns.
% It is a table in the same format returned by 
% <../analysis/computeMeanRunPerformancesAtPoolSamples.html computeMeanRunPerformancesAtPoolSamples>.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|Title|* (mandatory) - a string specifying the title of the plot.
% * *|OutputPath|* (optional) - a string specifying the path to the output 
% directory where the PDF of the plot will be saved. If not specified, the
% plot will not be saved to a PDF.
% * *|FileNameSuffix|* (optional) - a string to be added in the file name 
% for saving the PDF of the plot.
% * *|SelfTauBStats|* (optional) - a table containing descriptive
% statistics about the Kendall's tau B correlation among the measure at
% different pool samples. It is a table in the same format returned by 
% <../analysis/computeSelfKendallAtPoolSamples.html
% computeSelfKendallAtPoolSamples>. If provided, it adds a legend with the
% value of the tau B to the plot.
%
%% Example of use
%  
%   plotMeanRunPerformancesAtPoolSamples(ap_meanRunPerfStats, 'Title', 'Campaign 2014, Ad Hoc', ...
%           'SelfTauBStats', ap_selfTauBStats, 'OutputPath', '/output')
%
%
% It produces the following plot and saves it to a PDF file in the provided
% output directory.
%
% 
% <<meanRunPerf_AtPoolSamples.png>>
% 
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
function [] = plotMeanRunPerformancesAtPoolSamples(meanPerfStats, varargin)
         
    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
    % check that meanPerfStats run set is a non-empty table
    validateattributes(meanPerfStats, {'table'}, {'nonempty'}, '', 'meanPerfStats', 1);        
    
    % parse the variable inputs
    pnames = {'Title', 'OutputPath', 'SelfTauBStats' 'FileNameSuffix'};
    dflts =  {[],      [],           []                 ''};
    [plotTitle, outputPath, selfTauBStats, fileNameSuffix, supplied] = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
       
    if supplied.OutputPath
        % check that path is a non-empty string
        validateattributes(outputPath, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'OutputPath');
        
        if iscell(outputPath)
            % check that path is a cell array of strings with one element
            assert(iscellstr(outputPath) && numel(outputPathpath) == 1, ...
                'MATTERS:IllegalArgument', 'Expected OutputPath to be a cell array of strings containing just one string.');
        end

        % remove useless white spaces, if any, and ensure it is a char row
        outputPath = char(strtrim(outputPath));
        outputPath = outputPath(:).';

        % check if the path is a directory and if it exists
        if ~(isdir(outputPath))
            error('MATTERS:IllegalArgument', 'Expected OutputPath to be a directory.');
        end;

        % check if the given directory path has the correct separator at the
        % end.
        if outputPath(end) ~= filesep;
           outputPath(end + 1) = filesep;
        end; 
    end;
    
    if supplied.FileNameSuffix
        if iscell(fileNameSuffix)
            % check that fileNameSuffix is a cell array of strings with one element
            assert(iscellstr(fileNameSuffix) && numel(fileNameSuffix) == 1, ...
                'MATTERS:IllegalArgument', 'Expected FileNameSuffix to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        fileNameSuffix = char(strtrim(fileNameSuffix));
        fileNameSuffix = fileNameSuffix(:).';
        
        % check that the nameSuffix is ok according to the matlab rules
        if ~isempty(regexp(fileNameSuffix, '\W*', 'once'))
            error('MATTERS:IllegalArgument', 'FileNameSuffix %s is not valid: it can contain only letters, numbers, and the underscore.', ...
                fileNameSuffix);
        end  
        
        % if it starts with an underscore, remove it since il will be
        % appended afterwards
        if strcmp(fileNameSuffix(1), '_')
            fileNameSuffix = fileNameSuffix(2:end);
        end;
        
        % if it does not end with and underscore, append it
        if ~strcmp(fileNameSuffix(end), '_')
            fileNameSuffix(end+1) = '_';
        end;
    end;
     
    if supplied.Title
        % check that title is a non-empty string
        validateattributes(plotTitle, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'Title');
    
         if iscell(plotTitle)
            % check that title is a cell array of strings with one element
            assert(iscellstr(plotTitle) && numel(plotTitle) == 1, ...
                'MATTERS:IllegalArgument', 'Expected Title to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        plotTitle = char(strtrim(plotTitle));
        plotTitle = plotTitle(:).';       
        plotTitle = strrep(plotTitle, '_', '\_');
    else
        error('MATTERS:MissingArgument', 'Parameter ''Title'' not provided: the title of the plot is mandatory.');
    end;
    
    if supplied.SelfTauBStats
        % check that each element is a non-empty table
        validateattributes(selfTauBStats, {'table'}, {'nonempty'}, '', 'TauB', 1);    
    end;
    
    switch lower(meanPerfStats.Properties.UserData.shortDownsampling)
        case 'srs'
            plotTitle = {plotTitle,  'Mean Performances by System with Stratified Random Pool Sampling  '};
        case 'rs'
            plotTitle = {plotTitle,  'Mean Performances by System with Random Pool Sampling  '};
        case 'pds'
            plotTitle = {plotTitle,  'Mean Performances by System with Pool Depth Sampling  '};
        otherwise
            error('MATTERS:IllegalArgument', 'Unrecognized pool downsampling method %s. Only PoolDepthSampling, RandomSampling, and StratifiedRandomSampling are allowed', ...
                meanPerfStats.Properties.UserData.downsampling);
    end;
    
    % the actual data to plot 
    data = meanPerfStats('Mean', :);
    
    % the data for the x-axis
    x = data{1, 1}{1, 1}{:, :};
    
    % plot each sample against the original one
    for k = 2:width(meanPerfStats)
    
        y = data{1, k}{1, 1}{:, :};
        % if output path is supplied, hide the figure to avoid render it on
        % screen when it is actually saved to a file
        if supplied.OutputPath
            h = figure('Visible', 'off');
        else
            h = figure;
        end;
        hold on

        scatter(x, y, 50, 'b', 'o');
        plot([0 1], [0 1], 'k--');
        
        grid on;
        
        set(gca, 'FontSize', 14);
        
        set(gca, 'XLim', [0 1], ...
            'XTick', [0:0.10:1], ...
            'XTickLabel', cellstr(num2str([0:0.10:1].', '%3.2f')).');
        
        set(gca, 'YLim', [0 1], ...
            'YTick', [0:0.10:1], ...
            'YTickLabel', cellstr(num2str([0:0.10:1].', '%3.2f')).');
                        
        xlabel(['Original Mean ' strrep(meanPerfStats.Properties.UserData.shortName, '_', '\_')]);
        
        switch lower(meanPerfStats.Properties.UserData.shortDownsampling)
            case 'srs'
                ylabel(['Mean ' strrep(meanPerfStats.Properties.UserData.shortName, '_', '\_') ...
                    ' At ' num2str(meanPerfStats.Properties.UserData.sampleSize(k-1), '%d%%') ' Pool Reduction Rate']);
            case 'rs'
                ylabel(['Mean ' strrep(meanPerfStats.Properties.UserData.shortName, '_', '\_') ...
                    ' At ' num2str(meanPerfStats.Properties.UserData.sampleSize(k-1), '%d%%') ' Pool Reduction Rate']);
            case 'pds'
                ylabel(['Mean ' strrep(meanPerfStats.Properties.UserData.shortName, '_', '\_') ...
                    ' At ' num2str(meanPerfStats.Properties.UserData.sampleSize(k-1), '%d') ' Pool Depth']);
            otherwise
                error('MATTERS:IllegalArgument', 'Unrecognized pool downsampling method %s. Only PoolDepthSampling, RandomSampling, and StratifiedRandomSampling are allowed', ...
                    meanPerfStats.Properties.UserData.downsampling);
        end;
        
        if ~isempty(selfTauBStats)
            
            ann = annotation('textbox');
            set(ann, 'String', sprintf('\\tau = %5.4f\\pm%5.4f', selfTauBStats{'Mean', k}, selfTauBStats{'ConfidenceIntervalDelta', k}));
            set(ann, 'Position', [0.15 0.83 0.26 0.055]);
            set(ann, 'BackgroundColor', 'white');
            set(ann, 'FontSize', 14);
            set(ann, 'HorizontalAlignment', 'center');
            set(ann, 'VerticalAlignment', 'middle');                                 
            
        end;
                                
        title(plotTitle);
                
        if ~isempty(outputPath)
            set(h,'PaperPositionMode','manual'); 
            set(h,'PaperUnits','normalized');
            set(h,'PaperPosition',[0.05 0.05 0.9 0.9]);
            set(h,'PaperType','A4');
            set(h,'PaperOrientation','landscape');
            print(h, '-dpdf', sprintf('%1$smeanRunPerf_AtPoolSamples_%2$s%3$s.pdf', outputPath, fileNameSuffix, uuid()));
            close(h);
        end;
                
    end;                         
            
end



