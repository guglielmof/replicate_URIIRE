%% sersave
% 
% Saves workspace variables to a MAT file by using serialization.

%% Synopsis
%
%   [] = sersave(fileName, varargin)  
%  
% *Parameters*
%
% * *|fileName|* (mandatory) - the name of the MAT file where the variables
% have to be saved.
% * *|v1|*, *|v2|*, ..., *|vN|* - one or more variables (or names of 
% variables) to be saved.
%
%% Example of use
%  
%   a = [1 2 3];
%   b = 'string';
%   sersave('myFile.mat', a, b)
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
function [] = sersave(fileName, varargin)  
    
    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
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

    % create/open the mat file
    m = matfile(fileName, 'Writable', true);
    
    % serialize and save each input argument
    for k = 2:nargin
        
        varName = inputname(k);
        
        % if the varName is empty, check that varargin{k-1} is a string containing the
        % name of a variable to be saved
        if isempty(varName)
            
            % check that varargin{k-1} is a non-empty string
            validateattributes(varargin{k-1}, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'variable');
            
            %  ensure it is a char row
            varName = char(varargin{k-1});
            varName = varName(:).';
            
            m.(varName) = hlp_serialize(evalin('caller', varName));
        else
            m.(varName) = hlp_serialize(varargin{k-1});
        end;
        
    end;
end