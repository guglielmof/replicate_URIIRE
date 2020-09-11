%% evalf
% 
% Evaluates a function given its handle and the names of its input and
% ouput parameters.
%
% |evalf| is somehow similar to <www.mathworks.com/help/matlab/ref/feval.html
% feval> but, instead of passing input and output variables to it as in the
% case of feval, you pass the names of the input and output variables. 

%% Synopsis
%
%   [] = evalf(fh, inputs, outputs)  
%  
% *Parameters*
%
% * *|fh|* (mandatory) - the handle of the function to be evaluated.
% * *|inputs|* (mandatory) - a cell array of strings containing the names
% of the input parameters of the function. It can be empty.
% * *|outputs|* (mandatory) - a cell array of strings containing the names
% of the output parameters of the function. It can be empty.
%
%% Example of use
%  
%   A = rand(100);
%   B = [];
%   C = 2;
%   fh = @max
%   evalf(fh, {'A', 'B', 'C'}, {'M', 'I'})
%   
% This example is equivalent to execute from the command line
%
%   [M, I] = max(A, [], 2);

%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: Matlab 2013b or higher
% * *Copyright:* (C) 2013-2015 <http://ims.dei.unipd.it/ Information 
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
function [] = evalf(fh, inputs, outputs)

    % check that fh is a function handle
    assert(isa(fh,'function_handle'), ...
            'MATTERS:IllegalArgument', 'Expected fh to be a function handle.');
        
    % check that inputs is a cell array 
    assert(iscellstr(inputs), ...
            'MATTERS:IllegalArgument', 'Expected inputs to be a cell array of strings.');
        
    % check that outputs is a cell array 
    assert(iscellstr(outputs), ...
            'MATTERS:IllegalArgument', 'Expected outputs to be a cell array of strings.');
        
    % number of input parameters
    ni = length(inputs);
    localInputs = cell(1, ni);
    
    % number of output parameters
    no = length(outputs);
    localOutputs = cell(1, no);
    
    % copy the input variables from the caller workspace
    for k = 1:ni
        localInputs{k} = evalin('caller', inputs{k});
    end;
    
    [localOutputs{:}] = fh(localInputs{:});
    
    % copy the output variables to the caller workspace
    for k = 1:no
        assignin('caller', outputs{k}, localOutputs{k});
    end;


end

