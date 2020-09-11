function [] = import_collection(trackID)

    % set up the common parameters
    common_parameters;

    % disable warnings, not needed for bulk import
    warning('off');

    % start of overall import
    startImport = tic;

    fprintf('\n\n######## Importing collection %s ########\n\n', ...
        EXPERIMENT.track.(trackID).name);

    fprintf('+ Settings\n');
    fprintf('  - imported on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - pool %s\n', EXPERIMENT.track.(trackID).pool.file);
    fprintf('  - runs %s\n\n', EXPERIMENT.track.(trackID).run.path);

    % import the pool
    start = tic;

    fprintf('+ Importing the pool\n');

    % creating local input parameters for import
    fileName = EXPERIMENT.track.(trackID).pool.file;
    poolID = EXPERIMENT.pattern.identifier.pool(EXPERIMENT.track.(trackID).corpus, trackID);

    pool = EXPERIMENT.track.(trackID).pool.import(fileName, poolID);

    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
    fprintf('  - total number of topics: %d (expected topics %d)\n\n',...
        height(pool), EXPERIMENT.track.(trackID).topics);

    % the list of required topics
    requiredTopics = pool.Properties.RowNames;

    fprintf('+ Importing the run(s)\n');

    % creating local input parameters for import
    runID = EXPERIMENT.pattern.identifier.run( ...
        EXPERIMENT.track.(trackID).corpus, trackID);

    runSet = EXPERIMENT.track.(trackID).run.import( ...
        EXPERIMENT.track.(trackID).run.path, runID, requiredTopics);

    fprintf('  - elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));
    fprintf('  - total number of run(s): %d (expected runs %d)\n\n', ...
        width(runSet), EXPERIMENT.track.(trackID).runs);


    fprintf('+ Saving the data set\n');

    start = tic;

    sersave2(EXPERIMENT.pattern.file.dataset.corpus(trackID, poolID), ...
                'WorkspaceVarNames', {'pool'}, ...
                'FileVarNames', {poolID});

    sersave2(EXPERIMENT.pattern.file.dataset.corpus(trackID, runID), ...
                'WorkspaceVarNames', {'runSet'}, ...
                'FileVarNames', {runID});


    fprintf('  - elapsed time: %s\n\n', elapsedToHourMinutesSeconds(toc(start)));


    fprintf('\n\n######## Total elapsed time for importing collection %s: %s ########\n\n', ...
        EXPERIMENT.track.(trackID).name, elapsedToHourMinutesSeconds(toc(startImport)));

    % enable warnings
    warning('on');

end
