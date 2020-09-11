%% markovPrecision
% 
% Computes Markov precision (MP).

%% Synopsis
%
% [measuredRunSet, poolStats, runSetStats, inputParams] = markovPrecision(pool, runSet, Name, Value)
%  
% Note that Markov precision will be NaN when there are no relevant
% documents for a given topic in the pool (this may happen due to the way
% in which relevance degrees are mapped to binary relevance).
%
% *Parameters*
%
% * *|pool|* - the pool to be used to assess the run(s). It is a table in the
% same format returned by <../io/importPoolFromFileTRECFormat.html 
% importPoolFromFileTRECFormat>;
% * *|runSet|* - the run(s) to be assessed. It is a table in the same format
% returned by <../io/importRunFromFileTRECFormat.html 
% importRunFromFileTRECFormat> or by <../io/importRunsFromDirectoryTRECFormat.html 
% importRunsFromDirectoryTRECFormat>;
%
% *Name-Value Pair Arguments*
%
% Specify comma-separated pairs of |Name|, |Value| arguments. |Name| is the 
% argument name and |Value| is the corresponding value. |Name| must appear 
% inside single quotes (' '). You can specify several name and value pair 
% arguments in any order as |Name1, Value1, ..., NameN, ValueN|.
%
% * *|MarkovModel|* (optional) - a string providing the Markov model to be
% for computing Markov precion. Possible values are:  _|mmGAP|_ adopts a 
% transition matrix with global transitions among each state [G] and constant
% transition probabilities equal to the inverse of the number 
% of relevant retrieved documents by the run which converges to average
% precision; _|mmGIDNLOR|_ adopts a transition matrix with global 
% transitions among each state [G], transition probabilities inversely 
% proportional to the distance among documents [ID], without transitions to 
% the same document [NL], and considering only the  relevant retrieved 
% documents [OR]; _|mmGIDSLOR|_ adopts a transition matrix with global 
% transitions among each state [G], transition probabilities inversely 
% proportional to the distance among documents [ID], with transitions to 
% the same document [SL], and considering only the relevant retrieved 
% documents [OR]; _|mmGIDNLAD|_ adoptes a transition matrix with global 
% transitions among each state [G], transition probabilities inversely 
% proportional to the distance among documents [ID], without transitions
% to the same document [NL], and considering all the retrieved documents
% [AD]; _|mmGIDSLAD|_ adopts a transition matrix with global transitions 
% among each state [G], transition probabilities inversely proportional to 
% the distance among documents [ID], with transitions to the same document 
% [SL], and considering all the retrieved documents [AD]; _|mmGIDNLAD2OR|_ 
% adopts a transition matrix with global transitions among each state [G],
% transition probabilities inversely proportional to the distance among 
% documents [ID], without transitions to the same document [NL], 
% considering all the retrieved documents [AD] and then extracting the 
% submatrix concerning only the relevant ones [2OR]; _|mmGIDSLAD2OR|_ adopts
% a transition matrix with global transitions among each state [G], 
% transition probabilities inversely proportional to the distance among 
% documents [ID], with transitions to the same document [SL], considering 
% all the retrieved documents [AD] and then extracting the submatrix 
% concerning only the relevant ones [2OR]; _|mmLAP|_ adopts a transition 
% matrix with local transitions among adjacent states [L] and constant
% transition probabilities equal to the inverse of the number 
% of relevant retrieved documents by the run which converges to average
% precision; _|mmLIDNLOR|_ adopts a transition 
% matrix with local transitions among adjacent states [L], transition 
% probabilities inversely proportional to the distance among documents [ID], 
% without transitions to  the same document [NL], and considering only the 
% relevant retrieved documents [OR]; _|mmLIDSLOR|_ adopts a transition matrix 
% with local transitions among adjacent states [L], transition probabilities 
% inversely proportional to the distance among documents [ID], with 
% transitions to  the same document [SL], and considering only the relevant 
% retrieved documents [OR]; _|mmLIDNLAD|_ adoptes a transition matrix with 
% local transitions among adjacent states [L], transition probabilities 
% inversely proportional to the distance among documents [ID], without transitions
% to the same document [NL], and considering all the retrieved documents
% [AD]; _|mmLIDSLAD|_ adopts a transition matrix with local transitions 
% among adjacent states [L], transition probabilities inversely proportional 
% to the distance among documents [ID], with transitions to the same document 
% [SL], and considering all the retrieved documents [AD]; _|mmLIDNLAD2OR|_ 
% adopts a transition matrix with local transitions among adjacent states [L],
% transition probabilities inversely proportional to the distance among 
% documents [ID], without transitions to the same document [NL], 
% considering all the retrieved documents [AD] and then extracting the 
% submatrix concerning only the relevant ones [2OR]; _|mmLIDSLAD2OR|_ adopts
% a transition matrix with local transitions among adjacent states [L], 
% transition probabilities inversely proportional to the distance among 
% documents [ID], with transitions to the same document [SL], considering 
% all the retrieved documents [AD] and then extracting the submatrix 
% concerning only the relevant ones [2OR]. If not specified, the default 
% value is |mmGIDNLOR|.
% * * |MaxHop|* (optional) - an positive integer values specifying the
% maximum distance allowed for a transition. If not specified, the maximum
% distance is the size of the transition matrix.
% * *|ShortNameSuffix|* (optional) - a string providing a suffix which will
% be concatenated to the short name of the measure. It can contain only
% letters, numbers and the underscore. The default is empty.
% * *|NotAssessed|* (optional) - a string indicating how not assessed
% documents, i.e. those in the run but not in the pool, have to be
% processed: |NotRevelant|, the minimum of the relevance degrees of the 
% pool is used as |NotRelevant|; |Condensed|, the not assessed documents 
% are  removed from the run. If not specified, the default value  is 
% |NotRelevant| to mimic the behaviour of trec_eval.
% * *|MapToBinaryRelevance|* (optional) - a string specifying how relevance 
% degrees have to be mapped to binary relevance. The following values can 
% be used: _|Hard|_ considers only the maximum degree of relevance in the 
% pool as |Relevant| and any degree below it as |NotRelevant|; _|Lenient|_ 
% considers any degree of relevance in the pool above the minimum one as 
% |Relevant| and only the minimum one is considered as |NotRelevant|; 
% _|RelevanceDegree|_ considers the relevance degrees in the pool stricly 
% above the specified one as |Relevant| and all those less than or equal to 
% it as |NotRelevant|. In this latter case, if |RelevanceDegree| does not 
% correspond to any of the relevance degrees in the pool, an error is 
% raised. If not specified, |Lenient| will be used to map to binary
% relevance.
% * *|Verbose|* (optional) - a boolean specifying whether additional
% information has to be displayed or not. If not specified, then |false| is 
% used as default.
%
% *Returns*
%
% * |measureRunSet|  - a table containing a row for each topic and a column 
% for each run named |runName|. Each cell of the table contains a scalar
% representing the average precision. The |UserData| property of  the table 
% contains a struct  with the  following fields: _|identifier|_ is the 
% identifier of the run; _|name|_  is the name of the computed measure, i.e.
% |markovPrecision|; _|shortName|_ is a short name of the computed 
% measure, i.e. |MP|; _|pool|_ is the identifier of the pool with respect 
% to which the measure has been computed. Note that when the condensed
% measure is requested, as in (Sakai, SIGIR 2007), then the name and short
% name are, respectively, |conMarkovPrecision| and |condMP|). The name and
% short name are then suffixed with the used Markov model, according to the
% possible values of the |MarkovModel| parameter, and, when used, with the
% maximum allowed distance.
% * *|poolStats|* - see description in <assess.html assess>.
% * *|runSetStats|* - see description in <assess.html assess>.
% * *|inputParams|* - a struct summarizing the input parameters passed.

%% Example of use
%  
%   measuredRunSet = markovPrecision(pool, runSet, 'MarkovModel', 'mmAP');
%
% It computes the Markov precision. Suppose the run set contains the 
% following runs:
% 
% * |APL985LC.txt|
% * |AntHoc01.txt|
% * |acsys7al.txt|
%
% In this example each run has two topics, |351| and |352|. It returns the 
% following table.
%
%              APL985LC          AntHoc01          acsys7al   
%           ______________    ______________    ______________
%
%    351       0.1120            0.2899            0.3842
%    352       0.5527            0.0212            0.3758
%
% Column names are run identifiers, row names are topic identifiers; cells
% contain a row vector with the value of the average precision.
% 
%   APL985LC_351 = measuredRunSet{'351','APL985LC'}
%
%   ans =
%
%    0.1120
%
% It returns the Markov precision for topic 351 of run APL985LC.
%
%% References
% 
% Please refer to:
%
% * Ferrante, M., Ferro, N., Maistro, M. (2014). _Markov Precision_.
% Techical report, University of Padua, Italy.
%
% For condensed result lists (|Condensed| in parameter |NotAssessed|), 
% please refer to:
%
% * Sakai, T. (2007). Alternatives to Bpref. In Kraaij, W., de Vries, A. P., 
% Clarke, C. L. A., Fuhr, N., and Kando, N., editors, _Proc. 30th Annual 
% International ACM SIGIR Conference on Research and Development in 
% Information Retrieval (SIGIR 2007)_, pages 71-78. ACM Press, New York, 
% USA.
%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>,
% <mailto:maria.maistro@studenti.unipd.it Maria Maistro>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: Matlab 2013b or higher
% * *Copyright:* (C) 2014 <http://www.unipd.it/ University of Padua>, Italy
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
function [measuredRunSet, poolStats, runSetStats, inputParams, invariantDistribution] = markovPrecision(pool, runSet, varargin)

    % the list of supported Markov models
    persistent mmList;
    
    if isempty(mmList)
        
        %  global, only relevant, no loops
        G_OR_NL = {...
            'G_OR_NL_NA_NA_NA', 'G_OR_NL_NA_NA_R', 'G_OR_NL_NA_NA_RR', ...
            'G_OR_NL_NA_ID_NA', 'G_OR_NL_NA_ID_R', 'G_OR_NL_NA_ID_RR', ...
            'G_OR_NL_NA_LID_NA', 'G_OR_NL_NA_LID_R', 'G_OR_NL_NA_LID_RR', ...
            'G_OR_NL_FRBN_NA_NA', 'G_OR_NL_FRBN_NA_R', 'G_OR_NL_FRBN_NA_RR', ...
            'G_OR_NL_FRBN_ID_NA', 'G_OR_NL_FRBN_ID_R', 'G_OR_NL_FRBN_ID_RR', ...
            'G_OR_NL_FRBN_LID_NA', 'G_OR_NL_FRBN_LID_R', 'G_OR_NL_FRBN_LID_RR', ...
            'G_OR_NL_FNBR_NA_NA', 'G_OR_NL_FNBR_NA_R', 'G_OR_NL_FNBR_NA_RR', ...
            'G_OR_NL_FNBR_ID_NA', 'G_OR_NL_FNBR_ID_R', 'G_OR_NL_FNBR_ID_RR', ...
            'G_OR_NL_FNBR_LID_NA', 'G_OR_NL_FNBR_LID_R', 'G_OR_NL_FNBR_LID_RR', ...
            'G_OR_NL_FIRBIN_NA_NA', 'G_OR_NL_FIRBIN_NA_R', 'G_OR_NL_FIRBIN_NA_RR', ...
            'G_OR_NL_FIRBIN_ID_NA', 'G_OR_NL_FIRBIN_ID_R', 'G_OR_NL_FIRBIN_ID_RR', ...
            'G_OR_NL_FIRBIN_LID_NA', 'G_OR_NL_FIRBIN_LID_R', 'G_OR_NL_FIRBIN_LID_RR', ...
            'G_OR_NL_FINBIR_NA_NA', 'G_OR_NL_FINBIR_NA_R', 'G_OR_NL_FINBIR_NA_RR', ...
            'G_OR_NL_FINBIR_ID_NA', 'G_OR_NL_FINBIR_ID_R', 'G_OR_NL_FINBIR_ID_RR', ...
            'G_OR_NL_FINBIR_LID_NA', 'G_OR_NL_FINBIR_LID_R', 'G_OR_NL_FINBIR_LID_RR'};

        %  global, only relevant, self loops
        G_OR_SL = {...
            'G_OR_SL_NA_NA_NA', 'G_OR_SL_NA_NA_R', 'G_OR_SL_NA_NA_RR', ...
            'G_OR_SL_NA_ID_NA', 'G_OR_SL_NA_ID_R', 'G_OR_SL_NA_ID_RR', ...
            'G_OR_SL_NA_LID_NA', 'G_OR_SL_NA_LID_R', 'G_OR_SL_NA_LID_RR', ...
            'G_OR_SL_FRBN_NA_NA', 'G_OR_SL_FRBN_NA_R', 'G_OR_SL_FRBN_NA_RR', ...
            'G_OR_SL_FRBN_ID_NA', 'G_OR_SL_FRBN_ID_R', 'G_OR_SL_FRBN_ID_RR', ...
            'G_OR_SL_FRBN_LID_NA', 'G_OR_SL_FRBN_LID_R', 'G_OR_SL_FRBN_LID_RR', ...
            'G_OR_SL_FNBR_NA_NA', 'G_OR_SL_FNBR_NA_R', 'G_OR_SL_FNBR_NA_RR', ...
            'G_OR_SL_FNBR_ID_NA', 'G_OR_SL_FNBR_ID_R', 'G_OR_SL_FNBR_ID_RR', ...
            'G_OR_SL_FNBR_LID_NA', 'G_OR_SL_FNBR_LID_R', 'G_OR_SL_FNBR_LID_RR', ...
            'G_OR_SL_FIRBIN_NA_NA', 'G_OR_SL_FIRBIN_NA_R', 'G_OR_SL_FIRBIN_NA_RR', ...
            'G_OR_SL_FIRBIN_ID_NA', 'G_OR_SL_FIRBIN_ID_R', 'G_OR_SL_FIRBIN_ID_RR', ...
            'G_OR_SL_FIRBIN_LID_NA', 'G_OR_SL_FIRBIN_LID_R', 'G_OR_SL_FIRBIN_LID_RR', ...
            'G_OR_SL_FINBIR_NA_NA', 'G_OR_SL_FINBIR_NA_R', 'G_OR_SL_FINBIR_NA_RR', ...
            'G_OR_SL_FINBIR_ID_NA', 'G_OR_SL_FINBIR_ID_R', 'G_OR_SL_FINBIR_ID_RR', ...
            'G_OR_SL_FINBIR_LID_NA', 'G_OR_SL_FINBIR_LID_R', 'G_OR_SL_FINBIR_LID_RR'};
          
        % global, all documents, no loops
        G_AD_NL = {...
            'G_AD_NL_NA_NA_NA', 'G_AD_NL_NA_NA_R', 'G_AD_NL_NA_NA_RR', ...
            'G_AD_NL_NA_ID_NA', 'G_AD_NL_NA_ID_R', 'G_AD_NL_NA_ID_RR', ...
            'G_AD_NL_NA_LID_NA', 'G_AD_NL_NA_LID_R', 'G_AD_NL_NA_LID_RR', ...
            'G_AD_NL_FRBN_NA_NA', 'G_AD_NL_FRBN_NA_R', 'G_AD_NL_FRBN_NA_RR', ...
            'G_AD_NL_FRBN_ID_NA', 'G_AD_NL_FRBN_ID_R', 'G_AD_NL_FRBN_ID_RR', ...
            'G_AD_NL_FRBN_LID_NA', 'G_AD_NL_FRBN_LID_R', 'G_AD_NL_FRBN_LID_RR', ...
            'G_AD_NL_FNBR_NA_NA', 'G_AD_NL_FNBR_NA_R', 'G_AD_NL_FNBR_NA_RR', ...
            'G_AD_NL_FNBR_ID_NA', 'G_AD_NL_FNBR_ID_R', 'G_AD_NL_FNBR_ID_RR', ...
            'G_AD_NL_FNBR_LID_NA', 'G_AD_NL_FNBR_LID_R', 'G_AD_NL_FNBR_LID_RR', ...
            'G_AD_NL_FIRBIN_NA_NA', 'G_AD_NL_FIRBIN_NA_R', 'G_AD_NL_FIRBIN_NA_RR', ...
            'G_AD_NL_FIRBIN_ID_NA', 'G_AD_NL_FIRBIN_ID_R', 'G_AD_NL_FIRBIN_ID_RR', ...
            'G_AD_NL_FIRBIN_LID_NA', 'G_AD_NL_FIRBIN_LID_R', 'G_AD_NL_FIRBIN_LID_RR', ...
            'G_AD_NL_FINBIR_NA_NA', 'G_AD_NL_FINBIR_NA_R', 'G_AD_NL_FINBIR_NA_RR', ...
            'G_AD_NL_FINBIR_ID_NA', 'G_AD_NL_FINBIR_ID_R', 'G_AD_NL_FINBIR_ID_RR', ...
            'G_AD_NL_FINBIR_LID_NA', 'G_AD_NL_FINBIR_LID_R', 'G_AD_NL_FINBIR_LID_RR'};
      
        % global, all documents, self loops
        G_AD_SL = {...
            'G_AD_SL_NA_NA_NA', 'G_AD_SL_NA_NA_R', 'G_AD_SL_NA_NA_RR', ...
            'G_AD_SL_NA_ID_NA', 'G_AD_SL_NA_ID_R', 'G_AD_SL_NA_ID_RR', ...
            'G_AD_SL_NA_LID_NA', 'G_AD_SL_NA_LID_R', 'G_AD_SL_NA_LID_RR', ...
            'G_AD_SL_FRBN_NA_NA', 'G_AD_SL_FRBN_NA_R', 'G_AD_SL_FRBN_NA_RR', ...
            'G_AD_SL_FRBN_ID_NA', 'G_AD_SL_FRBN_ID_R', 'G_AD_SL_FRBN_ID_RR', ...
            'G_AD_SL_FRBN_LID_NA', 'G_AD_SL_FRBN_LID_R', 'G_AD_SL_FRBN_LID_RR', ...
            'G_AD_SL_FNBR_NA_NA', 'G_AD_SL_FNBR_NA_R', 'G_AD_SL_FNBR_NA_RR', ...
            'G_AD_SL_FNBR_ID_NA', 'G_AD_SL_FNBR_ID_R', 'G_AD_SL_FNBR_ID_RR', ...
            'G_AD_SL_FNBR_LID_NA', 'G_AD_SL_FNBR_LID_R', 'G_AD_SL_FNBR_LID_RR', ...
            'G_AD_SL_FIRBIN_NA_NA', 'G_AD_SL_FIRBIN_NA_R', 'G_AD_SL_FIRBIN_NA_RR', ...
            'G_AD_SL_FIRBIN_ID_NA', 'G_AD_SL_FIRBIN_ID_R', 'G_AD_SL_FIRBIN_ID_RR', ...
            'G_AD_SL_FIRBIN_LID_NA', 'G_AD_SL_FIRBIN_LID_R', 'G_AD_SL_FIRBIN_LID_RR', ...
            'G_AD_SL_FINBIR_NA_NA', 'G_AD_SL_FINBIR_NA_R', 'G_AD_SL_FINBIR_NA_RR', ...
            'G_AD_SL_FINBIR_ID_NA', 'G_AD_SL_FINBIR_ID_R', 'G_AD_SL_FINBIR_ID_RR', ...
            'G_AD_SL_FINBIR_LID_NA', 'G_AD_SL_FINBIR_LID_R', 'G_AD_SL_FINBIR_LID_RR'};
        
        
        % local, only relevant, no loops
        L_OR_NL = {...
            'L_OR_NL_NA_NA_NA', 'L_OR_NL_NA_NA_R', 'L_OR_NL_NA_NA_RR', ...
            'L_OR_NL_NA_ID_NA', 'L_OR_NL_NA_ID_R', 'L_OR_NL_NA_ID_RR', ...
            'L_OR_NL_NA_LID_NA', 'L_OR_NL_NA_LID_R', 'L_OR_NL_NA_LID_RR', ...
            'L_OR_NL_FRBN_NA_NA', 'L_OR_NL_FRBN_NA_R', 'L_OR_NL_FRBN_NA_RR', ...
            'L_OR_NL_FRBN_ID_NA', 'L_OR_NL_FRBN_ID_R', 'L_OR_NL_FRBN_ID_RR', ...
            'L_OR_NL_FRBN_LID_NA', 'L_OR_NL_FRBN_LID_R', 'L_OR_NL_FRBN_LID_RR', ...
            'L_OR_NL_FNBR_NA_NA', 'L_OR_NL_FNBR_NA_R', 'L_OR_NL_FNBR_NA_RR', ...
            'L_OR_NL_FNBR_ID_NA', 'L_OR_NL_FNBR_ID_R', 'L_OR_NL_FNBR_ID_RR', ...
            'L_OR_NL_FNBR_LID_NA', 'L_OR_NL_FNBR_LID_R', 'L_OR_NL_FNBR_LID_RR', ...
            'L_OR_NL_FIRBIN_NA_NA', 'L_OR_NL_FIRBIN_NA_R', 'L_OR_NL_FIRBIN_NA_RR', ...
            'L_OR_NL_FIRBIN_ID_NA', 'L_OR_NL_FIRBIN_ID_R', 'L_OR_NL_FIRBIN_ID_RR', ...
            'L_OR_NL_FIRBIN_LID_NA', 'L_OR_NL_FIRBIN_LID_R', 'L_OR_NL_FIRBIN_LID_RR', ...
            'L_OR_NL_FINBIR_NA_NA', 'L_OR_NL_FINBIR_NA_R', 'L_OR_NL_FINBIR_NA_RR', ...
            'L_OR_NL_FINBIR_ID_NA', 'L_OR_NL_FINBIR_ID_R', 'L_OR_NL_FINBIR_ID_RR', ...
            'L_OR_NL_FINBIR_LID_NA', 'L_OR_NL_FINBIR_LID_R', 'L_OR_NL_FINBIR_LID_RR'};
        
        
        %  local, only relevant, self loops
        L_OR_SL = {...
            'L_OR_SL_NA_NA_NA', 'L_OR_SL_NA_NA_R', 'L_OR_SL_NA_NA_RR', ...
            'L_OR_SL_NA_ID_NA', 'L_OR_SL_NA_ID_R', 'L_OR_SL_NA_ID_RR', ...
            'L_OR_SL_NA_LID_NA', 'L_OR_SL_NA_LID_R', 'L_OR_SL_NA_LID_RR', ...
            'L_OR_SL_FRBN_NA_NA', 'L_OR_SL_FRBN_NA_R', 'L_OR_SL_FRBN_NA_RR', ...
            'L_OR_SL_FRBN_ID_NA', 'L_OR_SL_FRBN_ID_R', 'L_OR_SL_FRBN_ID_RR', ...
            'L_OR_SL_FRBN_LID_NA', 'L_OR_SL_FRBN_LID_R', 'L_OR_SL_FRBN_LID_RR', ...
            'L_OR_SL_FNBR_NA_NA', 'L_OR_SL_FNBR_NA_R', 'L_OR_SL_FNBR_NA_RR', ...
            'L_OR_SL_FNBR_ID_NA', 'L_OR_SL_FNBR_ID_R', 'L_OR_SL_FNBR_ID_RR', ...
            'L_OR_SL_FNBR_LID_NA', 'L_OR_SL_FNBR_LID_R', 'L_OR_SL_FNBR_LID_RR', ...
            'L_OR_SL_FIRBIN_NA_NA', 'L_OR_SL_FIRBIN_NA_R', 'L_OR_SL_FIRBIN_NA_RR', ...
            'L_OR_SL_FIRBIN_ID_NA', 'L_OR_SL_FIRBIN_ID_R', 'L_OR_SL_FIRBIN_ID_RR', ...
            'L_OR_SL_FIRBIN_LID_NA', 'L_OR_SL_FIRBIN_LID_R', 'L_OR_SL_FIRBIN_LID_RR', ...
            'L_OR_SL_FINBIR_NA_NA', 'L_OR_SL_FINBIR_NA_R', 'L_OR_SL_FINBIR_NA_RR', ...
            'L_OR_SL_FINBIR_ID_NA', 'L_OR_SL_FINBIR_ID_R', 'L_OR_SL_FINBIR_ID_RR', ...
            'L_OR_SL_FINBIR_LID_NA', 'L_OR_SL_FINBIR_LID_R', 'L_OR_SL_FINBIR_LID_RR'};
        
        % local, all documents, no loops
        L_AD_NL = {...
            'L_AD_NL_NA_NA_NA', 'L_AD_NL_NA_NA_R', 'L_AD_NL_NA_NA_RR', ...
            'L_AD_NL_NA_ID_NA', 'L_AD_NL_NA_ID_R', 'L_AD_NL_NA_ID_RR', ...
            'L_AD_NL_NA_LID_NA', 'L_AD_NL_NA_LID_R', 'L_AD_NL_NA_LID_RR', ...
            'L_AD_NL_FRBN_NA_NA', 'L_AD_NL_FRBN_NA_R', 'L_AD_NL_FRBN_NA_RR', ...
            'L_AD_NL_FRBN_ID_NA', 'L_AD_NL_FRBN_ID_R', 'L_AD_NL_FRBN_ID_RR', ...
            'L_AD_NL_FRBN_LID_NA', 'L_AD_NL_FRBN_LID_R', 'L_AD_NL_FRBN_LID_RR', ...
            'L_AD_NL_FNBR_NA_NA', 'L_AD_NL_FNBR_NA_R', 'L_AD_NL_FNBR_NA_RR', ...
            'L_AD_NL_FNBR_ID_NA', 'L_AD_NL_FNBR_ID_R', 'L_AD_NL_FNBR_ID_RR', ...
            'L_AD_NL_FNBR_LID_NA', 'L_AD_NL_FNBR_LID_R', 'L_AD_NL_FNBR_LID_RR', ...
            'L_AD_NL_FIRBIN_NA_NA', 'L_AD_NL_FIRBIN_NA_R', 'L_AD_NL_FIRBIN_NA_RR', ...
            'L_AD_NL_FIRBIN_ID_NA', 'L_AD_NL_FIRBIN_ID_R', 'L_AD_NL_FIRBIN_ID_RR', ...
            'L_AD_NL_FIRBIN_LID_NA', 'L_AD_NL_FIRBIN_LID_R', 'L_AD_NL_FIRBIN_LID_RR', ...
            'L_AD_NL_FINBIR_NA_NA', 'L_AD_NL_FINBIR_NA_R', 'L_AD_NL_FINBIR_NA_RR', ...
            'L_AD_NL_FINBIR_ID_NA', 'L_AD_NL_FINBIR_ID_R', 'L_AD_NL_FINBIR_ID_RR', ...
            'L_AD_NL_FINBIR_LID_NA', 'L_AD_NL_FINBIR_LID_R', 'L_AD_NL_FINBIR_LID_RR'};
        
        
        % local, all documents, self loops
        L_AD_SL = {...
            'L_AD_SL_NA_NA_NA', 'L_AD_SL_NA_NA_R', 'L_AD_SL_NA_NA_RR', ...
            'L_AD_SL_NA_ID_NA', 'L_AD_SL_NA_ID_R', 'L_AD_SL_NA_ID_RR', ...
            'L_AD_SL_NA_LID_NA', 'L_AD_SL_NA_LID_R', 'L_AD_SL_NA_LID_RR', ...
            'L_AD_SL_FRBN_NA_NA', 'L_AD_SL_FRBN_NA_R', 'L_AD_SL_FRBN_NA_RR', ...
            'L_AD_SL_FRBN_ID_NA', 'L_AD_SL_FRBN_ID_R', 'L_AD_SL_FRBN_ID_RR', ...
            'L_AD_SL_FRBN_LID_NA', 'L_AD_SL_FRBN_LID_R', 'L_AD_SL_FRBN_LID_RR', ...
            'L_AD_SL_FNBR_NA_NA', 'L_AD_SL_FNBR_NA_R', 'L_AD_SL_FNBR_NA_RR', ...
            'L_AD_SL_FNBR_ID_NA', 'L_AD_SL_FNBR_ID_R', 'L_AD_SL_FNBR_ID_RR', ...
            'L_AD_SL_FNBR_LID_NA', 'L_AD_SL_FNBR_LID_R', 'L_AD_SL_FNBR_LID_RR', ...
            'L_AD_SL_FIRBIN_NA_NA', 'L_AD_SL_FIRBIN_NA_R', 'L_AD_SL_FIRBIN_NA_RR', ...
            'L_AD_SL_FIRBIN_ID_NA', 'L_AD_SL_FIRBIN_ID_R', 'L_AD_SL_FIRBIN_ID_RR', ...
            'L_AD_SL_FIRBIN_LID_NA', 'L_AD_SL_FIRBIN_LID_R', 'L_AD_SL_FIRBIN_LID_RR', ...
            'L_AD_SL_FINBIR_NA_NA', 'L_AD_SL_FINBIR_NA_R', 'L_AD_SL_FINBIR_NA_RR', ...
            'L_AD_SL_FINBIR_ID_NA', 'L_AD_SL_FINBIR_ID_R', 'L_AD_SL_FINBIR_ID_RR', ...
            'L_AD_SL_FINBIR_LID_NA', 'L_AD_SL_FINBIR_LID_R', 'L_AD_SL_FINBIR_LID_RR'};
        
        
        % cross check models
        CHK = {...
            'G_AD2OR_NL_NA_ID_NA', 'G_AD2OR_NL_NA_ID_R', 'G_AD2OR_NL_NA_ID_RR', ...
            'G_AD2OR_NL_NA_LID_NA', 'G_AD2OR_NL_NA_LID_R', 'G_AD2OR_NL_NA_LID_RR', ...
            'L_AD2OR_NL_NA_ID_NA', 'L_AD2OR_NL_NA_ID_R', 'L_AD2OR_NL_NA_ID_RR', ...
            'L_AD2OR_NL_NA_LID_NA', 'L_AD2OR_NL_NA_LID_R', 'L_AD2OR_NL_NA_LID_RR'};
        
        mmList = [G_OR_NL G_OR_SL G_AD_NL G_AD_SL L_OR_NL L_OR_SL L_AD_NL L_AD_SL CHK];
        
    end;


    % check that we have the correct number of input arguments. 
    narginchk(2, inf);
    
    % parse the variable inputs
    pnames = {'ShortNameSuffix', 'MapToBinaryRelevance' 'NotAssessed' 'MarkovModel'       'Verbose'};
    dflts =  {[]                 'lenient'              'NotRelevant' 'G_AD_NL_NA_ID_R'    false};
    [shortNameSuffix, mapToBinaryRelevance, notAssessed, markovModel, verbose, supplied] ...
         = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

    % actual parameters to be passed to assess.m, at least 6
    assessInput = cell(1, 10);
    
    % not assessed documents must be considered as not relevant for
    % precision
    assessInput{1, 1} = 'NotAssessed';
    assessInput{1, 2} = notAssessed;
    
    % map to binary relevance must be performed. Either use the value
    % passed by the caller or the default one
    assessInput{1, 3} = 'MapToBinaryRelevance';
    assessInput{1, 4} = mapToBinaryRelevance;
    
    % map to binary relevance weights to make follow-up computations
    % handier
    assessInput{1, 5} = 'MapToRelevanceWeights';
    assessInput{1, 6} = [0, 1];
     
    % padding is not needed
    assessInput{1, 7} = 'FixNumberRetrievedDocuments';
    assessInput{1, 8} = [];
    
    % remove unsampled/unjudged documents because they are not appropriate
    % for average precision computation
    assessInput{1, 9} = 'RemoveUUFromPool';
    assessInput{1, 10} = true;
    
    if supplied.MarkovModel        
        % check that MarkovModel is a non-empty string
        validateattributes(markovModel, ...
            {'char', 'cell'}, {'nonempty', 'vector'}, '', 'MarkovModel');
        
        if iscell(markovModel)
            % check that MarkovModel is a cell array of strings with one element
            assert(iscellstr(markovModel) && numel(markovModel) == 1, ...
                'MATTERS:IllegalArgument', 'Expected MarkovModel to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        markovModel = char(strtrim(markovModel));
        markovModel = markovModel(:).';
        
        % check that markovModel assumes a valid value
        validatestring(markovModel, mmList, '', 'MarkovModel');             
    end;     
        
    if supplied.ShortNameSuffix
        if iscell(shortNameSuffix)
            % check that nameSuffix is a cell array of strings with one element
            assert(iscellstr(shortNameSuffix) && numel(shortNameSuffix) == 1, ...
                'MATTERS:IllegalArgument', 'Expected ShortNameSuffix to be a cell array of strings containing just one string.');
        end
        
        % remove useless white spaces, if any, and ensure it is a char row
        shortNameSuffix = char(strtrim(shortNameSuffix));
        shortNameSuffix = shortNameSuffix(:).';
        
        % check that the nameSuffix is ok according to the matlab rules
        if ~isempty(regexp(shortNameSuffix, '\W*', 'once'))
            error('MATTERS:IllegalArgument', 'ShortNameSuffix %s is not valid: it can contain only letters, numbers, and the underscore.', ...
                shortNameSuffix);
        end  
        
        % if it starts with an underscore, remove it since il will be
        % appended afterwards
        if strcmp(shortNameSuffix(1), '_')
            shortNameSuffix = shortNameSuffix(2:end);
        end;
    end;
       
    if supplied.Verbose
        % check that verbose is a non-empty scalar logical value
        validateattributes(verbose, {'logical'}, {'nonempty','scalar'}, '', 'Verbose');
    end;    
                     
    if verbose
        fprintf('\n\n----------\n');
        
        fprintf('Computing markov precision %s for run set %s with respect to pool %s: %d run(s) and %d topic(s) to be processed.\n\n', ...
            markovModel, runSet.Properties.UserData.identifier, pool.Properties.UserData.identifier, width(runSet), height(runSet));
    end;
    
    [assessedRunSet, poolStats, runSetStats, inputParams] = assess(pool, runSet, 'Verbose', verbose, assessInput{:});
    
     % the topic currently under processing
    ct = 1;
        
    % the run currently under processing
    cr = 1;
    
    % return the Markov model split into sub-fields
    % parsedMarkovModel{1} = connectedness
    % parsedMarkovModel{2} = states
    % parsedMarkovModel{3} = loops
    % parsedMarkovModel{4} = counts
    % parsedMarkovModel{5} = distance
    % parsedMarkovModel{6} = rescaling
    parsedMarkovModel = strsplit(markovModel, '_');
    
    % the invariant distributions used to average the precision values
    invariantDistribution = cell2table(cell(height(runSet), width(runSet)));
    invariantDistribution.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    invariantDistribution.Properties.UserData.pool = pool.Properties.UserData.identifier;
    invariantDistribution.Properties.RowNames = runSet.Properties.RowNames;
    invariantDistribution.Properties.VariableNames = runSet.Properties.VariableNames;
    
    
    % compute the measure topic-by-topic
    measuredRunSet = rowfun(@processTopic, assessedRunSet, 'OutputVariableNames', runSet.Properties.VariableNames, 'OutputFormat', 'table', 'ExtractCellContents', true, 'SeparateInputs', false);
    measuredRunSet.Properties.UserData.identifier = assessedRunSet.Properties.UserData.identifier;
    measuredRunSet.Properties.UserData.pool = pool.Properties.UserData.identifier;
    
    measuredRunSet.Properties.UserData.name = 'markovPrecision';
    measuredRunSet.Properties.UserData.shortName = 'MP';
    
    if strcmpi(notAssessed, 'condensed')
      measuredRunSet.Properties.UserData.name = 'condensedMarkovAveragePrecision_';
      measuredRunSet.Properties.UserData.shortName = 'condMP_';
    end;
    
    % Add the used Markov model to the name
    measuredRunSet.Properties.UserData.name = [measuredRunSet.Properties.UserData.name ...
                                                '_' markovModel];
    measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
                                                '_' markovModel];
                                            
    if ~isempty(shortNameSuffix)
        measuredRunSet.Properties.UserData.shortName = [measuredRunSet.Properties.UserData.shortName ...
            '_' shortNameSuffix];
    end;
    
    % Add the measure name to the invariant distribution
    invariantDistribution.Properties.UserData.name =  measuredRunSet.Properties.UserData.name;
    invariantDistribution.Properties.UserData.shortName =  measuredRunSet.Properties.UserData.shortName;

    if verbose
        fprintf('Computation of Markov precision completed.\n');
    end;
    
    %%
    
    % compute the measure for a given topic over all the runs
    function [varargout] = processTopic(topic)
        
        if(verbose)
            fprintf('Processing topic %s (%d out of %d)\n', pool.Properties.RowNames{ct}, ct, inputParams.topics);
            fprintf('  - run(s): ');
        end;
               
        % reset the index of the run under processing for each topic
        cr = 1;
        
        % the maximum number of relevant retrieved documents across the run
        % set for the given topic.
        % Avoid computations if not needed
        if strcmpi(parsedMarkovModel{6}, 'RR')
            maxR = runSetStats{ct, :};
            maxR = max(cell2mat({maxR.relevantRetrieved}));
        else
            maxR = [];
        end;
         
        % compute the measure only on those column which contain the
        % actual runs
        varargout = cellfun(@processRun, topic);
              
        % increment the index of the current topic under processing
        ct = ct + 1;    
        
         if(verbose)
            fprintf('\n');
        end;
        
        %% 
        
        % compute the measure for a given topic of a given run
        function [measure] = processRun(runTopic)
                              
            if(verbose)
                fprintf('%s ', runSet.Properties.VariableNames{cr});
            end;
            
            % avoid useless computations when you already know that either
            % the run has retrieved no relevant documents (0) or that there
            % are no relevant documents in the pool (NaN)
            if(runSetStats{ct, cr}.relevantRetrieved == 0)  
                if (poolStats{ct, 'BinaryRelevant'} == 0)
                    measure = {NaN};
                else
                    measure = {0};
                end;
                
                % increment the index of the current run under processing
                cr = cr + 1;
                
                return;                               
            end;
                                   
            % determine the positions of the relevant documents. Assessment
            % is already a binary relevance vector where 1s correspond also
            % to the positions of the relevant documents when we look at
            % them as a logical row vector
            relPos = logical(runTopic{:, 'Assessment'});
            relPos = relPos(:).';
            
             % determine the indices of the positions of the relevant
            % documents as a row vector
            relInd = find(relPos);
            
            % if some count is asked, perform it, otherwise skip useless
            % computations
            if ~strcmpi(parsedMarkovModel{4}, 'NA')
                % determine the total number of relevant documents seen up to
                % each rank position
                relSoFar = cumsum(relPos);

                % determine the positions of the not relevant documents
                notRelPos = ~relPos;

                % determine the total number of not relevant documents seen up 
                % to each rank position
                notRelSoFar = cumsum(notRelPos);
            else
                relSoFar = [];               
                notRelSoFar = [];
            end;
                                                                     
            % compute precision at each relevant retrieved document.
            prec = cumsum(runTopic{relPos.', 'Assessment'}).' ./ relInd;
            
            % create the transition matrix
            % parsedMarkovModel{1} = connectedness
            % parsedMarkovModel{2} = states
            % parsedMarkovModel{3} = loops
            % parsedMarkovModel{4} = counts
            % parsedMarkovModel{5} = distance
            P = createTransitionMatrix(parsedMarkovModel{1}, parsedMarkovModel{2}, ...
                parsedMarkovModel{3}, parsedMarkovModel{4}, parsedMarkovModel{5});
            
            % map the all documents transition matrix to the only relevant
            % one
            if strcmpi(parsedMarkovModel{2}, 'AD2OR')
                P = extractRelevantOnlySubMatrix(P);
            end;
            
            % compute the invariant distribution of the Markov chain
            p = computeInvariantDistribution(P);
                        
            % check if it is empty. It should not happen 
            if isempty(p)                  
                 warning('MATTERS:IllegalState', 'The invariant distribution with Markov model %s for run %s at topic %s is empty at the following retrieved documents: %s.', ...
                        markovModel, runSet.Properties.VariableNames{cr}, ...
                        pool.Properties.RowNames{ct}, num2str(relInd(isnan(p))));
            end;
            
            % check if we have NaN values. It should not happen 
            if any(isnan(p))                  
                 warning('MATTERS:IllegalState', 'The invariant distribution with Markov model %s for run %s at topic %s contains NaN values at the following retrieved documents: %s.', ...
                        markovModel, runSet.Properties.VariableNames{cr}, ...
                        pool.Properties.RowNames{ct}, num2str(relInd(isnan(p))));
            end;
            
            % if we have considered all the documents in computing the
            % invariant distribution,  extract probabilities only at 
            % relevant documents and rescale them to sum up to 1. 
            if strcmpi(parsedMarkovModel{2}, 'AD')
                    p = p(relPos);
                    p = bsxfun(@rdivide, p, sum(p));  
            end;   
            
            % compute Markov precision as the weighted average of the
            % precision at each relevant document by the invariant
            % distribution
            measure = prec * p.';
                                                
            % adjust Markov precision according to the selected rescaling
            % parsedMarkovModel{6} = rescaling
            switch upper(parsedMarkovModel{6})
                
                % no rescaling needed, nothing to be done
                case {'NA'}
                    ;
                    
                % rescale to recall
                case {'R'}
                    measure = measure .* runSetStats{ct, cr}.relevantRetrieved ./ poolStats{ct, 'BinaryRelevant'};                                       
                    
                                    
                % rescale to relative recall
                case {'RR'}                                                          
                    measure = measure .* runSetStats{ct, cr}.relevantRetrieved ./ maxR;                                                               
            end;
                                                   
                                   
            % properly wrap the results into a cell in order to fit it into
            % a value for a table
            measure = {measure};
            
            % store the invariant distribution for the results
            invariantDistribution{ct, cr} = {p};
            
            % increment the index of the current run under processing
            cr = cr + 1;
                        
            %%

            % create the transition matrix of the Markov chain according to
            % the input parameters
            %
            % connectedness - *G* to indicate transitions among all state; 
            % *L* to indicate transitions only among adjacent states;
            %
            % states - *AD* to indicate that all the documents in a run are
            % considered as states of the transition matrix; *OR* to indicate 
            % that only the relevant documents in a run are considered as 
            % states of the transition matrix;
            %
            % loops - *SL* to indicate that self loops among states are
            % allowed; *NL* to indicate that self loops among state are not
            % allowed;
            %
            % counts - *FRBN* to indicate that forward transition probabilities 
            % are proportional to the number of relevant retrieved 
            % documents so far and that backward transition probabilities 
            % are proportional to the number of not relevant retrieved 
            % documents so far; *FNBR* to indicate that forward transition 
            % probabilities are proportional to the number of not relevant 
            % retrieved documents so far and that backward transition 
            % probabilities are proportional to the number of relevant
            % retrieved documents so far; *FIRBIN* to indicate that forward 
            % transition probabilities are proportional to the inverse the 
            % number of relevant retrieved documents so far and that
            % backward transition probabilities are proportional to the 
            % inverse of the number of not relevant retrieved documents so 
            % far; *FINBIR* to indicate that  forward transition probabilities 
            % are proportional to the inverse the number of not relevant
            % retrieved documents so far and backward transition 
            % probabilities are proportional to the inverse of the number
            % of relevant retrieved documents so far;
            %
            % distance - ID to indicate that transition propabilities are
            % proportional to the inverse of the distance among states; LID
            % to indicate that transition probabilities are proportional to
            % the inverse of the log of the distance among states;
            function P = createTransitionMatrix(connectedness, states, loops, counts, distance)
                
                % when considering only relevant retrieved documents, the
                % transition matrix has as many states as the relevant
                % retrieved documents are
                if strcmpi(states, 'OR')
                    s = relInd;           
                else 
                    s = 1:runSetStats{ct, cr}.retrieved;
                end
                
                % the number of states in the transition matrix
                m = length(s);
                
                % If we  have only one state we will stay there with 
                % probability 1, regardless whether we are considering only 
                % the relevant documents or all the retrieved documents.
                % So, avoid useless computations and return the transition
                % matrix directly.
                if m == 1
                    P = 1;
                    return;
                end;
                
                % the basic transition matrix has equal transition
                % probabilities among all states
                P = ones(m);
                
                % the transition matrix is based on the inverse of the
                % distance among document pairs
                if (strcmpi(distance, 'ID') || strcmpi(distance, 'LID'))
                    
                    % for each document pair (i, j) such that i <> j, compute 
                    % the distance as |i - j| + 1. Note that this is an upper
                    % triangular matrix among the considered document pairs.
                    Q = abs(triu(repmat(s.', 1, m), 1) - triu(repmat(s, m, 1), 1)) + ...
                        triu(ones(m), 1);

                    % make P symmetric since the distance i->j is the same as
                    % the one j->i and add the distance of a document from 
                    % itself (loops) as |i - i| + 1 = 1. 
                    % This also lets us to avoid having division by 0 and thus
                    % Inf values on the diagonal in the next step. 
                    Q = Q + Q.' + eye(m);

                    % smooth by log
                    if strcmpi(distance, 'LID')
                        Q = log10(Q + 1);
                    end;
                    
                    % transitions probabilities are inversely proportional to 
                    % the (log smoothed) distance among document pairs
                    Q = 1 ./ Q;
                                        
                    % make the transition matrix proportional to the
                    % inverse of the (log smoothed) distance among documents
                    P = P .* Q;
                end;
                
                switch upper(counts)
                                                          
                    % forward transition probabilities are proportional to 
                    % the number of relevant retrieved documents so far
                    % and backward transition probabilities are 
                    % proportional to the number of not relevant retrieved 
                    % documents so far
                    case 'FRBN'
                        forward  = relSoFar(s) + 1; 
                        backward = notRelSoFar(s) + 1;
                        
                        Q = triu(repmat(forward.', 1, m)) + ...
                            tril(repmat(backward.', 1, m));
                        
                        P = P .* Q;
                                            
                    % forward transition probabilities are proportional to 
                    % the number of not relevant retrieved documents so far
                    % and backward transition probabilities are 
                    % proportional to the number of relevant retrieved 
                    % documents so far
                    case 'FNBR'
                        
                        forward  = notRelSoFar(s) + 1;
                        backward = relSoFar(s) + 1; 
                                                
                        Q = triu(repmat(forward.', 1, m)) + ...
                            tril(repmat(backward.', 1, m));
                        
                        P = P .* Q;    
                        
                    % forward transition probabilities are proportional to the 
                    % inverse the number of relevant retrieved documents so
                    % far and backward transition probabilities are 
                    % proportional to the inverse of the number of not relevant 
                    % retrieved documents so far
                    case 'FIRBIN'
                        
                        forward  = 1 ./ (relSoFar(s) + 1);
                        backward = 1 ./ (notRelSoFar(s) + 1);
                                                
                        Q = triu(repmat(forward.', 1, m)) + ...
                            tril(repmat(backward.', 1, m));
                                                                     
                        P = P .* Q;
                        
                    % forward transition probabilities are proportional to the 
                    % inverse the number of not relevant retrieved documents 
                    % so far and backward transition probabilities are 
                    % proportional to the inverse of the number of relevant 
                    % retrieved documents so far
                    case 'FINBIR'
                        
                        forward  = 1 ./ (notRelSoFar(s) + 1);
                        backward = 1 ./ (relSoFar(s) + 1);
                                                
                        Q = triu(repmat(forward.', 1, m)) + ...
                            tril(repmat(backward.', 1, m));                                                                                                            
                        
                        P = P .* Q;                                                                   
                end;
                
                % self loops are not allowed
                if strcmpi(loops, 'NL')
                    P(logical(eye(m))) = 0;
                end;
                                                
                % only transitions among adjacent states are allowed
                if strcmpi(connectedness, 'L')
                  P = P - triu(P, 2) - tril(P, -2);
                end;
                
                % normalize rows of the transtion matrix to sum up to 1
                P = bsxfun(@rdivide, P, sum(P, 2));

            end % createTransitionMatrix 
            
            
            
            %%
    
            % extracts a sub-matric of a full transition matrix concerning
            % only the relevant documents
            function S = extractRelevantOnlySubMatrix(P)

                % the number of states in the sub transition matrix
                m = runSetStats{ct, cr}.relevantRetrieved;

                % the sub transition matrix
                S = NaN(m);

                % A matrix equal to the original transition matrix with
                % zeros in the columns corresponding to the relevant
                % documents
                barP = P;
                barP(:, relInd) = 0;
                
                barP = eye(size(P)) - barP;
                            
                % solve the linear systems for determining the columns of S
                for i = 1:m
                    h = barP \ P(:, relInd(i));
                    S(:,i) = h(relInd);
                end
            end % extractSubMatrix
        end % processRun
    end % processTopic    
end % markovPrecision
%%

% compute the invariant distribution of a discrete Markov chain with
% transition matrix P.
function p = computeInvariantDistribution(P)

    m = size(P, 1);
    a = ones(1, m);
    B = eye(m) - P + ones(m);

    % solve the linear systen p * B = a
    % B / a = a * inv(B)
    p = a / B;
end % computeInvariantDistribution