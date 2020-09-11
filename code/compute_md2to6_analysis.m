%% compute_md2to6_analysis
%
% Computes the different types of ANOVA analyses accounting for shard
% factors.

%% Synopsis
%
%   [] = compute_md2to6_analysis(trackID, splitID, balanced, sstype, quartile, startMeasure, endMeasure, startSample, endSample, threads)
%
% *Parameters*
%
% * *|trackID|* - the identifier of the track for which the processing is
% performed.
% * *|splitID|* - the identifier of the split to process.
% * *|balanced|* - the type of design to enforce. if |unb| it
% will use an unbalanced design where missing values are denoted by |NaN|;
% if |zero|, it will force a balanced design by substituting |NaN| values
% with zeros; if |med|, it will force a balanced design by substituting
% |NaN| values with the median value (ignoring |NaN|s) across all topics
% and systems; if |mean|, it will force a balanced design by substituting
% |NaN| values with the mean value (ignoring |NaN|s) across all topics
% and systems; if |lq|, it will force a balanced design by substituting
% |NaN| values with the lower quartile value (ignoring |NaN|s) across all
% topics and systems; if |uq|, it will force a balanced design by
% substituting |NaN| values with the upper quartile value (ignoring |NaN|s)
% across all topics and systems; % if |one|, it will force a balanced
% design by substituting |NaN| values with zeros;
% * *|sstype|* - the type of sum of squares in ANOVA. Use 3 for a typical
% balanced design.
% * *|quartile|* - the quartile of systems to be analysed. Use q1 for top
% quartile; q2 for median; q3 for up to third quartile; q4 for all systems.
% * *|startMeasure|* - the index of the start measure to analyse. Optional.
% * *|endMeasure|* - the index of the end measure to analyse. Optional.
% * *|startSample|* - the index of the start sample to process. Optional.
% * *|endSample|* - the index of the end sample to process. Optional.
% * *|threads|* - the maximum number of threads to be used. Optional.
%
% *Returns*
%
% Nothing.

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

%%

function [] = compute_md2to6_analysis(TAG, trackID, splitID, balanced, sstype, quartile, startMeasure, endMeasure, startSample, endSample, threads)

    % check the number of input parameters
    narginchk(6, 11);

    % load common parameters
    common_parameters

    % check that trackID is a non-empty string
    validateattributes(trackID, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'trackID');

    if iscell(trackID)
        % check that trackID is a cell array of strings with one element
        assert(iscellstr(trackID) && numel(trackID) == 1, ...
            'MATTERS:IllegalArgument', 'Expected trackID to be a cell array of strings containing just one string.');
    end

    % remove useless white spaces, if any, and ensure it is a char row
    trackID = char(strtrim(trackID));
    trackID = trackID(:).';

    % check that trackID assumes a valid value
    validatestring(trackID, ...
        EXPERIMENT.track.list, '', 'trackID');

    % check that splitID is a non-empty cell array
    validateattributes(splitID, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'splitID');

    if iscell(splitID)
        % check that splitID is a cell array of strings with one element
        assert(iscellstr(splitID) && numel(splitID) == 1, ...
            'MATTERS:IllegalArgument', 'Expected splitID to be a cell array of strings containing just one string.');
    end

    % remove useless white spaces, if any, and ensure it is a char row
    splitID = char(strtrim(splitID));
    splitID = splitID(:).';

    % check that splitID assumes a valid value
    validatestring(splitID, ...
        EXPERIMENT.split.list, '', 'splitID');

    % check that the track and the split rely on the same corpus
    assert(strcmp(EXPERIMENT.track.(trackID).corpus, EXPERIMENT.split.(splitID).corpus), 'Track %s and split %s do not rely on the same corpus', trackID, splitID);

    % check that balanced is a non-empty cell array
    validateattributes(balanced, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'balanced');

    if iscell(balanced)
        % check that balanced is a cell array of strings with one element
        assert(iscellstr(balanced) && numel(balanced) == 1, ...
            'MATTERS:IllegalArgument', 'Expected balanced to be a cell array of strings containing just one string.');
    end

    % remove useless white spaces, if any, and ensure it is a char row
    balanced = char(strtrim(balanced));
    balanced = balanced(:).';

    % check that balanced assumes a valid value
    validatestring(balanced, ...
        EXPERIMENT.analysis.balanced.list, '', 'balanced');

    % check that sstype is an integer with possible values 1, 2, 3. See
    % anovan for more details.
    validateattributes(sstype, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', 1, '<=', 3}, '', 'sstype');

    % check that quartile is a non-empty cell array
    validateattributes(quartile, {'char', 'cell'}, {'nonempty', 'vector'}, '', 'quartile');

    if iscell(quartile)
        % check that quartile is a cell array of strings with one element
        assert(iscellstr(quartile) && numel(quartile) == 1, ...
            'MATTERS:IllegalArgument', 'Expected quartile to be a cell array of strings containing just one string.');
    end

    % remove useless white spaces, if any, and ensure it is a char row
    quartile = char(strtrim(quartile));
    quartile = quartile(:).';

    % check that quartile assumes a valid value
    validatestring(quartile, ...
        EXPERIMENT.analysis.quartile.list, '', 'quartile');


    if nargin >= 7
        validateattributes(startMeasure, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', 1, '<=', EXPERIMENT.measure.number }, '', 'startMeasure');

        validateattributes(endMeasure, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', startMeasure, '<=', EXPERIMENT.measure.number }, '', 'endMeasure');
    else
        startMeasure = 1;
        endMeasure = EXPERIMENT.measure.number;
    end

    if nargin >= 9
        validateattributes(startSample, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', 1, '<=', EXPERIMENT.split.sample }, '', 'startSample');

        validateattributes(endSample, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', startSample, '<=', EXPERIMENT.split.sample }, '', 'endSample');
    else
        startSample = 1;
        endSample = EXPERIMENT.split.sample;
    end


    if nargin == 10
        % the number of threads must be at maximum equal to the number of
        % physical cores
        validateattributes(threads, {'numeric'}, ...
            {'nonempty', 'integer', 'scalar', '>=', 1, '<=', feature('numcores') }, '', 'threads');

        maxNumCompThreads(threads);
    else
        threads = maxNumCompThreads('automatic');
    end

    % start of overall computations
    startComputation = tic;

    fprintf('\n\n######## Performing md2 to md6 ANOVA analyses on track %s (%s) ########\n\n', ...
        EXPERIMENT.track.(trackID).name, EXPERIMENT.label.paper);

    fprintf('+ Settings\n');
    fprintf('  - computed on %s\n', datestr(now, 'yyyy-mm-dd at HH:MM:SS'));
    fprintf('  - analysis type:\n');
    fprintf('    * balanced: %s\n', balanced);
    fprintf('    * sstype: %d\n', sstype);
    fprintf('    * quartile: %s - %s \n', quartile, EXPERIMENT.analysis.quartile.(quartile).description);
    fprintf('    * significance level alpha: %3.2f\n', EXPERIMENT.analysis.alpha.threshold);
    fprintf('  - track: %s\n', trackID);
    fprintf('  - split: %s\n', splitID);
    fprintf('    * shard(s): %d\n', EXPERIMENT.split.(splitID).shard);
    fprintf('    * start sample: %d\n', startSample);
    fprintf('    * end sample: %d\n', endSample);
    fprintf('  - measures:\n');
    fprintf('    * start measure: %d (%s)\n', startMeasure, EXPERIMENT.measure.getAcronym(startMeasure));
    fprintf('    * end measure: %d (%s)\n', endMeasure, EXPERIMENT.measure.getAcronym(endMeasure));
    fprintf('  - threads: %d\n\n', threads);

    % for each measure
    for m = startMeasure:endMeasure

        fprintf('\n+ Analysing %s\n', EXPERIMENT.measure.getAcronym(m));

        fprintf('    * loading corpus data\n');

        mid = EXPERIMENT.measure.list{m};

        %{

        % load the whole corpus measure. The goal is to select the same Qx
        % systems used in rq1_analysis
        measureID = EXPERIMENT.pattern.identifier.measure(mid, EXPERIMENT.split.(splitID).corpus, trackID);

        serload2(EXPERIMENT.pattern.file.measure.corpus(trackID, measureID), ...
            'WorkspaceVarNames', {'measure'}, ...
            'FileVarNames', {measureID});

        % determine the indexes of the systems in the requested quartile of
        % the measure with respect to the whole corpus as well as the mean
        % of the measure on the selected quartile for the whole corpus
        [idx, mm] = compute_quartile(quartile, measure);

        clear measure;
        %}

        % repeat the computation for each sample
        for smpl = startSample:endSample

            fprintf('  - sample %d\n', smpl);

            fprintf('    * loading shard data\n');

            measures = cell(1, EXPERIMENT.split.(splitID).shard);

            % for each shard, load the shard measures
            for shr = 1:EXPERIMENT.split.(splitID).shard

                shardID = EXPERIMENT.pattern.identifier.shard(splitID, shr, smpl);

                measureID = EXPERIMENT.pattern.identifier.measure(mid, shardID, trackID);

                serload2(EXPERIMENT.pattern.file.measure.shard(trackID, splitID, measureID), ...
                    'WorkspaceVarNames', {'measure'}, ...
                    'FileVarNames', {measureID});

                measures{shr} = measure;

                clear tmp measure;

            end % for shard

            fprintf('    * preparing the data for the ANOVA analysis\n');

            % compute the needed balancing value, balance the measures, and
            % order systems as on the whole corpus
            [blc, measures] = compute_balancing(splitID, measures, balanced, 1:length(measures{1}.Properties.VariableNames));
            fprintf('      # balanced %s with value %3.2f\n', blc.type, blc.value);

            % layout the data for the ANOVA
            [N, R, T, S, data, subject, factorA, factorB] = layout_anova_data(splitID, measures);

            clear measures;

       

            fprintf('    * performing the %s ANOVA analysis\n', TAG);
            start = tic;

            fprintf('      # fitting the ANOVA model\n');

            [~, tbl, sts] = EXPERIMENT.analysis.(TAG).compute(data, subject, ...
                factorA, factorB, sstype);


            %{
            anovaBlcID = EXPERIMENT.pattern.identifier.anova.blc(TAG{md}, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);
            anovaSoAID = EXPERIMENT.pattern.identifier.anova.soa(TAG{md}, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);
            anovaMcID = EXPERIMENT.pattern.identifier.anova.mc(TAG{md}, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);

            df_subject = tbl{2, 3};
            ss_subject = tbl{2, 2};
            F_subject = tbl{2, 6};

            df_factorA = tbl{3, 3};
            ss_factorA = tbl{3, 2};
            F_factorA = tbl{3, 6};

            if (strcmpi(TAG{md}, MD3) || strcmpi(TAG{md}, MD4) || ...
                    strcmpi(TAG{md}, MD5) || strcmpi(TAG{md}, MD6))
                df_subject_factorA = tbl{4, 3};
                ss_subject_factorA = tbl{4, 2};
                F_subject_factorA = tbl{4, 6};
            end

            if (strcmpi(TAG{md}, MD4) || strcmpi(TAG{md}, MD5) || ...
                    strcmpi(TAG{md}, MD6))
                df_factorB = tbl{5, 3};
                ss_factorB = tbl{5, 2};
                F_factorB = tbl{5, 6};
            end

            if (strcmpi(TAG{md}, MD5) || strcmpi(TAG{md}, MD6))
                df_factorA_factorB = tbl{6, 3};
                ss_factorA_factorB = tbl{6, 2};
                F_factorA_factorB = tbl{6, 6};

            end

            if (strcmpi(TAG{md}, MD6))
                df_subject_factorB = tbl{7, 3};
                ss_subject_factorB = tbl{7, 2};
                F_subject_factorB = tbl{7, 6};
            end

            switch TAG{md}
                case MD2
                    df_error = tbl{4, 3};
                    ss_error = tbl{4, 2};
                    ms_error = tbl{4, 5};
                case MD3
                    df_error = tbl{5, 3};
                    ss_error = tbl{5, 2};
                    ms_error = tbl{5, 5};
                case MD4
                    df_error = tbl{6, 3};
                    ss_error = tbl{6, 2};
                    ms_error = tbl{6, 5};
                case MD5
                    df_error = tbl{7, 3};
                    ss_error = tbl{7, 2};
                    ms_error = tbl{7, 5};
                case MD6
                    df_error = tbl{8, 3};
                    ss_error = tbl{8, 2};
                    ms_error = tbl{8, 5};
            end


            % compute the strength of association and the power
            soa.omega2p.subject = df_subject * (F_subject - 1) / (df_subject * (F_subject - 1) + N);
            soa.omega2p.factorA = df_factorA * (F_factorA - 1) / (df_factorA * (F_factorA - 1) + N);

            soa.eta2p.subject = ss_subject / (ss_subject + ss_error);
            soa.eta2p.factorA = ss_factorA / (ss_factorA + ss_error);

            soa.f2.subject = ss_subject / ss_error;
            soa.f2.factorA = ss_factorA / ss_error;


            anovaPwrID = EXPERIMENT.pattern.identifier.anova.pwr(TAG{md}, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);

            pwr.subject.Fc = finv(1 - EXPERIMENT.analysis.alpha.threshold, df_subject, df_error);
            pwr.subject.lambda = soa.f2.subject * N;
            pwr.subject.power = ncfcdf(pwr.subject.Fc, df_subject, df_error, pwr.subject.lambda, 'upper');

            pwr.factorA.Fc = finv(1 - EXPERIMENT.analysis.alpha.threshold, df_factorA, df_error);
            pwr.factorA.lambda = soa.f2.factorA * N;
            pwr.factorA.power = ncfcdf(pwr.factorA.Fc, df_factorA, df_error, pwr.factorA.lambda, 'upper');


            if (strcmpi(TAG{md}, MD3) || strcmpi(TAG{md}, MD4) || ...
                    strcmpi(TAG{md}, MD5) || strcmpi(TAG{md}, MD6))
                soa.omega2p.subject_factorA = df_subject_factorA * (F_subject_factorA - 1) / (df_subject_factorA * (F_subject_factorA - 1) + N);

                soa.eta2p.subject_factorA = ss_subject_factorA / (ss_subject_factorA + ss_error);

                soa.f2.subject_factorA = ss_subject_factorA / ss_error;

                pwr.subject_factorA.Fc = finv(1 - EXPERIMENT.analysis.alpha.threshold, df_subject_factorA, df_error);
                pwr.subject_factorA.lambda = soa.f2.subject_factorA * N;
                pwr.subject_factorA.power = ncfcdf(pwr.subject_factorA.Fc, df_subject_factorA, df_error, pwr.subject_factorA.lambda, 'upper');
            end

            if (strcmpi(TAG{md}, MD4) || strcmpi(TAG{md}, MD5) || ...
                    strcmpi(TAG{md}, MD6))
                soa.omega2p.factorB =  df_factorB * (F_factorB - 1) / (df_factorB * (F_factorB - 1) + N);

                soa.eta2p.factorB = ss_factorB / (ss_factorB + ss_error);

                soa.f2.factorB = ss_factorB / ss_error;

                pwr.factorB.Fc = finv(1 - EXPERIMENT.analysis.alpha.threshold, df_factorB, df_error);
                pwr.factorB.lambda = soa.f2.factorB * N;
                pwr.factorB.power = ncfcdf(pwr.factorB.Fc, df_factorB, df_error, pwr.factorB.lambda, 'upper');
            end

            if (strcmpi(TAG{md}, MD5) || strcmpi(TAG{md}, MD6))
                soa.omega2p.factorA_factorB = df_factorA_factorB * (F_factorA_factorB - 1) / (df_factorA_factorB * (F_factorA_factorB - 1) + N);

                soa.eta2p.factorA_factorB = ss_factorA_factorB / (ss_factorA_factorB + ss_error);

                soa.f2.factorA_factorB = ss_factorA_factorB / ss_error;

                pwr.factorA_factorB.Fc = finv(1 - EXPERIMENT.analysis.alpha.threshold, df_factorA_factorB, df_error);
                pwr.factorA_factorB.lambda = soa.f2.factorA_factorB * N;
                pwr.factorA_factorB.power = ncfcdf(pwr.factorA_factorB.Fc, df_factorA_factorB, df_error, pwr.factorA_factorB.lambda, 'upper');
            end

            if (strcmpi(TAG{md}, MD6))
                soa.omega2p.subject_factorB = df_subject_factorB * (F_subject_factorB - 1) / (df_subject_factorB * (F_subject_factorB - 1) + N);

                soa.eta2p.subject_factorB = ss_subject_factorB / (ss_subject_factorB + ss_error);

                soa.f2.subject_factorB = ss_subject_factorB / ss_error;

                pwr.subject_factorB.Fc = finv(1 - EXPERIMENT.analysis.alpha.threshold, df_subject_factorB, df_error);
                pwr.subject_factorB.lambda = soa.f2.subject_factorB * N;
                pwr.subject_factorB.power = ncfcdf(pwr.subject_factorB.Fc, df_subject_factorB, df_error, pwr.subject_factorB.lambda, 'upper');
            end

            anovaMeID = EXPERIMENT.pattern.identifier.anova.me(TAG{md}, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);


            % main effects
            me.factorA.label = unique(factorA, 'stable');
            [me.factorA.mean, me.factorA.std] = grpstats(data(:), factorA(:), {'mean', 'std'});
            me.factorA.tau = EXPERIMENT.analysis.corr(mm, me.factorA.mean);

            % compute the Student's t CI
            me.factorA.student.t = tinv(1 - EXPERIMENT.analysis.alpha.threshold/2, T*S - 1);
            me.factorA.student.halfWidth = me.factorA.student.t .* me.factorA.std / sqrt(T*S);
            me.factorA.student.ci = [me.factorA.mean - me.factorA.student.halfWidth, me.factorA.mean + me.factorA.student.halfWidth];

            % compute the ANOVA CI
            me.factorA.anova.t = tinv(1 - EXPERIMENT.analysis.alpha.threshold/2, df_error);
            me.factorA.anova.halfWidth = me.factorA.student.t .* sqrt(ms_error / (T*S) );
            me.factorA.anova.ci = [me.factorA.mean - me.factorA.anova.halfWidth, me.factorA.mean + me.factorA.anova.halfWidth];

            % compute the Tukey CI
            me.factorA.tukey.q = internal.stats.stdrinv(1 - EXPERIMENT.analysis.alpha.threshold, df_error, R);
            me.factorA.tukey.halfWidth = me.factorA.tukey.q * sqrt(ms_error/(T*S)) / 2;
            me.factorA.tukey.ci = [me.factorA.mean - me.factorA.tukey.halfWidth, me.factorA.mean + me.factorA.tukey.halfWidth];

            fprintf('      # performing the multiple comparisons\n');

            % comparing systems
            mc = EXPERIMENT.analysis.multcompare.system(sts);

            % compute the top group
            me.factorA.tg = compute_mc_topgroup(mc, me);
            %}

            fprintf('      # saving the analyses\n');

            anovaID = EXPERIMENT.pattern.identifier.anova.analysis(TAG, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);
            anovaTableID = EXPERIMENT.pattern.identifier.anova.tbl(TAG, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);
            anovaStsID = EXPERIMENT.pattern.identifier.anova.sts(TAG, balanced, sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID);

            disp(tbl)

            sersave2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, anovaID), ...
                'WorkspaceVarNames', {'tbl', 'sts'}, ...
                'FileVarNames', {anovaTableID, anovaStsID});

            fprintf('      # elapsed time: %s\n', elapsedToHourMinutesSeconds(toc(start)));



            clear data blc

        end % for each sample

        clear idx mm

    end % measure

    fprintf('\n\n######## Total elapsed time for performing %s to md6 ANOVA analyses on track %s : %s ########\n\n', ...
           TAG, EXPERIMENT.track.(trackID).name,  elapsedToHourMinutesSeconds(toc(startComputation)));
end
