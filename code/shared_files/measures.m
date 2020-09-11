%% Configuration for measures

% The list of measures under experimentation
EXPERIMENT.measure.list = {'ap', 'p10', 'rbp', 'ndcg'};
EXPERIMENT.measure.number = length(EXPERIMENT.measure.list);

% Configuration for AP
EXPERIMENT.measure.ap.id = 'ap';
EXPERIMENT.measure.ap.acronym = 'AP';
EXPERIMENT.measure.ap.name = 'Average Precision';
EXPERIMENT.measure.ap.compute = @(pool, runSet, runLength) averagePrecision(pool, runSet);

% Configuration for P@10
EXPERIMENT.measure.p10.id = 'p10';
EXPERIMENT.measure.p10.acronym = 'P@10';
EXPERIMENT.measure.p10.name = 'Precision at 10 Retrieved Documents';
EXPERIMENT.measure.p10.cutoffs = 10;
EXPERIMENT.measure.p10.compute = @(pool, runSet, runLength) precision(pool, runSet, 'Cutoffs', EXPERIMENT.measure.p10.cutoffs);

% Configuration for RBP
EXPERIMENT.measure.rbp.id = 'rbp';
EXPERIMENT.measure.rbp.acronym = 'RBP';
EXPERIMENT.measure.rbp.name = 'Rank-biased Precision';
EXPERIMENT.measure.rbp.persistence = 0.8;
EXPERIMENT.measure.rbp.compute = @(pool, runSet, runLength) rankBiasedPrecision(pool, runSet, 'Persistence', EXPERIMENT.measure.rbp.persistence);

% Configuration for nDCG
EXPERIMENT.measure.ndcg.id = 'ndcg';
EXPERIMENT.measure.ndcg.acronym = 'nDCG';
EXPERIMENT.measure.ndcg.name = 'Normalized Discounted Cumulated Gain at Last Retrieved Document';
EXPERIMENT.measure.ndcg.cutoffs = 'LastRelevantRetrieved';
EXPERIMENT.measure.ndcg.logBase = 10;
EXPERIMENT.measure.ndcg.fixedNumberRetrievedDocumentsPaddingStrategy = 'NotRelevant';
EXPERIMENT.measure.ndcg.compute = @(pool, runSet, runLength) discountedCumulatedGain(pool, runSet, 'CutOffs', EXPERIMENT.measure.ndcg.cutoffs, 'LogBase', EXPERIMENT.measure.ndcg.logBase, 'Normalize', true, 'FixNumberRetrievedDocuments', runLength, 'FixedNumberRetrievedDocumentsPaddingStrategy', EXPERIMENT.measure.ndcg.fixedNumberRetrievedDocumentsPaddingStrategy);

% Returns the identifier of a measure given its index in EXPERIMENT.measure.list
EXPERIMENT.measure.getID = @(idx) ( EXPERIMENT.measure.(EXPERIMENT.measure.list{idx}).id );

% Returns the acronym of a measure given its index in EXPERIMENT.measure.list
EXPERIMENT.measure.getAcronym = @(idx) ( EXPERIMENT.measure.(EXPERIMENT.measure.list{idx}).acronym );

% Returns the name of a measure given its index in EXPERIMENT.measure.list
EXPERIMENT.measure.getName = @(idx) ( EXPERIMENT.measure.(EXPERIMENT.measure.list{idx}).name );