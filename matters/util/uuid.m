%% uuid
% 
% Generates a Type 4 random Universal Unique IDentifier (UUID).

%% Synopsis
%
%   [id] = uuid()
%  
% *Returns*
%
% * *|id|*  - a string containing a type 4 random UUID.
%
%% Example of use
%  
%   uuid()
%
% It returns a type 4 random UUID:
%   
%   ans =
%
%   f5af93da-f6e0-4b9b-9eaa-433e7cc9107c
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
function [id] = uuid()  
    % return a type 4 random UUID
    id = char(java.util.UUID.randomUUID().toString());
end