%% plotGlobalAveragePerformancesAtPoolSamples
% 
% It plot the global average performances over all the runs and topics in 
% a given measured run set across iterations of sampled pools.
%
%% Synopsis
%
%   plotGlobalAveragePerformancesAtPoolSamples(varargin)
%  
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
% * *|Observed|* (mandatory) - a cell vector containing the the descriptive
% statistics about the global average performances for each measure of
% interest. See return parameter |globalAvgPerfStats| in 
% <../analysis/computeGlobalAveragePerformancesAtPoolSamples.html
% computeGlobalAveragePerformancesAtPoolSamples> for more information.
% * *|Reference|* (optional) - a cell vector containing the the descriptive
% statistics about the global average performances for each measure of
% reference. See return parameter |globalAvgPerfStats| in 
% <../analysis/computeGlobalAveragePerformancesAtPoolSamples.html
% computeGlobalAveragePerformancesAtPoolSamples> for more information.
% Reference performances will be plot with a different color and line style
% with respect to observed performances.
% * *|PlotCI|* (optional) -  a boolean indicating whether confidence
% intervals across pool iterations have to be plotted. The default is
% |false|.
%
%% Example of use
%  
%   plotGlobalAveragePerformancesAtPoolSamples('Title', 'Campaign 2014, Ad Hoc', ...
%               'Observed', {p10_globalAvgPerfStats, p100_globalAvgPerfStats, Rprec_globalAvgPerfStats}, ...
%               'Reference', {ap_globalAvgPerfStats, bpref_globalAvgPerfStats, rbp_globalAvgPerfStats}, ....
%               'PlotCI', true, ...
%               'OutputPath', '/output')
%
% It produces the following plot and saves it to a PDF file in the provided
% output directory.
%
% 
% <<globalAvgPerf_AtPoolSamples.png>>
% 
% You can note as |Observed| performances are plotted in blu with a
% continuous line while |Reference| performance are plotted in black with a
% dashed line.
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
function [] = plotGlobalAveragePerformancesAtPoolSamples(varargin)

    persistent MARKERS ...
        REF_LINESTYLE REF_LINEWIDTH REF_MARKERSIZE ...
        OBS_LINESTYLE OBS_LINEWIDTH OBS_MARKERSIZE;
    
    if isempty(MARKERS)
        
        MARKERS = {'o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};

        REF_LINESTYLE = '--';
        REF_LINEWIDTH = 1.0;
        REF_MARKERSIZE = 6;
        
        OBS_LINESTYLE = '-';
        OBS_LINEWIDTH = 1.2;
        OBS_MARKERSIZE = 7;        
    end;
       
    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
     % parse the variable inputs
    pnames = {'Title' 'OutputPath' 'Reference', 'Observed', 'PlotCI', 'FileNameSuffix'};
    dflts =  {[]      []           []           []           true      ''};
    [plotTitle, outputPath, reference, observed, plotCI, fileNameSuffix, supplied] = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
       
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
           
    % the labels for the legend, as deduced from the short name of the
    % computed measure
    legendLabels = {};
    
    if supplied.Observed
        % check that observed is a non-empty cell vector
        validateattributes(observed, {'cell'}, {'nonempty', 'vector'}, '', 'Observed');

        for k = 1:length(observed)
            % check that each element is a non-empty table
            validateattributes(observed{k}, {'table'}, {'nonempty'}, '', num2str(k, 'Observed{%d}'), 1);
            
            % add the short name of the measure as label for the plot
            legendLabels = [legendLabels observed{k}.Properties.UserData.shortName];
        end;   
    else
        error('MATTERS:MissingArgument', 'Parameter ''Observed'' not provided: the observed performances are mandatory.');
    end;
    
    
    switch lower(observed{1}.Properties.UserData.shortDownsampling)
        case 'srs'
            xTickLabels = [100 observed{1}.Properties.UserData.sampleSize];
            xTickLabels = strtrim(cellstr(num2str(xTickLabels.', '%d%%')));
            xLabel = 'Pool Reduction Rate';
            plotTitle = {plotTitle,  'Global Average Performances with Stratified Random Pool Sampling  '};
        case 'rs'
            xTickLabels = [100 observed{1}.Properties.UserData.sampleSize];
            xTickLabels = strtrim(cellstr(num2str(xTickLabels.', '%d%%')));
            xLabel = 'Pool Reduction Rate';
            plotTitle = {plotTitle,  'Global Average Performances with Random Pool Sampling  '};
        case 'pds'
            xTickLabels = [observed{1}.Properties.UserData.sampleSize];
            xTickLabels = strtrim(cellstr('Original', num2str(xTickLabels.', '%d')));
            xLabel = 'Pool Depth';
            plotTitle = {plotTitle,  'Global Average Performances with Pool Depth Sampling  '};
        otherwise
            error('MATTERS:IllegalArgument', 'Unrecognized pool downsampling method %s. Only PoolDepthSampling, RandomSampling, and StratifiedRandomSampling are allowed', ...
                observed{1}.Properties.UserData.downsampling);
    end;
        
    % markers for the observed performances
    obsMarkers = MARKERS;
    
    if supplied.Reference
        % check that reference is a non-empty cell vector
        validateattributes(reference, {'cell'}, {'nonempty', 'vector'}, '', 'Reference');

        for k = 1:length(reference)
            % check that each element is a non-empty table
            validateattributes(reference{k}, {'table'}, {'nonempty'}, '', num2str(k, 'Reference{%d}'), 1);
            
            % add the short name of the measure as label for the plot
            legendLabels = [legendLabels reference{k}.Properties.UserData.shortName];
        end;        
        
        % do not use more than half of the markers for the reference
        % performances
        refMarkers = MARKERS(1:min(length(reference), length(MARKERS)/2));
        
        % assign all the remaining markers for the observed performances
        obsMarkers = MARKERS(length(refMarkers)+1:end);
        
    end;
    
    if supplied.PlotCI
        % check that plotCI is a non-empty scalar logical value
        validateattributes(plotCI, {'logical'}, {'nonempty', 'scalar'}, '', 'PlotCI');
    end; 
    
    legendLabels = strrep(legendLabels, '_', '\_');
    obsColors = hsv(length(observed));
    refColors = copper(length(reference));
    
     % if output path is supplied, hide the figure to avoid render it on
    % screen when it is actually saved to a file
    if supplied.OutputPath
        h = figure('Visible', 'off');
    else
        h = figure;
    end;
    
        hold on
        
        % plot the observed performances
        for k = 1:length(observed)
            tmp = observed{k}{'Mean', :};            
            plot(tmp, 'Color', obsColors(k, :), 'LineStyle', OBS_LINESTYLE, ...
                'Marker', obsMarkers{mod(k, length(obsMarkers)) + 1}, ...
                'LineWidth', OBS_LINEWIDTH, 'MarkerSize', OBS_MARKERSIZE, ...
                'MarkerFaceColor', obsColors(k, :));
            
            % plot confidence intervals 
            if plotCI                
                ci = observed{k}{'ConfidenceIntervalDelta', :};   

                ciLo = tmp - ci;
                ciLo = ciLo(:).';
                ciHi = tmp + ci;
                ciHi = ciHi(:).';

                x = 1:length(ciHi);
                hFill = fill([x fliplr(x)],[ciHi fliplr(ciLo)], obsColors(k, :), ...
                    'LineStyle', 'none', 'EdgeAlpha', 0.10, 'FaceAlpha', 0.10);

                % send the fill to back
                uistack(hFill, 'bottom');

                % Exclude fill from legend
                set(get(get(hFill, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off'); 
            end;    
        end
    
        % plot the reference performances
        for k = 1:length(reference)
            tmp = reference{k}{'Mean', :};            
            plot(tmp, 'Color', refColors(k, :), 'LineStyle', REF_LINESTYLE, ...
                'Marker', refMarkers{mod(k, length(refMarkers)) + 1}, ...
                'LineWidth', REF_LINEWIDTH, 'MarkerSize', REF_MARKERSIZE, ...
                'MarkerFaceColor', refColors(k, :));
            
            
             % plot confidence intervals 
            if plotCI                
                ci = reference{k}{'ConfidenceIntervalDelta', :};   

                ciLo = tmp - ci;
                ciLo = ciLo(:).';
                ciHi = tmp + ci;
                ciHi = ciHi(:).';

                x = 1:length(ciHi);
                hFill = fill([x fliplr(x)],[ciHi fliplr(ciLo)], refColors(k, :), ...
                    'LineStyle', 'none', 'EdgeAlpha', 0.10, 'FaceAlpha', 0.10);

                % send the fill to back
                uistack(hFill, 'bottom');

                % Exclude fill from legend
                set(get(get(hFill, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off'); 
            end;    
        end
        
        set(gca, 'FontSize', 14);
        set(gca,'XTick', 1:length(xTickLabels));
        set(gca,'XTickLabel', xTickLabels);
        
        grid on;

        hl = legend(legendLabels{:}, 'Location', 'NorthEast');

        xlabel(xLabel)
        ylabel('Performances Averaged over Topics and Runs')
        title(plotTitle);

        if ~isempty(outputPath)
            set(h,'PaperPositionMode','manual'); 
            set(h,'PaperUnits','normalized');
            set(h,'PaperPosition',[0.05 0.05 0.9 0.9]);
            set(h,'PaperType','A4');
            set(h,'PaperOrientation','landscape');
            print(h, '-dpdf', sprintf('%1$sglobalAvgPerf_AtPoolSamples_%2$s%3$s.pdf', outputPath, fileNameSuffix, uuid()));
            close(h);
        end;
   
    
            
end



