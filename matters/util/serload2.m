%% serload2
% 
% Loads variables from MAT-file into workspace by using deserialization and
% specifying the names to be assigned to the variables both in the
% workspace and in the file.

%% Synopsis
%
%   [] = serload(fileName, varargin)  
%  
% *Parameters*
%
% * *|fileName|* (mandatory) - the name of the mat file where the variables
% are saved.
%
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|FileVarNames|* (mandatory) - a cell array of strings providing
% a list of names of variables in the file to be loaded.
% * *|WorkspaceVarNames|* (mandatory) - a cell array of strings providing
% a list of names to be assigned to variables in the current workspace. In
% the current workspace, it names each variable in |FileVarNames| with the 
% corresponding name in |WorkspaceVarNames|.
%
%% Example of use
%
% It loads the variable named |a| in the file |myFile.mat| as a variable
% named |b| in the current workspace.
%
%
%   serload('myFile.mat', 'FileVarNames', {'a'}, 'WorkspaceVarNames', {'b'})
%
%   b = 
%       [1 2 3]
%   
%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>,
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: Matlab 2015b or higher
% * *Copyright:* (C) 2013-2016 <http://ims.dei.unipd.it/ Information 
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
function [] = serload2(fileName, varargin)  
    
    % check that we have the correct number of input arguments. 
    narginchk(5, 5);
           
    % check that fileName is a non-empty string
    validateattributes(fileName, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'fileName');
    
    if iscell(fileName)
        % check that fileName is a cell array of strings with one element
        assert(iscellstr(fileName) && numel(fileName) == 1, ...
            'MATTERS:IllegalArgument', 'Expected fileName to be a cell array of strings containing just one string.');
    end
        
    % remove useless white spaces, if any, and ensure it is a char row
    fileName = char(strtrim(fileName));
    fileName = fileName(:).';
    
    % if there is no extension or the extension is not .mat, add it
    ind =find(fileName == '.', 1, 'last');
    if isempty(ind) || ~strcmpi('.mat',  fileName(ind:end))
        fileName = [fileName '.mat'];
    end;
    
    if ~exist(fileName, 'file')
        error('MATTERS:IllegalArgument', 'File %s does not exist: cannot read it.', fileName);
    end;
        
    % parse the variable inputs
    pnames = {'FileVarNames', 'WorkspaceVarNames'};
    dflts =  {[]                   []};
    
    if verLessThan('matlab', '9.2.0')
        [fileVarNames, workspaceVarNames, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [fileVarNames, workspaceVarNames, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end
     
    if ~supplied.FileVarNames
        error('MATTERS:IllegalArgument', 'FileVarNames must be provided as input.');
    end;
    
    if ~supplied.WorkspaceVarNames
        error('MATTERS:IllegalArgument', 'WorkspaceVarNames must be provided as input.');
    end;
         
    % check that fileVarNames is a non-empty cell array
    validateattributes(fileVarNames, {'cell'}, {'nonempty', 'vector'}, '', 'FileVarNames');
    
    % check that fileVarNames is a cell array of strings
    assert(iscellstr(fileVarNames), 'MATTERS:IllegalArgument', 'Expected FileVarNames to be a cell array of strings.');
    
    % check that workspaceVarNames is a non-empty cell array
    validateattributes(workspaceVarNames, {'cell'}, {'nonempty', 'vector'}, '', 'WorkspaceVarNames');
    
    % check that workspaceVarNames is a cell array of strings
    assert(iscellstr(workspaceVarNames), 'MATTERS:IllegalArgument', 'Expected WorkspaceVarNames to be a cell array of strings.');
    
    % check that fileVarNames and workspaceVarNames have the same number of elements
    assert(length(fileVarNames) == length(workspaceVarNames), 'MATTERS:IllegalArgument', 'FileVarNames and WorkspaceVarNames must have the same number of elements.');
    
    
    % open the mat file
    m = matfile(fileName, 'Writable', false);
    
    % load and deserialize each variable
    for v = 1:length(fileVarNames)         
        validateattributes(fileVarNames{v}, {'char'}, {'nonempty', 'vector'}, '', num2str(v, 'file variable name %d'));
        validateattributes(workspaceVarNames{v}, {'char'}, {'nonempty', 'vector'}, '', num2str(v, 'workspace variable name %d'));
        
        assignin('caller', workspaceVarNames{v}, hlp_deserialize(m.(fileVarNames{v})));                
    end;
end