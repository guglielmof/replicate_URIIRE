%% serload
% 
% Loads variables from MAT-file into workspace by using deserialization.

%% Synopsis
%
%   [] = serload(fileName, varargin)  
%  
% *Parameters*
%
% * *|fileName|* (mandatory) - the name of the mat file where the variables
% have to be saved.
% * *|v1|*, *|v2|*, ..., *|vN|* (optional) - one or more strings containing
% names of variables to be loaded. Alternativelty, it is possible to pass,
% as second and only argument, a two-dimensional cell array of strings,
% where the first element is the name of the variable to be loaded from the
% MAT-file and the second element is the name to be assigned to the loaded
% variable in the caller workspace.
%
%% Example of use
%  
%   serload('myFile.mat', 'a', 'b')
%
%   a = 
%       [1 2 3]
%
%   b =
%       string
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
function [] = serload(fileName, varargin)  
    
    % check that we have the correct number of input arguments. 
    narginchk(1, inf);
    
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
    
    % open the mat file
    m = matfile(fileName, 'Writable', false);
    
    % if only the file name is passed, read all the variables
    if nargin == 1        
        vars = who(m);
        varNames = vars;
        
    % if we have only two arguments and the second one is a cell matrix
    elseif nargin == 2 && iscell(varargin{1}) && size(varargin{1}, 2) == 2
        vars = varargin{1}(:, 1);
        varNames = varargin{1}(:, 2);
    else
        vars = varargin;
        varNames = vars;
    end;
    
    % load and deserialize each input variable
    for k = 1:length(vars)  
        validateattributes(varNames{k}, {'char'}, {'nonempty', 'vector'}, '', num2str(k, 'variable name %d'));
        validateattributes(vars{k}, {'char'}, {'nonempty', 'vector'}, '', num2str(k, 'variable %d'));
        
        assignin('caller', varNames{k}, hlp_deserialize(m.(vars{k})));                
    end;
end