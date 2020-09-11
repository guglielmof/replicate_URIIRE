%% confidenceIntervalDelta
% 
% Computes the delta to be added/subtracted to the sample mean to 
% obtain a confidence interval

%% Synopsis
%
%   [delta] = confidenceIntervalDelta(data, alpha)
%  
%
% *Parameters*
%
% * *|data|* - the data whose confidence interval has to be computed. 
% * *|alpha|* - the confidence degree.
% * *|dim|* - the dimension of data along which standard deviation if
% computed. If not specified, default is 1.

% *Returns*
%
% * *|delta|*  - the delta to be added/subtracted to the sample mean to 
% obtain a confidence interval.
%
%% Example of use
%  
%   confidenceIntervalDelta(rand(20, 3), 0.05)
%
% It returns the delta for creating the confidence interval
%   
%   ans =
%
%      0.1433    0.1191    0.1370
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
function [delta] = confidenceIntervalDelta(data, alpha, dim)
    
    narginchk(2, 3);
    
    if nargin < 3
        dim = 1;
    end;

    n = size(data, dim);

    delta = tinv(1 - alpha/2, n - 1) * std(data, 0, dim) / sqrt(n);
end

