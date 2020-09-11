%% plotDiscriminativePowerAtPoolSamples
% 
% It plot the discriminative power of a set of runs at differente pool samples.
%
%% Synopsis
%
%   plotDiscriminativePowerAtPoolSamples(aslStats, varargin)
%
% *Parameters*
%
% * *|aslStats|* - a table containing the achieved significance level for each
% measures. It is a table in the same format returned by the output |aslStats| 
% in <../analysis/computeDiscriminativePowerAtPoolSamples.html computeDiscriminativePowerAtPoolSamples>.
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
% * *|Observed|* (mandatory) - a cell vector of strings containing the list 
% of measure short names in |asl| to be considered as observations.
% * *|Reference|* (optional) -  a cell vector of strings containing the list 
% of measure short names in |asl| to be considered as references.
% Reference performances will be plot with a different color and line style
% with respect to observed performances.
% * *|DpStats|* (optional) -  a table containing the discriminative 
% power for each measure. It is a table in the same format 
% returned by the output |dpStats| in <../analysis/computeDiscriminativePowerAtPoolSamples.html computeDiscriminativePowerAtPoolSamples>.
% * *|DeltaStats|* (optional) -  a table containing the needed delta for each 
% measure. It is a table in the same format returned by the output
% |deltaStats| in <../analysis/computeDiscriminativePowerAtPoolSamples.html computeDiscriminativePowerAtPoolSamples>.
% * *|PlotCI|* (optional) -  a boolean indicating whether confidence
% intervals across pool iterations have to be plotted. The default is
% |false|.
% * *|PlotSelf|* (optional) -  a boolean indicating whether self discriminative power plots
% have to be plotted. The default is |false|.

%
%% Example of use
%  
%   plotDiscriminativePowerAtPoolSamples(aslStats, 'Title', 'Campaign 2014, Ad Hoc', ...
%                  'Observed', {'P_10', 'P_100', 'Rprec'}, ...
%                  'Reference', {'AP', 'bpref', 'RBP_080'}, ....
%                  'DpStats', pdStats, ...
%                  'DeltaStats', deltaStats, ...
%                  'PlotCI', true,
%                  'OutputPath', '/output')
%
% It produces the following plots and saves it to a PDF file in the provided
% output directory.
%
% 
% <<discriminativePowerAtPoolSamples.png>>
%
%
% <<discriminativePowerAtPoolSamples2.png>>
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
function [] = plotDiscriminativePowerAtPoolSamples(aslStats, varargin)

    persistent MARKERS ...
        REF_LINESTYLE REF_LINEWIDTH REF_MARKERSIZE ...
        OBS_LINESTYLE OBS_LINEWIDTH OBS_MARKERSIZE ...
        X_LIM_STEP;
    
    if isempty(MARKERS)
        
        MARKERS = {'o', '+', '*', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};

        REF_LINESTYLE = '--';
        REF_LINEWIDTH = 1.0;
        REF_MARKERSIZE = 6;
        
        OBS_LINESTYLE = '-';
        OBS_LINEWIDTH = 1.2;
        OBS_MARKERSIZE = 7; 
        
        X_LIM_STEP = 50;
    end;
       
    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
     % parse the variable inputs
    pnames = {'Title' 'OutputPath' 'Reference', 'Observed', 'DpStats', 'DeltaStats', 'PlotCI', 'FileNameSuffix' 'SelfPlot'};
    dflts =  {[]      []           []           []          []          []            false,    '',             false};
    [plotTitle, outputPath, reference, observed, dpStats, deltaStats, plotCI, fileNameSuffix, selfPlot, supplied] = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
       
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
    
    if supplied.DpStats
        % check that each element is a non-empty table
        validateattributes(dpStats, {'table'}, {'nonempty'}, '', 'ASLRatio', 1);    
    end;
    
     if supplied.DeltaStats
        % check that each element is a non-empty table
        validateattributes(deltaStats, {'table'}, {'nonempty'}, '', 'Delta', 1);    
    end;
                  
    if supplied.Observed
        % check that observed is a cell array
        validateattributes(observed, {'cell'}, {'nonempty', 'vector'}, '', 'Observed');

        % check that observed is a cell array of strings with one element
        assert(iscellstr(observed), ...
        'MATTERS:IllegalArgument', 'Expected Observed to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a char row
        observed = strtrim(observed);
        observed = observed(:).';
        
        % check that all the requested observed measures are part of the ASL table
        tmp = setdiff(observed, aslStats{1, 1}{1, 1}.Properties.RowNames);
        if ~isempty(tmp)        
            error('MATTERS:IllegalArgument', 'The following requested observed measures %s are not part of the ASL table for run set %s%s.', ...
                strjoin(tmp, ', '), aslStats.Properties.UserData.identifier); 
        end;       
    else
        error('MATTERS:MissingArgument', 'Parameter ''Observed'' not provided: the observed performances are mandatory.');
    end;
    
    % markers for the observed performances
    obsMarkers = MARKERS;
    
    if supplied.Reference
        % check that reference is a cell array
        validateattributes(reference, {'cell'}, {'nonempty', 'vector'}, '', 'Reference');

        % check that observed is a cell array of strings with one element
        assert(iscellstr(reference), ...
        'MATTERS:IllegalArgument', 'Expected Reference to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a char row
        reference = strtrim(reference);
        reference = reference(:).';
        
        % check that all the requested reference measures are part of the ASL table
        tmp = setdiff(reference, aslStats{1, 1}{1, 1}.Properties.RowNames);
        if ~isempty(tmp)        
            error('MATTERS:IllegalArgument', 'The following requested reference measures %s are not part of the ASL table for run set %s%s.', ...
                strjoin(tmp, ', '), aslStats.Properties.UserData.identifier); 
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
    
    if supplied.SelfPlot
        % check that selfPlot is a non-empty scalar logical value
        validateattributes(selfPlot, {'logical'}, {'nonempty', 'scalar'}, '', 'SelfPlot');
    end; 
           
    switch lower(aslStats.Properties.UserData.shortMethod)
        case {'pbt'}
            plotTitle = {plotTitle; 'ASL using Paired Bootstrap Test'};
        case 'rthsdt'
            plotTitle = {plotTitle; 'ASL using Randomised Tukey HSD Test'};
        otherwise
            error('MATTERS:IllegalArgument', 'Unrecognized discriminative power method %s. Only Paired Bootstrap Test and Randomised Tukey HSD Test are allowed', ...
                aslStats.Properties.UserData.method);
    end;
    
    % adjust the title, if needed
    if supplied.DpStats || supplied.DeltaStats
        plotTitle{2} = [plotTitle{2} ', \alpha = ' num2str(aslStats.Properties.UserData.alpha, '%3.2f')];
    end;
        
    
    measures = aslStats.Properties.UserData.shortName;
    samples = length(aslStats.Properties.UserData.sampleSize) + 1;
    colors = hsv(samples);
    
    if selfPlot
		% for each measure produce a plot of the ASL of the measure at
		% different pool samples
		for m = 1:length(measures)
		
			% if output path is supplied, hide the figure to avoid render it on
			% screen when it is actually saved to a file
			if supplied.OutputPath
				h = figure('Visible', 'off');
			else
				h = figure;
			end;
			hold on
		
			legendLabels = cell(1, samples);
		
			% plot the observed performances
			for k = 1:samples
				meanAsl = aslStats{'Mean', k}{1, 1}{m, 1}{1, 1}{:, :};            
				[meanAsl loc] = sort(meanAsl(~isnan(meanAsl)), 1, 'descend');
									
				plot(meanAsl, 'Color', colors(k, :), 'LineStyle', OBS_LINESTYLE, ...
					'Marker', MARKERS{mod(k, length(MARKERS)) + 1}, ...
					'LineWidth', OBS_LINEWIDTH, 'MarkerSize', OBS_MARKERSIZE, ...
					'MarkerFaceColor', colors(k, :));
			
				% plot confidence intervals 
				if plotCI                
					ciAslDelta = aslStats{'ConfidenceIntervalDelta', k}{1, 1}{m, 1}{1, 1}{:, :};
					ciAslDelta = ciAslDelta(~isnan(ciAslDelta));
					% get it sorted as the meanAsl
					ciAslDelta = ciAslDelta(loc);   


					ciAslLo = meanAsl - ciAslDelta;
					ciAslLo = ciAslLo(:).';
					ciAslHi = meanAsl + ciAslDelta;
					ciAslHi = ciAslHi(:).';

					x = 1:length(ciAslHi);
					hFill = fill([x fliplr(x)],[ciAslHi fliplr(ciAslLo)], colors(k, :), ...
						'LineStyle', 'none', 'EdgeAlpha', 0.10, 'FaceAlpha', 0.10);

					% send the fill to back
					uistack(hFill, 'bottom');

					% Exclude fill from legend
					set(get(get(hFill, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off'); 
				end;
			
				if k == 1
					legendLabels{k} = [measures{m} ', original'];
				else    
					 switch lower(aslStats.Properties.UserData.shortDownsampling)
						case {'srs', 'rs'}
							legendLabels{k} = sprintf('%s, %d%% sample', measures{m}, ...
								aslStats.Properties.UserData.sampleSize(k-1));
						case 'pds'
							legendLabels{k} = sprintf('%s, %d% depth', measures{m}, ...
								aslStats.Properties.UserData.sampleSize(k-1));
						otherwise
							error('MATTERS:IllegalArgument', 'Unrecognized pool downsampling method %s. Only PoolDepthSampling, RandomSampling, and StratifiedRandomSampling are allowed', ...
								meanPerfStats.Properties.UserData.downsampling);
					 end;
				end;
			
				% adjust the legend, if needed
				if supplied.DpStats || supplied.DeltaStats
					tmpLegendLabels = [legendLabels{k} ' ['];

					if supplied.DpStats  
						% if we have more than 1 iteration, plot also the
						% confidence interval, otherwise only the mean
						if dpStats.Properties.UserData.iterations > 1
							tmpLegendLabels = sprintf('%sDP = %4.2f%%\\pm%4.2f', tmpLegendLabels, ...
								dpStats{'Mean', k}{1, 1}{m, 1}*100, ...
								dpStats{'ConfidenceIntervalDelta', k}{1, 1}{m, 1}*100);
						else
							tmpLegendLabels = sprintf('%sDP = %4.2f%%', tmpLegendLabels, ...
								dpStats{'Mean', k}{1, 1}{m, 1}*100);
						end;
					end;

					if supplied.DeltaStats
						if supplied.DpStats                
							tmpLegendLabels = [tmpLegendLabels '; '];
						end;
					
						% if we have more than 1 iteration, plot also the
						% confidence interval, otherwise only the mean
						if deltaStats.Properties.UserData.iterations > 1
							tmpLegendLabels = sprintf('%s\\Delta = %5.2f\\pm%5.2f', tmpLegendLabels, ...
								deltaStats{'Mean', k}{1, 1}{m, 1}, ...
								deltaStats{'ConfidenceIntervalDelta', k}{1, 1}{m, 1});
						else
							tmpLegendLabels = sprintf('%s\\Delta = %5.2f', tmpLegendLabels, ...
								deltaStats{'Mean', k}{1, 1}{m, 1});

						end;
					end;

					legendLabels{k} = [tmpLegendLabels ']'];
				end;
			
			end          
		
			set(gca, 'FontSize', 14);

			set(gca, 'XLim', [0 (fix(length(meanAsl)/X_LIM_STEP) + 1)*X_LIM_STEP])
		
			set(gca, 'YLim', [0 0.15], ...
				'YTick', [0:0.01:0.15], ...
				'YTickLabel', cellstr(num2str([0:0.01:0.15].', '%3.2f')).');
		
			grid on;
		
			legendLabels = strrep(legendLabels, '_', '\_');  
			hl = legend(legendLabels{:}, 'Location', 'NorthEast');
			set(hl, 'FontSize', 12);

			xlabel('System Pair (sorted by decreasing ASL)')
			ylabel('Achieved Significance Level (ASL)')
			title(plotTitle);

			if ~isempty(outputPath)
				set(h,'PaperPositionMode','manual'); 
				set(h,'PaperUnits','normalized');
				set(h,'PaperPosition',[0.05 0.05 0.9 0.9]);
				set(h,'PaperType','A4');
				set(h,'PaperOrientation','landscape');
				print(h, '-dpdf', sprintf('%1$ssDiscriminativePowerAtPoolSamples_%2$s_%3$s.pdf', outputPath, measures{m}, uuid()));
				close(h);
			end;
		
		end;
    
    end;
            
    
    measures = [observed reference];
    obsColors = hsv(length(observed));
    refColors = copper(length(reference));
    origPlotTitle = plotTitle{2};
        
    for k = 1:samples
        

        if k == 1
            plotTitle{2} = [origPlotTitle ', Original Pool'];
        else    
             switch lower(aslStats.Properties.UserData.shortDownsampling)
                case {'srs', 'rs'}
                    plotTitle{2} = sprintf('%s, %d%% Pool Reduction Rate', origPlotTitle, ...
                        aslStats.Properties.UserData.sampleSize(k-1));
                case 'pds'
                    plotTitle{2} = sprintf('%s, %d% Pool Depth', origPlotTitle, ...
                        aslStats.Properties.UserData.sampleSize(k-1));
                otherwise
                    error('MATTERS:IllegalArgument', 'Unrecognized pool downsampling method %s. Only PoolDepthSampling, RandomSampling, and StratifiedRandomSampling are allowed', ...
                        meanPerfStats.Properties.UserData.downsampling);
             end;
        end;

        legendLabels = measures;

        % adjust the legend, if needed
        if supplied.DpStats || supplied.DeltaStats
            
            for m = 1:length(legendLabels)
       
                legendLabels{m} = [legendLabels{m} ' ['];

                if supplied.DpStats                      
                    % if we have more than 1 iteration, plot also the
                    % confidence interval, otherwise only the mean
                    if dpStats.Properties.UserData.iterations > 1
                        legendLabels{m} = sprintf('%sDP = %4.2f%%\\pm%4.2f', legendLabels{m}, ...
                        dpStats{'Mean', k}{1, 1}{measures{m}, 1}*100, ...
                        dpStats{'ConfidenceIntervalDelta', k}{1, 1}{measures{m}, 1}*100);
                    else
                        legendLabels{m} = sprintf('%sDP = %4.2f%%', legendLabels{m}, ...
                        dpStats{'Mean', k}{1, 1}{measures{m}, 1}*100);
                    end;
                end;

                if supplied.DeltaStats
                    if supplied.DpStats                
                        legendLabels{m} = [legendLabels{m} '; '];
                    end;
                    
                    
                    % if we have more than 1 iteration, plot also the
                    % confidence interval, otherwise only the mean
                    if deltaStats.Properties.UserData.iterations > 1
                        legendLabels{m} = sprintf('%s\\Delta = %4.2f\\pm%4.2f', legendLabels{m}, ...
                        deltaStats{'Mean', k}{1, 1}{measures{m}, 1}, ...
                        deltaStats{'ConfidenceIntervalDelta', k}{1, 1}{measures{m}, 1});
                    else
                        legendLabels{m} = sprintf('%s\\Delta = %4.2f', legendLabels{m}, ...
                        deltaStats{'Mean', k}{1, 1}{measures{m}, 1});
                    end;
                end;

                legendLabels{m} = [legendLabels{m} ']'];
            end;
            
        end;
               
        legendLabels = strrep(legendLabels, '_', '\_');

                
        % if output path is supplied, hide the figure to avoid render it on
        % screen when it is actually saved to a file
        if supplied.OutputPath
            h = figure('Visible', 'off');
        else
            h = figure;
        end;
        hold on
        
        % plot the observed performances
        for m = 1:length(observed)
            
            meanAsl = aslStats{'Mean', k}{1, 1}{observed{m}, 1}{1, 1}{:, :};            
            [meanAsl loc] = sort(meanAsl(~isnan(meanAsl)), 1, 'descend');
                                    
            plot(meanAsl, 'Color', obsColors(m, :), 'LineStyle', OBS_LINESTYLE, ...
                'Marker', obsMarkers{mod(m, length(obsMarkers)) + 1}, ...
                'LineWidth', OBS_LINEWIDTH, 'MarkerSize', OBS_MARKERSIZE, ...
                'MarkerFaceColor', obsColors(m, :));
            
            % plot confidence intervals 
            if plotCI                
                ciAslDelta = aslStats{'ConfidenceIntervalDelta', k}{1, 1}{observed{m}, 1}{1, 1}{:, :};
                ciAslDelta = ciAslDelta(~isnan(ciAslDelta));
                % get it sorted as the meanAsl
                ciAslDelta = ciAslDelta(loc);   


                ciAslLo = meanAsl - ciAslDelta;
                ciAslLo = ciAslLo(:).';
                ciAslHi = meanAsl + ciAslDelta;
                ciAslHi = ciAslHi(:).';

                x = 1:length(ciAslHi);
                hFill = fill([x fliplr(x)],[ciAslHi fliplr(ciAslLo)], obsColors(m, :), ...
                    'LineStyle', 'none', 'EdgeAlpha', 0.10, 'FaceAlpha', 0.10);

                % send the fill to back
                uistack(hFill, 'bottom');

                % Exclude fill from legend
                set(get(get(hFill, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off'); 
            end;            
        end;
    
        % plot the reference performances
        for m = 1:length(reference)
            
            meanAsl = aslStats{'Mean', k}{1, 1}{reference{m}, 1}{1, 1}{:, :};            
            [meanAsl loc] = sort(meanAsl(~isnan(meanAsl)), 1, 'descend');
                                    
            plot(meanAsl, 'Color', refColors(m, :), 'LineStyle', REF_LINESTYLE, ...
                'Marker', refMarkers{mod(m, length(refMarkers)) + 1}, ...
                'LineWidth', REF_LINEWIDTH, 'MarkerSize', REF_MARKERSIZE, ...
                'MarkerFaceColor', refColors(m, :));
            
            % plot confidence intervals 
            if plotCI                
                ciAslDelta = aslStats{'ConfidenceIntervalDelta', k}{1, 1}{reference{m}, 1}{1, 1}{:, :};
                ciAslDelta = ciAslDelta(~isnan(ciAslDelta));
                % get it sorted as the meanAsl
                ciAslDelta = ciAslDelta(loc);   


                ciAslLo = meanAsl - ciAslDelta;
                ciAslLo = ciAslLo(:).';
                ciAslHi = meanAsl + ciAslDelta;
                ciAslHi = ciAslHi(:).';

                x = 1:length(ciAslHi);
                hFill = fill([x fliplr(x)],[ciAslHi fliplr(ciAslLo)], refColors(m, :), ...
                    'LineStyle', 'none', 'EdgeAlpha', 0.10, 'FaceAlpha', 0.10);

                % send the fill to back
                uistack(hFill, 'bottom');

                % Exclude fill from legend
                set(get(get(hFill, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle','off'); 
            end;            
        end;
           
        
        set(gca, 'FontSize', 14);

        set(gca, 'XLim', [0 (fix(length(meanAsl)/X_LIM_STEP) + 1)*X_LIM_STEP])
        
        set(gca, 'YLim', [0 0.15], ...
            'YTick', [0:0.01:0.15], ...
            'YTickLabel', cellstr(num2str([0:0.01:0.15].', '%3.2f')).');
        
        grid on;

        hl = legend(legendLabels{:}, 'Location', 'NorthEast');
        set(hl, 'FontSize', 12);

        xlabel('System Pair (sorted by decreasing ASL)')
        ylabel('Achieved Significance Level (ASL)')
        title(plotTitle);

        if ~isempty(outputPath)
            
            sfx = 'original';
            if k > 1
                sfx = sprintf('%03d-sample', aslStats.Properties.UserData.sampleSize(k-1));
            end;
            
            
            set(h,'PaperPositionMode','manual'); 
            set(h,'PaperUnits','normalized');
            set(h,'PaperPosition',[0.05 0.05 0.9 0.9]);
            set(h,'PaperType','A4');
            set(h,'PaperOrientation','landscape');
            print(h, '-dpdf', sprintf('%1$sxDiscriminativePower_AtPoolSamples_%2$s%3$s_%4$s.pdf', outputPath, fileNameSuffix, sfx, uuid()));
            close(h);
        end;        
    end;

    
  
            
end



