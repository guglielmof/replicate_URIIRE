%% rmseCoeff
% 
% Returns a P-by-P matrix containing the pairwise root mean square error 
% for each pair of columns in the N-by-P matrix X.

%% Synopsis
%
%   [rmse] = rmseCoeff(X)
%
% *Parameters*
%
% * *|X|* - a N-by-P matrix where rows are systems and columns are ranking
% of systems according to different criteria, e.g. different measures or
% the same measure computed on different pools.
%
% *Returns*
%
% * |rmse| - a P-by-P matrix containing the pairwise root mean square error
% coefficient between each pair of columns. 

%% Example of use
%  
%   X =
%
%        6     1     6
%        2     6     5
%        3     4     2
%        4     5     3
%        5     3     4
%        1     2     1
%
%
%   rmse = rmseCoeff(X)
% 
% It computes the pairwise root mean square error between the columns of X.
%
% It returns the |rmse| matrix.
%
%   rmse =
%   
%            0    2.8284    1.4142
%       2.8284         0    2.4495
%       1.4142    2.4495         0
%
%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>,
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
function [rmse] = rmseCoeff(X, varargin)

    if nargin == 2
        Y = varargin{1};
        rmseXX = false;
    else
        rmseXX = true;
    end;
    
    
    if rmseXX    
        cols = size(X, 2);

        % set the diagonal to 0 and avoid useless computations
        rmse = zeros(cols);

        for c1 = 1:cols

            for c2 = c1+1:cols

                rmse(c1, c2) = rms(X(:, c1) - X(:, c2));
                rmse(c2, c1) = rmse(c1, c2);
            end;
        end;   
    else        
        rmse = rms(X - Y);
    end;
end

