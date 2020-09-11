%% common_parameters
%
% Sets up parameters common to the different scripts.
%
%% Information
%
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: MATTERS 1.0 or higher; Matlab 2017a
% * *Copyright:* (C) 2018-2019 <http://www.dei.unipd.it/
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

diary off;

%% Path Configuration

% if we are running on the cluster
if (strcmpi(computer, 'GLNXA64'))
    addpath(genpath('../../matters/'))   % ave/eva
    addpath(genpath('../../matters/'))   % grace
end

addpath(genpath('./utils/'));
addpath(genpath('./shared_files/'));



EXPERIMENT.path.base = '../experiment/';  % grace

% The path for the corpora, i.e. text files containing the list of
% documents for a corpus
EXPERIMENT.path.corpus = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'corpus', filesep);

% The path for the shards, i.e. a directories containing text files,
% each one listing documents from a corpus according to some criterion
EXPERIMENT.path.shard = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'shard', filesep);

% The path for the datasets, i.e. the runs and the pools of both original
% tracks and sub-corpora
EXPERIMENT.path.dataset = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'dataset', filesep);

% The path for the measures
EXPERIMENT.path.measure = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'measure', filesep);

% The path for analyses
EXPERIMENT.path.analysis = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'analysis', filesep);

% The path for figures
EXPERIMENT.path.figure = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'figure', filesep);

% The path for reports
EXPERIMENT.path.report = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'report', filesep);

% The path for the corpora, i.e. text files containing the list of
% documents for a corpus
EXPERIMENT.path.run = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'runs', filesep);

% The path for the corpora, i.e. text files containing the list of
% documents for a corpus
EXPERIMENT.path.pool = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.base, 'pool', filesep);


%% General Configuration

% Label of the paper this experiment is for
EXPERIMENT.label.paper = 'SIGIR 2019 FS';


%% Configuration for Corpora

EXPERIMENT.corpus.list = {'GOV2', 'NYT', 'TIP', 'WAPO', 'WT10g'};
EXPERIMENT.corpus.number = length(EXPERIMENT.corpus.list);

% The full TIPSTER corpus
EXPERIMENT.corpus.TIP.id = 'TIP';
EXPERIMENT.corpus.TIP.name = 'TIPSTER, Disk 4-5 minus Congressional Record';
EXPERIMENT.corpus.TIP.size = 528155;

% The full WT10g corpus
EXPERIMENT.corpus.WT10g.id = 'WT10g';
EXPERIMENT.corpus.WT10g.name = 'WT10g, a crawl of Web preserving some desiderablde corpus properties (around 1999-2000)';
EXPERIMENT.corpus.WT10g.size = 1692096;

% The full GOV2 corpus
EXPERIMENT.corpus.GOV2.id = 'GOV2';
EXPERIMENT.corpus.GOV2.name = 'A crawl of .gov sites (early 2004)';
EXPERIMENT.corpus.GOV2.size = 25205179;

% The full NYT corpus
EXPERIMENT.corpus.NYT.id = 'NYT';
EXPERIMENT.corpus.NYT.name = 'The New York Times Annotated Corpus contains articles published between January 1, 1987 and June 19, 2007';
EXPERIMENT.corpus.NYT.size = 1855658;

% The full WAPO corpus
EXPERIMENT.corpus.WAPO.id = 'WAPO';
EXPERIMENT.corpus.WAPO.name = 'The TREC Washington Post Corpus contains news articles and blog posts from January 2012 through August 2017';
EXPERIMENT.corpus.WAPO.size = 1855658;



tracks;

splits;

%% Patterns for file names

% TXT - Pattern EXPERIMENT.path.base/corpus/<corpusID>.txt
EXPERIMENT.pattern.file.corpus = @(corpusID) sprintf('%1$s%2$s.txt', EXPERIMENT.path.corpus, corpusID);

% TXT - Pattern EXPERIMENT.path.shard/<splitID>/<shardID>.txt
EXPERIMENT.pattern.file.shard = @(splitID, shardID) sprintf('%1$s%3$s%2$s%4$s.txt', EXPERIMENT.path.shard, filesep, splitID, shardID);

% ALL - Pattern <path>/<trackID>/<fileID>.<ext>
EXPERIMENT.pattern.file.general.track = @(path, trackID, fileID, ext) sprintf('%1$s%2$s%3$s%4$s.%5$s', path, trackID, filesep, fileID, ext);

% ALL - Pattern <path>/<trackID>/<splitID>/<fileID>.<ext>
EXPERIMENT.pattern.file.general.shard = @(path, trackID, splitID, fileID, ext) sprintf('%1$s%2$s%3$s%4$s%3$s%5$s.%6$s', path, trackID, filesep, splitID, fileID, ext);

% MAT - Pattern EXPERIMENT.path.base/dataset/<trackID>/<datasetID>.mat
EXPERIMENT.pattern.file.dataset.corpus = @(trackID, datasetID) EXPERIMENT.pattern.file.general.track(EXPERIMENT.path.dataset, trackID, datasetID, 'mat');

% MAT - Pattern EXPERIMENT.path.base/dataset/<trackID>/<splitID>/<datasetID>.mat
EXPERIMENT.pattern.file.dataset.shard = @(trackID, splitID, datasetID) EXPERIMENT.pattern.file.general.shard(EXPERIMENT.path.dataset, trackID, splitID, datasetID, 'mat');

% MAT - Pattern EXPERIMENT.path.base/measure/<trackID>/<measureID>.mat
EXPERIMENT.pattern.file.measure.corpus = @(trackID, measureID) EXPERIMENT.pattern.file.general.track(EXPERIMENT.path.measure, trackID, measureID, 'mat');

% MAT - Pattern EXPERIMENT.path.base/measure/<trackID>/<splitID>/<measureID>.mat
EXPERIMENT.pattern.file.measure.shard = @(trackID, splitID, measureID) EXPERIMENT.pattern.file.general.shard(EXPERIMENT.path.measure, trackID, splitID, measureID, 'mat');

% MAT - Pattern EXPERIMENT.path.base/analysis/<trackID>/<analysisID>.mat
EXPERIMENT.pattern.file.analysis.corpus = @(trackID, analysisID) EXPERIMENT.pattern.file.general.track(EXPERIMENT.path.analysis, trackID, analysisID, 'mat');

% MAT - Pattern EXPERIMENT.path.base/analysis/<trackID>/<splitID>/<analysisID>.mat
EXPERIMENT.pattern.file.analysis.bootstrapAnova = @(trackID, splitID, analysisID) EXPERIMENT.pattern.file.general.shard(EXPERIMENT.path.analysis, trackID, splitID, analysisID, 'mat');


% MAT - Pattern EXPERIMENT.path.base/analysis/<trackID>/<splitID>/<analysisID>.mat
EXPERIMENT.pattern.file.analysis.shard = @(trackID, splitID, analysisID) EXPERIMENT.pattern.file.general.shard(EXPERIMENT.path.analysis, trackID, splitID, analysisID, 'mat');

% PDF - Pattern EXPERIMENT.path.base/figure/<trackID>/<figureID>
EXPERIMENT.pattern.file.figure = @(trackID, figureID) EXPERIMENT.pattern.file.general.track(EXPERIMENT.path.figure, trackID, figureID, 'pdf');

% TEX - Pattern EXPERIMENT.path.base/report/<trackID>/<reportID>
EXPERIMENT.pattern.file.report = @(trackID, reportID) EXPERIMENT.pattern.file.general.track(EXPERIMENT.path.report, trackID, reportID, 'tex');


%% Patterns for identifiers

% Pattern <splitID>_s<smpl>
EXPERIMENT.pattern.identifier.split =  @(splitID, smpl) sprintf('%1$s_s%2$03d', splitID, smpl);

% Pattern <splitID>_shr<shr>_s<smpl>
EXPERIMENT.pattern.identifier.shard =  @(splitID, shr, smpl) sprintf('%1$s_shr%2$03d_s%3$03d', splitID, shr, smpl);

% Pattern pool_<corpusID>_<trackID>
% Pattern pool_<shardID>_<trackID>
EXPERIMENT.pattern.identifier.pool =  @(partID, trackID) sprintf('pool_%1$s_%2$s', partID, trackID);

% Pattern run_<corpusID>_<trackID>
% Pattern run_<shardID>_<trackID>
EXPERIMENT.pattern.identifier.run = @(partID, trackID) sprintf('run_%1$s_%2$s', partID, trackID);

% Pattern <mid>_<corpusID>_<trackID>
% Pattern <mid>_<shardID>_<trackID>
EXPERIMENT.pattern.identifier.measure =  @(mid, partID, trackID) sprintf('%1$s_%2$s_%3$s', mid, partID, trackID);

% Pattern <mdID>_<type>_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.general =  @(mdID, type, balanced, sstype, quartile, measureID, splitID, trackID) sprintf('%1$s_%2$s_%6$s_%3$s_sst%4$d_%5$s_%7$s_%8$s', mdID, type, balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_anova_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.analysis =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'anova', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_tbl_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.tbl =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'tbl', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_sts_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.sts =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'sts', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_blc_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.blc =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'blc', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_me_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.me =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'me', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_<measureID>_<factor>-me_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.mePlot =  @(mdID, factor, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, [factor '-me'], balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_mc_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.mc =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'mc', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_soa_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.soa =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'soa', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_pwr_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.pwr =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'pwr', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_sts_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.anova.sts =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.anova.general(mdID, 'sts', balanced, sstype, quartile, measureID, splitID, trackID);



% Pattern <mdID>_<type>_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootsrapEffects.general =  @(mdID, type, balanced, sstype, quartile, measureID, splitID, trackID, M) sprintf('%1$s_%2$s_%6$s_%3$s_sst%4$d_%5$s_%7$s_%8$s_%9$d', mdID, type, balanced, sstype, quartile, measureID, splitID, trackID, M);

% Pattern <mdID>_anova_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootsrapEffects.analysis =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID, M) EXPERIMENT.pattern.identifier.bootsrapEffects.general(mdID, 'bEffects', balanced, sstype, quartile, measureID, splitID, trackID, M);





% Pattern <mdID>_<type>_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova.general =  @(mdID, type, balanced, sstype, quartile, direction, measureID, splitID, trackID) sprintf('%1$s_%2$s_%7$s_%3$s_sst%4$d_%5$s_%6$s_%8$s_%9$s', mdID, type, balanced, sstype, quartile, direction, measureID, splitID, trackID);

% Pattern <mdID>_bootstrapAnova_<direction>_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova.analysis =  @(mdID, balanced, sstype, quartile, direction, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.bootstrapAnova.general(mdID, 'bootstrapAnova', balanced, sstype, quartile, direction, measureID, splitID, trackID);

% Pattern <mdID>_mc_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova.mc =  @(mdID, balanced, sstype, quartile, direction, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.bootstrapAnova.general(mdID, 'mc', balanced, sstype, quartile, direction, measureID, splitID, trackID);

% Pattern <mdID>_k_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova.k =  @(mdID, balanced, sstype, quartile, direction, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.bootstrapAnova.general(mdID, 'k', balanced, sstype, quartile, direction, measureID, splitID, trackID);





% Pattern <mdID>_<type>_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova_o.general =  @(mdID, type, balanced, sstype, quartile, measureID, splitID, trackID) sprintf('%1$s_%2$s_%6$s_%3$s_sst%4$d_%5$s_%7$s_%8$s', mdID, type, balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_bootstrapAnova_<direction>_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova_o.analysis =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.bootstrapAnova_o.general(mdID, 'bootstrapAnova', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_mc_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova_o.mc =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.bootstrapAnova_o.general(mdID, 'mc', balanced, sstype, quartile, measureID, splitID, trackID);

% Pattern <mdID>_k_<measureID>_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.bootstrapAnova_o.k =  @(mdID, balanced, sstype, quartile, measureID, splitID, trackID) EXPERIMENT.pattern.identifier.bootstrapAnova_o.general(mdID, 'k', balanced, sstype, quartile, measureID, splitID, trackID);







% Pattern sigcnt_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.report.sigcounts = @(balanced, sstype, quartile, splitID, trackID) sprintf('sigcnt_%1$s_sst%2$d_%3$s_%4$s_%5$s', balanced, sstype, quartile, splitID, trackID);


% Pattern sigcnt_<balanced>_sst<sstype>_<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.figure.me = @(balanced, sstype, quartile, splitID, trackID) sprintf('me_%1$s_sst%2$d_%3$s_%4$s_%5$s', balanced, sstype, quartile, splitID, trackID);



% Pattern shard_stats_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.stats.shard =  @(splitID, trackID) sprintf('%1$s_%2$s_%3$s_%4$s', 'shard', 'stats', splitID, trackID);


% Pattern detailed_shard_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.rep.shard =  @(splitID, trackID) sprintf('%1$s_%2$s_%3$s_%4$s', 'detailed', 'shard', splitID, trackID);

% Pattern <rqID>_detailed_anova_<balanced>_sst<sstype>_q<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.rep.anova.detailed =  @(rqID, balanced, sstype, quartile, splitID, trackID) sprintf('%1$s_%2$s_%3$s_sst%4$d_q%5$d_%6$s_%7$s', rqID, 'detailed_anova', balanced, sstype, quartile, splitID, trackID);

% Pattern <rqID>_summary_anova_<balanced>_sst<sstype>_q<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.rep.anova.summary =  @(rqID, balanced, sstype, quartile, splitID, trackID) sprintf('%1$s_%2$s_%3$s_sst%4$d_q%5$d_%6$s_%7$s', rqID, 'summary_anova', balanced, sstype, quartile, splitID, trackID);

% Pattern <rqID>_overall_anova_<balanced>_sst<sstype>_q<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.rep.anova.overall =  @(rqID, balanced, sstype, quartile, splitID, trackID) sprintf('%1$s_%2$s_%3$s_sst%4$d_q%5$d_%6$s_%7$s', rqID, 'overall_anova', balanced, sstype, quartile, splitID, trackID);

% Pattern <rqID>_overall_anova_<balanced>_sst<sstype>_q<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.rep.anova.counts =  @(rqID, balanced, sstype, quartile, splitID, trackID) sprintf('%1$s_%2$s_%3$s_sst%4$d_q%5$d_%6$s_%7$s', rqID, 'counts_anova', balanced, sstype, quartile, splitID, trackID);


% Pattern <rqID>_detailed_tukey_<balanced>_sst<sstype>_q<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.rep.tukey.detailed =  @(rqID, balanced, sstype, quartile, splitID, trackID) sprintf('%1$s_%2$s_%3$s_sst%4$d_q%5$d_%6$s_%7$s', rqID, 'detailed_tukey', balanced, sstype, quartile, splitID, trackID);

% Pattern <rqID>_summary_tukey_<balanced>_sst<sstype>_q<quartile>_<splitID>_<trackID>
EXPERIMENT.pattern.identifier.rep.tukey.summary =  @(rqID, balanced, sstype, quartile, splitID, trackID) sprintf('%1$s_%2$s_%3$s_sst%4$d_q%5$d_%6$s_%7$s', rqID, 'summary_tukey', balanced, sstype, quartile, splitID, trackID);


%% Configuration for measures
measures;


%% Configuration for analyses

% The significance level for the analyses
EXPERIMENT.analysis.alpha.threshold = 0.05;
EXPERIMENT.analysis.alpha.color = 'lightgrey';

EXPERIMENT.analysis.smallEffect.threshold = 0.06;
EXPERIMENT.analysis.smallEffect.color = 'verylightblue';

EXPERIMENT.analysis.mediumEffect.threshold = 0.14;
EXPERIMENT.analysis.mediumEffect.color = 'lightblue';

EXPERIMENT.analysis.largeEffect.color = 'blue';

EXPERIMENT.analysis.label.subject = 'Topic';
EXPERIMENT.analysis.color.subject = rgb('FireBrick');

EXPERIMENT.analysis.label.factorA = 'System';
EXPERIMENT.analysis.color.factorA = rgb('RoyalBlue');

EXPERIMENT.analysis.label.factorB = 'Shard';
EXPERIMENT.analysis.color.factorB = rgb('ForestGreen');

% The list of the possible balancing types
% - if |unb| it will use an unbalanced design where missing values
%   are denoted by |NaN|;
% - if |zero|, it will force a balanced design by substituting
%   |NaN| values with zeros;
% - if |one|, it will force a balanced design by substituting |NaN| values
%   with ones;
% - if |med|, it will force a balanced design by substituting |NaN| values
%   with the median value (ignoring |NaN|s) across all topics and systems;
% - if |mean|, it will force a balanced design by substituting  |NaN|
%   values with the mean value (ignoring |NaN|s) across all topics and
%   systems;
% - if |lq|, it will force a balanced design by substituting |NaN| values
%   with the lower quartile value (ignoring |NaN|s) across all topics and
%   systems;
% - if |uq|, it will force a balanced design by substituting |NaN| values
%   with the upper quartile value (ignoring |NaN|s) across all topics and
%   systems;
% - if |top|, keep only the topics with at least one relevant document for
% each shard;
% - if |b|, assume an already balanced design;
EXPERIMENT.analysis.balanced.list = {'unb', 'zero', 'one', 'mean', 'med', 'lq', 'uq', 'top', 'b'};

EXPERIMENT.analysis.balanced.unb.id = 'unb';
EXPERIMENT.analysis.balanced.unb.description  = 'Unbalanced design where missing values are denoted by NaN';
EXPERIMENT.analysis.balanced.unb.color = rgb('DarkSalmon');

EXPERIMENT.analysis.balanced.zero.id = 'zero';
EXPERIMENT.analysis.balanced.zero.description  = 'Balanced design where missing values are forced to zero';
EXPERIMENT.analysis.balanced.zero.color = rgb('FireBrick');

EXPERIMENT.analysis.balanced.one.id = 'one';
EXPERIMENT.analysis.balanced.one.description  = 'Balanced design where missing values are forced to one';
EXPERIMENT.analysis.balanced.one.color = rgb('Violet');

EXPERIMENT.analysis.balanced.mean.id = 'mean';
EXPERIMENT.analysis.balanced.mean.description  = 'Balanced design where missing values are forced to the mean value';
EXPERIMENT.analysis.balancedmeanone.color = rgb('Goldenrod');

EXPERIMENT.analysis.balanced.med.id = 'med';
EXPERIMENT.analysis.balanced.med.description  = 'Balanced design where missing values are forced to the median value';
EXPERIMENT.analysis.balanced.med.color = rgb('RoyalBlue');

EXPERIMENT.analysis.balanced.lq.id = 'lq';
EXPERIMENT.analysis.balanced.lq.description  = 'Balanced design where missing values are forced to the lower quartile value';
EXPERIMENT.analysis.balanced.lq.color = rgb('Orange');

EXPERIMENT.analysis.balanced.uq.id = 'uq';
EXPERIMENT.analysis.balanced.uq.description  = 'Balanced design where missing values are forced to the upper quartile value';
EXPERIMENT.analysis.balanced.uq.color = rgb('ForestGreen');

% The possible quartiles used in the experiments
EXPERIMENT.analysis.quartile.list = {'q1', 'q2', 'q3', 'q4'};
EXPERIMENT.analysis.quartile.q1.id = 'q1';
EXPERIMENT.analysis.quartile.q1.description  = 'Systems up to first quartile (top 25\%) of performance';

EXPERIMENT.analysis.quartile.q2.id = 'q2';
EXPERIMENT.analysis.quartile.q2.description  = 'Systems up to second quartile (top 50\%)/median of performance';

EXPERIMENT.analysis.quartile.q3.id = 'q3';
EXPERIMENT.analysis.quartile.q3.description  = 'Systems up to third quartile (top 75\%) of performance';

EXPERIMENT.analysis.quartile.q4.id = 'q4';
EXPERIMENT.analysis.quartile.q4.description  = 'All systems used';


anova_models;