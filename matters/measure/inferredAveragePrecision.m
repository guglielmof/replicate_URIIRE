%% inferredAveragePrecision
% 
% Computes inferred average precision (infAP).

%% Synopsis
%
% [measuredRunSet, poolStats, runSetStats, inputParams] = inferredAveragePrecision(pool, runSet, Name, Value)
%  
% Note that inferred average precision will be NaN when there are no relevant
% documents for a given topic in the pool (this may happen due to the way
% in which relevance degrees are mapped to binary relevance).
%
% *Parameters*
%
% * *|pool|* - the pool to be used to assess the run(s). It is a table in the
% same format returned by <../io/importPoolFromFileTRECFormat.html 
% importPoolFromFileTRECFormat>;
% * *|runSet|* - the run(s) to be assessed. It is a table in the same format
% returned by <../io/importRunFromFileTRECFormat.html 
% importRunFromFileTRECFormat> or by <../io/importRunsFromDirectoryTRECFormat.html 
% importRunsFromDirectoryTRECFormat>;
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|ShortNameSuffix|* (optional) - a string providing a suffix which will
% be concatenated to the short name of the measure. It can contain only
% letters, numbers and the underscore. The default is empty.
% * *|MapToBinaryRelevance|* (optional) - a string specifying how relevance 
% degrees have to be mapped to binary relevance. The following values can 
% be used: _|Hard|_ considers only the maximum degree of relevance in the 
% pool as |Relevant| and any degree below it as |NotRelevant|; _|Lenient|_ 
% considers any degree of relevance in the pool above the minimum one as 
% |Relevant| and only the minimum one is considered as |NotRelevant|; 
% _|RelevanceDegree|_ considers the relevance degrees in the pool stricly 
% above the specified one as |Relevant| and all those less than or equal to 
% it as |NotRelevant|. In this latter case, if |RelevanceDegree| does not 
% correspond to any of the relevance degrees in the pool, an error is 
% raised. If not specified, |Lenient| will be used to map to binary
% relevance.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |measureRunSet|  - a table containing a row for each topic and a column 
% for each run named |runName|. Each cell of the table contains a scalar
% representing the binary preference. The |UserData| property of  the table 
% contains a struct  with the  following fields: _|identifier|_ is the 
% identifier of the run; _|name|_  is the name of the computed measure, i.e.
% |binaryPreference|; _|shortName|_ is a short name of the computed 
% measure, i.e. |bpref|; _|pool|_ is the identifier of the pool with respect 
% to which the measure has been computed.
% * *|poolStats|* - see description in <assess.html assess>.
% * *|runSetStats|* - see description in <assess.html assess>.
% * *|inputParams|* - a struct summarizing the input parameters passed.

%% Example of use
%  
%   measuredRunSet = binaryPreference(pool, runSet);
%
% It computes the bynary preference. Suppose the run set contains the 
% following runs:
% 
% * |APL985LC.txt|
% * |AntHoc01.txt|
% * |acsys7al.txt|
%
% In this example each run has two topics, |351| and |352|. It returns the 
% following table.
%
%              APL985LC          AntHoc01          acsys7al   
%           ______________    ______________    ______________
%
%    351       0.42067           0.26716            0.38774
%    352       0.30428           0.29448            0.39106
%
% Column names are run identifiers, row names are topic identifiers; cells
% contain a row vector with the value of the average precision.
% 
%   APL985LC_351 = measuredRunSet{'351','APL985LC'}
%
%   ans =
%
%    0.42067
%
% It returns the binary preference for topic 351 of run APL985LC.
%
%% References
% 
% Please refer to:
%
% * Yilmaz, E. and Aslam, J. A. (2006). Estimating Average Precision With 
% Incomplete and Imperfect Judgments. In Yu, P. S., Tsotras, V., Fox, E. A., 
% and Liu, C.-B., editors, _Proc. 15th International Conference on 
% Information and Knowledge Management (CIKM 2006)_, pages 102-111. ACM
% Press, New York, USA.
% * Yilmaz, E. and Aslam, J. A. (2008). Estimating average precision 
% when judgments are incomplete. _Knowledge and Information Systems_, 
% 16(2):173-211.
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
function [measuredRunSet, poolStats, runSetStats, inputParams] = inferredAveragePrecision(pool, runSet, varargin)
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % parse the variable inputs
    pnames = {'ShortNameSuffix', 'MapToBinaryRelevance' 'Verbose'};
    dflts =  {[]                 'lenient'              false};
    
     
    if verLessThan('matlab', '9.2.0')
        [shortNameSuffix, mapToBinaryRelevance, verbose, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [shortNameSuffix, mapToBinaryRelevance, verbose, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end 

    % actual parameters to be passed to assess.m, at least 6
    assessInput = cell(1, 8);
    
    % not assessed documents must be condensed (see Sakai, SIGIR 2007)
    assessInput{1, 1} = 'NotAssessed';
    assessInput{1, 2} = 'Undefined';
    
    % map to binary relevance must be performed. Either use the value
    % passed by the caller or the default one
    assessInput{1, 3} = 'MapToBinaryRelevance';
    assessInput{1, 4} = mapToBinaryRelevance;
    
    % map to binary relevance weights to make follow-up computations
    % handier. Since we are basically interested in counting number of
    % not relevant documents up to each rank position and we need relevance
    % weights to be an increasing vector, the easiest way is to assign -1
    % to not relevant documents and 0 to relevant ones, so that the number
    % of not relevant documents up to each rank position is given by the
    % absolute value of the sum of -1 up to that rank.
    assessInput{1, 5} = 'MapToRelevanceWeights';
    assessInput{1, 6} = [0, 1];
    
    % padding is not needed
    assessInput{1, 7} = 'FixNumberRetrievedDocuments';
    assessInput{1, 8} = [];
    
    if supplied.ShortNameSuffix
        if iscell(shortNameSuffix)
            % check that nameSuffix is a cell array of strings with one element
            assert(iscellstr(shortNameSuffix) && numel(shortNameSuffix) == 1, ...
                'MATTERS:IllegalArgument', 'Expected NameSuffix to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        shortNameSuffix = char(strtrim(shortNameSuffix));
        shortNameSuffix = shortNameSuffix(:).';
        
        % check that the nameSuffix is ok according to the matlab rules
        if ~isempty(regexp(shortNameSuffix, '\W*', 'once'))
            error('MATTERS:IllegalArgument', 'NameSuffix %s is not valid: it can contain only letters, numbers, and the underscore.', ...
                shortNameSuffix);
        end  
        
        % if it starts with an underscore, remove it since il will be
        % appended afterwards
        if strcmp(shortNameSuffix(1), '_')
            shortNameSuffix = shortNameSuffix(2:end);
        end;
    end;
       
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing inferred average precision for run set %s with respect to pool %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            runSet.Properties.UserData.identifier, pool.Properties.UserData.identifier, width(runSet), height(runSet));
    end;
    
    [assessedRunSet, poolStats, runSetStats, inputParams] = assess(pool, runSet, 'Verbose', verbose, assessInput{:});
    
     % the topic currently under processing
    ct = 1;
        
    % the run currently under processing
    cr = 1;
    
    % compute the measure topic-by-topic
    measuredRunSet = rowfun(@processTopic, assessedRunSet, 'OutputVariableNames', runSet.Properties.VariableNames, 'OutputFormat', 'table', 'ExtractCellContents', true, 'SeparateInputs', false);
    measuredRunSet.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    measuredRunSet.Properties.UserData.pool = pool.Properties.UserData.identifier;
    
    measuredRunSet.Properties.UserData.name = 'inferredAveragePrecision';
    measuredRunSet.Properties.UserData.shortName = 'infAP';
    
    if ~isempty(shortNameSuffix)
        measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
            '_' shortNameSuffix];
    end;

    if verbose
        fprintf('Computation of inferred average precision completed.\n');
    end;
    
    %%
    
    % compute the measure for a given topic over all the runs
    function [varargout] = processTopic(topic)
        
        if(verbose)
            fprintf('Processing topic %s (%d out of %d)\n', pool.Properties.RowNames{ct}, ct, inputParams.topics);
            fprintf('  - run(s): ');
        end;
               
        % reset the index of the run under processing for each topic
        cr = 1;
         
        % compute the measure only on those column which contain the
        % actual runs
        varargout = cellfun(@processRun, topic);
              
        % increment the index of the current topic under processing
        ct = ct + 1;    
        
         if(verbose)
            fprintf('\n');
        end;
        
        %% 
        
        % compute the measure for a given topic of a given run
        function [measure] = processRun(runTopic)
                              
            if(verbose)
                fprintf('%s ', runSet.Properties.VariableNames{cr});
            end;
                                   
            % determine the positions of the relevant documents
            rows = runTopic{:, 'Assessment'} == 1;
            rows = rows(:).';
            
            % determine the positions of the not assessed documents
            na = isnan(runTopic{:, 'Assessment'});
            na = na(:).';
            
            % the row vector of the relevant documents (1 at each relevant doc)
            rel = runTopic{:, 'Assessment'};
            rel = rel(:).';
            
            % the row vector of the not relevant documents (1 at each not relevant doc)
            notRel = rel;
            notRel(~na) = ~rel(~na);
                                    
            % compute the number of relevant documents up to each rank
            % position
            rel(na) = 0;
            rel = cumsum(rel) - 1;
                        
            
            % compute the number of not relevant documents up to each rank
            % position
            notRel(na) = 0;
            notRel = cumsum(notRel);
            
            % shift right one position
          %  notRel = [-realmax notRel(1:end-1)];
            
            % the ranks
            ranks = 1:length(rel);
            
            
            % compute infAP at each rank position as in eq. (2) of Yilmaz
            % and Aslam, 2008.
            %infAP = 1./ranks + ((ranks - 1)./ ranks).*( (rel + 0.00001) ./ (rel + notRel + 2*0.00001));
            
            
            % compute infAP at each rank position as trec_eval 8.1
            infAP = 1./ranks + ((ranks - 1)./ ranks).*((rel + notRel)./(ranks-1)).*( (rel + + 0.00001) ./ (rel + notRel + 2*0.00001));
            
            % patch the first position which is NaN due to the division by
            % ranks -1 (as done in trec_eval)
            infAP(1) = 1;
            
            %infAP = (rel + 1) ./ ranks;
            
            %infAP = 1./ranks + ( (rel + 0.00001) ./ (rel + notRel + 2*0.00001));
                                  
            % extract infAP only at relevant documents and  average over 
            % the total number of relevant documents
            measure = sum(infAP(rows)) ./ poolStats{ct, 'BinaryRelevant'};
                                   
            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            measure = {measure};
            
            % increment the index of the current run under processing
            cr = cr + 1;
        end
    end
    
end



