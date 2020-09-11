%% extractNameValuePairs
% 
% Extracts the name-value arguments from the inputs and return them separated 
% from the other input arguments. 
% To do so, it scans the argument list until we run into a string. 
% Everything to theright of the string is considered extra name-value 
% arguments.
%
% Similar code can be found in the source of 
% <http://www.mathworks.it/it/help/stats/bootstrp.html bootstrp.m> in the 
% Statistics Toolbox.

%% Synopsis
%
%   [nvp, oth] = extractNameValuePairs(varargin)
%  
% % *Parameters*
%
% * *|varargin|* - the input arguments from which the name-value pair have
% to be extracted.
%
% *Returns*
%
% * *|nvp|*  - a cell array containing the name-value pairs.
% * *|oth|*  - a cell array containing the input arguments other than
% name-value pairs.
%
%% Example of use
%  
%   [nvp, oth] = extractNameValuePairs(1, [2 3], {3, 'a string'}, 'Name1', 'value1', 'Name2', {'value2'}, 'Name3', 14)
%   
%   nvp = 
%   
%       'Name1'    'value1'    'Name2'    {1x1 cell}    'Name3'    [14]
%   
%   
%   oth = 
%   
%       [1]    [1x2 double]    {1x2 cell}
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
function [nvp, oth] = extractNameValuePairs(varargin)

    % handles to anonymous functions to ease computations
    persistent NAME_VALUE_PAIRS;

    % initialize anonymous functions
    if isempty(NAME_VALUE_PAIRS)

        % looks for the first string in the input arguments
        NAME_VALUE_PAIRS = @(x) (ischar(x) && size(x, 1) == 1);
    end

    % empty name-value pairs
    nvp = {};
    oth = varargin;

    isNameValuePair = cellfun(NAME_VALUE_PAIRS, varargin);

    if any(isNameValuePair)

        firstNameValuePair = find(isNameValuePair, 1, 'first');

        % extract the name-value pairs
        nvp = varargin(firstNameValuePair:end);

        % return the input arguments without the name-value pairs
        oth = varargin(1:firstNameValuePair-1);
    end   
end
