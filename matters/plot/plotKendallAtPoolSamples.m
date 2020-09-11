%% plotKendallAtPoolSamples
% 
% It plots the Kendall's tau B correlation between the measures at different
% pool samples and across the different iterations.
%
%% Synopsis
%
%   plotKendallAtPoolSamples(varargin)
%  
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
% * *|Observed|* (mandatory) - a cell vector containing the the descriptive
% statistics about the Self Kendall's tau for each observed measure.
% See return parameter |tauBStats| in  <../analysis/computeKendallAtPoolSamples.html
% computeKendallAtPoolSamples> for more information.
% * *|Reference|* (optional) - a cell vector containing the the descriptive
% statistics about the Kendall's tau for each measure of
% reference. See return parameter |tauBStats| in 
% <../analysis/computeKendallAtPoolSamples.html
% computeKendallAtPoolSamples> for more information.
% Reference performances will be plot with a different color and line style
% with respect to observed performances.
% * *|PlotCI|* (optional) -  a boolean indicating whether confidence
% intervals across pool iterations have to be plotted. The default is
% |false|.
%
%% Example of use
%  
%   plotKendallAtPoolSamples('Title', 'Campaign 2014, Ad Hoc', 'Observed', p10_p100_Rprec_tauBStats, ...
%               'Reference', ap_bpref_rbp_tauBStats, ....
%               'PlotCI', true, ...
%               'OutputPath', '/output')
%
% It produces the following plot and saves it to a PDF file in the provided
% output directory.
%
% <<tauB_AtPoolSamples.png>>
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
function [] = plotKendallAtPoolSamples(varargin)

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
     pnames = {'Title' 'OutputPath' 'Reference', 'Observed' 'PlotCI'};
    dflts =  {[]      []     []     []           []          false};
    [plotTitle, outputPath, reference, observed, plotCI, supplied] = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    
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
    
    if supplied.Observed
        % check that observed is a non-empty table
        validateattributes(observed, {'table'}, {'nonempty'}, '', 'Observed', 1);                  
    else
        error('MATTERS:MissingArgument', 'Parameter ''Observed'' not provided: the observed performances are mandatory.');
    end;
               
    obsMarkers = MARKERS;
    obsMeasureShortNames = observed.Properties.UserData.shortName;
    obsMeasureShortNames = strrep(obsMeasureShortNames, '_', '\_');
    
    % total number of observed measures to be plotted
    obsN = width(observed{1, 1}{1, 1});
    
    % total number of samples to be plotted
    s = width(observed);
           
    switch lower(observed.Properties.UserData.shortDownsampling)
        case 'srs'
            xTickLabels = [100 observed.Properties.UserData.sampleSize];
            xTickLabels = strtrim(cellstr(num2str(xTickLabels.', '%d%%')));
            xLabel = 'Pool Reduction Rate';
            plotTitle = {plotTitle,  'Kendall''s tau Correlation with Stratified Random Pool Sampling  '};
        case 'rs'
            xTickLabels = [100 observed.Properties.UserData.sampleSize];
            xTickLabels = strtrim(cellstr(num2str(xTickLabels.', '%d%%')));
            xLabel = 'Pool Reduction Rate';
            plotTitle = {plotTitle,  'Kendall''s tau Correlation with Random Pool Sampling  '};
        case 'pds'
            xTickLabels = [observed.Properties.UserData.sampleSize];
            xTickLabels = strtrim(cellstr('Original', num2str(xTickLabels.', '%d')));
            xLabel = 'Pool Depth';
            plotTitle = {plotTitle,  'Kendall''s tau Correlation with Pool Depth Sampling  '};
        otherwise
            error('MATTERS:IllegalArgument', 'Unrecognized pool downsampling method %s. Only PoolDepthSampling, RandomSampling, and StratifiedRandomSampling are allowed', ...
                observed{1}.Properties.UserData.downsampling);
    end;
    
     if supplied.Reference
        % check that reference is a non-empty table
        validateattributes(reference, {'table'}, {'nonempty'}, '', 'Reference', 2);

        % total number of observed measures to be plotted
        refN = width(reference{1, 1}{1, 1});
        
        refMeasureShortNames = reference.Properties.UserData.shortName;
        refMeasureShortNames = strrep(refMeasureShortNames, '_', '\_');
        
        % do not use more than half of the markers for the reference
        % performances
        refMarkers = MARKERS(1:min(refN, length(MARKERS)/2));
        
        % assign all the remaining markers for the observed performances
        obsMarkers = MARKERS(length(refMarkers)+1:end);        
    end;
    
    if supplied.PlotCI
        % check that plotCI is a non-empty scalar logical value
        validateattributes(plotCI, {'logical'}, {'nonempty', 'scalar'}, '', 'PlotCI');
    end; 
    
    obsColors = hsv(obsN);
    refColors = copper((refN-1)*refN/2);
      
    % plot each sample against the original one
    for r = 1:obsN
        
        % if output path is supplied, hide the figure to avoid render it on
        % screen when it is actually saved to a file
        if supplied.OutputPath
            h = figure('Visible', 'off');
        else
            h = figure;
        end;
        hold on

       legendLabels = {};
        
        for c = 1:obsN
            
            data = NaN(1, s);
                       
            if r ~= c
                legendLabels = [legendLabels [obsMeasureShortNames{r} ' vs ' obsMeasureShortNames{c}]];
                
                for k = 1:s                    
                    data(k) = observed{'Mean', k}{1, 1}{r, c};                    
                end;
                
              
                plot(data, 'Color', obsColors(c, :), 'LineStyle', OBS_LINESTYLE, ...
                    'Marker', obsMarkers{mod(c, length(obsMarkers)) + 1}, ...
                    'LineWidth', OBS_LINEWIDTH, 'MarkerSize', OBS_MARKERSIZE, ...
                    'MarkerFaceColor', obsColors(c, :));   
                
                
                % plot confidence intervals 
                if plotCI  
                    ci = NaN(1, s);
                    
                    for k = 1:s                    
                        ci(k) = observed{'ConfidenceIntervalDelta', k}{1, 1}{r, c};                    
                    end;
                                        
                    ciLo = data - ci;
                    ciLo = ciLo(:).';
                    ciHi = data + ci;
                    ciHi = ciHi(:).';

                    x = 1:length(ciHi);
                    hFill = fill([x fliplr(x)],[ciHi fliplr(ciLo)], obsColors(c, :), ...
                        'LineStyle', 'none', 'EdgeAlpha', 0.10, 'FaceAlpha', 0.10);

                    % send the fill to back
                    uistack(hFill, 'bottom');

                    % Exclude fill from legend
                    set(get(get(hFill, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off'); 
                end;  
            end;
                                    
        end;
        
        % add the reference measures, if any
        if ~isempty(reference)
            
            for rr = 1:refN
                for cc = rr+1:refN
                    
                     data = NaN(1, s);

                    legendLabels = [legendLabels [refMeasureShortNames{rr} ' vs ' refMeasureShortNames{cc}]];

                    for k = 1:s                    
                        data(k) = reference{'Mean', k}{1, 1}{rr, cc};                    
                    end;
                    
                    plot(data, 'Color', refColors(mod(rr+cc, length(refColors)) + 1, :), 'LineStyle', REF_LINESTYLE, ...
                        'Marker', refMarkers{mod(rr+cc, length(refMarkers)) + 1}, ...
                        'LineWidth', REF_LINEWIDTH, 'MarkerSize', REF_MARKERSIZE, ...
                        'MarkerFaceColor', refColors(mod(rr+cc, length(refColors)) + 1, :));    
                    
                % plot confidence intervals 
                if plotCI     
                    ci = NaN(1, s);
                    
                    for k = 1:s                    
                        ci(k) = reference{'ConfidenceIntervalDelta', k}{1, 1}{rr, cc};                    
                    end;
                                        
                    ciLo = data - ci;
                    ciLo = ciLo(:).';
                    ciHi = data + ci;
                    ciHi = ciHi(:).';

                    x = 1:length(ciHi);
                    hFill = fill([x fliplr(x)],[ciHi fliplr(ciLo)], refColors(mod(rr+cc, length(refColors)) + 1, :), ...
                        'LineStyle', 'none', 'EdgeAlpha', 0.10, 'FaceAlpha', 0.10);

                    % send the fill to back
                    uistack(hFill, 'bottom');

                    % Exclude fill from legend
                    set(get(get(hFill, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off'); 
                end;    

                end;
            end;
        end;
        
        
        set(gca, 'FontSize', 14);
        set(gca,'XTick', 1:length(xTickLabels));
        set(gca,'XTickLabel', xTickLabels);
        
        set(gca, 'YLim', [0 1], ...
            'YTick', [0:0.10:1], ...
            'YTickLabel', cellstr(num2str([0:0.10:1].', '%3.2f')).');

        
        grid on;
        
        title(plotTitle);
        xlabel(xLabel)
        ylabel('Kendall''s tau Correlation')        
        
        hl = legend(legendLabels{:}, 'Location', 'SouthWest');
        
        if ~isempty(outputPath)
            set(h,'PaperPositionMode','manual'); 
            set(h,'PaperUnits','normalized');
            set(h,'PaperPosition',[0.05 0.05 0.9 0.9]);
            set(h,'PaperType','A4');
            set(h,'PaperOrientation','landscape');
            print(h, '-dpdf', [outputPath 'tauB_AtPoolSamples_' uuid() '.pdf']);
            close(h);
        end;
        
    end;
                       
end



