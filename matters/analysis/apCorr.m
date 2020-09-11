%% apCorr
% 
% Returns a P-by-P matrix containing the pairwise AP correlation coefficient 
% between each pair of columns in the N-by-P matrix X.

%% Synopsis
%
%   [apTau] = apCorr(X, varargin)
%
% The current implementation is based on the R implementation 
% <http://www.mansci.uwaterloo.ca/~msmucker/software/apcorr.r apcorr.r>
% developed by Mark D. Smucker for the TREC 2013 Crowdsourcing track.
%
% *Parameters*
%
% * *|X|* - a N-by-P matrix where rows are systems and columns are ranking
% of systems according to different criteria, e.g. different measures or
% the same measure computed on different pools.
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|Symmetric|* (optional) - a boolean specifying whether the symmetric
% version of AP correlation has to be computed. The default is |false|.
% * *|Ties|* (optional) - a boolean specifying whether tied values have to
% be taken into account or not. The default is |true|.
% * *|TiesSamples|* (optional) - a scalar integer value greater than
% zero which indicates how many samples have to be used when ties are taken
% into account. The default is |1000|.
%
% *Returns*
%
% * |apTau| - aP-by-P matrix containing the pairwise AP correlation 
% coefficient between each pair of columns. If |Symmetric| is |true| then
% the matrix will be symmetric.

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
%   apTau = apCorr(X)
% 
% It computes the pairwise AP correlation between the columns of X.
%
% It returns the |apTau| matrix.
%
%   apTau =
%   
%       1.0000   -0.4000    0.5667
%      -0.5467    1.0000   -0.1467
%       0.7000    0.3333    1.0000
%
%% References
% 
% Please refer to:
%
% * Yilmaz, E., Aslam, J. A., and Robertson, S. E. (2008). A New Rank 
% Correlation Coefficient for Information Retrieval. In Chua, T.-S., 
% Leong, M.-K., Oard, D. W., and Sebastiani, F., editors, 
% _Proc. 31st Annual International ACM SIGIR Conference on Research and Development in Information Retrieval (SIGIR 2008)_, 
% pages 587-594. ACM Press, New York, USA.
% * Smucker, M. D., Kazai, G., and Lease, M. (2014). Overview of the TREC 2013
% Crowdsourcing Track. In Voorhees, E. M., editor, _The Twenty-Second Text REtrieval Conference Proceedings (TREC 2013)_.
% National Institute of Standards and Technology (NIST), 
% Special Publication 500- 302, Washington, USA.
% 

%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>,
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
function [apTau] = apCorr(X, varargin)

   
    % Only x given, compute pairwise rank correlations
    if (nargin < 2) || ischar(varargin{1})
        corrXX = true;

    % Both x and y given, compute the pairwise rank cross correlations
    else
        Y = varargin{1};
        varargin = varargin(2:end);
        assert(size(Y,1) == size(X, 1), 'X and Y must have the same size');
        corrXX = false;
    end

    % parse the variable inputs
    pnames = {'Symmetric', 'Ties', 'TiesSamples'};
    dflts =  {false,       true,      1000};
    
    if verLessThan('matlab', '9.2.0')
        [symmetric, ties, tiesSamples, supplied] ...
            = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});
    else
        [symmetric, ties, tiesSamples, supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    end
    
     
    if supplied.Symmetric
        % check that symmetric is a non-empty scalar logical value
        validateattributes(symmetric, {'logical'}, {'nonempty','scalar'}, '', 'Symmetric');
    end;   
    
    if supplied.Ties
        % check that ties is a non-empty scalar logical value
        validateattributes(ties, {'logical'}, {'nonempty','scalar'}, '', 'Ties');
    end;   
    
    if supplied.TiesSamples
        % check that TiespSamples is a nonempty scalar integer value
        % greater than 0
        validateattributes(tiesSamples, {'numeric'}, ...
            {'nonempty', 'scalar', 'integer', '>', 0}, '', 'TiesSamples');
    end;
    
    % determine which kind of correlation has to be computed
    if ties
        corrFun = @apCorrSampling;
    else
        corrFun = @apCorrNoSampling;
    end
    
    if corrXX
        cols = size(X, 2);

        % set the diagonal to 1 and avoid useless computations
        apTau = eye(cols);

        for c1 = 1:cols
            for c2 = c1+1:cols

                apTau(c1, c2) = corrFun(X(:, c1), X(:, c2), tiesSamples);
                apTau(c2, c1) = corrFun(X(:, c2), X(:, c1), tiesSamples);
            end;
        end;

        if symmetric
            apTau = (apTau + apTau.') / 2;
        end;
        
    else % just two vectors        
        apTau = corrFun(X, Y, tiesSamples);        
    end;
        
   
end

%% 

%
% This is port to MATLAB of the original R code by
% Mark D. Smucker: http://www.mansci.uwaterloo.ca/~msmucker/software/apcorr.r
% but optimized for efficiency (about XX times faster than a plain port)
%
% The last parameter is just to have the same signature of the
% apCorrSampling function and simplify calling code
function [apTau] = apCorrNoSampling(truth, estimate, ~)

    n = length(truth);

    [~, truthOrder] = sort(truth, 'descend');
    [~, estimateOrder] = sort(estimate, 'descend');

    innerSum = 0;
    
    for i = 2:n
        
        currDocID = estimateOrder(i);
        
        estimateRankedHigherIDs = estimateOrder(1:i-1);
        
        % where is the current doc in the truth order?
        currDocTruthOrderIndex =  find(truthOrder == currDocID);
        
        truthRankedHigherIDs = [];
        if (currDocTruthOrderIndex ~= 1) % top ranked doc, beware
            truthRankedHigherIDs = truthOrder(1:currDocTruthOrderIndex-1);
        end;
        
        % if Matlab R2014a,b 
        if verLessThan('matlab','8.5')
            Ci = sum(builtin('_ismemberoneoutput', estimateRankedHigherIDs, sort(truthRankedHigherIDs)));
        else
            Ci = sum(builtin('_ismemberhelper', estimateRankedHigherIDs, sort(truthRankedHigherIDs)));
        end;
       
        innerSum = innerSum + (Ci / (i-1));
    end;

    apTau = 2 / (n-1) * innerSum - 1;

    
end


%% 

%
% This is just a straightforward port to MATLAB of the original R code by
% Mark D. Smucker: http://www.mansci.uwaterloo.ca/~msmucker/software/apcorr.r
%
function [apTau] = apCorrSampling(truth, estimate, tiesSamples)

    n = length(truth);

    if ( length(unique(truth)) + length(unique(estimate)) == n + n )
        apTau = apCorrNoSampling(truth, estimate);
        return;
    end

    sumAPcorr = 0;
    
    for sampleIdx = 1:tiesSamples
  
      permutation = randperm(n);

      sumAPcorr = sumAPcorr + apCorrNoSampling(truth(permutation), estimate(permutation));
    end;
    
    apTau = sumAPcorr / tiesSamples;
 

end


