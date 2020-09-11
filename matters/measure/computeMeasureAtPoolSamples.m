%% computeMeasureAtPoolSamples
% 
% Computes a given measure over a set of sampled pools.
%
%% Synopsis
%
%   [measuredRunSet, poolStats, runSetStats, varargout] = computeMeasureAtPoolSamples(sampledPool, runSet, func, varargin)
%  
%
% *Parameters*
%
% * *|sampledPool|* - the sampledPool to be used to assess the run(s). It is a table in the
% same format returned by <../analysis/downsamplePool.html 
% downsamplePool>;
% * *|runSet|* - the run(s) to be assessed. It is a table in the same format
% returned by <../io/importRunFromFileTRECFormat.html 
% importRunFromFileTRECFormat> or by <../io/importRunsFromDirectoryTRECFormat.html 
% importRunsFromDirectoryTRECFormat>;
% * *|func|* - the <http://www.mathworks.it/it/help/matlab/ref/function_handle.html 
% function handle> of the function to be computed.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|NumOutputs|* (optional) - an integer specifying the number of output
% arguments returned by the function. The default is 1. 
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% Any additional Name-Value pair is passed as argument to the computed
% function.
%
% *Returns*
%
% * *|measureRunSet|*  - a table in the same format returned by <../analysis/downsamplePool.html 
% downsamplePool> where each cell contains the measure computed for that
% given pool sample, in the given iteration, over all the run set. The
% actual contents of the cell depends on the computed function.
% * *|poolStats|* - a table in the same format returned by <../analysis/downsamplePool.html 
% downsamplePool> where each cell contains the statistics about the given 
% pool sample in the given iteration. See the description in
% <assess.html assess> for a more information about these statistics.
% * *|runSetStats|* - a table in the same format returned by <../analysis/downsamplePool.html 
% downsamplePool> where each cell contains the statistics about the run set
% with respect to the given  pool sample in the given iteration. See the
% description in<assess.html assess> for more information about these 
% statistics.
% * *|varargout|* - a table in the same format returned by <../analysis/downsamplePool.html 
% downsamplePool> where each cell contains additional output parameters
% from the computed function.

%% Example of use
%  
%   measuredRunSet = computeMeasureAtPoolSamples(downsampledPool, runSet, @averagePrecision);
%
% It computes the average precision for different pool samples over a given
% run set. It returns the following table.
%
%
%                    Samples  
%                     ___________
%
%    Iteration_001    [6x4 table]
%    Iteration_002    [6x4 table]
%    Iteration_003    [6x4 table]
%    Iteration_004    [6x4 table]
%    Iteration_005    [6x4 table]
%
% The table below contains the measure computed at each pool sample for the
% second iteration.
%
%    measuredRunSet{2, 1}{1, 1}
%
%            Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%           ____________    ________________    ________________    ________________
%
%    101    []             [1x8 table]         [1x8 table]         [1x8 table]    
%    102    []             [1x8 table]         [1x8 table]         [1x8 table]    
%    103    []             [1x8 table]         [1x8 table]         [1x8 table]    
%    104    []             [1x8 table]         [1x8 table]         [1x8 table]    
%    105    []             [1x8 table]         [1x8 table]         [1x8 table]    
%    106    []             [1x8 table]         [1x8 table]         [1x8 table]    
%
% Note that the column |Original| contains empty values for the second
% iteration. Indeed, the measure computed on the original pool is contained
% only in the first iteration (and not in the subsequent ones) since it is
% always the same over all iterations and it makes no sense to waste memory
% repeating the same information over all the iterations.
%
% The table below contains the measure computed at each pool sample for the
% first iteration. As you can see, the first iteration contains the measure
% computed also on the original pool.
%
%    measuredRunSet{1, 1}{1, 1}
%
%            Original      SRS_SampleAt_090    SRS_SampleAt_070    SRS_SampleAt_050
%           ____________    ________________    ________________    ________________
%
%    101    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]    
%    102    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]    
%    103    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]    
%    104    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]    
%    105    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]    
%    106    [1x8 table]    [1x8 table]         [1x8 table]         [1x8 table]     
%
%
% As a further example, the following statement return the values of average
% precision for the stratified random sample at 90% for topic 102 for the
% second iteration.
%
%    measuredRunSet{2, 1}{1, 1}{2, 2}{1, 1}
%
%            Brkly3    CLARTA     CLARTM      CnQst1      CnQst2     HNCad1      HNCad2     INQ001 
%           ______    _______    _______    ________    ________    _______    ________    _______
%
%    102    0.1493    0.12755    0.12099    0.039477    0.041628    0.10828    0.099274    0.11005
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
function [measuredRunSet, poolStats, runSetStats, varargout] = computeMeasureAtPoolSamples(sampledPool, runSet, func, varargin)
   
    
    % check that we have the correct number of input arguments. 
    narginchk(3, inf);
    
    % check that sampled pool is a non-empty table
    validateattributes(sampledPool, {'table'}, {'nonempty'}, '', 'sampledPool', 1);
    
    % check that runSet is a non-empty table
    validateattributes(runSet, {'table'}, {'nonempty'}, '', 'runSet', 2);
    
    if ~isa(func,'function_handle')
        error('MATTERS:IllegalArgument', 'Expected func to be a function handle.');
    end
    funcName = func2str(func);
    
    % parse the variable inputs
    pnames = {'NumOutputs', 'Verbose'};
    dflts =  {1             false};
    
    if verLessThan('matlab', '9.2.0')
        [numOutputs, verbose, supplied, otherArgs] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [numOutputs, verbose, supplied, otherArgs] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end
    
                 
    if supplied.NumOutputs                     
        % check that numOutputs is a nonempty scalar integer value
        % greater than 0
        validateattributes(numOutputs, {'numeric'}, ...
            {'nonempty', 'scalar', 'integer', '>', 0}, '', 'NumOutputs');
    end;
    
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                
    iterations = sampledPool.Properties.UserData.iterations;
    samples = [Inf sampledPool.Properties.UserData.sampleSize];
    sampleNum = length(samples);
    topics = height(sampledPool{1, 1}{1, 1});
    
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing function %s with respect to run set %s and pool %s.\n', ...
            funcName, runSet.Properties.UserData.identifier, sampledPool.Properties.UserData.identifier);
        
        fprintf(' - %d iteration(s), %d sample(s), %d topic(s), %d run(s)\n\n', ...
            iterations, sampleNum, topics, height(runSet));        
    end;
                    
    
    % the computed measure at different iterations
    measuredRunSet = cell2table(cell(iterations, 1));
    measuredRunSet.Properties.UserData.identifier = runSet.Properties.UserData.identifier;
    measuredRunSet.Properties.UserData.pool = sampledPool.Properties.UserData.identifier;
    measuredRunSet.Properties.UserData.funcName = funcName;
    measuredRunSet.Properties.UserData.downsampling = sampledPool.Properties.UserData.downsampling;
    measuredRunSet.Properties.UserData.shortDownsampling = sampledPool.Properties.UserData.shortDownsampling;
    measuredRunSet.Properties.UserData.sampleSize = sampledPool.Properties.UserData.sampleSize;
    measuredRunSet.Properties.UserData.iterations = sampledPool.Properties.UserData.iterations;
    measuredRunSet.Properties.RowNames = sampledPool.Properties.RowNames;
    measuredRunSet.Properties.VariableNames = {'Samples'};


    % the pool statistics at different iterations
    poolStats = cell2table(cell(iterations, 1));
    poolStats.Properties.UserData.identifier = sampledPool.Properties.UserData.identifier;
    poolStats.Properties.UserData.funcName = funcName;
    poolStats.Properties.UserData.downsampling = sampledPool.Properties.UserData.downsampling;
    poolStats.Properties.UserData.shortDownsampling = sampledPool.Properties.UserData.shortDownsampling;
    poolStats.Properties.UserData.sampleSize = sampledPool.Properties.UserData.sampleSize;
    poolStats.Properties.UserData.iterations = sampledPool.Properties.UserData.iterations;
    poolStats.Properties.RowNames = sampledPool.Properties.RowNames;
    poolStats.Properties.VariableNames = {'Samples'};
    
    % the run statistics at different iterations
    runSetStats = cell2table(cell(iterations, 1));
    runSetStats.Properties.UserData.identifier = runSet.Properties.UserData.identifier;
    runSetStats.Properties.UserData.pool = sampledPool.Properties.UserData.identifier;
    runSetStats.Properties.UserData.funcName = funcName;
    runSetStats.Properties.UserData.downsampling = sampledPool.Properties.UserData.downsampling;
    runSetStats.Properties.UserData.shortDownsampling = sampledPool.Properties.UserData.shortDownsampling;
    runSetStats.Properties.UserData.sampleSize = sampledPool.Properties.UserData.sampleSize;
    runSetStats.Properties.UserData.iterations = sampledPool.Properties.UserData.iterations;
    runSetStats.Properties.RowNames = sampledPool.Properties.RowNames;
    runSetStats.Properties.VariableNames = {'Samples'};

    % if we have to keep more than one output from the function, allocate
    % room for them
    if numOutputs > 1
        
        varargout = cell(1, numOutputs-1);
        
        for o = 1:numOutputs-1
            varargout{o} = cell2table(cell(iterations, 1));
            varargout{o}.Properties.UserData.identifier = runSet.Properties.UserData.identifier;
            varargout{o}.Properties.UserData.pool = sampledPool.Properties.UserData.identifier;
            varargout{o}.Properties.UserData.funcName = funcName;
            varargout{o}.Properties.UserData.downsampling = sampledPool.Properties.UserData.downsampling;
            varargout{o}.Properties.UserData.shortDownsampling = sampledPool.Properties.UserData.shortDownsampling;
            varargout{o}.Properties.UserData.sampleSize = sampledPool.Properties.UserData.sampleSize;
            varargout{o}.Properties.UserData.iterations = sampledPool.Properties.UserData.iterations;
            varargout{o}.Properties.RowNames = sampledPool.Properties.RowNames;
            varargout{o}.Properties.VariableNames = {'Samples'};
        end;
        
    end;
              
    % compute the measure for each iteration
    for k = 1:iterations
                
        % pre-allocate the measure
        m = cell2table(cell(topics, sampleNum));
        m.Properties.RowNames = sampledPool{1, 1}{1, 1}.Properties.RowNames;
        m.Properties.VariableNames = sampledPool{1, 1}{1, 1}.Properties.VariableNames;
        
        % pre-allocate the poolStat
        pStat = cell2table(cell(topics, sampleNum));
        pStat.Properties.RowNames = sampledPool{1, 1}{1, 1}.Properties.RowNames;
        pStat.Properties.VariableNames = sampledPool{1, 1}{1, 1}.Properties.VariableNames;
        
        % pre-allocate the runSetStat
        rStat = cell2table(cell(topics, sampleNum));
        rStat.Properties.RowNames = sampledPool{1, 1}{1, 1}.Properties.RowNames;
        rStat.Properties.VariableNames = sampledPool{1, 1}{1, 1}.Properties.VariableNames;
        
        
        % if we have to keep more than one output from the function, allocate
        % room for them
        if numOutputs > 1

            out = cell(1, numOutputs-1);

            for o = 1:numOutputs-1
                out{o} = cell2table(cell(topics, sampleNum));
                out{o}.Properties.RowNames = sampledPool{1, 1}{1, 1}.Properties.RowNames;
                out{o}.Properties.VariableNames = sampledPool{1, 1}{1, 1}.Properties.VariableNames;
            end;

        end;
        
        
        % get all the pools
        pools = sampledPool{k, 1}{1, 1};
                
        % compute the measure for each sample
        for s = 1:sampleNum
            
            if verbose        
                fprintf(' - processing iteration %d and sample %d...\n', k, s);        
            end;

            
            % the original pool is present only in the first column of the
            % first iteration, skip senseless computations afterwards
            if s == 1 && k > 1
                continue;
            end;
                        
            pool = pools(:, s);
            pool.Properties.UserData.identifier = sprintf('%s_%s', pools.Properties.UserData.identifier, ...
                pools.Properties.VariableNames{s});
            
            % every measure returns the following tables
            % - measuredRunSet (numOutputs == 1)
            % - poolStats
            % - runSetStats
            % - inputParams
            % - other output (numOutputs > 1)
            tmp = cell(1, numOutputs + 3);
            
            %[tmp{1, :}] = func(pool, runSet, 'Verbose', verbose, otherArgs{:});
            [tmp{1, :}] = func(pool, runSet, otherArgs{:});
            
            % if it is the first iteration, set the name and short name of
            % the computed measure
            if s == 1 && k == 1
                measuredRunSet.Properties.UserData.name = tmp{1}.Properties.UserData.name;
                measuredRunSet.Properties.UserData.shortName = tmp{1}.Properties.UserData.shortName;
                
                poolStats.Properties.UserData.name = tmp{1}.Properties.UserData.name;
                poolStats.Properties.UserData.shortName = tmp{1}.Properties.UserData.shortName;
                
                runSetStats.Properties.UserData.name = tmp{1}.Properties.UserData.name;
                runSetStats.Properties.UserData.shortName = tmp{1}.Properties.UserData.shortName;
                
                % if we have to keep more than one output from the function, 
                % set the name and short name of the computed measure for
                % them
                if numOutputs > 1
                    for o = 1:numOutputs-1
                        
                        % check whether there are a name and shortName fields to
                        % copy them in the output, otherwise use the one of
                        % the main result
                        if isfield(tmp{4+o}.Properties.UserData, 'name')
                            varargout{o}.Properties.UserData.name = tmp{4+o}.Properties.UserData.name;
                        else
                            varargout{o}.Properties.UserData.name = tmp{1}.Properties.UserData.name;
                        end;

                        if isfield(tmp{4+o}.Properties.UserData, 'shortName')
                            varargout{o}.Properties.UserData.shortName = tmp{4+o}.Properties.UserData.shortName;
                        else
                            varargout{o}.Properties.UserData.shortName = tmp{1}.Properties.UserData.shortName;
                        end;
                    end;
                end;
            end;
            
            for t = 1:topics
                
                % first output is always the measured runSet
                m{t, s} = {tmp{1}(t, :)};
                
                % second output is always the pool statistics
                pStat{t, s} = {tmp{2}(t, :)};
                
                % third output is always the runSet statistics
                rStat{t, s} = {tmp{3}(t, :)};
                
                % fourth output is always inputParams but we are  not
                % interested in it
                
                % from the fifth output onwards are additional outputs
                if numOutputs > 1
                    for o = 1:numOutputs-1
                        out{o}{t, s} = {tmp{4+o}(t, :)};
                    end;
                end;
                
            end;
            
           
        end;
       
        
        % assign the results
        m.Properties.UserData.shortName = tmp{1}.Properties.UserData.shortName;
        m.Properties.UserData.name = tmp{1}.Properties.UserData.name;
        measuredRunSet{k, :} = {m};
        poolStats{k, :} = {pStat};
        runSetStats{k, :} = {rStat};
        
        % if we have to keep more than one output from the function,
        % return them
        if numOutputs > 1
            for o = 1:numOutputs-1
                varargout{o}{k, :} = out(o);
                
                % check whether there are a name and shortName fields to
                % copy them in the output, otherwise use the ones of the
                % main results
                if isfield(tmp{4+o}.Properties.UserData, 'name')
                    varargout{o}{k, :}{1, 1}.Properties.UserData.name = tmp{4+o}.Properties.UserData.name;
                else
                    varargout{o}{k, :}{1, 1}.Properties.UserData.name = tmp{1}.Properties.UserData.name;
                end;

                if isfield(tmp{4+o}.Properties.UserData, 'shortName')
                    varargout{o}{k, :}{1, 1}.Properties.UserData.shortName = tmp{4+o}.Properties.UserData.shortName;
                else                    
                    varargout{o}{k, :}{1, 1}.Properties.UserData.shortName = tmp{1}.Properties.UserData.shortName;
                end;
            end;

        end;
    end;
           
    if verbose
        fprintf('Computation of %s completed.\n', funcName);
    end;
    
end



