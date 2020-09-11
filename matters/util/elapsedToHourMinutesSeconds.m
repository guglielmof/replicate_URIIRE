
%% elapsedToHourMinutesSeconds
% 
% Transforms an elapsed time in seconds (and milliseconds) into hours,
% minutes, and seconds.

%% Synopsis
%
%   [hms, h, m, s] = elapsedToHourMinutesSeconds(e)
%  
% % *Parameters*
%
% * *|e|* - an elapsed time in seconds (and milliseconds);
%
% *Returns*
%
% * *|hms|*  - a string containing the elapsed hour(s), minute(s), and
% second(s);
% * *|h|*  - the number of elapsed hour(s);
% * *|m|*  - the number of elapsed minute(s);
% * *|s|*  - the number of elapsed second(s);
%
%% Example of use
%  
%   elapsedToHourMinutesSeconds(123.456)
%
% It returns the string containing the elapsed time in hour(s), minute(s),
% and second(s):
%   
%   ans =
%
%   0 hour(s), 2 minute(s), 3.456 second(s)
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
function [hms, h, m, s] = elapsedToHourMinutesSeconds(e)

    % check that e is a scalar numeric value greater than 0
    validateattributes(e, {'numeric'}, {'scalar', '>', 0}, '', 'e');

    % compute the number of elapsed seconds
    s = rem(e, 60);
    
    % compute the number of elapsed minutes
    m  = rem((e - s)/60, 60);
    
    % compute the number of elapsed hours
    h     = fix((e - m*60 - s)/3600);
  
    % create the result string
    hms = [num2str(h), ' hour(s), ', num2str(m), ' minute(s), ', num2str(s), ' second(s)'];
  
end