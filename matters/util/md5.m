%% md5
% 
% Computes the MD5 hash of the given string.

%% Synopsis
%
%   [h] = md5(s)
%  
% % *Parameters*
%
% * *|h|* - the string whose MD5 hash has to be computed.
%
% *Returns*
%
% * *|h|*  - a string containing the hexadecimal representation of the MD5
% hash of the given string. Each byte is represented with two hexadecimal
% digits.
%
%% Example of use
%  
%   md5('a test string')
%
% It returns the MD5 hash of the string:
%   
%   ans =
%
%   b1a4cf30d3f4095f0a7d2a6676bcae77
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
function [h] = md5(s)

    % the hashing engine
    persistent ENGINE;
    
    if isempty(ENGINE)
        ENGINE = java.security.MessageDigest.getInstance('MD5');
    end;

    % check that s is a non empty char vector and ensure it is a column
    validateattributes(s, {'char'}, {'vector', 'nonempty'}, '', 's');
    s = s(:);
  
    % compute the message digest (java byte are 8 bit signed int -127..+128 
    % but treat them as 16 bit signed int to ease next processing)
    d = int16(ENGINE.digest(uint8(s)));
    
    % 'overflow' negative values to positive ones to match Matlab way for
    % hex printing afterwards
    n = find(d < 0);
    d(n) = 256 + d(n);
    
    % turn into HEX representation
    h = sprintf('%02x', d);
         
end