function [] = compute_bootstrap_effects(TAG, trackID, splitID, balanced, sstype, ...
                                  quartile, M, startMeasure, endMeasure, ...
                                  startSample, endSample, threads)
  common_parameters;


  fprintf('  - threads: %d\n\n', threads);
  maxNumCompThreads(threads);

  for m = startMeasure:endMeasure

    fprintf('\n+ Analysing %s\n', EXPERIMENT.measure.getAcronym(m));

    estMeasures = cell(1, EXPERIMENT.split.(splitID).shard);
    mid = EXPERIMENT.measure.list{m};


    fprintf('  - model %s\n', TAG);
    for smpl = startSample:endSample
      fprintf('    - sample %d\n', smpl);
      fprintf('      * load data\n');
      anovaID = EXPERIMENT.pattern.identifier.anova.analysis(TAG, balanced, ...
                          sstype, quartile, mid,...
                          EXPERIMENT.pattern.identifier.split(splitID, smpl), ...
                          trackID);

      anovaTableID = EXPERIMENT.pattern.identifier.anova.tbl(TAG, balanced, ...
                          sstype, quartile, mid, ...
                          EXPERIMENT.pattern.identifier.split(splitID, smpl), ...
                          trackID);

      anovaStsID = EXPERIMENT.pattern.identifier.anova.sts(TAG, balanced,...
                          sstype, quartile, mid, ...
                          EXPERIMENT.pattern.identifier.split(splitID, smpl),...
                          trackID);


      serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, anovaID), ...
          'WorkspaceVarNames', {'tbl', 'sts'}, ...
          'FileVarNames', {anovaTableID, anovaStsID});
      %fprintf('      # balanced %s with value %3.2f\n', blc.type, blc.value);
      % for each shard, load the shard measures

      measures = cell(1, EXPERIMENT.split.(splitID).shard);

      for shr = 1:EXPERIMENT.split.(splitID).shard
        shardID = EXPERIMENT.pattern.identifier.shard(splitID, shr, smpl);
        sh = strcat("Shard=shr",char(sprintf("%03d", shr)));

        measureID = EXPERIMENT.pattern.identifier.measure(mid, shardID, trackID);

        serload2(EXPERIMENT.pattern.file.measure.shard(trackID, splitID, measureID), ...
            'WorkspaceVarNames', {'measure'}, ...
            'FileVarNames', {measureID});

        %[idx, mm] = compute_quartile(quartile, measure);

        measures{shr} = measure;


        clear tmp measure;
      end

      idx = 1:size(measures{1},2);

      [blc, measures] = compute_balancing(splitID, measures, balanced, idx);

      for shr = 1:EXPERIMENT.split.(splitID).shard
        sh = strcat("Shard=shr",char(sprintf("%03d", shr)));
        fprintf('        # computing shard %d estimations\n', shr);
        measure = measures{shr};

        %compute hatY-> estimated Y using anova model
        sz = size(measure);
        estMeasures{shr} = array2table(zeros(sz), ...
                                 'VariableNames', measure.Properties.VariableNames, ...
                                 'RowNames', measure.Properties.RowNames);
        for v=1:length(measure.Properties.VariableNames)
            s =  strcat("System=",char(measure.Properties.VariableNames(v)));
            ssh = strcat(s, " * ", sh);
            for r=1:length(measure.Properties.RowNames)
              t = strcat("Topic=",char(measure.Properties.RowNames(r)));
              ts = strcat(t, " * ", s);
              tsh = strcat(t, " * ", sh);
              estMeasures{shr}{measure.Properties.RowNames{r}, ...
                               measure.Properties.VariableNames{v}} =  ...
                               compute_estimations(TAG, sts, s, t, sh, ts, tsh, ssh);

            end
        end


        %measures{shr} = measure;
        clear tmp measure;
      end % for shard



      fprintf('      * bootstrapping\n          ');
      %[~, idx] = sort(me.factorA.mean,'asc');
      %sortedSystems = me.factorA.label(idx);



      bootstrapTable = table();
      for mb=1:M
        %fprintf('\b\b\b\b\b%5d', mb);
        boot_measures = cell(1, EXPERIMENT.split.(splitID).shard);
        % for each shard, load the shard measures
        for shr = 1:EXPERIMENT.split.(splitID).shard
          [n_topics, n_systems] = size(estMeasures{shr});
          perturbation = datasample(sts.resid, n_topics*n_systems);
          perturbation = reshape(perturbation, [n_topics, n_systems]);
          vNames = estMeasures{shr}.Properties.VariableNames;
          rNames = estMeasures{shr}.Properties.RowNames;
          perturbation = array2table(perturbation, ...
                                    'VariableNames', vNames, ...
                                    'RowNames', rNames);


          %perturbate measures using anova residuals
          boot_measures{shr} = array2table(estMeasures{shr}{:,:} + perturbation{:,:}, ...
                         'VariableNames', vNames, ...
                         'RowNames', rNames);
        end
        % layout the data for the ANOVA
        [N, R, T, S, data, subject, factorA, factorB] = layout_anova_data(splitID, boot_measures);
        %compute effect sizes
        tmpLabel = unique(factorA, 'stable');
        [tmpMean, tmpStd] = grpstats(data(:), factorA(:), {'mean', 'std'});
        newRow = array2table(tmpMean.',...
                             'VariableNames', tmpLabel);
        bootstrapTable = [bootstrapTable; newRow];
      end

      %SAVE BOOTSTRAP EFFECTS

      bootsrapEffectsID = EXPERIMENT.pattern.identifier.bootsrapEffects.analysis(TAG, balanced, ...
        sstype, quartile, mid, EXPERIMENT.pattern.identifier.split(splitID, smpl), trackID, char(M));

      sersave2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, bootsrapEffectsID), ...
                      'WorkspaceVarNames', {'bootstrapTable'}, ...
                      'FileVarNames', {bootsrapEffectsID});



      %{
      fprintf('\n\n');
      fprintf('      * correcting for multiple comparision\n');
      if strcmp(direction, 'bi')
         [cutoff, ssdcouples, pvalMatrix, k] = BHcorrection_bidirectional(sortedSystems, bootstrapTable, EXPERIMENT.analysis.alpha.threshold, 1);
      else
         [cutoff, ssdcouples, pvalMatrix, k] = BHcorrection(sortedSystems, bootstrapTable, EXPERIMENT.analysis.alpha.threshold, 1);
      end
      fprintf('      * statistically significantly different couples of systems: %d\n',ssdcouples);

      ci = [];
      for i =1:length(me.factorA.label)
          sortedboot = sort(bootstrapTable{:,me.factorA.label{i}});
          %cisize = sortedboot(end-cutoff) - sortedboot(cutoff+1);
          %cisize = cisize/2;
          %infci = me.factorA.mean(i) - cisize;
          %supci = me.factorA.mean(i) + cisize;
          %ci = [ci; [infci, supci]];
          %infci = cast(M*cutoff+1, 'int32');
          %supci = cast(M-M*cutoff, 'int32');
          infci = cast(cutoff, 'int32');
          supci = cast(M - cutoff, 'int32');

          ci = [ci; [sortedboot(infci) sortedboot(supci) me.factorA.mean(i)]];
      end
      %}
    end
  end
end
