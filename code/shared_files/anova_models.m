% The list of the possible ANOVA analyses
EXPERIMENT.analysis.list = {'md1', 'md2', 'md3', 'md4', 'md5', 'md6'};

% Topic/System Effects on Whole Corpus
EXPERIMENT.analysis.md1.id = 'md1';
EXPERIMENT.analysis.md1.name = 'Topic/System Effects on Whole Corpus';
EXPERIMENT.analysis.md1.description = 'Crossed effects GLM on whole corpus: subjects are topics; effects are systems';
EXPERIMENT.analysis.md1.glmm = '$y_{ij} = \mu_{\cdot\cdot} + \tau_i + \alpha_j + \varepsilon_{ij}$';
% the model = Topic (subject) + System (factorA)
EXPERIMENT.analysis.md1.model = [1 0; ...
                                 0 1];
EXPERIMENT.analysis.md1.compute = @(data, subject, factorA, sstype) anovan(data, {subject, factorA}, ...
        'Model', EXPERIMENT.analysis.md1.model, ...
        'VarNames', {EXPERIMENT.analysis.label.subject, EXPERIMENT.analysis.label.factorA}, ...
        'sstype', sstype, 'alpha', EXPERIMENT.analysis.alpha.threshold, 'display', 'off');


% Topic/System Effects on Shards
EXPERIMENT.analysis.md2.id = 'md2';
EXPERIMENT.analysis.md2.name = 'Topic/System Effects on Shards';
EXPERIMENT.analysis.md2.description = 'Crossed effects GLM on shards: subjects are topics; effects are systems';
EXPERIMENT.analysis.md2.glmm = '$y_{ijk} = \mu_{\cdot\cdot\cdot} + \tau_i + \alpha_j + \varepsilon_{ijk}$';
% the model = Topic (subject) + System (factorA)
EXPERIMENT.analysis.md2.model = EXPERIMENT.analysis.md1.model;
EXPERIMENT.analysis.md2.compute = @(data, subject, factorA, factorB, sstype) anovan(data, {subject, factorA}, ...
        'Model', EXPERIMENT.analysis.md2.model, ...
        'VarNames', {EXPERIMENT.analysis.label.subject, EXPERIMENT.analysis.label.factorA}, ...
        'sstype', sstype, 'alpha', EXPERIMENT.analysis.alpha.threshold, 'display', 'off');


% Topic/System Effects and Topic*System Interaction on Shards
EXPERIMENT.analysis.md3.id = 'md3';
EXPERIMENT.analysis.md3.name = 'Topic/System Effects and Topic*System Interaction on Shards';
EXPERIMENT.analysis.md3.description = 'Crossed effects GLM on shards: subjects are topics; effects are systems plus topic*system interaction';
EXPERIMENT.analysis.md3.glmm = '$y_{ijk} = \mu_{\cdot\cdot\cdot} + \tau_i + \alpha_j + (\tau\alpha)_{ij} + \varepsilon_{ijk}$';
% the model = Topic (subject) + System (factorA) + Topic*System
EXPERIMENT.analysis.md3.model = [EXPERIMENT.analysis.md2.model;
                                 1 1];
EXPERIMENT.analysis.md3.compute = @(data, subject, factorA, factorB, sstype) anovan(data, {subject, factorA}, ...
        'Model', EXPERIMENT.analysis.md3.model, ...
        'VarNames', {EXPERIMENT.analysis.label.subject, EXPERIMENT.analysis.label.factorA}, ...
        'sstype', sstype, 'alpha', EXPERIMENT.analysis.alpha.threshold, 'display', 'off');

% Topic/System/Shard Effects and Topic*System Interaction on Shards
EXPERIMENT.analysis.md4.id = 'md4';
EXPERIMENT.analysis.md4.name = 'Topic/System/Shard Effects and Topic*System Interaction on Shards';
EXPERIMENT.analysis.md4.description = 'Crossed effects GLM on shards: subjects are topics; effects are systems and shards plus topic*system interaction';
EXPERIMENT.analysis.md4.glmm = '$y_{ijk} = \mu_{\cdot\cdot\cdot} + \tau_i + \alpha_j + \beta_k + (\tau\alpha)_{ij} + \varepsilon_{ijk}$';
% the model = Topic (subject) + System (factorA) + Topic*System +
%             Shards (factorB)
EXPERIMENT.analysis.md4.model = [1 0 0; ...
                                 0 1 0; ...
                                 1 1 0; ...
                                 0 0 1];
EXPERIMENT.analysis.md4.compute = @(data, subject, factorA, factorB, sstype) anovan(data, {subject, factorA, factorB}, ...
        'Model', EXPERIMENT.analysis.md4.model, ...
        'VarNames', {EXPERIMENT.analysis.label.subject, EXPERIMENT.analysis.label.factorA, EXPERIMENT.analysis.label.factorB}, ...
        'sstype', sstype, 'alpha', EXPERIMENT.analysis.alpha.threshold, 'display', 'off');

% Topic/System/Shard Effects and Topic*System/System*Shard Interaction on Shards
EXPERIMENT.analysis.md5.id = 'md5';
EXPERIMENT.analysis.md5.name = 'Topic/System/Shard Effects and Topic*System/System*Shard Interaction on Shards';
EXPERIMENT.analysis.md5.description = 'Crossed effects GLM on shards: subjects are topics; effects are systems and shards plus topic*system and system*shard interactions';
EXPERIMENT.analysis.md5.glmm = '$t_{ijk} = \mu_{\cdot\cdot\cdot} + \tau_i + \alpha_j + \beta_k + (\tau\alpha)_{ij} + (\alpha\beta)_{jk} + \varepsilon_{ijk}$';
% the model = Topic (subject) + System (factorA) + Topic*System +
%             Shards (factorB) + System*Shard
EXPERIMENT.analysis.md5.model = [EXPERIMENT.analysis.md4.model; ...
                                 0 1 1];
EXPERIMENT.analysis.md5.compute = @(data, subject, factorA, factorB, sstype) anovan(data, {subject, factorA, factorB}, ...
        'Model', EXPERIMENT.analysis.md5.model, ...
        'VarNames', {EXPERIMENT.analysis.label.subject, EXPERIMENT.analysis.label.factorA, EXPERIMENT.analysis.label.factorB}, ...
        'sstype', sstype, 'alpha', EXPERIMENT.analysis.alpha.threshold, 'display', 'off');

% Topic/System/Shard Effects and Topic*System/System*Shard/Topic*Shard Interaction on Shards
EXPERIMENT.analysis.md6.id = 'md6';
EXPERIMENT.analysis.md6.name = 'Topic/System/Shard Effects and Topic*System/System*Shard/Topic*Shard Interactions on Shards';
EXPERIMENT.analysis.md6.description = 'Crossed effects GLM on shards: subjects are topics; effects are systems and shards plus topic*system, system*shard, and topic*shard interactions';
EXPERIMENT.analysis.md6.glmm = '$y_{ijk} = \mu_{\cdot\cdot\cdot} + \tau_i + \alpha_j + \beta_k + (\tau\alpha)_{ij} + (\alpha\beta)_{jk} + (\tau\beta)_{ik} + \varepsilon_{ijk}$';
% the model = Topic (subject) + System (factorA) + Topic*System +
%             Shards (factorB) + System*Shard + Topic*Shard
EXPERIMENT.analysis.md6.model = [EXPERIMENT.analysis.md5.model; ...
                                 1 0 1];
EXPERIMENT.analysis.md6.compute = @(data, subject, factorA, factorB, sstype) anovan(data, {subject, factorA, factorB}, ...
        'Model', EXPERIMENT.analysis.md6.model, ...
        'VarNames', {EXPERIMENT.analysis.label.subject, EXPERIMENT.analysis.label.factorA, EXPERIMENT.analysis.label.factorB}, ...
        'sstype', sstype, 'alpha', EXPERIMENT.analysis.alpha.threshold, 'display', 'off');

% Tukey HSD multiple comparison analysis for the system factor
EXPERIMENT.analysis.multcompare.system = @(sts) multcompare(sts, 'CType', 'hsd', 'Alpha', EXPERIMENT.analysis.alpha.threshold, 'dimension', [2], 'Display', 'off');

% Correlation among two rankings of systems
EXPERIMENT.analysis.corr = @(x, y) corr(x(:), y(:), 'type', 'Kendall');


