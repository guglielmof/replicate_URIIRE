%% computeAndSaveMeasureAtPoolSamples
% 
% Load the downsampled pool and the runSet (this function assumes these tables are already available) 
% of an experimental collection and calculates and saves the measures.

%% Example of use
%  
% collectionIdentifier = {'TREC_02_1993_AdHoc'};
%
% experimentalCollectionPath = {'/experimental-collections/TREC/'};
%
% outputPath = strcat(experimentalCollectionPath, collectionIdentifier, filesep, 'matlab', filesep, 'measures', filesep);
%
% measureFunctions = {'AP'; 'bpref'; 'RPrec'; 'P10'; 'rbp'};
% samplingTechniques = {'StratifiedRandomSampling', 'RandomSampling'};
%
% iterations = [1 10 20];
%
% computeAndSaveMeasureAtPoolSamples('CollectionIdentifier', collectionIdentifier, ...
%	'ExperimentalCollectionsPath', experimentalCollectionPath, ...
%	'OutputPath', strcat(outputPath, 'treceval'), 'DocumentOrdering', 'TrecEval', 'MeasureFunctions', measureFunctions, ...
%	'Iterations', iterations, 'SamplingTechniques', samplingTechniques);
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
function measuredRunSet = computeAndSaveMeasureAtPoolSamples(varargin)

    
    % disable warnings, not needed for bulk import
    warning('off');
    
     persistent saveMeasureStratifiedRandomSampling saveMeasureRandomSampling saveMeasureDepthSampling
     
      if isempty(saveMeasureStratifiedRandomSampling)
        
        % save MeasureStratifiedRandomSampling variable
        saveMeasureStratifiedRandomSampling = 'sersave(''%1$s%3$s_%2$s_stratifiedRandomSampling_%4$s'', %3$s_%2$s);';
        
        % save MeasureRandomSampling variable
        saveMeasureRandomSampling = 'sersave(''%1$s%3$s_%2$s_randomSampling_%4$s'', %3$s_%2$s);';
        
         % save MeasureRandomSampling variable
        saveMeasureDepthSampling = 'sersave(''%1$s%3$s_%2$s_depthSampling_%4$s'', %3$s_%2$s);';
        
     end;
    
    % parse the variable inputs
    pnames = {'CollectionIdentifier' 'OutputPath' 'ExperimentalCollectionsPath', 'DocumentOrdering', 'MeasureFunctions', 'Iterations', 'SamplingTechniques', 'IsGraded'};
    dflts =  {[]                     []               []                                []                  []             [1]              []                  false     };
    [collectionIdentifier, outputPath, experimentalCollectionsPath, documentOrdering, measureFunctions, iterations, samplingTechniques, isGraded, supplied, otherArgs] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

    if supplied.CollectionIdentifier
        % check that identifier is a non-empty string
        validateattributes(collectionIdentifier, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'CollectionIdentifier');
    
         if iscell(collectionIdentifier)
            % check that identifier is a cell array of strings with one element
            assert(iscellstr(collectionIdentifier) && numel(collectionIdentifier) == 1, ...
                'MATTERS:IllegalArgument', 'Expected CollectionIdentifier to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        collectionIdentifier = char(strtrim(collectionIdentifier));
        collectionIdentifier = collectionIdentifier(:).';
        
         % check that the identifier is ok according to the matlab rules
        if ~isempty(regexp(collectionIdentifier, '(^[0-9_])?\W*', 'once'))
            error('MATTERS:IllegalArgument', 'Collection identifier %s is not valid: identifiers can contain only letters, numbers, and the underscore character and they must start with a letter.', ...
                collectionIdentifier);
        end      
    else
        error('MATTERS:MissingArgument', 'Parameter ''CollectionIdentifier'' not provided: the unique identifier of the pool is mandatory.');
    end;
        
    if supplied.OutputPath
        % check that path is a non-empty string
        validateattributes(outputPath, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'OutputPath');
        
        if iscell(outputPath)
            % check that path is a cell array of strings with one element
            assert(iscellstr(outputPath) && numel(outputPath) == 1, ...
                'MATTERS:IllegalArgument', 'Expected OutputPath to be a cell array of strings containing just one string.');
        end

        % remove useless white spaces, if any, and ensure it is a char row
        outputPath = char(strtrim(outputPath));
        outputPath = outputPath(:).';
        
        % check if the path is a directory and if it exists
        if ~(isdir(outputPath))
            warning('MATTERS:IllegalArgument', 'Expected OutputPath to be an existing directory.');
            % create the output directory 
            mkdir(outputPath);
        end;

        % check if the given directory path has the correct separator at the
        % end.
        if outputPath(end) ~= filesep;
           outputPath(end + 1) = filesep;
        end; 
    else
        error('MATTERS:MissingArgument', 'Parameter ''OutputPath'' not provided: the directory to which the collection has to be written is mandatory.');
    end;
    
    if supplied.ExperimentalCollectionsPath
        % check that path is a cell array
        validateattributes(experimentalCollectionsPath, {'cell'}, {'nonempty', 'vector'}, '', 'ExperimentalCollectionsPath');
        
        % check that path is a cell array of strings with one element
        assert(iscellstr(experimentalCollectionsPath), ...
            'MATTERS:IllegalArgument', 'Expected ExperimentalCollectionsPath to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a char row
        experimentalCollectionsPath = strtrim(experimentalCollectionsPath);
        experimentalCollectionsPath = experimentalCollectionsPath(:).';
        
        for k = 1:length(experimentalCollectionsPath)
             % check if the path is a directory and if it exists
            if ~(isdir(experimentalCollectionsPath{k}))
                error('MATTERS:IllegalArgument', 'Expected matlab dataset path %s to be a directory.', experimentalCollectionsPath{k});
            end;

            % check if the given directory path has the correct separator at the
            % end.
            if experimentalCollectionsPath{k}(end) ~= filesep;
               experimentalCollectionsPath{k}(end + 1) = filesep;
            end; 
        end;
        
    else
        error('MATTERS:MissingArgument', 'Parameter ''ExperimentalCollectionsPath'' not provided: the directories from which the matlab datasets have to be imported are mandatory.');
    end;

     if supplied.DocumentOrdering
        % check that documentOrdering is a non-empty string
        validateattributes(documentOrdering, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'DocumentOrdering');
        
        if iscell(documentOrdering)
            % check that documentOrdering is a cell array of strings with one element
            assert(iscellstr(documentOrdering) && numel(documentOrdering) == 1, ...
                'MATTERS:IllegalArgument', 'Expected DocumentOrdering to be a cell array of strings containing just one string.');
        end
               
        % check that documentOrdering assumes a valid value
        validatestring(documentOrdering,{'Original',  'TrecEval', 'TrecEval_Asc', 'Conservative', 'MATTERS'}, '', 'DocumentOrdering');                        
    end;
    % remove useless white spaces, if any, lower case, and ensure it is
    % a char row
    documentOrdering = lower(char(strtrim(documentOrdering)));
    documentOrdering = documentOrdering(:).';
    
    if supplied.MeasureFunctions
        % check that measureFunctions is a non-empty cell array 
        validateattributes(measureFunctions,{'cell'}, {'vector', 'nonempty'}, '', 'MeasureFunctions');

        % check that measureFunctions is a cell array of strings
        assert(iscellstr(measureFunctions), 'MATTERS:IllegalArgument', 'Expected MeasureFunctions to be a cell array of strings.');

        % remove useless white spaces, if any, and ensure it is a row
        % vector
        measureFunctions = strtrim(measureFunctions);
        measureFunctions = measureFunctions(:).';
        
        if supplied.Iterations           
            validateattributes(iterations, {'numeric'}, ...
                    {'nonempty', 'integer', 'vector', '>', 0, '<', 1001}, '', 'Iterations');
    
            % ensure it is a row vector
            iterations = iterations(:).';
        end;
        
         % check that the measure functions short names are ok according to the matlab 
         % rules for variable names
        if ~isempty(cell2mat(regexp(measureFunctions, '(^[0-9_])?\W*', 'once')))
            error('MATTERS:IllegalArgument', 'Measure function(s) %s are not valid: they can contain only letters, numbers, and the underscore character and they must start with a letter.', ...
                strjoin(measureFunctions, ', '));
        end 
    else
        error('MATTERS:MissingArgument', 'Parameter ''MeasureFunctions'' not provided: the measure functions for which the measure tables have to be calculated are mandatory.');
    end;
    
    if supplied.SamplingTechniques
        % check that samplingTechniques is a non-empty string
        validateattributes(samplingTechniques, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'SamplingTechniques');
        
        if iscell(samplingTechniques)
            % check that documentOrdering is a cell array of strings with one element
            assert(iscellstr(samplingTechniques), ...
                'MATTERS:IllegalArgument', 'Expected SamplingTechniques to be a cell array of strings.');
        end
               
        % check that documentOrdering assumes a valid value
        validatestring(samplingTechniques{1},{'StratifiedRandomSampling',  'RandomSampling', 'DownSampling'}, '', 'SamplingTechniques');                        
    end;
    
    if supplied.IsGraded
        % check that mapToBinary is a non-empty scalar
        % logical value
        validateattributes(isGraded, {'logical'}, {'nonempty', 'scalar'}, '', 'IsGraded');

    end; 
    
    
    % remove useless white spaces, if any, lower case, and ensure it is
    % a char row
    samplingTechniques = lower(char(strtrim(samplingTechniques)));
    samplingTechniques = samplingTechniques(:).';
    
    % start import
    begin = tic;
    
    fprintf('\n\n>>>>>>>> Importing pool and RunSet for collection %s <<<<<<<<\n\n', ...
        collectionIdentifier);

    fprintf('+ Settings\n');
    fprintf('  - imported on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - Matlab version: %s\n', version);
    fprintf('  - platform: %s\n', computer('arch'));
    fprintf('  - output path: %s\n', outputPath);
    fprintf('\n');    
    
    runSetFile = [experimentalCollectionsPath collectionIdentifier filesep 'matlab' filesep 'datasets' filesep documentOrdering filesep 'runSet_' collectionIdentifier '.mat'];
    
    % import the pool
    fprintf('+ Import %s ordering data \n', documentOrdering);
    
    start = tic;
    
    fprintf('+ Importing run set: runSet_%s from file: %s \n', collectionIdentifier, strcat(runSetFile{:}));
    
    % serload the runSet
    serload(strcat(runSetFile{:}));
    
    eval(sprintf('%s = %s;', 'runSet', strcat('runSet_', collectionIdentifier)));
 
    clear strcat('runSet_', collectionIdentifier);
    
    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
    
    % Measures calculated with Stratified Random Sampling
    if (ismember('stratifiedrandomsampling', samplingTechniques))
        for i=1:length(iterations)
            clear assess;
            start = tic;

            % serload the pool
            sampledPoolFile = [experimentalCollectionsPath collectionIdentifier filesep 'matlab'...
                filesep 'datasets' filesep documentOrdering filesep 'sampledPool_' ...
                collectionIdentifier  '_stratifiedRandomSampling_' num2str(iterations(i)) '.mat'];

            fprintf('+ Importing (stratified random sampling) pool: sampledPool_%s_stratifiedRandomSampling_%s from file: %s \n', collectionIdentifier, num2str(iterations(i)), strcat(sampledPoolFile{:}));

            serload(strcat(sampledPoolFile{:}));
            
            eval(sprintf('%s = %s;', 'sampledPool', strcat('sampledPool_', collectionIdentifier, ...
                '_stratifiedRandomSampling_', num2str(iterations(i)))));

            clear strcat('sampledPool_', collectionIdentifier, '_stratifiedRandomSampling_', num2str(iterations(i));

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            if (ismember('AP', measureFunctions))
                shortName = 'AP';
                func = str2func('averagePrecision');
                otherArgs = {};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end
            
            if (ismember('RR', measureFunctions))
                shortName = 'RR';
                func = str2func('reciprocalRank');
                otherArgs = {};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end

            if(ismember('RPrec', measureFunctions))
                shortName = 'RPrec';
                func = str2func('precision');
                otherArgs = {'RPrec', true};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end

            if(ismember('P_10', measureFunctions))
                shortName = 'P_10';
                func = str2func('precision');
                otherArgs = {'CutOffs', 10};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end
            
            if(ismember('P_LRR', measureFunctions))
                shortName = 'P_LRR';
                func = str2func('precision');
                otherArgs = {'CutOffs', 'LastRelevantRetrieved'};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end

            if(ismember('bpref', measureFunctions))
                shortName = 'bpref';
                func = str2func('binaryPreference');
                otherArgs = {};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end

            if(ismember('rbp', measureFunctions))
                shortName = 'rbp_8';
                func = str2func('rankBiasedPrecision');
                otherArgs = {};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                 eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end
            
             if(ismember('rbp_5', measureFunctions))
                shortName = 'rbp_5';
                func = str2func('rankBiasedPrecision');
                otherArgs = {'Persistence', 0.5};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                 eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
             end
            
             if(ismember('rbp_95', measureFunctions))
                shortName = 'rbp_95';
                func = str2func('rankBiasedPrecision');
                otherArgs = {'Persistence', 0.95};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                 eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
            end
             
            if (ismember('DCG_10', measureFunctions))
                shortName = 'DCG_10';
                func = str2func('discountedCumulatedGain');
                otherArgs = {'CutOffs', 10, 'LogBase', 2, 'MapToBinaryRelevance', 'lenient'};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                 eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if (isGraded)
                    shortName = 'DCG_10';
                    func = str2func('discountedCumulatedGain');
                    otherArgs = {'CutOffs', 10, 'LogBase', 2};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                     eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                end
            end
            
            if(ismember('DCG_R', measureFunctions))
                shortName = 'DCG_R';
                func = str2func('discountedCumulatedGain');
                otherArgs = {'RecallBase', true, 'MapToBinaryRelevance', 'lenient', 'LogBase', 2};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                 eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'DCG_R';
                    func = str2func('discountedCumulatedGain');
                    otherArgs = {'RecallBase', true, 'LogBase', 2};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                     eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    

                    start = tic;
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                end
            end
            
             if (ismember('DCG_LRR', measureFunctions))
                shortName = 'DCG_LRR';
                func = str2func('discountedCumulatedGain');
                otherArgs = {'CutOffs', 'LastRelevantretrieved', 'MapToBinaryRelevance', 'lenient', 'LogBase', 2};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                 eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if (isGraded)
                    shortName = 'DCG_LRR';
                    func = str2func('discountedCumulatedGain');
                    otherArgs = {'CutOffs', 'LastRelevantretrieved', 'LogBase', 2};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                     eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    

                    start = tic;
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                end
             end
             
            if (ismember('nDCG_10', measureFunctions))
                shortName = 'nDCG_10';
                func = str2func('discountedCumulatedGain');
                otherArgs = {'CutOffs', 10, 'Normalize', true, 'MapToBinaryRelevance', 'lenient', 'LogBase', 2};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'nDCG_10';
                    func = str2func('discountedCumulatedGain');
                    otherArgs = {'CutOffs', 10, 'Normalize', true, 'LogBase', 2};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                     eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    

                    start = tic;
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                end
            end
            
            if(ismember('nDCG_R', measureFunctions))
                shortName = 'nDCG_R';
                func = str2func('discountedCumulatedGain');
                otherArgs = {'RecallBase', true, 'Normalize', true, 'MapToBinaryRelevance', 'lenient', 'LogBase', 2};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'nDCG_R';
                    func = str2func('discountedCumulatedGain');
                    otherArgs = {'RecallBase', true, 'Normalize', true, 'LogBase', 2};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                     eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    

                    start = tic;
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                end
            end
            
            if (ismember('nDCG_LRR', measureFunctions))
                shortName = 'nDCG_LRR';
                func = str2func('discountedCumulatedGain');
                otherArgs = {'CutOffs', 'LastRelevantretrieved', 'Normalize', true, 'MapToBinaryRelevance', 'lenient', 'LogBase', 2};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'nDCG_LRR';
                    func = str2func('discountedCumulatedGain');
                    otherArgs = {'CutOffs', 'LastRelevantretrieved', 'Normalize', true, 'LogBase', 2};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                     eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    

                    start = tic;
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                end
            end
            
             if (ismember('nDCG_1000', measureFunctions))
                shortName = 'nDCG_1000';
                func = str2func('discountedCumulatedGain');
                otherArgs = {'CutOffs', 1000, 'Normalize', true, 'MapToBinaryRelevance', 'lenient', 'LogBase', 2};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'nDCG_1000';
                    func = str2func('discountedCumulatedGain');
                    otherArgs = {'CutOffs', 1000, 'Normalize', true, 'LogBase', 2};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations\n', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                     eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    

                    start = tic;
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                end
            end
            
            if(ismember('CRPIndicators', measureFunctions))
                shortName = 'CRPIndicators';
                func = str2func('cumulatedRelativePosition');
                otherArgs = {'MapToBinaryRelevance', 'lenient', 'NumOutputs', 4};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                [measuredRunSet, ~, ~, rho, sigma, tau] = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                shortName = 'CRP';
                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;
                
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                
                start = tic;
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                shortName = 'rho';
                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'rho'));

                clear rho;

                start = tic;
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                shortName = 'sigma';
                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'sigma'));

                clear sigma;

                start = tic;
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                shortName = 'tau';
                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'tau'));

                clear tau;

                start = tic;
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'CRPIndicators';
                    func = str2func('cumulatedRelativePosition');
                    otherArgs = {'NumOutputs', 4};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    [measuredRunSet, ~, ~, rho, sigma, tau] = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                    shortName = 'CRP';
                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    

                    start = tic;
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);

                    shortName = 'rho';
                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'rho'));

                    clear rho;

                    start = tic;
                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);

                    shortName = 'sigma';
                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'sigma'));

                    clear sigma;

                    start = tic;
                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);

                    shortName = 'tau';
                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'tau'));

                    clear tau;

                    start = tic;
                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);

                end

            end
            
            if(ismember('CRP_10', measureFunctions))
                shortName = 'CRP_10';
                func = str2func('cumulatedRelativePosition');
                otherArgs = {'CutOffs', 10, 'MapToBinaryRelevance', 'lenient'};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'CRP_10';
                    func = str2func('cumulatedRelativePosition');
                    otherArgs = {'CutOffs', 10};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    start = tic;
                    fprintf('\n+ Saving measure: %s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                   
                end

            end
            
            if(ismember('CRP_LRR', measureFunctions))
                shortName = 'CRP_LRR';
                func = str2func('cumulatedRelativePosition');
                otherArgs = {'CutOffs', 'LastRelevantRetrieved', 'MapToBinaryRelevance', 'lenient'};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'CRP_LRR';
                    func = str2func('cumulatedRelativePosition');
                    otherArgs = {'CutOffs', 'LastRelevantRetrieved'};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    start = tic;
                    fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                   
                end

            end
            
            if(ismember('CRP_R', measureFunctions))
                shortName = 'CRP_R';
                func = str2func('cumulatedRelativePosition');
                otherArgs = {'RecallBase', true, 'MapToBinaryRelevance', 'lenient'};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'CRP_R';
                    func = str2func('cumulatedRelativePosition');
                    otherArgs = {'RecallBase', true};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    start = tic;
                    fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                   
                end

            end
            
            if(ismember('nCRP_10', measureFunctions))
                shortName = 'nCRP_10';
                func = str2func('cumulatedRelativePosition');
                otherArgs = {'CutOffs', 10, 'MapToBinaryRelevance', 'lenient', 'Normalize', true};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'nCRP_10';
                    func = str2func('cumulatedRelativePosition');
                    otherArgs = {'CutOffs', 10, 'Normalize', true};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    start = tic;
                    fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                   
                end

            end
            
            if(ismember('nCRP_LRR', measureFunctions))
                shortName = 'nCRP_LRR';
                func = str2func('cumulatedRelativePosition');
                otherArgs = {'CutOffs', 'LastRelevantRetrieved', 'MapToBinaryRelevance', 'lenient', 'Normalize', true};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'nCRP_LRR';
                    func = str2func('cumulatedRelativePosition');
                    otherArgs = {'CutOffs', 'LastRelevantRetrieved', 'Normalize', true};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    start = tic;
                    fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                   
                end

            end
            
            if(ismember('nCRP_R', measureFunctions))
                shortName = 'nCRP_R';
                func = str2func('cumulatedRelativePosition');
                otherArgs = {'RecallBase', true, 'MapToBinaryRelevance', 'lenient', 'Normalize', true};
                fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear([shortName '_' collectionIdentifier]);
                
                if isGraded
                    shortName = 'nCRP_R';
                    func = str2func('cumulatedRelativePosition');
                    otherArgs = {'RecallBase', true, 'Normalize', true};
                    fprintf('+ Calculating %s for the Stratified Random Sampled pool with %d iterations', shortName, iterations(i));

                    start = tic;

                    measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                    eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

                    clear measuredRunSet;

                    start = tic;
                    fprintf('\n+ Saving measure: measuredRunSet_%s_%s_stratifiedRandomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                    eval(sprintf(saveMeasureStratifiedRandomSampling, strcat(outputPath, 'graded', filesep), collectionIdentifier, shortName, num2str(iterations(i)))); 

                    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                    % free space
                    clear([shortName '_' collectionIdentifier]);
                   
                end

            end

        end
    end
    
    % Measures calculated with random sampling
    if (ismember('randomsampling', samplingTechniques))
        for i=1:length(iterations)
            clear assess;
            start = tic;

            sampledPoolFile = [experimentalCollectionsPath collectionIdentifier filesep 'matlab'...
                filesep 'datasets' filesep documentOrdering filesep 'sampledPool_' ...
                collectionIdentifier  '_randomSampling_' num2str(iterations(i)) '.mat'];

            fprintf('+ Importing (random sampling) pool: sampledPool_%s_randomSampling_%s from file: %s \n', collectionIdentifier, num2str(iterations(i)), strcat(sampledPoolFile{:}));

            % serload the pool

            serload(strcat(sampledPoolFile{:}));

            eval(sprintf('%s = %s;', 'sampledPool', strcat('sampledPool_', collectionIdentifier, ...
                '_randomSampling_', num2str(iterations(i)))));
            % free space
            clear strcat('sampledPool_', collectionIdentifier, ...
                '_randomSampling_', num2str(iterations(i));

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            if (ismember('AP', measureFunctions))
                shortName = 'AP';
                func = str2func('averagePrecision');
                otherArgs = {};
                fprintf('+ Calculating %s for the Random Sampled pool with %d iterations\n', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat('measuredRunSet_', collectionIdentifier, '_', shortName), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_randomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i))));       
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
            end

            if(ismember('RPrec', measureFunctions))
                shortName = 'RPrec';
                func = str2func('precision');
                otherArgs = {'RPrec', true};
                fprintf('+ Calculating %s for the Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat('measuredRunSet_', collectionIdentifier, '_', shortName), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_randomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i))));       
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
            end

            if(ismember('P_10', measureFunctions))
                shortName = 'P_10';
                func = str2func('precision');
                otherArgs = {'CutOffs', 10};
                fprintf('+ Calculating %s for the Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat('measuredRunSet_', collectionIdentifier, '_', shortName), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_randomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i))));       
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
            end

            if(ismember('bpref', measureFunctions))
                shortName = 'bpref';
                func = str2func('binaryPreference');
                otherArgs = {};
                fprintf('+ Calculating %s for the Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat('measuredRunSet_', collectionIdentifier, '_', shortName), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_randomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i))));       
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
            end

            if(ismember('rbp', measureFunctions))
                shortName = 'rbp';
                func = str2func('rankBiasedPrecision');
                otherArgs = {};
                fprintf('+ Calculating %s for the Random Sampled pool with %d iterations', shortName, iterations(i));

                start = tic;

                measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

                eval(sprintf('%s = %s;', strcat('measuredRunSet_', collectionIdentifier, '_', shortName), 'measuredRunSet'));

                clear measuredRunSet;

                start = tic;
                fprintf('\n+ Saving measure: measuredRunSet_%s_%s_randomSampling_%s_iter\n', collectionIdentifier, shortName, num2str(iterations(i)));    
                eval(sprintf(saveMeasureRandomSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(iterations(i))));       
                
                fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
                % free space
                clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
            end
        end
    end

    % Measures calculated with pool depth sampling
    if (ismember('downsampling', samplingTechniques))
        start = tic;
        clear assess;
        % serload the pool
        sampledPoolFile = [experimentalCollectionsPath collectionIdentifier filesep 'matlab'...
            filesep 'datasets' filesep documentOrdering filesep 'sampledPool_' ...
            collectionIdentifier  '_poolDepthSampling.mat'];

        fprintf('+ Importing (Pool Depth Sampling) pool: sampledPool_%s_poolDepthSampling from file: %s \n', collectionIdentifier, strcat(sampledPoolFile{:}));

        serload(strcat(sampledPoolFile{:}));

        eval(sprintf('%s = %s;', 'sampledPool', strcat('sampledPool_', collectionIdentifier, ...
            '_poolDepthSampling')));

        % free space
        clear strcat('sampledPool_', collectionIdentifier, ...
            '_poolDepthSampling'))

        fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

        if (ismember('AP', measureFunctions))
            shortName = 'AP';
            func = str2func('averagePrecision');
            otherArgs = {};
            fprintf('+ Calculating %s for the Pool Depth Sampled pool\n', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));           

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end

        if(ismember('RPrec', measureFunctions))
            shortName = 'RPrec';
            func = str2func('precision');
            otherArgs = {'RPrec', true};
            fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));
            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1))); 
            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end

        if(ismember('P_10', measureFunctions))
            shortName = 'P_10';
            func = str2func('precision');
            otherArgs = {'CutOffs', 10};
           fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));
            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));                       fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end

        if(ismember('bpref', measureFunctions))
            shortName = 'bpref';
            func = str2func('binaryPreference');
            otherArgs = {};

            fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

           measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));
            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));                       fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end

        if(ismember('rbp', measureFunctions))
            shortName = 'rbp_8';
            func = str2func('rankBiasedPrecision');
            otherArgs = {'Persistence', 0.8};

            fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));

            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));                       fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end
        
        if(ismember('rbp_5', measureFunctions))
            shortName = 'rbp_5';
            func = str2func('rankBiasedPrecision');
            otherArgs = {'Persistence', 0.5};

            fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));
            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));                       fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end
        
        if(ismember('rbp_95', measureFunctions))
            shortName = 'rbp_95';
            func = str2func('rankBiasedPrecision');
            otherArgs = {'Persistence', 0.95};

            fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));
            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));                       fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end
        
        if(ismember('nDCG_1000', measureFunctions))
             shortName = 'nDCG_1000';
             func = str2func('discountedCumulatedGain');
             otherArgs = {'CutOffs', 1000, 'Normalize', true, 'MapToBinaryRelevance', 'lenient', 'LogBase', 2};
                

            fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));
            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));                       fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end
        
         if(ismember('RR', measureFunctions))
             shortName = 'RR';
             func = str2func('reciprocalRank');
             otherArgs = {};
                

            fprintf('+ Calculating %s for the Depth Sampled pool', shortName);

            start = tic;

            measuredRunSet = computeMeasureAtPoolSamples(sampledPool, runSet, func, otherArgs{:});

            fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));

            eval(sprintf('%s = %s;', strcat(shortName, '_', collectionIdentifier), 'measuredRunSet'));
            clear measuredRunSet;

            start = tic;
            fprintf('\n+ Saving measure: measuredRunSet_%s_%s_poolDepthSampling\n', collectionIdentifier, shortName);    
            eval(sprintf(saveMeasureDepthSampling, strcat(outputPath, 'binary', filesep), collectionIdentifier, shortName, num2str(1)));                       fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
            % free space
            clear(['measuredRunSet_' collectionIdentifier '_' shortName]);
        end
    end
    clear assess;
    % re-enable warnings
    warning('on');
end

