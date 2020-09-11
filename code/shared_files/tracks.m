
%% Configuration for Tracks
EXPERIMENT.track.list = {'T03', 'T08'};
EXPERIMENT.track.number = length(EXPERIMENT.track.list);


% TREC 03, 1994, Adhoc
EXPERIMENT.track.T03.id = 'T03';
EXPERIMENT.track.T03.name = 'TREC 03, 1994, Adhoc';
EXPERIMENT.track.T03.corpus = 'TIP12';
EXPERIMENT.track.T03.topics = 50;
EXPERIMENT.track.T03.runs = 40;
EXPERIMENT.track.T03.runLength = 1000;
EXPERIMENT.track.T03.pool.name = 'qrels.151-200.disk1-3.txt';
EXPERIMENT.track.T03.pool.file = sprintf('%1$s%2$s%3$s%4$s', EXPERIMENT.path.pool, 'T03', filesep, EXPERIMENT.track.T03.pool.name);
EXPERIMENT.track.T03.pool.relevanceDegrees = {'NotRelevant', 'Relevant'};
EXPERIMENT.track.T03.pool.relevanceGrades = 0:1;
EXPERIMENT.track.T03.pool.delimiter = 'space';
EXPERIMENT.track.T03.pool.import = @(fileName, id) importPoolFromFileTRECFormat('FileName', fileName, 'Identifier', id, 'RelevanceDegrees', EXPERIMENT.track.T03.pool.relevanceDegrees, 'RelevanceGrades', EXPERIMENT.track.T03.pool.relevanceGrades, 'Delimiter', EXPERIMENT.track.T03.pool.delimiter,  'Verbose', false);
EXPERIMENT.track.T03.run.path = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.run, 'T03');
EXPERIMENT.track.T03.run.documentOrdering = 'TrecEvalLexDesc';
EXPERIMENT.track.T03.run.singlePrecision = true;
EXPERIMENT.track.T03.run.delimiter = 'space';
EXPERIMENT.track.T03.run.import = @(runPath, id, requiredTopics) importRunsFromDirectoryTRECFormat('Path', runPath, 'Identifier', id, 'RequiredTopics', requiredTopics, 'DocumentOrdering', EXPERIMENT.track.T03.run.documentOrdering, 'SinglePrecision', EXPERIMENT.track.T03.run.singlePrecision, 'Delimiter', EXPERIMENT.track.T03.run.delimiter, 'Verbose', false);




% TREC 08, 1999, Adhoc
EXPERIMENT.track.T08.id = 'T08';
EXPERIMENT.track.T08.name = 'TREC 08, 1999, Adhoc';
EXPERIMENT.track.T08.corpus = 'TIP';
EXPERIMENT.track.T08.topics = 50;
EXPERIMENT.track.T08.runs = 129;
EXPERIMENT.track.T08.runLength = 1000;
EXPERIMENT.track.T08.pool.name = 'qrels.trec8.adhoc.txt';
EXPERIMENT.track.T08.pool.file = sprintf('%1$s%2$s%3$s%4$s', EXPERIMENT.path.pool, 'T08', filesep, EXPERIMENT.track.T08.pool.name);
EXPERIMENT.track.T08.pool.relevanceDegrees = {'NotRelevant', 'Relevant'};
EXPERIMENT.track.T08.pool.relevanceGrades = 0:1;
EXPERIMENT.track.T08.pool.delimiter = 'space';
EXPERIMENT.track.T08.pool.import = @(fileName, id) importPoolFromFileTRECFormat('FileName', fileName, 'Identifier', id, 'RelevanceDegrees', EXPERIMENT.track.T08.pool.relevanceDegrees, 'RelevanceGrades', EXPERIMENT.track.T08.pool.relevanceGrades, 'Delimiter', EXPERIMENT.track.T08.pool.delimiter,  'Verbose', false);
EXPERIMENT.track.T08.run.path = sprintf('%1$s%2$s%3$s', EXPERIMENT.path.run, 'T08');
EXPERIMENT.track.T08.run.documentOrdering = 'TrecEvalLexDesc';
EXPERIMENT.track.T08.run.singlePrecision = true;
EXPERIMENT.track.T08.run.delimiter = 'tab';
EXPERIMENT.track.T08.run.import = @(runPath, id, requiredTopics) importRunsFromDirectoryTRECFormat('Path', runPath, 'Identifier', id, 'RequiredTopics', requiredTopics, 'DocumentOrdering', EXPERIMENT.track.T08.run.documentOrdering, 'SinglePrecision', EXPERIMENT.track.T08.run.singlePrecision, 'Delimiter', EXPERIMENT.track.T08.run.delimiter, 'Verbose', false);






% Returns the name of a track given its index in EXPERIMENT.track.list
EXPERIMENT.track.getName = @(idx) ( EXPERIMENT.track.(EXPERIMENT.track.list{idx}).name );
